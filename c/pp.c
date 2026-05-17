/**
 * Used with a script of mine. Reformats printout from
 *      50 -> 50
 *      45 -> 50
 *      21 -> 50
 *      11 -> 50
 *      1 -> 50
 *      50 -> 10
 *      50 -> 20
 *      50 -> 30
 *      50 -> 40
 *      50 -> 50
 * to
 *      1 - 10 = -9
 *      11 - 20 = -9
 *      21 - 30 = -9
 *      34 - 40 = -6
 *      50 - 50 = 0
 *      Moved 5 songs.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(argc, argv)
        int argc;
        char ** argv;
{
        int debug = 0;
        for(int i = 0; i < argc; i++)
        {
                if(!strcmp("--debug", argv[i]))
                {
                        fprintf(stderr, "arg: %s\n", argv[i]);
                    debug++;
                }
        }
        int start, stop, end = 0;

        int const size = 500;
        int count = 0;

        int *list = (int*)malloc(size*sizeof(int));

        int moved = -1;

        while(2 == scanf("%u -> %u\n", &start, &stop))
        {
                if(debug != 0)
                {
                        fprintf(stderr, "start: %u\n", start);
                        fprintf(stderr, "stop: %u\n", stop);
                }
                if(0 == end && -1 == moved)
                {
                        moved++;
                        end = stop;
                        if(debug != 0)
                        {
                                fprintf(stderr, "end: %u\n", end);
                        }
                }
                if(start == end && moved > 0)
                {
                        count--;
                        int diff = list[count] - stop;
                        printf("%'d - %'d = %'d\n", list[count], stop, diff);
                        fflush(stdout);
                }
                else
                {
                        moved++;
                        list[count] = start;
                        count++;
                        if(debug != 0)
                        {
                                fprintf(stderr, "moved: %u\n", moved);
                                fprintf(stderr, "count: %u\n", count);
                        }
                }
        }

        moved = moved == (-1) ? 0 : moved;
        printf("Moved %d song%s\n", moved, moved == 1 ? "." : "s.");
        
        return 0;
}
