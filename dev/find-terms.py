import sys, re;
import time
import urllib.request
import urllib.parse

crh_rus = open(sys.argv[1]);

def temizle(s): #{
	o = '';
	durum = 0;	

	for c in s: #{
		if c == '[': durum = 1; 
		if c == ']': durum = 0;
		if c == ']' or c == '[': continue

		if durum == 0:  #{
			o = o + c;
		#}
	#}
	return o;
#}

def szlk_demek(s): #{
	# wget -q -O - "http://demek.ru/soz/?q=машина"
	url = 'http://demek.ru/soz/?q=' + urllib.parse.quote(s);
	sablon = re.compile('<div class="item_bsc">[^<]+</div>');
	sayfa = urllib.request.urlopen(url).read();
	katilma = sablon.findall(sayfa.decode());
	return katilma;	
#}

kelime = '';
ilk = True;
sozluk = {};

cyrl = re.compile('[а-яёА-ЯЁ]+[а-яёА-ЯЁ ]+[а-яёА-ЯЁ]+');
latn = re.compile('[öçğşüıa-zA-Z]+[öçğşüıa-zA-Z ]+[öçğşüıa-zA-Z]+');

for cizgi in crh_rus.readlines(): #{
	if cizgi.strip() == '': #{
		continue;
	#}
	
	if ilk == True: #{
		kelime = cizgi.strip();
		sozluk[kelime] = [];
		ilk = False;
		continue;
	#}	

	if cizgi[0] == '\t': #{
		xcizgi = temizle(cizgi.strip());
		k = latn.findall(xcizgi);
		if k == []: k = [kelime];
		sozluk[kelime].append({'crh': k, 'rus': cyrl.findall(xcizgi)});
	else: #{
		kelime = cizgi.strip();
		sozluk[kelime] = [];
	#}
#}

for katilma in sozluk: #{
	for kelime in sozluk[katilma]: #{
		if kelime['rus'] == [] or kelime['rus'] == []: #{
			continue;
		#}
		for o in kelime['rus']: #{
			ox = szlk_demek(o);
			print(katilma,'\t',kelime['crh'],'\t',o,'\t',ox);
		#}
	#}

#}
