lang2path=`cat config.log | grep lang2= | sed 's/lang2=/@/g' | cut -f2 -d'@'`
lang2=`basename $lang2path | sed 's/apertium-//g'`
pair=`cat config.log | grep ^PACKAGE= | cut -f2 -d"'" | sed 's/apertium-//g'`;
sed 's/#//g' | apertium -d . $pair-postchunk2 2>/dev/null > /tmp/$pair.postchunk2.0
cat /tmp/$pair.postchunk2.0 | sed 's/\$/$\n/g' | sed 's/^ *//g' | sed 's/ *$//g' | sort -f | uniq -c | sort -gr > /tmp/$pair.postchunk2.1
cat /tmp/$pair.postchunk2.1 | lt-proc -g $pair.autogen.bin > /tmp/$pair.gen
paste /tmp/$pair.postchunk2.1 /tmp/$pair.gen | grep -v '#^' | grep '#' > /tmp/$pair.fail
cat /tmp/$pair.fail | cut -f2 -d'#' | cut -f1 -d'\' | apertium-destxt | lt-proc -w $lang2path/$lang2.automorf.bin | apertium-retxt > /tmp/$pair.$lang2.morf
paste /tmp/$pair.fail /tmp/$pair.$lang2.morf 
paste /tmp/$pair.fail /tmp/$pair.$lang2.morf | wc -l
