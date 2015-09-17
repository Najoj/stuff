#include <stdio.h>

void indent(int nind, char *ind)
{
    int indc;

    for (indc = nind; indc; indc--)
        printf("%s", ind);
}

int main(int argc, char **argv)
{
    char *ind = "\t";
    int nind = 0;
    char *ptr = "ptr";
    int adj = 0;
    int size = 2000;
    int c = 0, a = 0;

    printf("#include <stdlib.h>%s/* %s */\n", ind, "Needed for malloc.");
    printf("#include <stdio.h>%s/* %s */\n\n", ind,
           "Needed for putchar and getchar.");
    printf("int main(argc, argv)\n");
    printf("%sint argc;\n", ind);
    printf("%schar ** argv;\n", ind);
    printf("{\n");

    nind++;

    indent(nind, ind);
    printf("char * %s = (char *)malloc( %d * sizeof(char));\n", ptr, size);

    for (a = 1; a < argc; a++)
    {
        while (argv[a][c] != '\0')
        {
            indent(nind, ind);

            switch (argv[a][c])
            {
            case '+':
                adj++;
                printf("(*%s)++;", ptr);
                break;
            case '-':
                adj--;
                printf("(*%s)--;", ptr);
                break;

            case '>':
                printf("%s++;", ptr);
                break;
            case '<':
                printf("%s--;", ptr);
                break;

            case ',':
                printf("*%s = getchar();", ptr);
                break;
            case '.':
                printf("putchar(*%s);", ptr);
                break;

            case '[':
                printf("while (*%s)\n", ptr);
                indent(nind, ind);
                printf("{");
                nind++;
                break;
            case ']':
                nind--;
                printf("\xd");
                indent(nind, ind);
                printf("}");
                break;
            case ' ':
                break;
            default:
                printf("/* %c */", argv[a][c]);
                break;
            }
            putchar('\n');
            c++;
        }
    }

    indent(nind, ind);
    printf("free(%s - 4);\n", ptr);
    indent(nind, ind);
    printf("return 0;\n");

    nind--;
    indent(nind, ind);
    printf("}\n");

    int ret = 0;

    if (!nind)
    {
        ret = 1;
    }

    return ret;
}
