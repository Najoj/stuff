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

    //fprintf(stderr, "%c\t%c\n%d\t%d\t%d\n", start, slut, taljare, namnare, langd);
    if (taljare > namnare)
    {
        fprintf (stderr, "täljare %s  >  nämnare %s\n", argv[3],
                 argv[4]);
        return EXIT_FAILURE;
    }

    double kvot = (double) taljare / (double) namnare;

    int i;
    for (i = 0; i < (int) ((kvot * langd) + 0.5); i++)
    {
        putchar (start);
    }

    if (i == 0)
        printf ("00 %% %c", slut);
    else if (i != langd)
        printf (" %02d %% ", (int) (100 * kvot));
    else
        printf (" %02d %%", (int) (100 * kvot));

    for (i++; i <= langd; i++)
    {
        putchar (slut);
    }

    putchar ('\n');
    fflush (stdout);

    return EXIT_SUCCESS;
}
