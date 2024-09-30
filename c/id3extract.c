/* gcc id3extract.c -lvorbisfile -logg */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <vorbis/vorbisfile.h>

void extract_vorbis_tag(OggVorbis_File *vf, const char *tag) {
    vorbis_comment *comment = ov_comment(vf, -1);
    if (comment) {
        size_t tag_len = strlen(tag);
        for (int i = 0; i < comment->comments; i++) {
            if (strncmp(comment->user_comments[i], tag, tag_len) == 0 && comment->user_comments[i][tag_len] == '=') {
                printf("%s\n", comment->user_comments[i] + tag_len + 1);
                return;
            }
        }
        printf("Taggen '%s' hittades inte.\n", tag);
    } else {
        printf("Inga Vorbis-kommentarer hittades.\n");
    }
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Användning: %s <tagg> <filnamn.ogg>\n", argv[0]);
        return 1;
    }

    const char *tag = argv[1];
    const char *filename = argv[2];
    OggVorbis_File vf;
    FILE *file = fopen(filename, "rb");

    if (!file) {
        fprintf(stderr, "Kunde inte öppna filen: %s\n", filename);
        return 1;
    }

    if (ov_open(file, &vf, NULL, 0) < 0) {
        fprintf(stderr, "Det verkar inte vara en giltig Ogg Vorbis-fil: %s\n", filename);
        fclose(file);
        return 1;
    }

    extract_vorbis_tag(&vf, tag);

    /*ov_clear will do fclose */
    ov_clear(&vf);

    return 0;
}
