/***
 * Based on mpdsonglisten.c: https://gist.github.com/sahib/6718139
 * Compile: cc spela_klart.c -o spela_klart -lmpdclient
 * Run: ./spela_klart
 * 
 * Exist successfully when song changes.
 *
 * Error handling is done by ignoring none-fatal erros and trying to reconnect if
 * fatal errors happen.
 * 
 * TODO: Comment the hell out of the code.
 * TODO: Get host and port from arguments.
 * 
 **/
#include <mpd/client.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>

const int const main (argc, argv)
	const int argc;
	const char *const *const argv;
{
    if (argc > 1)
    {
        printf ("Usage: %s\n", argv[0]);
        return EXIT_FAILURE;
    }

    int first_song_id = -1;
    int second_song_id = -1;
	
    struct mpd_connection *client =
        mpd_connection_new ("localhost", 6600, 2000);
    struct mpd_status *status = mpd_run_status (client);

    if (status != NULL)
    {
        first_song_id = mpd_status_get_song_id (status);
        second_song_id = first_song_id;
    }

    while (first_song_id == second_song_id)
    {
        if (mpd_run_idle (client))
        {
            struct mpd_status *status = mpd_run_status (client);
            if (status != NULL)
            {
                second_song_id = mpd_status_get_song_id (status);
            }
        }
        else
        {
            if (client != NULL)
            {
                mpd_connection_free (client);
            }
            return EXIT_FAILURE;
        }
    }

    if (client != NULL)
    {
        mpd_connection_free (client);
    }
    return EXIT_SUCCESS;
}
