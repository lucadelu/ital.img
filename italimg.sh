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
### VARIABILI CHE POSSONO ESSERE MODIFICATE ##
#nome della zona rappresentata default italy
name="Italia"
#abbreviazione della zona
abbr="IT"
#nome dello style
style_it="../resources/styles/gfoss"
style_escu="../resources/styles/hiking"
style="../../../resources/styles/gfoss"

#assegna il livello della mappa se sul dispositivo sono presenti più mappe
priority="10"

###  FUNZIONE PER L'HELP ##
usage()
{
  echo "Utilizzo: `basename $0` opzioni 

Opzioni:
    -r		crea i file regionali
    -i		crea il file dell'Italia
    -e		crea il file dell'Italia con stile per escursionisti
    -h		visualizza questa schermata
"
#     -R	nome	crea il file della regione scelta ATTENZIONE OPZIONE ANCORA DA TESTARE
# 
# Regioni accettate:
#
# ls -1 poly/ | cut -d'.' -f'1' | tr '\n' ' '
# echo "\n"
#   "
}

### FUNZIONE PER CREARE I FILE DI TUTTE REGIONI ##
regioni()
{
    #si sposta nella cartella di osmosis per divedere il file dell'italia in base alle regioni
    cd osmosis/bin/
    #per ogni file poly della regione crea un file osm dell regione
    for NAME in $(find ../../poly/*.poly -type f)
    do
	#estrapola il nome del file poly
	#nomepoly=`echo "$NAME" | cut -d'/' -f4` SE FUNGE QUESTA RIGA È DA RIMUOVERE
	nome=`basename $nomepoly .poly`
	#divide il file dell'italia in quello delle regioni
	./osmosis --read-xml file="../../italy.osm" --bounding-polygon file="$NAME" --write-xml file="../../regioni/$nome.osm"
    done
    #si sposta nella cartella regioni dove sono stati creati i file osm
    cd ../../
    cd regioni/
    #crea il file .img per ogni regione
    for NAME_REG in $(find *.osm -type f)
    do
	#assegna il nome e crea la directory per il file diviso
	nome_reg=`echo "$NAME_REG" | cut -d'.' -f1`
	#crea ed entra dentro la cartella
	mkdir $nome_reg
	cd $nome_reg
	#divide il file osm della regione se troppo grande
	java -Xmx1000M -jar ../../splitter.jar --overlap=2500 ../$NAME_REG 
	#per tutti i file della regione che trova
	for NAME in $(find *.osm.gz -type f)
	do
	    #decomprime il file
	    gzip -d $NAME
	    nome=`echo "$NAME" | cut -d'.' -f1`
	    #crea la stringa del nome
	    filename=regioni/${nome_reg}/${nome}/${nome}.img" "
	    #crea la stringa per poi unire i singoli file della regione
	    stringa=${stringa}${filename}
	    #imposta il nome della mappa
	    serie_reg="Mappa della regione $nome_reg creata da ital.img"
	    #crea ed entra nella directory
	    mkdir $nome
	    cd $nome
	    #crea il file img
	    java -Xmx1000M -jar ../../../mkgmap.jar --style-file=$style --net --route --latin1 --country-name="$nome" --draw-priority=$priority --add-pois-to-areas --series-name="$serie_reg" ../$nome.osm 
	    cd ..
	done
	#torna alla directory di partenza
	cd ../../
	#unisce tutti i file
	java -Xmx1000M -jar mkgmap.jar --gmapsupp $stringa
	#crea il file tar.gz da scaricare e lo comprime
	tar -cf output_img/${nome_reg}.tar gmapsupp.img README_data.txt 
	gzip -9 -f output_img/${nome_reg}.tar
	#rimuove i singoli file
	rm gmapsupp.img
	unset stringa
	#comprime il file osm e lo mette nella cartella download
	cd regioni/
	bzip2 $nome_reg.osm
	mv $nome_reg.osm.bz2 ../output_img/
    done
    cd ..
}

### FUNZIONE PER CREARE IL FILE DI UNA REGIONE ##
regione()
{
    #si sposta nella cartella di osmosis per divedere il file dell'italia in base alle regione
    cd osmosis/bin/
    $NAMEREG_poly="../../poly/$NAMEREG.poly"
    nome=$NAMEREG
    #divide il file dell'italia in quello delle regioni
    ./osmosis --read-xml file="../../italy.osm" --bounding-polygon file="$NAMEREG_poly" --write-xml file="../../regioni/$nome.osm"  
    #si sposta nella cartella regioni
    cd ../../
    cd regioni/
    #crea e si sposta nella cartella della ragione
    mkdir $nome
    cd $nome
    #divide il file osm della regione se troppo grande
    java -Xmx1000M -jar ../../splitter.jar --overlap=2500 ../${nome}.osm
    #per tutti i file della regione che trova
    for NAME in $(find *.osm.gz -type f)
    do
	#decomprime i file
	gzip -d $NAME
	nome=`echo "$NAME" | cut -d'.' -f1`
	#crea la stringa del nome
	filename=regioni/${nome_reg}/${nome}/${nome}.img" "
	#crea la stringa per poi unire i singoli file della regione
	stringa=${stringa}${filename}
	#imposta il nome della mappa
	serie_reg="Mappa della regione $nome_reg creata da ital.img"
	#crea la directory e il file
	mkdir $nome
	cd $nome
	java -Xmx1000M -jar ../../../mkgmap.jar --style-file=$style --net --route --latin1 --country-name="$nome" --draw-priority=$priority --add-pois-to-areas --series-name="$serie_reg" ../$nome.osm 
	cd ..
    done
    #torna alla directory di partenza
    cd ../../
    #unisce tutti i file
    #./sendmap20 -l $stringa
    java -Xmx1000M -jar mkgmap.jar --gmapsupp $stringa
    #crea il file tar.gz da scaricare
    tar -cf output_img/${nome_reg}.tar gmapsupp.img README_data.txt 
    gzip -9 -f output_img/${nome_reg}.tar
    #rimuove i singoli file
    rm gmapsupp.img
    unset stringa
    #comprime il file osm e lo mette nella cartella download
    cd regioni/
    bzip2 $nome_reg.osm
    mv $nome_reg.osm.bz2 ../output_img/
    cd ..
}

### FUNZIONE PER CREARE IL FILE DELL'ITALIA ##
italia()
{
    #divide il file osm, se si cambia regione ricordarsi di cambiare il nome
    java -Xmx1000M -jar splitter.jar --overlap=2000 italy.osm
    #crea il file .img dei singoli pezzi dell'italia
    for NAME in $(find *.osm.gz -type f)
    do
	#nome del file osm considerato
	nome=`echo "$NAME" | cut -d'.' -f1`
	#crea la mappa con lo stile gfoss
	if [[ $ITALY == true ]]
	then  
	    #nome della mappa
	    serie="Mappa italiana creata da ital.img"
	    #decomprima il file
	    gzip -d $NAME
	    #crea il nome del file
	    filename=${nome}/${nome}.img" "
	    stringa=${stringa}${filename} 
	    #crea la directory e ci entra
	    mkdir $nome
	    cd $nome
	    #crea il file img
	    java -Xmx1000M -jar ../mkgmap.jar --style-file=$style_it --net --route --latin1 --country-name="$name" --country-abbr="$abbr" --draw-priority=$priority --add-pois-to-areas --series-name="$serie" ../$nome.osm  #--style-file=$style
	    cd ..
	fi
	#crea la mappa con lo stile escursionismo
	if [[ $HIKING == true ]]
	then
	    #nome della mappa
	    serie="Mappa italiana per escursionisti creata da ital.img"
	    #crea il nome e la stringe per l'escursionismo
	    nome_escu=$nome"_escu"
	    filename_escu=${nome_escu}/${nome}.img" "
	    stringa_escu=${stringa_escu}${filename_escu} 
	    #crea la directory ed entra
	    mkdir $nome_escu
	    cd $nome_escu
	    #crea il file img con lo stile escursionismo
	    java -Xmx1000M -jar ../mkgmap.jar  --style-file=$style_escu --check-roundabouts --route --latin1 --country-name="$name" --country-abbr="$abbr" --draw-priority=$priority --add-pois-to-areas --series-name="$serie" --ignore-maxspeeds --ignore-turn-restrictions  ../$nome.osm #--style-file=$style
	    cd ..
	fi
    done
    #echo $stringa
    #unisce tutti i file in un unico file dell'italia
    java -Xmx1000M -jar mkgmap.jar --gmapsupp $stringa 
    #comprime il file
    tar -cf output_img/italia.tar gmapsupp.img README_data.txt 
    gzip -9 -f output_img/italia.tar

    # echo $stringa_escu
    java -Xmx1000M -jar mkgmap.jar --gmapsupp openmtbmap_it_srtm/GMAPSUPP_srtm.IMG $stringa_escu
    #comprime il file
    tar -cf output_img/italia_escursionismo.tar gmapsupp.img README_data.txt 
    gzip -9 -f output_img/italia_escursionismo.tar
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
if [ $# -eq "$NO_ARG" ] 
then
    usage
    exit 
fi

#ciclo per vedere le opzioni scelte
while getopts "R:rieh" Opzione
do
    case $Opzione in
	#opzione per creare tutte le regioni
	r ) REGIONS=true;;
	#opzione per creare l'italia stile gfoss
	i ) ITALY=true;;
	#opzione per creare l'italia stile escursionismo
	e ) HIKING=true;;
	#opzione per stampare l'help
	h ) usage; exit;;
	#opzione per creare una singola regione
	R ) if [ -n $OPTARG ]; then 
		#nome della regione
		NAMEREG=$OPTARG; 
		#variabile che serve per controllare se il nome della regione ha un file poly corrispondente, di defaul false
		REGION=false
		#per tutti i file poly trovati nella cartella poly
		for i in `ls -1 poly/ | cut -d'.' -f'1' | tr '\n' ' '`; do 
		    #se il nome della regione scelta combacia con il nome considerato nel ciclo setta REGION a true e ferma il ciclo
		    if [ "$NAMEREG" = "$i" ]
		    then 
			REGION=true; 
			break
		    fi 
		done 
		#se a fine ciclo REGION è ancora false restituisce un errore
		if [ "$REGION" != true ]
		then 
		    echo "Regione non trovata, controllate le regioni accettate lanciando `basename $0` senza parametri"; 
		fi
            fi;;
    esac
done

#scarica i dati dell'italia, per altri stati basta cambiare il path
#usa wget
if [ "$USE_WGET" ] ; then
    wget --quiet -c http://download.geofabrik.de/osm/europe/italy.osm.bz2 
#usa curl
else 
    curl -silent --location http://download.geofabrik.de/osm/europe/italy.osm.bz2
fi
# estrae i dati, se si cambia regione ricordarsi di cambiare il nome
bzcat italy.osm.bz2 > italy.osm
#crea i file delle regioni
if [ "$REGIONS" = true ]
then
    #crea i file per le regioni
    regioni
    #sposta i file da scaricare
    mv -f output_img/*.osm.* output_osm_regioni/
fi
#crea il file della regione
if [ "$REGION" = true ]
then
    #crea i file per le regioni
    regione
    #sposta i file da scaricare
    mv -f output_img/*.osm.* output_osm_regioni/
fi
#crea il file dell'italia
if [ "$ITALY" = true || "$HIKING" = true ]
then
    #crea i file per l'italia
    italia
fi
#rimuove tutti i file non più utili
rm -rf *.bz
rm -rf 632400*
rm -rf *.img 
rm -rf *.IMG 
rm -rf *.osm
rm -rf regioni/*