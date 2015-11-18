#!/usr/bin/env perl

use File::Basename;

if ((scalar @ARGV) != 1) {
  die "Usage : CleanTranscripts.pl [TRANSCRIPT]"
}

open(T, "<", $ARGV[0]) || die "Can't open input file";

while (<T>) {
	my @stringComponents = split("\t");
  my $time = $stringComponents[0];
  my $words = $stringComponents[1];
  $words =~ s|\[\[[^]]*\]\]||g;    #removes comments
  $words =~ s|\{laugh\}|\$laughter\$|g;    # replaces laughter tmp
  $words =~ s|\{[^}]*\}|\[noise\]|g;       # replaces noise
  $words =~ s|\[/*([^]]*)\]|\[noise\]|g;   # replaces end of noise
  $words =~ s|\$laughter\$|\[laughter\]|g; # replaces laughter again
  $words =~ s|\(\(([^)]*)\)\)|$1|g;        # replaces unintelligible speech
  $words =~ s|//([^/]*)//|$1|g;        # replaces aside speech
  $words =~ s|<[\/]aside||g;
  $words =~ s|\*\*([^\*]*)\*\*|$1|g;        # replaces aside speech
  $words =~ s|#([^)]*)#|$1|g;        # replaces unintelligible speech
  $words =~ s|<\?([^>]*)>|$1|g;             # for unrecognized language
  $words =~ s|<\s*\S*\s*([^>]*)>| $1|g;        # replaces foreign text
  $words =~ s|~||g;
  $words =~ s|\(\S\)||g;                  # tEh marbUta "B"
  $words =~ s|&||g;                       # Proper noun marker removed
  $words =~ s|(\S+)%(\S*)|$1<ext>$2|g;
  $words =~ s|%(\S*)|[hes]|g;        # Takes care of hesitations
  $words =~ s|<ext>|%|g;
  $words =~ s|-*||g;                      # Removes hyphens 
  $words =~ s|\?||g;
  $words =~ s|\s\s*| |g;
  $words =~ s|\s$||g;
  chomp($words);
  print $time . "\t" . $words . "\n";
}

close(T);
