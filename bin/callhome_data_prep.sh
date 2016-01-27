#!/bin/bash
#
# Johns Hopkins University : (Gaurav Kumar)
# The input to this file is the LDC transcript directory list
# for the Callhome Egyptian Arabic dataset.

export LC_ALL=C
CLEAN_TRANS=0

if [ $# -lt 3 ]; then
   echo "Arguments should be the location of the Callhome Egyptian Arabic Transcript Directories."
   exit 1;
fi

links=`pwd`/links
tmpdir=`pwd`/tmp

mkdir -p $tmpdir
mkdir -p $links

# Make directory of links to the ECA data.  This relies on the command
# line arguments being absolute pathnames.
ln -s $* $links

# Basic spot checks to see if we got the data that we needed
if [ ! -d $links/LDC97T19 ];
then
        echo "The callhome data directory LDC97T19 not found"
        exit 1;
fi
if [ ! -d $links/LDC2002T38 ];
then
        echo "The Callhome supplement directory LDC2002T38 not found."
        exit 1;
fi
if [ ! -d $links/LDC2002T39 ];
then
        echo "The H5-ECA directory LDC2002T39 not found."
        exit 1;
fi

#Check the transcripts directories as well to see if they exist
if [ ! -d $links/LDC97T19/callhome_arabic_trans_970711/transcrp/devtest -o ! -d $links/LDC97T19/callhome_arabic_trans_970711/transcrp/evaltest -o ! -d $links/LDC97T19/callhome_arabic_trans_970711/transcrp/train ]
then
        echo "Transcript directories missing or not properly organised"
        exit 1;
fi

if [ ! -d $links/LDC2002T38/ch_ara_transcr_suppl/transcr ]
then
        echo "Callhome supplement Transcript directories missing or not properly organised"
        exit 1;
fi

if [ ! -d $links/LDC2002T39/transcr ]
then
        echo "H5 Transcript directories missing or not properly organised"
        exit 1;
fi

transcripts_train=$links/LDC97T19/callhome_arabic_trans_970711/transcrp/train/script
transcripts_dev=$links/LDC97T19/callhome_arabic_trans_970711/transcrp/devtest/script
transcripts_test=$links/LDC97T19/callhome_arabic_trans_970711/transcrp/evaltest/script
transcripts_sup=$links/LDC2002T38/ch_ara_transcr_suppl/transcr
transcripts_h5=$links/LDC2002T39/transcr

fcount_t_train=`find ${transcripts_train} -iname '*.scr' | wc -l`
fcount_t_dev=`find ${transcripts_dev} -iname '*.scr' | wc -l`
fcount_t_test=`find ${transcripts_test} -iname '*.scr' | wc -l`
fcount_t_sup=`find ${transcripts_sup} -iname '*.scr' | wc -l`
fcount_t_h5=`find ${transcripts_h5} -iname '*.scr' | wc -l`

#Now check if we got all the files that we needed
if [ $fcount_t_train != 80 -o $fcount_t_dev != 20 -o $fcount_t_test != 20 ];
then
        echo "Incorrect number of files in the data directories"
        echo "The paritions should contain 80/20/20 files"
        exit 1;
fi
if [ $fcount_t_sup != 20 ];
then
        echo "Incorrect number of files in the ECA sup data directories"
        echo "The paritions should contain 20 files"
        exit 1;
fi
if [ $fcount_t_h5 != 20 ];
then
        echo "Incorrect number of files in the H5 data directories"
        echo "The paritions should contain 20 files"
        exit 1;
fi

for split in train dev test sup h5; do
  transcripts="transcripts_$split"

  for scrFile in `find "${!transcripts}" -iname '*.scr'`; do
    iconv -f iso-8859-6 -t utf-8 -c $scrFile > $tmpdir/${scrFile##*/}.utf
  done

    # Now that we are done collecting all the files in one directory, create a TSV
  for utfFile in $tmpdir/*.utf; do
    perl -CSD -i.orig -00 -ple 's/\s*\n\s*/ /g' $utfFile
    grep -e "^$" -v $utfFile > $utfFile.clean
    fileId=${utfFile##*/}
    cat $utfFile.clean | \
      sed -re "s/([0-9]+\.[0-9]+\s[0-9]+\.[0-9]+\s[^\s]+:)\s(.*)/\1\t\2/g" | \
      awk -v file="${fileId%.*}" 'BEGIN{FS="\t"} {split($1,a," "); \
        $1=file"-"a[1]"-"a[2]"-"substr(a[3],0,length(a[3])-1); print $1"\t"$2}' \
      >> $tmpdir/$split.final
  done
  mv $tmpdir/$split.final corpus/callhome_$split.ar
  rm $tmpdir/*.utf*
done

rm -rf tmp links

echo "CALLHOME ECA Data preparation succeeded."
