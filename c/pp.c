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
 *      1 < 10
 *      11 < 20
 *      21 < 30
 *      45 > 40
 *      50 = 50
 */
#include <stdio.h>
#include <stdlib.h>

#define uint unsigned int

int main(argc, argv)
        int argc;
        char ** argv;
{
        uint start, stop, end = 0;

        uint const size = 500;
        uint count = 0;

        uint *list = (uint*)malloc(size*sizeof(uint));

        uint moved = -1;

        while(2 == scanf("%u -> %u\n", &start, &stop))
        {
                if(0 == end && moved == 0)
                {
                        moved++;
                        end = stop;
                        /*fprintf(stderr, "end: %u\n", end);*/
                }
                if(start == end && moved > 0)
                {
                        count--;
                        int diff = list[count] - stop;
                        printf("%'u - %'u = %'d\n", list[count], stop, diff);
                        fflush(stdout);
                }
                else
                {
                        moved++;
                        list[count] = start;
                        count++;
                }
        }

        moved = moved == (-1) ? 0 : moved;
        printf("Moved %d song%s\n", moved, moved == 1 ? "." : "s.");
        
        return 0;
}

