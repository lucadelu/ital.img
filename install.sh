#!/bin/sh

# This file is useful to install ital.img dependencies
### VARIABILI CHE POSSONO ESSERE MODIFICATE ##
mkgmap="mkgmap-r3694"
splitter="splitter-r439"

#ciclo per vedere le opzioni scelte
while getopts "f" Opzione
do
    case $Opzione in
	#opzione per forzare l'installazione dei software
	f ) FORCE=1;;
    esac
done

if [ "$(id -u)" != "0" ]; then
    echo "To install osmconvert you should be root" 1>&2
else
    if [ ! `which osmconvert` ]; then
	wget -O - http://m.m.i24.cc/osmconvert.c | cc -x c - -lz -O3 -o /usr/local/bin/osmconvert
    else
	if [ "$FORCE" ] ; then
	    rm -rf /usr/local/bin/osmconvert
	    wget -O - http://m.m.i24.cc/osmconvert.c | cc -x c - -lz -O3 -o /usr/local/bin/osmconvert
	fi
    fi
fi
if [ ! -d $mkgmap ]; then
    wget -c http://www.mkgmap.org.uk/download/${mkgmap}.tar.gz
    tar xzf ${mkgmap}.tar.gz
fi

if [ ! -d $splitter ]; then
    wget -c http://www.mkgmap.org.uk/download/${splitter}.tar.gz
    tar xzf ${splitter}.tar.gz
fi

sed -i "/mkgmap=/c\mkgmap=\"${mkgmap}\"" italimg.sh
sed -i "/splitter=/c\splitter=\"${splitter}\"" italimg.sh
sed -i "/mkgmap=/c\mkgmap=\"${mkgmap}\"" other_nation.sh
sed -i "/splitter=/c\splitter=\"${splitter}\"" other_nation.sh
