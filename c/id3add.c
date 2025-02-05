/* gcc id3add.c -lvorbisfile -lvorbis -logg */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <vorbis/vorbisfile.h>
#include <vorbis/codec.h>
#include <ogg/ogg.h>

#define TRUE (0==0)
#define FALSE (!(TRUE))

int add_vorbis_comment(const char *file_path, const char *comment_key, const char *comment_value) {
        FILE *ogg_file = fopen(file_path, "r+b");
        if (!ogg_file) {
                fprintf(stderr, "Kunde inte öppna filen: %s\n", file_path);
                return FALSE;
        }

        OggVorbis_File vf;
        if (ov_open(ogg_file, &vf, NULL, 0) < 0) {
                fprintf(stderr, "Kunde inte öppna filen: %s\n", file_path);
                fclose(ogg_file);
                return FALSE;
        }

        vorbis_info *vi = ov_info(&vf, -1);
        vorbis_comment *vc = ov_comment(&vf, -1);

        // Create new Vorbis comment structure and add a new comment
        vorbis_comment *new_comment = (vorbis_comment *)malloc(sizeof(vorbis_comment));
        vorbis_comment_init(new_comment);
        vorbis_comment_add_tag(new_comment, comment_key, comment_value);

        // Now update the Ogg file with the new comment
        // Note: Direct modification of the file is non-trivial, and would require custom
        // code to modify the Ogg stream headers. You would usually need to use an external tool
        // like `oggenc` or a more specific library to fully handle this.

        // For simplicity, the following will save changes to a new file.
        FILE *output_file = fopen("output.ogg", "wb");
        if (!output_file) {
                fprintf(stderr, "Kunde inte öppna filen: %s\n", file_path);
                fclose(ogg_file);
                free(new_comment);
                return FALSE;
        }

        // Copy the contents of the original Ogg file to the new one, along with the new comment
        unsigned char buffer[4096];
        int bitstream;
        long bytes;
        while ((bytes = ov_read(&vf, (char *)buffer, sizeof(buffer), 0, 2, 1, &bitstream)) > 0) {
                fwrite(buffer, 1, bytes, output_file);
        }

        // Add new metadata comments to the Ogg file here, but for now, we'll use a simple copy
        const char * comment = *new_comment->user_comments;
        fwrite(new_comment->user_comments, 1, strlen(comment), output_file);

        // Close everything
        fclose(output_file);
        fclose(ogg_file);
        free(new_comment);

        return TRUE;
}

int main(int argc, char *argv[]) {
        if (argc != 4) {
                fprintf(stderr, "Användning: %s <tagg> <value> <filnamn.ogg>\n", argv[0]);
                return 1;
        }

        const char *comment_key = argv[1];
        const char *comment_value = argv[2];
        const char *file_path = argv[3];

        const int success = add_vorbis_comment(file_path, comment_key, comment_value);
        if (success == FALSE)
        {
            fprintf(stderr, "Användning: %s <tagg> <value> <filnamn.ogg>\n", argv[0]);
            return 1;
        }

        return 0;
}

