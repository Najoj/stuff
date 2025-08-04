/**
 * WORK IN PROGRESS
 *
 * extraheta id3 taggar från ogg- och flac-filer
 * 
 * Kompilera:
 * gcc id3extract_ext.c -lvorbisfile -logg -lFLAC
 *
 * Använd:
 * ./id3extract <tag> <file>
 *
 **/
#include <stdio.h>
#include <string.h>
#include <ctype.h>              // Behövs för tolower()
#include <vorbis/vorbisfile.h>
#include <FLAC/metadata.h>

#define TRUE (0==0)
#define FALSE (!(TRUE))

// Hjälpfunktion för att konvertera en sträng till gemener
void to_lowercase (char *str)
{
    for (int i = 0; str[i]; i++)
    {
        str[i] = tolower (str[i]);
    }
}

/**
 * För .ogg (vorbis)
 *
 * Denna funktion söker igenom filens metadata efter en angiven tagg och skriver
 * ut dess värde. Taggen konverteras till gemener för att matcha kommentarerna.
 */
int extract_vorbis_tag (const char *filename, const char *tag)
{
    OggVorbis_File vf;
    FILE *file = fopen (filename, "rb");
    if (!file)
    {
        fprintf (stderr, "Kunde inte öppna filen: %s\n", filename);
        return 1;
    }

    if (ov_open (file, &vf, NULL, 0) < 0)
    {
        fprintf (stderr,
                 "Det verkar inte vara en giltig Ogg Vorbis-fil: %s\n",
                 filename);
        fclose (file);
        return 1;
    }
    vorbis_comment *comment = ov_comment (&vf, -1);
    ov_clear (&vf);
    if (comment)
    {
        // Skapa en kopia av taggen och konvertera till gemener
        char search_tag[256];
        strncpy (search_tag, tag, sizeof (search_tag) - 1);
        search_tag[sizeof (search_tag) - 1] = '\0';
        to_lowercase (search_tag);
        size_t tag_len = strlen (search_tag);
        for (int i = 0; i < comment->comments; i++)
        {
            // Skapa en kopia av kommentaren och konvertera till gemener för jämförelse
            char comment_copy[256];
            strncpy (comment_copy, comment->user_comments[i],
                     sizeof (comment_copy) - 1);
            comment_copy[sizeof (comment_copy) - 1] = '\0';
            to_lowercase (comment_copy);
            if (strncmp (comment_copy, search_tag, tag_len) == 0
                && comment_copy[tag_len] == '=')
            {
                printf ("%s\n", comment->user_comments[i] + tag_len + 1);
                return TRUE;
            }
        }
        fprintf (stderr,
                 "Taggen '%s' hittades inte i Ogg Vorbis-filen.\n", tag);
    }
    else
    {
        fprintf (stderr, "Inga Vorbis-kommentarer hittades i filen.\n");
    }
    return FALSE;
}

/**
 * För .flac
 *
 * Denna funktion använder libFLAC för att läsa FLAC-filens metadata och söker
 * efter den angivna taggen. Taggen konverteras till gemener för att matcha
 * kommentarerna.
 */
int extract_flac_tag (const char *filename, const char *tag)
{
    FLAC__Metadata_Chain *chain = FLAC__metadata_chain_new ();
    if (!chain)
    {
        fprintf (stderr, "Kunde inte allokera minne för metadata-kedjan.\n");
        return FALSE;
    }

    if (!FLAC__metadata_chain_read (chain, filename))
    {
        fprintf (stderr,
                 "Kunde inte läsa metadata från FLAC-filen: %s\n", filename);
        FLAC__metadata_chain_delete (chain);
        return FALSE;
    }

    FLAC__StreamMetadata *metadata;
    FLAC__Metadata_Iterator *iterator = FLAC__metadata_iterator_new ();
    if (!iterator)
    {
        fprintf (stderr,
                 "Kunde inte allokera minne för metadata-iteratorn.\n");
        FLAC__metadata_chain_delete (chain);
        return FALSE;
    }

    FLAC__metadata_iterator_init (iterator, chain);
    int found = FALSE;
    // Skapa en kopia av taggen och konvertera till gemener
    char search_tag[256];
    strncpy (search_tag, tag, sizeof (search_tag) - 1);
    search_tag[sizeof (search_tag) - 1] = '\0';
    to_lowercase (search_tag);
    size_t tag_len = strlen (search_tag);
    do
    {
        metadata = FLAC__metadata_iterator_get_block (iterator);
        if (metadata && metadata->type == FLAC__METADATA_TYPE_VORBIS_COMMENT)
        {
            FLAC__StreamMetadata_VorbisComment *vc =
                &metadata->data.vorbis_comment;
            for (unsigned i = 0; i < vc->num_comments; ++i)
            {
                // Skapa en kopia av kommentaren och konvertera till gemener för jämförelse
                char comment_copy[256];
                strncpy (comment_copy, (char *) vc->comments[i].entry,
                         sizeof (comment_copy) - 1);
                comment_copy[sizeof (comment_copy) - 1] = '\0';
                to_lowercase (comment_copy);
                if (strncmp (comment_copy, search_tag, tag_len) == 0
                    && comment_copy[tag_len] == '=')
                {
                    printf ("%s\n", vc->comments[i].entry + tag_len + 1);
                    found = TRUE;
                    break;
                }
            }
        }
    }
    while (!found && FLAC__metadata_iterator_next (iterator));
    FLAC__metadata_iterator_delete (iterator);
    FLAC__metadata_chain_delete (chain);
    if (!found)
    {
        fprintf (stderr, "Taggen '%s' hittades inte i FLAC-filen.\n", tag);
        return FALSE;
    }

    return TRUE;
}

/**
 * Den kontrollerar antalet argument, bestämmer filtypen baserat på filändelsen
 * (.ogg eller .flac) och anropar sedan lämplig funktion för att extrahera metadata.
 */
int main (int argc, char *argv[])
{
    if (argc != 3)
    {
        fprintf (stderr, "Användning: %s <tagg> <filnamn>\n", argv[0]);
        fprintf (stderr, "Stödjer filtyper: .ogg och .flac\n");
        return 1;
    }

    const char *tag = argv[1];
    const char *filename = argv[2];
    size_t filename_len = strlen (filename);
    int return_code = 1;
    // Kontrollera filändelsen
    if (filename_len >= 4 && strcmp (filename + filename_len - 4, ".ogg") == 0)
    {

        if (extract_vorbis_tag (filename, tag))
        {
            return_code = 0;
        }
    }
    else if (filename_len >= 5
             && strcmp (filename + filename_len - 5, ".flac") == 0)
    {
        if (extract_flac_tag (filename, tag))
        {
            return_code = 0;
        }
    }
    else
    {
        fprintf (stderr, "Okänd filtyp. Stödjer endast .ogg och .flac.\n");
        return 1;
    }

    return return_code;
}
