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
### VARIABILI CHE POSSONO ESSERE MODIFICATE ##
#nome della zona rappresentata default italy
name="Italia"
#abbreviazione della zona
abbr="IT"
#nome dello style
style_it="../../styles/gfoss"
style_escu="../../styles/hiking"
style_reg="../../../styles/gfoss"

#assegna il livello della mappa se sul dispositivo sono presenti più mappe
priority="10"

###  FUNZIONE PER L'HELP ##
usage()
{
  echo "Utilizzo: `basename $0` opzioni 

Opzioni:
    -d          elimina file originali
    -f		non scarica il file italy.osm.bz2/pbf ma lo prende  
		dalla cartella in cui si trova `basename $0`
    -p          scarica/usa file pbf
    -r		crea i file regionali
    -i		crea il file dell'Italia
    -e		crea il file dell'Italia con stile per escursionisti
    -h		visualizza questa schermata
    -R	nome	crea il file della regione scelta
 
 Regioni accettate:
"
 regions=`find poly/*.poly -type f | cut -d'.' -f'1' | cut -d'/' -f'2' | tr '\n' ' '`
 echo "    $regions \n"

#per supportare in furuto un file degli stili esterno
#  echo " Stili accettati:"
#   styles=""
#   for i in `find styles/* -type d `;do 
#       style=`pwd`/$i
#       styles="${styles}${style} "; 
#       echo "  -  ${style}"
#   done
 
   
}

