#!/bin/bash

if test -t 0; then
    echo "Usage:" 1>&2
    echo "\$ bzcat crhcorpus.txt.bz2 | ./$0" 1>&2
    exit 1
fi

# This file is kept even after the script is ended:
needed=/tmp/corpus-stat-all-needed.txt

covgoal="75.0" # percent goal we aim for this week, according to http://wiki.apertium.org/wiki/Crimean_Tatar_and_Turkish/Work_plan


cd "$(dirname $0)"

transfout=$(mktemp -t trimmed-coverage.XXXXXXXXX)
genout=$(mktemp -t trimmed-coverage.XXXXXXXXX)
sorted=$(mktemp -t trimmed-coverage.XXXXXXXXX)

TODOstripwords="the The of oblast in In it if ki any will his this who we right new their kraj that OfNm you www com org Ob http px inst also na on one One On och till und with which were can when was"



### Do the translation:
apertium-deshtml | apertium -f none -d ../../ crh-tur-postchunk2-postchunk | apertium-transfer -n ../../apertium-crh-tur.crh-tur.t4x ../../crh-tur.t4x.bin | apertium-cleanstream -n | tee "$transfout" | lt-proc -g ../../crh-tur.autogen.bin | lt-proc -p ../../crh-tur.autopgen.bin > "$genout"
#apertium-deshtml | apertium -f none -d ../../ tur-crh-postchunk2-postchunk | apertium-cleanstream -n | tee "$transfout" | lt-proc -g ../../tur-crh.autogen.bin | lt-proc -p ../../tur-crh.autopgen.bin > "$genout"


### Calculate stuff:
# Make sorting and printf the same regardless of locale (has to be set after apertium commands):
export LC_ALL='C'

numwords=$(grep -cF '^' "$transfout")
numstar=$(grep -cF '^*' "$transfout")
numat=$(grep -cF '^@' "$transfout")
numhash=$(grep -c '^#' "$genout") # Note: this one's a regex, the above are not

numknown_upto_ana=$(calc -p "$numwords - $numstar")
numknown_upto_bi=$(calc  -p "$numwords - $numstar - $numat")
numknown_upto_gen=$(calc -p "$numwords - $numstar - $numat - $numhash")

numneeded=$(calc -p "round($numwords * ($covgoal/100) - $numknown_upto_bi)")

pad () { printf "%*d" ${#numwords} "$1"; }
pct_of_words () { printf "% 5.1f" $(calc -p "round( $1 / $numwords * 1000)/10"); }
echo "Number of tokenised words in the corpus:         $(pad $numwords)"
echo "Number of tokenised words unknown to analyser:   $(pad $numstar)  — $(pct_of_words $numstar) % of tokens had *"
echo "                          unknown to bidix:      $(pad $numat)  — $(pct_of_words $numat) % of tokens had @" 
echo "     w/transfer errors or unknown to generator:  $(pad $numhash)  — $(pct_of_words $numhash) % of tokens had #"
echo ""
echo "Error-free coverage of analyser only:            $(pad $numknown_upto_ana)  — $(pct_of_words $numknown_upto_ana) % of tokens had no *"
echo "Error-free coverage of analyser and bidix:       $(pad $numknown_upto_bi)  — $(pct_of_words $numknown_upto_bi) % of tokens had no */@"
echo "Error-free coverage of the full translator:      $(pad $numknown_upto_gen)  — $(pct_of_words $numknown_upto_gen) % of tokens had no */@/#"
echo ""
echo "Top unknown words in the corpus:"
grep -F '^*' "$transfout" | sort -f | uniq -c | sort -gr | tee "$sorted" | head -10
echo ""
if [[ $numneeded -gt 0 ]]; then
    echo "Tokens needed to get $covgoal % bidix-trimmed coverage (no */@/#): $numneeded"
    echo "Storing corresponding wordlist in $needed"
else
    echo "Goal of $covgoal % bidix-trimmed coverage reached"'!'
fi

<"$sorted" awk -vn="$numneeded" '{print $0; t += $1; if( t > n ) exit; } END {print t}' > "$needed"


# Try uncommenting this to see words that didn't pass through transfer alright:
paste "$transfout" "$genout"
# This is the full list of unknown words:
#cat "$sorted"

rm -f "$transfout" "$genout" "$sorted"
