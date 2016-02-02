#!/usr/bin/env python

import sys
import codecs

assert len(sys.argv) == 3

plf_output = codecs.open(sys.argv[1], encoding="utf8")
transcript = codecs.open(sys.argv[2], encoding="utf8")

# First read ASR output and store
output_cache = {}
for line in plf_output:
    line = line.strip().split()
    timestamp = line.pop(0)
    output = " ".join(line)
    output_cache[timestamp] = output

# Read the transcript and process one by one
for line in transcript:
    line = line.strip().split()
    timestamp = line.pop(0)
    # ar_4264.scr-28.83-37.20-A
    # ar_4264-A-002883-003720.plf
    t_split = timestamp.split("-")
    mod_timestamp = t_split[0][:-4] + "-" + t_split[3][0] + "-" + \
            '{0:06d}'.format(int(float(t_split[1]) * 100)) + "-" + \
            '{0:06d}'.format(int(float(t_split[2]) * 100)) + ".plf"
    if mod_timestamp not in output_cache:
        print timestamp + "\t" + "()"
    else:
        print timestamp + "\t" + output_cache[mod_timestamp]
        del output_cache[mod_timestamp]

assert len(output_cache) == 0

transcript.close()
plf_output.close()