download()
{

    echo "Downloading italy.osm.$EXT file..."

    if [ "$USE_WGET" ] ; then
	wget --quiet -c http://download.geofabrik.de/osm/europe/italy.osm.$EXT 
    #usa curl
    else 
	curl -silent --location http://download.geofabrik.de/osm/europe/italy.osm.$EXT
    fi

    if [ ! "$PBF" ] ; then
        bzcat italy.osm.$EXT > italy.osm
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
            ./osmconvert  italy.osm.$EXT -B=$NAME > tmp/regioni/$nome_reg.osm
        else
            ./osmconvert  italy.osm -B=$NAME > tmp/regioni/$nome_reg.osm
        fi

        cd tmp/regioni

	e crea la directory per il file diviso
	#crea ed entra dentro la cartella
	mkdir $nome_reg
	cd $nome_reg
        
	#divide il file osm della regione se troppo grande
        serie="Mappa della regione $nome_reg creata da ital.img"        
        java -Xmx2500M -jar ../../../splitter-r180/splitter.jar --overlap=2000 ../$nome_reg.osm
        java -Xmx2000M -jar ../../../mkgmap-r1995/mkgmap.jar --style-file=$style_reg --net --route --latin1 --country-name="$nome_reg" --draw-priority=$priority --add-pois-to-areas --series-name="$serie" 6*.osm.pbf  #--style-file=$style
	#unisce tutti i file
	java -Xmx2000M -jar ../../../mkgmap-r1995/mkgmap.jar --gmapsupp *.img
	#crea il file tar.gz da scaricare e lo comprime
	tar -cf ../../../output_img/${nome_reg}.tar gmapsupp.img ../../../README_data.txt 
	gzip -9 -f ../../../output_img/${nome_reg}.tar
	unset serie
	#comprime il file osm e lo mette nella cartella download
        cd ..
        rm $nome_reg.osm.bz2
	bzip2 $nome_reg.osm
	mv $nome_reg.osm.bz2 ../../output_osm_regioni/
        cd ../..
    done

    rm -rf tmp/regioni/*
}

### FUNZIONE PER CREARE IL FILE DI UNA REGIONE ##
regione()
{
    NAMEREG_poly="poly/$NAMEREG.poly"
    nome_reg=$NAMEREG
    #divide il file dell'italia in quello delle regioni
    if [ "$PBF" ] ; then
        ./osmconvert  italy.osm.$EXT -B=$NAMEREG_poly > tmp/regioni/$nome_reg.osm
    else
        ./osmconvert  italy.osm -B=$NAMEREG_poly > tmp/regioni/$nome_reg.osm
    fi
    cd tmp/regioni
    #crea e si sposta nella cartella della ragione
    mkdir $nome_reg
    cd $nome_reg

    java -Xmx2500M -jar ../../../splitter-r180/splitter.jar --overlap=2000 ../${nome_reg}.osm 
    java -Xmx2000M -jar ../../../mkgmap-r1995/mkgmap.jar --style-file=$style_reg --net --route --latin1 --country-name="$nome_reg" --draw-priority=$priority --add-pois-to-areas --series-name="$serie" 6*.osm.pbf  #--style-file=$style
    #unisce tutti i file
    java -Xmx2000M -jar ../../../mkgmap-r1995/mkgmap.jar --gmapsupp *.img
    #crea il file tar.gz da scaricare e lo comprime
    tar -cf ../../../output_img/${nome_reg}.tar gmapsupp.img ../../../README_data.txt 
    gzip -9 -f ../../../output_img/${nome_reg}.tar
    #rimuove i singoli file
    rm gmapsupp.img
    unset stringa
    #comprime il file osm e lo mette nella cartella download
    cd ..
    rm $nome_reg.osm.bz2
    bzip2 $nome_reg.osm
    mv $nome_reg.osm.bz2 ../../output_osm_regioni/
    cd ../..
    rm -rf tmp/regioni/*
}

### FUNZIONE PER CREARE IL FILE DELL'ITALIA ##
italia()
{
    if [ "$PBF" ] ; then
        java -Xmx2500M -jar splitter-r180/splitter.jar --overlap=2000 italy.osm.$EXT
    else
        java -Xmx2500M -jar splitter-r180/splitter.jar --overlap=2000 italy.osm
    fi

    #crea la mappa con lo stile gfoss
    if [ "$ITALY" ] ; then  
        #nome della mappa
        serie="Mappa italiana creata da ital.img"
        cd tmp/italia
        #crea il file img
        java -Xmx2000M -jar ../../mkgmap-r1995/mkgmap.jar --style-file=$style_it --net --route --latin1 --country-name="$name" --country-abbr="$abbr" --draw-priority=$priority --add-pois-to-areas --series-name="$serie" ../../6*.osm.pbf  #--style-file=$style
        java -Xmx1000M -jar ../../mkgmap-r1995/mkgmap.jar --gmapsupp *.img
        tar -cf ../../output_img/italia.tar gmapsupp.img ../../README_data.txt 
        gzip -9 -f ../../output_img/italia.tar
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
        java -Xmx1000M -jar ../../mkgmap-r1995/mkgmap.jar  --style-file=$style_escu --check-roundabouts --route --latin1 --country-name="$name" --country-abbr="$abbr" --draw-priority=$priority --add-pois-to-areas --series-name="$serie" --ignore-maxspeeds --ignore-turn-restrictions  ../../6*.osm.pbf #--style-file=$style
        java -Xmx1000M -jar ../../mkgmap-r1995/mkgmap.jar --gmapsupp ../../openmtbmap_it_srtm/*.img *img
        #comprime il file
        tar -cf ../../output_img/italia_escursionismo.tar gmapsupp.img ../../README_data.txt 
        gzip -9 -f ../../output_img/italia_escursionismo.tar
        cd ../../
        rm -rf tmp/italia_escu/*
    fi
    rm -f 6*.pbf
}

##### SCRIP VERO E PROPRIO #####

### INIZIO CODICE PRESO DA g.extension di GRASS GIS 6.4 copyrigth di Markus Neteler
#controlla la presenza di bzcat
if [ ! -x "`which bzcat`" ] ; then
    echo "Il programma 'wget' è richiesto. Installatelo per far funzionare ital.img"
    exit 1
fi
#controlla la presenza di tar
if [ ! -x "`which tar`" ] ; then
    echo "Il programma 'tar' è richiesto. Installatelo per far funzionare ital.img."
    exit 1
fi
#controlla la presenza di bzip
if [ ! -x "`which gzip`" ] ; then
    echo "Il programma 'tar' è richiesto. Installatelo per far funzionare ital.img."
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
while getopts "R:riehdpf" Opzione
do
    case $Opzione in
	#opzione per creare tutte le regioni
	r ) REGIONS=1;;
	#opzione per creare l'italia stile gfoss
	i ) ITALY=1;;
	#opzione per creare l'italia stile escursionismo
	e ) HIKING=1;;
	#opzione per stampare l'help
	h ) usage; exit;;
	#opzione per eliminare il file originale
	d ) REMOVE=1;;
        #opzione per non scaricare il file
        f ) DOWN=false;;
        #scarica file pbf invece che bz2
        p ) PBF=1;;
	#opzione per creare una singola regione
	R ) if [ -n $OPTARG ] ; then 
		#nome della regione
		NAMEREG=$OPTARG 
		#variabile che serve per controllare se il nome della regione ha un file poly corrispondente, di defaul false
		REGION=false
		#per tutti i file poly trovati nella cartella poly
		for i in `ls -1 poly/ | cut -d'.' -f'1' | tr '\n' ' '`; do 
		    #se il nome della regione scelta combacia con il nome considerato nel ciclo setta REGION a true e ferma il ciclo
		    if [ "$NAMEREG" = "$i" ] ; then 
			REGION=true; 
			break
		    fi 
		done 
		#se a fine ciclo REGION è ancora false restituisce un errore
		if [ "$REGION" != true ] ; then 
		    echo "Regione non trovata, controllate le regioni accettate lanciando `basename $0` senza parametri"; 
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
        bzcat italy.osm.bz2 > italy.osm
    fi
fi

#crea i file delle regioni
if [ "$REGIONS" ] ; then
    #crea i file per le regioni
    regioni
    #sposta i file da scaricare
    mv -f output_img/*.osm.* output_osm_regioni/

fi
#crea il file della regione
if [ "$REGION" = true ] ; then
    #crea i file per le regioni
    regione
    #sposta i file da scaricare
    mv -f output_img/*.osm.* output_osm_regioni/
fi
#crea il file dell'italia
if [ "$ITALY" ] || [ "$HIKING" ] ; then
    #crea i file per l'italia
    italia
fi

#rimuove file originale
if [ "$REMOVE" = true ] ; then
    #controlla se il file è pbf o bz2
    if [ ! "$PBF" ] ; then
        rm -f italy.osm.bz2 italy.osm
    else
        rm -f italy.osm.pbf
    fi
fi
