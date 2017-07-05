cat prefixes.txt | grep -v '^#' | grep -v '^$'  | hfst-regexp2fst -j -o prefixes.hfst
echo "?* %<err%_orth%>"   | hfst-regexp2fst -o err_orth.hfst
hfst-project -p lower ../../.deps/crh-tur.automorf.trimmed | hfst-subtract -2 err_orth.hfst | hfst-compose-intersect -2 - -1 prefixes.hfst |\
hfst-fst2strings -c 0  | tee /tmp/crh-tur.testvoc.0 |\
cut -f1 -d':' | sed 's/.*/^&$^.<sent>$/g' | apertium-pretransfer | lt-proc -b ../../crh-tur.autobil.bin | tee /tmp/crh-tur.testvoc.1 |\
apertium-transfer -b ../../apertium-crh-tur.crh-tur.t1x ../../crh-tur.t1x.bin  2>/dev/null |\
apertium-interchunk ../../apertium-crh-tur.crh-tur.t2x ../../crh-tur.t2x.bin  2>/dev/null |\
apertium-postchunk ../../apertium-crh-tur.crh-tur.t3x ../../crh-tur.t3x.bin   2>/dev/null |\
apertium-transfer -n ../../apertium-crh-tur.crh-tur.t4x ../../crh-tur.t4x.bin   2>/dev/null | tee /tmp/crh-tur.testvoc.2 |\
lt-proc -d ../../crh-tur.autogen.bin > /tmp/crh-tur.testvoc.3
paste /tmp/crh-tur.testvoc.0 /tmp/crh-tur.testvoc.1 /tmp/crh-tur.testvoc.2 /tmp/crh-tur.testvoc.3 | cat -n | sed 's/^ *//g' | sed 's/ /\t/1' > /tmp/crh-tur.testvoc
cat /tmp/crh-tur.testvoc
