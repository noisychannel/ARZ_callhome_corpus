#!/usr/bin/env python

# Converts PLFs (lattices) from ECA romanizes to the
# UTF8 arabic script

import sys
import codecs
import re

dict_cache = {}


def replace_sym(match):
    assert match
    sym = match.group(2)
    if sym in dict_cache:
        return "".join([match.group(1), dict_cache[sym], match.group(3)])
    else:
        return match.group()

if len(sys.argv) < 3:
    print "USAGE: local/convert_symtable_to_utf.py [PLF-FILE] [ECA-LEXICON]"
    print "E.g., local/convert_symtable_to_utf.py callhome_dev.ar \
                /export/corpora/LDC/LDC99L22"
    sys.exit(1)

# Note that the ECA lexicon's default encoding is ISO-8859-6, not UTF8
plf_file = codecs.open(sys.argv[1], encoding="utf8")
lexicon = codecs.open(sys.argv[2] +
                      "/callhome_arabic_lexicon_991012/ar_lex.v07",
                      encoding="iso-8859-6")

# First read off the dictionary and store stuff in a cache
for line in lexicon:
    line = line.strip().split()
    roman = line[0].strip()
    script = line[1].strip()
    assert roman not in dict_cache
    dict_cache[roman] = script

# Now read the symbol table and write off the ut8 versions
for line in plf_file:
    utfline = re.sub(r"(\(')(\S+)(',\s\S+,\s\d+\))",
                    replace_sym, line).encode("utf-8")
    sys.stdout.write(utfline)

lexicon.close()
plf_file.close()
