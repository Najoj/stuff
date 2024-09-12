/***
 * Based on mpdsonglisten.c: https://gist.github.com/sahib/6718139
 * Compile: cc spela_klart.c -o spela_klart -lmpdclient
 * Run: ./spela_klart
 *
 * Exits successfully when song changes.
 *
 * Error handling is done by ignoring none-fatal erros, and try to reconnect if
 * fatal errors happen.
 *
 * Can take no argument or one argument interpreted as an integer.
 *
 * TODO: Get host and port from arguments.
 *
 **/
#include <mpd/client.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define  print_usage  fprintf (stderr, "Usage: %s [ITERATIONS]\n", argv[0]);

int main (argc, argv)
        const int argc;
        const char *const *const argv;
{
        /* Wrong number of arguments */
        if (argc > 2)
        {
                print_usage;
                return EXIT_FAILURE;
        }

        /* Parse iterations */
        int iterations = 1; /* Defaults to 1 iteration */
        int it;
        if (argc == 2)
        {
                it = atoi(argv[1]);
                if (it < 0)
                {
                        print_usage;
                        return EXIT_FAILURE;
                }
                iterations = it;
        }

        for (it = 0; it < iterations; it++)
        {
                int first_song_id = -1;
                int second_song_id = -1;

                struct mpd_connection *client = mpd_connection_new ("localhost", 6600, 2000);
                struct mpd_status *status = mpd_run_status (client);

                if (status != NULL)
                {
                        first_song_id = mpd_status_get_song_id (status);
                        second_song_id = first_song_id;
                }

                while (first_song_id == second_song_id)
                {
                        int code;
                        if ((code = mpd_run_idle (client)))
                        {
                                status = mpd_run_status (client);
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
                                fprintf(stderr, "No reply from server. Return code: %d\n", code);
                                return EXIT_FAILURE;
                        }
                }
                if (client != NULL)
                {
                        mpd_connection_free (client);
                }
        }

        return EXIT_SUCCESS;
}
