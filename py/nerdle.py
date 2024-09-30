# coding=utf-8

import itertools
from random import shuffle
import spotipy
import time
import spotipy.util as util
from string import strip
from multiprocessing.dummy import Pool

# Tiempos de threads con MAX_PLAYLISTS = 100: 1->45s, 2->23s, 3->16s, 4->12s, 5->10s, 6->10s, 7->11+s Spotify me hace esperar
import sys

THREADS = 3  # 5 threads make too many requests y Spotify make us wait, I'm also afraid the account might get blocked
MAX_PLAYLISTS = 10
SONG_AMOUNT = 100
MAX_SONGS_PER_REQUEST = 100  # as per Spotiy
POP_IMP = 0.4
PLAYLIST_NAMES = "Autom"

CLIENT_ID = 'asdfasdfasdf12341234'
CLIENT_SECRET = 'asdfgasdfg12341234'
REDIRECT_URI = 'http://your.redirect.url'

scope = 'user-library-modify, playlist-read-private, playlist-modify-public, playlist-modify-private, playlist-read-collaborative'


def is_good_playlist(items):
    artists = set()
    albums = set()
    for item in items:
        track = item['track']
        if track:
            artists.add(track['artists'][0]['id'])
            albums.add(track['album']['id'])
    return len(artists) > 1 and len(albums) > 1


def process_playlist(playlist):
    global data
    tracks = data['tracks']

    pid = playlist['id']
    uid = playlist['owner']['id']
    data['playlists'] += 1

    # print data['playlists'], data['ntracks'], len(tracks), playlist['name']

    try:
        results = sp.user_playlist_tracks(uid, pid)

        if results and 'items' in results and is_good_playlist(results['items']):
            for item in results['items']:
                track = item['track']
                if track:
                    tid = track['id']
                    if tid not in tracks:
                        popularity = track['popularity']
                        # release_date = track['album']['release_date']
                        tracks[tid] = {
                            'count': 0,
                            'popularity': popularity,
                            # 'release_date': release_date,
                        }
                    tracks[tid]['count'] += 1
                    data['ntracks'] += 1
        # else:
        # print 'mono playlist skipped'
    except spotipy.SpotifyException:
        pass
        # print 'trouble, skipping'


def crawl_playlists():
    global data, queries, MAX_PLAYLISTS
    limit = 50
    playlists_per_query = MAX_PLAYLISTS / len(queries)
    for query in queries:
        # print 'Query:', query
        which = 0
        offset = 0 if data['offset'] < 0 else data['offset'] + limit
        results = sp.search(query, limit=limit, offset=offset, type='playlist')
        playlist = results['playlists']
        # total = playlist['total']
        while playlist and which < playlists_per_query:
            data['offset'] = playlist['offset'] + playlist['limit']

            for item in itertools.islice(playlist['items'], playlists_per_query):
                if which >= playlists_per_query:
                    break
                pool.apply_async(process_playlist, args=(item,))
                which += 1

            if playlist['next']:
                try:
                    results = sp.next(playlist)
                except spotipy.client.SpotifyException, e:
                    print "Got an exception:", e
                    refresh_token()
                playlist = results['playlists']
            else:
                playlist = None


def refresh_token():
    global token, sp
    token = get_token()
    sp = spotipy.Spotify(auth=token)


def get_queries_from_description(desc):
    return map(strip, desc.split(':')[1].split(','))


def get_description(user, pid):
    results = sp.user_playlist(user, playlist_id=pid, fields=None)
    return results['description']


def sort_tracks():
    global data
    trs = data['tracks']
    trs = sorted(trs, key=lambda k: ( trs[k]['count'] + trs[k]['count']*POP_IMP*trs[k]['popularity']/100), reverse=True)
    trs = trs[0:SONG_AMOUNT]
    return [x for x in trs if x is not None]


def load():
    return {
        'playlists': 0,
        'ntracks': 0,
        'offset': -1,
        'tracks': {},
    }


def chunks(l, n):
    n = max(1, n)
    return [l[i:i+n] for i in xrange(0, len(l), n)]


def save_and_clear(tracks_list, pid):
    try:
        count = 0
        max_chunk_lists = chunks(tracks_list, MAX_SONGS_PER_REQUEST)
        sp.user_playlist_replace_tracks(username, pid, max_chunk_lists[0])
        count += len(max_chunk_lists[0])
        for tracks_chunk in max_chunk_lists[1:]:
            sp.user_playlist_add_tracks(username, pid, tracks_chunk)
            count += len(tracks_chunk)
    except spotipy.client.SpotifyException, e:
        print "Got an exception:", e
        refresh_token()
        count = save_and_clear(tracks_list, pid)
    return count


def get_popularity(desc):
    return float(desc.split(':')[2])


def get_token():
    return util.prompt_for_user_token(username, scope, client_id=CLIENT_ID, client_secret=CLIENT_SECRET, redirect_uri=REDIRECT_URI)


def getAutomaticPlaylists(playlists2):
    resp = []
    for p in playlists2['items']:
        if PLAYLIST_NAME in p['name']:
            resp.append(p)
    return resp


def get_max_playlists(desc):
    return int(desc.split(':')[3])


def generatePlaylist(playlist2):
    global POP_IMP, data, pool, queries, MAX_PLAYLISTS

    pool = Pool(THREADS)
    start_time = time.time()

    refresh_token()
    pid2 = playlist2['uri']
    description = get_description(username, pid2)
    POP_IMP = get_popularity(description)
    MAX_PLAYLISTS = get_max_playlists(description)
    queries = get_queries_from_description(description)

    print "Running on playlist:", playlist2['name'], ", for user:", username
    print "Queries:", queries, ", Max:", MAX_PLAYLISTS, ", Popularity:", POP_IMP

    data = load()
    crawl_playlists()
    pool.close()
    pool.join()
    n_songs_saved = save_and_clear(sort_tracks(), pid2)

    elapsed_time = time.time() - start_time
    elapsed_time = time.strftime("%H:%M:%S", time.gmtime(elapsed_time))

    print "Successful run on playlist:", playlist2['name'], ", for user:", username
    print n_songs_saved, ", songs where saved", data['playlists'], " playlists read with max set to:"
    print "Total time elapsed:", elapsed_time
    print


if __name__ == '__main__':

    if len(sys.argv) > 1:
        username = sys.argv[1]
    else:
        username = "xxxxUSERNAMExxxx"

    pool = Pool(THREADS)

    # pedimos los tokens
    token = get_token()

    if token:
        sp = spotipy.Spotify(auth=token)

        data = []
        queries = []
        if len(sys.argv) > 2:
            singleURI = sys.argv[2]
            playlist = sp.user_playlist(username, singleURI)
            generatePlaylist(playlist)
        else:
            # Levantamos todas y filtramos las que tienen "Autom" en el nombre
            playlists = sp.current_user_playlists(limit=50, offset=0)  # chequear si esto ya me da la descripcion
            playlists = getAutomaticPlaylists(playlists)
            shuffle(playlists)

            for playlist in playlists:
                generatePlaylist(playlist)

                # dormimos para no apurar tanto a spotify
                time.sleep(120)
    else:
        print "Can't get token for", username
