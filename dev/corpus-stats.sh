lang1path=`cat config.log | grep lang1= | sed 's/lang1=/@/g' | sed 's/--with-lang2=/@/g' | cut -f2 -d'@'`
lang1=`basename $lang1path | sed 's/apertium-//g'`
lang2path=`cat config.log | grep lang2= | sed 's/lang2=/@/g' | cut -f2 -d'@'`
lang2=`basename $lang2path | sed 's/apertium-//g'`
pair=`cat config.log | grep ^PACKAGE= | cut -f2 -d"'" | sed 's/apertium-//g'`;

tee /tmp/$pair.input | apertium -d . $pair-postchunk2 2>/dev/null > /tmp/$pair.postchunk2.0
cat /tmp/$pair.postchunk2.0 | sed 's/\$/$\n/g' | sed 's/^ *//g' | sed 's/ *$//g' | grep -v '^ *$' > /tmp/$pair.postchunk2.1
cat /tmp/$pair.postchunk2.1 | lt-proc -g $pair.autogen.bin > /tmp/$pair.gen

total=`cat /tmp/$pair.postchunk2.1 | wc -l`
generr=`cat /tmp/$pair.gen | grep '#' | wc -l`;
unkerr=`cat /tmp/$pair.postchunk2.1 | grep '\*' | wc -l`;

cat /tmp/$pair.input | apertium -d $lang1path "$lang1""-morph" | sed 's/\$/$\n/g' | sed 's/^ *//g' | sed 's/ *$//g' | grep -v '^ *$' > /tmp/$pair.morph

untr_total=`cat /tmp/$pair.morph | wc -l`;
untr_known=`cat /tmp/$pair.morph | grep -v '\*' | wc -l`;

untrimmed=`calc "(($untr_known/$untr_total)*100)" | cut -f2 -d'~' | head -c 5`;
trimmedclean=`calc "100-((($generr+$unkerr)/$total)*100)" | cut -f2 -d'~' | head -c 5`;
trimmed=`calc "100-(($unkerr/$total)*100)" | cut -f2 -d'~' | head -c 5`;

echo "$untr_total $untr_known // $total $unkerr $generr"
echo -e "Untrimmed:\t$untrimmed %";
echo -e "Trimmed:\t$trimmed %";
echo -e "Clean  :\t$trimmedclean %";
