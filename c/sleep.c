#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

#define SECOND  1
#define MINUTE  60*SECOND
#define HOUR    60*MINUTE
#define DAY     24*HOUR

int secs = 0, days = 0, hours = 0, minutes = 0, seconds = 0;

//char * FORMAT = "%02i:%02i:%02i:%02i ";

int parse_to_secs(char *tp)
{
    if ('\0' == tp[0])
        return 0;

    /*
     * Temporary second counter that will contain return value.
     */
    int secs = 0;

    /*
     * Character pointer to a position. Start by the end.
     */
    char *smhd;

    for (smhd = tp; *smhd != '\0'; smhd++);
    /*
     * Reverse one step from the null pointer.
     */
    smhd--;

    /*
     * Check suffix, if any.
     */
    switch (*smhd)
    {
        case 's':
            *smhd = '\0';
            secs += atoi(tp) * SECOND;
            break;
        case 'm':
            *smhd = '\0';
            secs += atoi(tp) * MINUTE;
            break;
        case 'h':
            *smhd = '\0';
            secs += atoi(tp) * HOUR;
            break;
        case 'd':
            *smhd = '\0';
            secs += atoi(tp) * DAY;
            break;
        default:
            if ('/' < *smhd && *smhd < ':')
            {
                secs += atoi(tp);
            }
            else
            {
                fprintf(stderr, "Cannot parse \"%s\".\n", tp);
            }
    }
    return secs;
}

void convert()
{
    /*
     * Convert seconds to days, hours, minutes and seconds.
     */
    days = hours = minutes = seconds = 0;
    while (secs > DAY - 1)
    {
        days = (int) (secs / (DAY));
        secs -= days * DAY;
    }
    while (secs > HOUR - 1)
    {
        hours = (int) (secs / (HOUR));
        secs -= hours * HOUR;
    }
    while (secs > MINUTE - 1)
    {
        minutes = (int) (secs / (MINUTE));
        secs -= minutes * MINUTE;
    }
    if (secs > SECOND - 1)
    {
        seconds = secs;
    }
}

void countdown()
{

    short option = 0b0001;

    if (days > 0)
    {
        option = 0b1000;
    }
    else if (hours > 0)
    {
        option = 0b0100;
    }
    else if (minutes > 0)
    {
        option = 0b0010;
    }
    short first = 0;
    while ((seconds | minutes | hours | days) != 0)
    {

        if (option == 0b1000)
        {
            printf("\r%id %02ih %02im %02is ", days, hours, minutes,
                    seconds);
        }
        else if (option == 0b0100)
        {
            for(int i = 0; first > 0 && i < 9; i++) putchar('\b');
            printf("%02i:%02i:%02i ", hours, minutes, seconds);
        }
        else if (option == 0b0010)
        {
            for(int i = 0; first > 0 && i < 6; i++) putchar('\b');
            printf("%02i:%02i ", minutes, seconds);
        }
        else if (option == 0b0001)
        {
            for(int i = 0; first > 0 && i < 4; i++) putchar('\b');
            printf("%02is ", seconds);
        }
        first = 1;

        fflush(stdout);
        sleep(SECOND);

        if (0 == seconds)
        {
            seconds = 59;
            if (0 == minutes)
            {
                minutes = 59;
                if (0 == hours)
                {
                    hours = 23;
                    if (0 < days)
                    {
                        days--;
                    }
                }
                else
                {
                    hours--;
                }
            }
            else
            {
                minutes--;
            }
        }
        else
        {
            seconds--;
        }
    }
    putchar('\r');
    for(seconds = 80; seconds > -1; --seconds )
        putchar(' ');
    putchar('\r');
}

int main(int argc, char **argv)
{
    int i;

    /*
     * Check the number of arguments.
     */
    if (1 == argc)
    {
        fprintf(stderr,
                "\33[1m%s\e[0m \e[4mANTAL\e[0m[\e[4mÄNDELSE\e[0m] ...\n",
                argv[0]);
        return 1;
    }

    /*
     * Look for arguments.
     */
    /*int err = 0;*/
    /*for (i = 1; i < argc; i++)*/
    /*{*/
        /*if ('-' == argv[i][0] && '\0' == argv[i][2])*/

            /*switch (argv[i][1])*/
            /*{*/
                /*case 'e':*/
                    /*break;*/
                /*default:*/
                    /*err = 1;*/
            /*}*/
    /*}*/
    /*if (1 == err)*/
    /*{*/
        /*fprintf(stderr, "Invalid argument: \"%s\"\n", argv[i]);*/
        /*return -1;*/
    /*}*/

    /*
     * Take every argument and parse it to seconds.
     */
    for (i = 1; i < argc; i++)
    {
        secs += parse_to_secs(argv[i]);
    }

    /*
     * If you have less than zeros seconds, an error message returns.
     */
    if (secs < 0)
    {
        fprintf(stderr,
                "Negative time (%d seconds). Will not continue.\n", secs);
        return 1;
    }
    else if (0 == secs)
    {
        return 1;
    }

    convert();
    countdown();
    return 0;
}
