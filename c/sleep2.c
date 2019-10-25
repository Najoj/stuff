#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

#define SECOND  1
#define MINUTE  60*SECOND
#define HOUR    60*MINUTE
#define DAY     24*HOUR

 /*
  * EVR -> every second,
  * FWD -> forward (days first)
  * BCK -> backward (seconds first)
  * Px  -> What to print up to. D:H:M:S
  */
enum { EVR, FWD, BCK,
	PD, PH, PM, PS
} states;

struct Option {
	int print_order;
	int print_format;

} option;

struct {
	int secs;
	int days;
	int hours;
	int minutes;
	int seconds;
} time;

//char * FORMAT = "%02i:%02i:%02i:%02i ";

int parse_to_secs(char *tp)
{
	if ('\0' == tp[0])
		return 0;

	/*Temporary second counter that will contain return value. */
	int temp_secs = 0;

	/*Character pointer to a position. Start by the end. */
	char *smhd;

	for (smhd = tp; *smhd != '\0'; smhd++) ;
	/*Reverse one step from the null pointer. */
	smhd--;

	/*Check suffix, if any. */
	switch (*smhd) {
	case 's':
		*smhd = '\0';
		temp_secs += atoi(tp) * SECOND;
		break;
	case 'm':
		*smhd = '\0';
		temp_secs += atoi(tp) * MINUTE;
		break;
	case 'h':
		*smhd = '\0';
		temp_secs += atoi(tp) * HOUR;
		break;
	case 'd':
		*smhd = '\0';
		temp_secs += atoi(tp) * DAY;
		break;
	default:
		if ('/' < *smhd && *smhd < ':') {
			temp_secs += atoi(tp);
		} else {
			fprintf(stderr, "Cannot parse \"%s\".\n", tp);
		}
	}
	return temp_secs;
}

void convert()
{
	int secs = time.secs;

	/*Convert secs to days, hours, minutes and seconds. */
	time.days = time.hours = time.minutes = time.seconds = 0;

	while (secs > DAY - 1) {
		time.days = (int)(secs / (DAY));
		secs -= time.days * DAY;
	}
	while (secs > HOUR - 1) {
		time.hours = (int)(secs / (HOUR));
		secs -= time.hours * HOUR;
	}
	while (secs > MINUTE - 1) {
		time.minutes = (int)(secs / (MINUTE));
		secs -= time.minutes * MINUTE;
	}
	if (secs > SECOND - 1) {
		time.seconds = secs;
	}
}

void print_time()
{
	if (option.print_format == PD )
    {
		printf("\r%id %02ih %02im %02is   \r", time.days, time.hours, time.minutes, time.seconds);
    }
	else if (option.print_format == PH)
    {
		printf("\r%02i:%02i:%02i   \r", time.hours, time.minutes, time.seconds);
    }
	else if (option.print_format == PM)
    {
		printf("\r%02i:%02i   \r", time.minutes, time.seconds);
    }
	else /* if (option.print_format == PS) */
    {
		printf("\r%02is   \r", time.seconds);
    }
}

int mode()
{
    switch(option.print_order)
    {
        case FWD:

            if (time.days > 0)
                return DAY;
            if (time.hours > 0)
                return HOUR;
            if (time.minutes > 0)
                return MINUTE;
            return SECOND;

            break;
        case BCK:

            if (time.seconds > 0)
                return SECOND;
            if (time.minutes > 0)
                return MINUTE;
            if (time.hours > 0)
                return HOUR;
            return DAY;

            break;
        case EVR:
        default:
            return SECOND;
            break;
    }
}

void countdown()
{
	int secs = time.secs;

	if (time.days > 0) {
		option.print_format = PD;
	} else if (time.hours > 0) {
		option.print_format = PH;
	} else if (time.minutes > 0) {
		option.print_format = PM;
	} else {
		option.print_format = PS;
	}

	//while (seconds > 0 || minutes > 0 || hours > 0 || days > 0)
	while ((time.seconds | time.minutes | time.hours | time.days) != 0) {
		print_time();
		fflush(stdout);

		int WAIT_TIME = mode();
		sleep(WAIT_TIME);
		secs -= WAIT_TIME;
		convert();
	}
	putchar('\r');

    /**
     * Fill out with 80 spaces before quitting.
     */
	for (secs = 80; secs > -1; --secs)
		putchar(' ');
	putchar('\r');
}

int main(argc, argv)
int argc;
char **argv;
{
	int i;

	/*
	 * Check the number of arguments.
	 */
	if (1 == argc) {
		fprintf(stderr,
			"\33[1m%s\e[0m \e[4mANTAL\e[0m[\e[4mÄNDELSE\e[0m] ...\n",
			argv[0]);
		return 1;
	}

	/*
	 * Default option(s)
	 */
	option.print_order = EVR;

	/*
	 * Look for arguments.
	 */
	int err = 0;
	for (i = 1; i < argc; i++) {
		if ('-' == argv[i][0] && '\0' == argv[i][2]) {

			switch (argv[i][1]) {
			case 'b':
				option.print_order = BCK;
				break;
			case 'e':
				option.print_order = EVR;
				break;
			case 'f':
				option.print_order = FWD;
				break;
			default:
				err = 1;
				fprintf(stderr, "Invalid argument: \"%s\"\n",
					argv[i]);
				break;
			}
            argv[i][0] = '\0';
		}
	}
	printf("order: %d\n", option.print_order);
	if (1 == err) {
		return -1;
	}

	/*
	 * Take every argument and parse it to seconds.
	 */
	for (i = 1; i < argc; i++) {
		time.secs += parse_to_secs(argv[i]);
	}

	/*
	 * If you have less than zeros seconds, an error message returns.
	 */
	if (time.secs < 0) {
		fprintf(stderr,
			"Negative time (%d seconds). Will not continue.\n",
			time.secs);
		return 1;
	} else if (0 == time.secs) {
		return 0;
	}

	convert();
	countdown();
	return 0;
}
