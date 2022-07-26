# convert decomposed utf-8 chars to precompiled chars
import sys
import unicodedata


def bytes_from_file(filename, chunksize=8192):
    with open(filename, "rb") as f:
        content = f.readlines()
        while True:
            chunk = f.read(chunksize)
            if chunk:
                for b in chunk:
                    yield b
            else:
                break

def lines_from_file(filename):
    with open(filename, "r") as f:
        for line in f:
            yield line


with open(sys.argv[2], "w") as f:
    for line in lines_from_file(sys.argv[1]):
        f.write(unicodedata.normalize("NFC", line))
