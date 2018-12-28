#include <stdio.h>
#include <stdlib.h>

void brainfuck(char *argv[], unsigned char *c)
{
#ifdef DEBUG
    printf("====================\nDEBUG: New brainfuck.\n");
#endif

    while (*argv[1])
    {
#ifdef DEBUG
        printf("DEBUG:  %c\n", *argv[1]);
#endif

        switch (*argv[1])
        {
            /* Increasing and decreasing values of position. */
        case '+':
            (*c)++;
            break;

        case '-':
            (*c)--;
            break;

            /* Moving pointer. */
        case '<':
            c--;
            break;

        case '>':
            c++;
            break;

            /* Reading and writing character */
        case ',':
#ifdef DEBUG
            printf("DEBUG: Reading char: ");
#endif
            *c = getchar();
            break;

        case '.':
#ifdef DEBUG
            printf("DEBUG: Printing char: ");
#endif
            putchar(*c);
#ifdef DEBUG
            putchar('\n');
#endif
            break;
            /* The loop */
        case '[':
#ifdef DEBUG
            printf("DEBUG:  LOOP start!\n");
#endif

            /* while *c is not zero */

            break;
        case ']':
#ifdef DEBUG
            printf("DEBUG:  LOOP end?\n");
#endif

            /* return pointer to next */

            return;

            break;

        default:
#ifdef DEBUG
            printf("DEBUG: Skip\n");
#endif
            break;
        }

        argv[1]++;
    }
}

int main(int argc, char *argv[])
{
    unsigned char *c = malloc(2000 * sizeof(unsigned char));

    if (argc == 2 && brainfuck(argv, c))
        return 0;
    return 1;
}
