lang2path=`cat config.log | grep lang2= | sed 's/lang2=/@/g' | cut -f2 -d'@'`
lang2=`basename $lang2path | sed 's/apertium-//g'`
pair=`cat config.log | grep ^PACKAGE= | cut -f2 -d"'" | sed 's/apertium-//g'`;
apertium -d . $pair-postchunk2 2>/dev/null > /tmp/$pair.postchunk2.0
cat /tmp/$pair.postchunk2.0 | sed 's/\$/$\n/g' | sed 's/^ *//g' | sed 's/ *$//g' | grep -v '^ *$' > /tmp/$pair.postchunk2.1
cat /tmp/$pair.postchunk2.1 | lt-proc -g $pair.autogen.bin > /tmp/$pair.gen

total=`cat /tmp/$pair.postchunk2.1 | wc -l`
generr=`cat /tmp/$pair.gen | grep '#' | wc -l`;
unkerr=`cat /tmp/$pair.postchunk2.1 | grep '\*' | wc -l`;


trimmedclean=`calc "100-((($generr+$unkerr)/$total)*100)" | cut -f2 -d'~' | head -c 5`;
trimmed=`calc "100-(($unkerr/$total)*100)" | cut -f2 -d'~' | head -c 5`;

echo "$total $unkerr $generr"
echo "Trimmed: $trimmed %";
echo "Clean: $trimmedclean %";