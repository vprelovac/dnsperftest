#!/usr/bin/env bash

command -v bc > /dev/null || { echo "bc was not found. Please install bc."; exit 1; }
{ command -v drill > /dev/null && dig=drill; } || { command -v dig > /dev/null && dig=dig; } || { echo "dig was not found. Please install dnsutils."; exit 1; }



NAMESERVERS=`cat /etc/resolv.conf | grep ^nameserver | cut -d " " -f 2 | sed 's/\(.*\)/&#&/'`

PROVIDERS="
1.1.1.1#cloudflare 
8.8.8.8#google 
9.9.9.9#quad9 
45.90.28.0#NextDNS
103.247.36.36#DNSFilter
76.76.2.0#ControlD
4.2.2.1#level3 
208.67.222.123#Cisco
80.80.80.80#freenom 
208.67.222.123#opendns 
199.85.126.20#norton 
185.228.168.168#cleanbrowsing 
77.88.8.7#yandex 
156.154.70.3#neustar 
"

# Domains to test. Duplicated domains are ok
DOMAINS2TEST="kagi.com google.com facebook.com yahoo.com amazon.com ibm.com microsoft.com apple.com medium.com cnn.com foxnews.com bild.de nytimes.com mateja.prelovac.com enigma.rs hmdt.jp podravka.hr argentia.com.ar bildung.sachsen.de orionfeedback.org unknowndomain1233.com womenoftoday.com unionsforenergydemocracy.org adaniairports.com labola.es christopherfowler.co.uk groupe-ecomedia.com 12noon.com michaelasseff.net intfiction.org headhunter-blog.de dorure.fr hookedonphonics.us annhamiltonstudio.com sv-mistelgau.de heimat-berlin.com sdreadytowork.com leadabatementproducts.com goingonanadventure.co.uk junkfood.com noncense.org teclis.com igotthiswrongsdklf.com sundayhome.brb"

totaldomains=0
printf "%-18s" ""
for d in $DOMAINS2TEST; do
    totaldomains=$((totaldomains + 1))
    printf "%-8s" "test$totaldomains"
done
printf "%-8s" "Average"
echo ""

for p in $NAMESERVERS $PROVIDERS; do
    pip=${p%%#*}
    pname=${p##*#}
    ftime=0

    printf "%-18s" "$pname"
    for d in $DOMAINS2TEST; do
        ttime=`$dig +tries=1 +time=2 +stats @$pip $d |grep "Query time:" | cut -d : -f 2- | cut -d " " -f 2`
        if [ -z "$ttime" ]; then
	        #let's have time out be 1s = 1000ms
	        ttime=1000
        elif [ "x$ttime" = "x0" ]; then
	        ttime=1
	    fi

        printf "%-8s" "$ttime ms"
        ftime=$((ftime + ttime))
    done
    avg=`bc -lq <<< "scale=2; $ftime/$totaldomains"`

    echo "  $avg"
done


exit 0;