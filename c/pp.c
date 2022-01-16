/**
 * Used with a script of mine. Reformats printout from
 *      10 -> 1
 *      11 -> 1
 *      12 -> 1
 *      13 -> 1
 *      14 -> 1
 *      1 -> 2
 *      1 -> 3
 *      1 -> 4
 *      1 -> 5
 *      1 -> 6
 * to
 *      10 -> 6
 *      11 -> 5
 *      12 -> 4
 *      13 -> 3
 *      14 -> 2
 */
#include <stdio.h>
#include <stdlib.h>

#define uint unsigned int

int main(argc, argv)
        int argc;
        char ** argv;
{
        uint start, stop, end = 0;

        uint const size = 300;
        uint count = 0;

        uint *list = (uint*)malloc(size*sizeof(uint));

        while(0 < scanf("%u -> %u\n", &start, &stop))
        {
                if(0 == end)
                {
                        end = stop;
                        /*fprintf(stderr, "end: %u\n", end);*/
                }

                /*fprintf(stderr, "count: %u\n", count);*/
                if(start == end)
                {
                        count--;
                        char c = '=';
                        if(list[count] < stop) c = '<';
                        else if(list[count] > stop) c = '>';
                        printf("%u %c %u\n", list[count], c, stop);
                        fflush(stdout);
                }
                else
                {
                        list[count] = start;
                        count++;
                }
        }

        return 0;
}

