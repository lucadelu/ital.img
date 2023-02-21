#!/bin/sh

# This file is useful to install ital.img dependencies
### VARIABILI CHE POSSONO ESSERE MODIFICATE ##
mkgmap="mkgmap-r4905"
splitter="splitter-r653"

#ciclo per vedere le opzioni scelte
while getopts "f" Opzione
do
    case $Opzione in
	#opzione per forzare l'installazione dei software
	f ) FORCE=1;;
    esac
done

if which aria2c >/dev/null; then
    DOWN=aria2c
elif which wget >/dev/null; then
    DOWN=wget
elif which curl >/dev/null; then
    DOWN=curl
else
    echo "'aria2c', 'wget' or 'curl' is required, please install one of this tool"
    exit 1
fi

if [ ! `which unzip` ]; then
    echo "unzip is required, please install it"
fi

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
    $DOWN http://www.mkgmap.org.uk/download/${mkgmap}.tar.gz
    tar xzf ${mkgmap}.tar.gz
    rm -f ${mkgmap}.tar.gz
fi

if [ ! -d $splitter ]; then
    $DOWN http://www.mkgmap.org.uk/download/${splitter}.tar.gz
    tar xzf ${splitter}.tar.gz
    rm -f ${splitter}.tar.gz
fi

sed -i "/mkgmap=/c\mkgmap=\"${mkgmap}\"" italimg.sh
sed -i "/splitter=/c\splitter=\"${splitter}\"" italimg.sh
sed -i "/mkgmap=/c\mkgmap=\"${mkgmap}\"" other_nation.sh
sed -i "/splitter=/c\splitter=\"${splitter}\"" other_nation.sh

if [ ! -d sea ]; then
    $DOWN https://www.thkukuk.de/osm/data/sea-latest.zip
    unzip sea-latest.zip
    rm -f sea-latest.zip
else
    if [ "$FORCE" ]; then
        rm -rf sea
        $DOWN https://www.thkukuk.de/osm/data/sea-latest.zip
        unzip sea-latest.zip
        rm -f sea-latest.zip
    fi
fi

if [ ! -d bounds ]; then
    $DOWN https://www.thkukuk.de/osm/data/bounds-latest.zip
    unzip bounds-latest.zip -d bounds
    rm -f bounds-latest.zip
else
    if [ "$FORCE" ]; then
        rm -rf bounds
        $DOWN https://www.thkukuk.de/osm/data/bounds-latest.zip
        unzip bounds-latest.zip -d bounds
        rm -f bounds-latest.zip
    fi
fi
if [ ! -f cities15000.txt ]; then
    $DOWN -c http://download.geonames.org/export/dump/cities15000.zip
    unzip cities15000.zip
    rm -f cities15000.zip
else
    if [ "$FORCE" ]; then
        rm -rf cities15000.txt
        $DOWN http://download.geonames.org/export/dump/cities15000.zip
        unzip cities15000.zip
        rm -f cities15000.zip
    fi
fi
