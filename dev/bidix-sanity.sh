#!/bin/bash

pair=`pwd | grep -o 'apertium-[a-z][a-z][a-z]-[a-z][a-z][a-z]'`;
dir=`printf "%s\n" "$pair" | grep -o  -- '-[a-z][a-z][a-z]-[a-z][a-z][a-z]' | sed 's/^-//g'`; 
dix=$pair.$dir.dix
lang2=`printf "%s\n"  "$dir" | cut -f2 -d'-'`
lang2dir=`cat ../config.log | grep ^AP_SRC2 | cut -f2 -d\'`
analysator=../$lang2dir"/"$lang2".automorf.bin"

lt-expand ../$dix | sed 's/\(<[^>]\+>\)\(<[^>]\+>\)\+/&/g' | sed 's/:[><]:/:/g'  | grep -v ':\([[:punct:]]\|[[:space:]]\)' | grep -v -- '-<' | grep -v '\/' | sort -u > /tmp/$dir.exp

cat /tmp/$dir.exp | cut -f2- -d':' | cut -f1 -d'<' | lt-proc -w $analysator > /tmp/$dir.a

wc -l /tmp/$dir.exp /tmp/$dir.a

for line in `paste /tmp/$dir.exp /tmp/$dir.a  | sed 's/\t/:/g' | sed 's/ /¬/g'`; do
	lang1s=`printf "%s\n"  "$line" | cut -f1 -d':'`;
	lang2s=`printf "%s\n"  "$line" | cut -f2 -d':'`;
	lang2m=`printf "%s\n"  "$line" | cut -f3 -d':'`;

	num=`printf "%s\n"   "$lang2m" | grep -o "$lang2s" | wc -l`
#	gecho $num" "$lang2m" "$lang2s;
	if [[ $num -eq 0 ]]; then
		printf "%%\t%s\n" "$line";
	else
#		printf "%%\t%s\n" "$line";
		continue
	fi
done
	
