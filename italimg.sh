#!/bin/sh
#
#    Copyright 2011 Luca Delucchi
#    lucadeluge@gmail.com
#
#
#    This program is free software; you can redistribute it and/or odify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

### VARIABILI DA NON TOCCARE ##
#per accedere all'help
NO_ARG=0
#per scaricare il file dell'italia
DOWN=true
#percorso al directory di lavoro
#bisogna lanciare il comando dalla directory di italimg.sh
MYPATH=`pwd`
### VARIABILI CHE POSSONO ESSERE MODIFICATE ##
#nome della zona rappresentata default italy
name="Italia"
#percorso al file da scaricare deve esserci poi le estensioni pbf e/o bz2
url="http://download.geofabrik.de/openstreetmap/europe/"
file_name="italy-latest.osm"
#abbreviazione della zona
abbr="IT"
#nome dello style
style_it="../../styles/gfoss"
style_escu="../../styles/hiking"
style_cycli="../../styles/cycling"
style_reg="../../../styles/gfoss"
mkgmap="mkgmap-r4140"
splitter="splitter-r591"
#assegna il livello della mappa se sul dispositivo sono presenti più mappe
priority="10"
XMX=2000M
###  FUNZIONE PER L'HELP ##
usage()
{
  echo "Utilizzo: `basename $0` opzioni

Opzioni:
    -d          elimina file originali
    -f		non scarica il file ${file_name}.bz2/pbf ma lo prende
		dalla cartella in cui si trova `basename $0`
    -p          scarica/usa file pbf
    -r		crea i file regionali bz2
    -w		scrive file regionali pbf
    -i		crea il file dell'Italia
    -e		crea il file dell'Italia con stile per escursionisti
    -c          crea il file dell'Italia con stile per ciclisti
    -h		visualizza questa schermata
    -R	nome	crea il file della regione scelta in formato bz2 e pbf

 Regioni accettate:
"
 regions=`find poly/*.poly -type f | cut -d'.' -f'1' | cut -d'/' -f'2' | tr '\n' ' '`
 echo "    $regions \n"

#per supportare in futuro un file degli stili esterno
#  echo " Stili accettati:"
#   styles=""
#   for i in `find styles/* -type d `;do
#       style=`pwd`/$i
#       styles="${styles}${style} ";
#       echo "  -  ${style}"
#   done


}

checkfile()
{
    if [ ! -e $1 ] ; then
        echo "File $1 not found"
        exit 0
    fi
}

download()
{

    echo "Downloading ${file_name}.$EXT file..."

    if [ "$USE_WGET" ] ; then
	wget --quiet -c ${url}${file_name}.${EXT}
    #usa curl
    else
	curl -silent --location ${url}${file_name}.${EXT}
    fi

    if [ ! "$PBF" ] ; then
        bzcat ${file_name}.$EXT > ${file_name}
    fi
}

