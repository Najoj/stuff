import mutagen
from mutagen.oggvorbis import OggVorbis
import sys
import os


def add_vorbis_comment(_file_path, _comment_key, _comment_value) -> bool:
    try:
        # Open the Ogg file using Mutagen's OggVorbis class
        audio = OggVorbis(_file_path)
    except mutagen.oggvorbis.OggVorbisHeaderError:
        print('Not an ogg vorbis file', file=sys.stderr)
        return False
    # Add the Vorbis comment (key-value pair)
    audio[_comment_key] = _comment_value
    # Save the changes to the Ogg file
    audio.save()
    return True


def get_vorbis_comment(_file_path, _comment_key) -> str:
    try:
        # Open the Ogg file using Mutagen's OggVorbis class
        audio = OggVorbis(_file_path)
    except mutagen.oggvorbis.OggVorbisHeaderError:
        print('Not an ogg vorbis file', file=sys.stderr)
        return ''
    if _comment_key not in audio:
        print(f'Tag {_comment_key} not in file', file=sys.stderr)
        return ''
    return audio[_comment_key]


if __name__ == "__main__":
    if len(sys.argv) == 4:
        comment_key = sys.argv[1]
        comment_value = sys.argv[2]
        file_path = sys.argv[3]

        if not comment_key:
            print('No tag specified', file=sys.stderr)
            sys.exit(1)
        elif not os.path.isfile(file_path):
            print('File does not exist:', file_path, file=sys.stderr)
            sys.exit(1)

        successful = add_vorbis_comment(file_path, comment_key, comment_value)
        sys.exit(0 if successful else 1)

    elif len(sys.argv) == 2:
        file_path = sys.argv[1]
        if not os.path.isfile(file_path):
            print('File does not exist:', file_path, file=sys.stderr)
            sys.exit(1)

        artist_value = get_vorbis_comment(file_path, 'Artist')
        
    else:
        print('Usage: [<tag> <value>] <file>', file=sys.stderr)
        sys.exit(1)

    sys.exit(0)