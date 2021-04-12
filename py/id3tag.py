from mutagen.easyid3 import EasyID3
import mutagen
import sys

if len(sys.argv) < 2:
    sys.exit(0)

for arg in sys.argv[1:]:
    file = mutagen.File(arg)

    for tag in file:
        if tag != 'artist' and tag != 'title':
            file.pop(tag)
    file.save()