### FUNZIONE PER CREARE I FILE DI TUTTE REGIONI ##
regioni()
{
    for NAME in $(find poly/*.poly -type f)
    do
	#estrapola il nome del file poly
	nome_reg=`basename $NAME .poly`

        if [ "$PBF" ] ; then
            osmconvert  ${file_name}.$EXT -B=$NAME > tmp/regioni/$nome_reg.osm
        else
            osmconvert  ${file_name} -B=$NAME > tmp/regioni/$nome_reg.osm
        fi

        cd tmp/regioni

	#e crea la directory per il file diviso
	#crea ed entra dentro la cartella
	mkdir $nome_reg
	cd $nome_reg

	#divide il file osm della regione se troppo grande
    serie="Mappa della regione $nome_reg creata da ital.img"
    java -Xmx${XMX} -jar ${MYPATH}/${splitter}/splitter.jar --max-areas=4096 --max-nodes=3000000 --wanted-admin-level=8 --geonames-file=${MYPATH}/cities15000.txt --overlap=2000 ../$nome_reg.osm
    java -Xmx${XMX} -jar ${MYPATH}/${mkgmap}/mkgmap.jar \
        --style-file=$style_reg \
        --latin1 \
        --country-name="$name_reg" \
        --area-name="$name_reg" \
        --family-name="OpenStreetMap: $name_reg" \
        --description="$name_reg" \
        --draw-priority=$priority \
        --series-name="$serie" \
        --precomp-sea=${MYPATH}/sea/ \
        --generate-sea \
        --bounds=${MYPATH}/bounds \
        --max-jobs \
        --remove-short-arcs \
        --route \
        --drive-on=detect,right \
        --process-destination \
        --process-exits \
        --location-autofill=is_in,nearest \
        --index \
        --x-split-name-index \
        --housenumbers \
        --road-name-pois \
        --add-pois-to-areas \
        --no-poi-address \
        --link-pois-to-ways \
        --preserve-element-order \
        --verbose \
        --name-tag-list=int_name,name,name:it \
        --draw-priority=$priority \
        --merge-lines \
        --reduce-point-density=3.2 \
        --gmapsupp \
        6*.osm.pbf
	# l'unione dei file è già avvenuta con opzione --gmapsupp
	#java -Xmx${XMX} -jar ${MYPATH}/${mkgmap}/mkgmap.jar --gmapsupp *.img
	#crea il file tar.gz da scaricare e lo comprime
	tar -cf ${MYPATH}/output_img/${nome_reg}.tar gmapsupp.img ${MYPATH}/README_data.txt
	gzip -9 -f ${MYPATH}/output_img/${nome_reg}.tar
	unset serie
	#comprime il file osm e lo mette nella cartella download
        cd ..
	if [ "$WPBF" ] ; then
	    osmconvert $nome_reg.osm -o=$nome_reg.pbf
	    mv $nome_reg.pbf ${MYPATH}/output_osm_regioni/
	fi
	if [ "$WBZ2" ] ; then
	    bzip2 $nome_reg.osm
	    mv $nome_reg.osm.bz2 ${MYPATH}/output_osm_regioni/
	fi
        cd ../..
    done

    rm -rf tmp/regioni/*
}

### FUNZIONE PER CREARE IL FILE DI UNA REGIONE ##
regione()
{
    NAMEREG_poly="poly/$NAMEREG.poly"
    nome_reg=$NAMEREG
    serie="Mappa di $nome_reg creata da ital.img"
    #divide il file dell'italia in quello delle regioni
    if [ "$PBF" ] ; then
        osmconvert  ${file_name}.$EXT -B=$NAMEREG_poly > tmp/regioni/$nome_reg.osm
    else
        osmconvert  ${file_name} -B=$NAMEREG_poly > tmp/regioni/$nome_reg.osm
    fi
    cd tmp/regioni
    #crea e si sposta nella cartella della ragione
    mkdir $nome_reg
    cd $nome_reg

    java -Xmx${XMX} -jar ${MYPATH}/${splitter}/splitter.jar --max-areas=4096 --max-nodes=3000000 --wanted-admin-level=8 --geonames-file=${MYPATH}/cities15000.txt --overlap=2000 ../${nome_reg}.osm
    java -Xmx${XMX} -jar ${MYPATH}/${mkgmap}/mkgmap.jar \
        --style-file=$style_reg \
        --latin1 \
        --country-name="$name_reg" \
        --area-name="$name_reg" \
        --family-name="OpenStreetMap: $name_reg" \
        --description="$name_reg" \
        --draw-priority=$priority \
        --series-name="$serie" \
        --precomp-sea=${MYPATH}/sea/ \
        --generate-sea \
        --bounds=${MYPATH}/bounds/ \
        --max-jobs \
        --remove-short-arcs \
        --route \
        --drive-on=detect,right \
        --process-destination \
        --process-exits \
        --location-autofill=is_in,nearest \
        --index \
        --x-split-name-index \
        --housenumbers \
        --road-name-pois \
        --add-pois-to-areas \
        --no-poi-address \
        --link-pois-to-ways \
        --preserve-element-order \
        --verbose \
        --name-tag-list=int_name,name,name:it \
        --draw-priority=$priority \
        --merge-lines \
        --reduce-point-density=3.2 \
        --gmapsupp \
        6*.osm.pbf
    #unisce tutti i file
    #l'unione dei file è già avvenuta con opzione --gmapsupp
    #java -Xmx${XMX} -jar ${MYPATH}/${mkgmap}/mkgmap.jar --gmapsupp *.img
    #crea il file tar.gz da scaricare e lo comprime
    tar -cf ${MYPATH}/output_img/${nome_reg}.tar gmapsupp.img ${MYPATH}/README_data.txt
    gzip -9 -f ${MYPATH}/output_img/${nome_reg}.tar
    #rimuove i singoli file
    rm gmapsupp.img
    unset serie
    #comprime il file osm e lo mette nella cartella download
    cd ..
#     if [ "$REGION_PBF" ] ; then
	osmconvert $nome_reg.osm -o=$nome_reg.pbf
	mv $nome_reg.pbf ${MYPATH}/output_osm_regioni/
#     fi
#     if [ "$REGION_BZ2" ] ; then
	bzip2 $nome_reg.osm
	mv $nome_reg.osm.bz2 ${MYPATH}/output_osm_regioni/
#     fi
    cd ../..
    rm -rf tmp/regioni/*
}

### FUNZIONE PER CREARE IL FILE DELL'ITALIA ##
italia()
{
    if [ "$PBF" ] ; then
        checkfile ${file_name}.$EXT
        java -Xmx${XMX} -jar $splitter/splitter.jar --overlap=2000 --max-areas=4096 --max-nodes=3000000 --wanted-admin-level=8 --geonames-file=${MYPATH}/cities15000.txt ${file_name}.$EXT
    else
        checkfile ${file_name}
        java -Xmx${XMX} -jar $splitter/splitter.jar --overlap=2000 --max-areas=4096 --max-nodes=3000000 --wanted-admin-level=8 --geonames-file=${MYPATH}/cities15000.txt ${file_name}
    fi

    #crea la mappa con lo stile gfoss
    if [ "$ITALY" ] ; then
        #nome della mappa
        serie="Mappa italiana creata da ital.img"
        cd tmp/italia
        #crea il file img
        java -Xmx${XMX} -jar ${MYPATH}/${mkgmap}/mkgmap.jar \
            --style-file=$style_it \
            --latin1 \
            --country-name="$name" \
            --country-abbr="$abbr" \
            --area-name="$name" \
            --family-name="OpenStreetMap: $name" \
            --description="$name" \
            --draw-priority=$priority \
            --series-name="$serie" \
            --precomp-sea=${MYPATH}/sea/ \
            --generate-sea \
            --bounds=${MYPATH}/bounds \
            --max-jobs \
            --remove-short-arcs \
            --route \
            --drive-on=detect,right \
            --process-destination \
            --process-exits \
            --location-autofill=is_in,nearest \
            --index \
            --x-split-name-index \
            --housenumbers \
            --road-name-pois \
            --add-pois-to-areas \
            --no-poi-address \
            --link-pois-to-ways \
            --preserve-element-order \
            --verbose \
            --name-tag-list=int_name,name,name:it \
            --merge-lines \
            --reduce-point-density=3.2 \
            --gmapsupp \
            ../../6*.osm.pbf
	# l'unione dei file è già avvenuta con opzione --gmapsupp
        #java -Xmx${XMX} -jar ${MYPATH}/${mkgmap}/mkgmap.jar --gmapsupp *.img
        tar -cf ${MYPATH}/output_img/italia.tar gmapsupp.img ${MYPATH}/README_data.txt
        gzip -9 -f ${MYPATH}/output_img/italia.tar
        cd ../../
        rm -rf tmp/italia/*
    fi
    #crea la mappa con lo stile escursionismo
    if [ "$HIKING" ] ; then
        #nome della mappa
        serie="Mappa italiana per escursionisti creata da ital.img"
        #crea il nome e la stringe per l'escursionismo
        cd tmp/italia_escu
        #crea il file img con lo stile escursionismo
        java -Xmx${XMX} -jar ${MYPATH}/${mkgmap}/mkgmap.jar \
            --style-file=$style_escu \
            --check-roundabouts \
            --latin1 \
            --country-name="$name" \
            --country-abbr="$abbr" \
            --area-name="$name" \
            --family-name="OpenStreetMap: $name" \
            --description="$name" \
            --draw-priority=$priority \
            --series-name="$serie" \
            --precomp-sea=${MYPATH}/sea/ \
            --generate-sea \
            --bounds=${MYPATH}/bounds \
            --max-jobs \
            --remove-short-arcs \
            --route \
            --drive-on=detect,right \
            --process-destination \
            --process-exits \
            --location-autofill=is_in,nearest \
            --index \
            --x-split-name-index \
            --housenumbers \
            --road-name-pois \
            --add-pois-to-areas \
            --no-poi-address \
            --link-pois-to-ways \
            --preserve-element-order \
            --verbose \
            --name-tag-list=int_name,name,name:it \
            --ignore-maxspeeds \
            --ignore-turn-restrictions \
            --merge-lines \
            --reduce-point-density=3.2 \
            --gmapsupp \
            ../../6*.osm.pbf
        java -Xmx${XMX} -jar ${MYPATH}/${mkgmap}/mkgmap.jar --latin1 --index --gmapsupp *img ${MYPATH}/openmtbmap_it_srtm/*.img
        #comprime il file
        tar -cf ${MYPATH}/output_img/italia_escursionismo.tar gmapsupp.img ${MYPATH}/README_data.txt
        gzip -9 -f ${MYPATH}/output_img/italia_escursionismo.tar
        cd ../../
        rm -rf tmp/italia_escu/*
    fi
    #crea la mappa con lo stile ciclismo
    if [ "$CYCLING" ] ; then
        #nome della mappa
        serie="Mappa italiana per ciclisti creata da ital.img"
        #crea il nome e la stringe per l'escursionismo
        cd tmp/italia_bici
        #crea il file img con lo stile escursionismo
        java -Xmx${XMX} -jar ${MYPATH}/${mkgmap}/mkgmap.jar \
            --style-file=$style_cycli \
            --check-roundabouts \
            --latin1 \
            --country-name="$name" \
            --country-abbr="$abbr" \
            --area-name="$name" \
            --family-name="OpenStreetMap: $name" \
            --description="$name" \
            --draw-priority=$priority \
            --series-name="$serie" \
            --precomp-sea=${MYPATH}/sea/ \
            --generate-sea \
            --bounds=${MYPATH}/bounds \
            --max-jobs \
            --remove-short-arcs \
            --route \
            --drive-on=detect,right \
            --process-destination \
            --process-exits \
            --location-autofill=is_in,nearest \
            --index \
            --x-split-name-index \
            --housenumbers \
            --road-name-pois \
            --add-pois-to-areas \
            --no-poi-address \
            --link-pois-to-ways \
            --preserve-element-order \
            --verbose \
            --name-tag-list=int_name,name,name:it \
            --draw-priority=$priority \
            --ignore-maxspeeds \
            --ignore-turn-restrictions \
            --merge-lines \
            --reduce-point-density=3.2 \
            --gmapsupp \
            --make-cycleways \
            --make-opposite-cycleways \
            --cycle-map \
            ../../6*.osm.pbf
        java -Xmx${XMX} -jar ${MYPATH}/${mkgmap}/mkgmap.jar --latin1 --index --gmapsupp *img ${MYPATH}/openmtbmap_it_srtm/*.img
        #comprime il file
        tar -cf ${MYPATH}/output_img/italia_ciclismo.tar gmapsupp.img ${MYPATH}/README_data.txt
        gzip -9 -f ${MYPATH}/output_img/italia_ciclismo.tar
        cd ../../
        rm -rf tmp/italia_escu/*
    fi
    rm -f 6*.pbf
}

##### SCRIP VERO E PROPRIO #####

### INIZIO CODICE PRESO DA g.extension di GRASS GIS 6.4 copyrigth di Markus Neteler
#controlla la presenza di bzcat
if [ ! -x "`which bzcat`" ] ; then
    echo "Il programma 'bzcat' è richiesto. Installatelo per far funzionare ital.img"
    exit 1
fi
#controlla la presenza di tar
if [ ! -x "`which tar`" ] ; then
    echo "Il programma 'tar' è richiesto. Installatelo per far funzionare ital.img."
    exit 1
fi
#controlla la presenza di bzip
if [ ! -x "`which gzip`" ] ; then
    echo "Il programma 'gzip' è richiesto. Installatelo per far funzionare ital.img."
    exit 1
fi
#controlla la presenza di wget o curl
if [ ! -x "`which wget`" ] ; then
    if [ ! -x "`which curl`" ] ; then
        echo "O 'wget' o 'curl' è richiesto, installate uno dei due  per far funzionare ital.img."
        exit 1
    else
        USE_CURL=1
    fi
else
    USE_WGET=1
fi
### FINE CODICE PRESO DA g.extension di GRASS GIS 6.4 copyrigth di Markus Neteler

#controlla se non ci sono parametri ed stampa l'help
if [ $# -eq "$NO_ARG" ] ; then
    usage
    exit
fi

DOWN=true
#ciclo per vedere le opzioni scelte
while getopts "R:riechdpfwx" Opzione
do
    case $Opzione in
	#opzione per creare tutte le regioni
	r ) WBZ2=1;;
	#opzione per creare l'italia stile gfoss
	i ) ITALY=1;;
	#opzione per creare l'italia stile escursionismo
	e ) HIKING=1;;
	#opzione per creare l'italia stile escursionismo
	c ) CYCLING=1;;
	#opzione per stampare l'help
	h ) usage; exit;;
	#opzione per eliminare il file originale
	d ) REMOVE=1;;
        #opzione per non scaricare il file
        f ) DOWN=false;;
        #scarica file pbf invece che bz2
        p ) PBF=1;;
	#scrive file regionali bz2
	w ) WPBF=1;;
	#opzione per creare una singola regione
	R ) if [ -n $OPTARG ] ; then
		#nome della regione
		NAMEREG=$OPTARG
		#variabile che serve per controllare se il nome della regione ha un file poly corrispondente, di defaul false
		REGION=0
		#per tutti i file poly trovati nella cartella poly
		for i in `ls -1 poly/ | cut -d'.' -f'1' | tr '\n' ' '`; do
		    #se il nome della regione scelta combacia con il nome considerato nel ciclo setta REGION a true e ferma il ciclo
		    if [ "$NAMEREG" = "$i" ] ; then
			REGION=1;
			break
		    fi
		done
		#se a fine ciclo REGION è ancora false restituisce un errore
		if [ ! "$REGION" ] ; then
		    echo "Regione non trovata, controllate le regioni accettate lanciando `basename $0` senza parametri";
		    exit 0;
		fi
            fi;;
    esac
done

#controlla se scaricare bz2 o pbf
if [ "$PBF" ] ; then
    EXT=pbf
else
    EXT=bz2
fi

#scarica i dati dell'italia, per altri stati basta cambiare il path
if [ "$DOWN" = true ] ; then
    download
else
    if [ ! "$PBF" ] ; then
        checkfile ${file_name}.bz2
        bzcat ${file_name}.bz2 > ${file_name}
    fi
fi

#crea i file delle regioni
if [ "$WBZ2" ] || [ "$WPBF" ] ; then
    #crea i file per le regioni
    regioni
    #sposta i file da scaricare
    mv -f output_img/*.osm.* output_osm_regioni/
fi
#crea il file della regione
if [ "$REGION" ] ; then
    #crea i file per le regioni
    regione
fi
#crea il file dell'italia
if [ "$ITALY" ] || [ "$HIKING" ]  || [ "$CYCLING" ]; then
    #crea i file per l'italia
    italia
fi

#rimuove file originale
if [ "$REMOVE" = true ] ; then
    #controlla se il file è pbf o bz2
    if [ ! "$PBF" ] ; then
        rm -f ${file_name}.bz2 ${file_name}
    else
        rm -f ${file_name}.pbf
    fi
fi
