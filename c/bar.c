/*
 * Run as
 *  ./a.out A B C D E
 * where A is inital char and B is trailing char. C is the numerator, D is the
 * denominator, E is a length of the bar.
 */

#include <stdlib.h>
#include <stdio.h>

int main (argc, argv)
    int argc;
    char **argv;
{
    if (6 != argc)
    {
        fprintf (stderr, "Fel antal argument.\n");
        fprintf (stderr,
                 "%s fyllnadstecken tomtecken nämnare täljare längd\n",
                 argv[0]);
        return EXIT_FAILURE;
    }

    char start = argv[1][0];
    char slut = argv[2][0];
    int taljare = atoi (argv[3]);
    int namnare = atoi (argv[4]);
    int langd = atoi (argv[5]);

    if (taljare > namnare)
    {
        fprintf (stderr, "täljare %s  >  nämnare %s\n", argv[3], argv[4]);
        return EXIT_FAILURE;
    }

    double kvot = (double) taljare / (double) namnare;
    int i = (int) (100 * kvot);

    if (i == 100)
        printf ("%02d %% ", i);
    else
        printf (" %02d %% ", i);

    for (i = 0; i < (int) ((kvot * langd) + 0.5); i++)
    {
        putchar (start);
    }
    for (i = i; i < langd; i++)
    {
        putchar (slut);
    }

    putchar ('\n');
    fflush (stdout);

    return EXIT_SUCCESS;
}
