#!/usr/bin/env bash

cat $1 \
  | sed 's:\[laughter\]::g' \
  | sed 's:\[noise\]::g' \
  | sed 's:\[hes\]::g' \
  | sed 's:\[oov\]::g' \
  | sed 's:<unk>::g' \
  | sed 's:  : :g' \
  | sed 's: *$::g'\
  | sed 's:^ *::g'
