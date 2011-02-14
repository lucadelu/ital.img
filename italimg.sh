#!/bin/bash
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



#####VARIABILI DA SETTARE#####
#nome della zona rappresentata default italy
name="Italia"
#abbreviazione della zona
abbr="IT"
#nome dello style
style_it="../resources/styles/gfoss"
style_escu="../resources/styles/hiking"
style="../../../resources/styles/gfoss"

#nome della mappa
serie="Italia creata da ital.img"
#assegna il livello della mappa se sul dispositivo sono presenti più mappe
priority="10"


### CREA I FILE DELLE REGIONI ##
function regioni {

  # si sposta nella cartella di osmosis per divedere il file dell'italia in base alle regioni
  cd osmosis/bin/
  # per ogni file poly della regione crea un file osm dell regione
  for NAME in $(find ../../italia_poly/*.poly -type f)
  do
	  nomepoly=`echo "$NAME" | cut -d'/' -f4`
	  nome=`echo "$nomepoly" | cut -d'.' -f1`
	  # divide il file dell'italia in quello delle regioni
	  ./osmosis --read-xml file="../../italy.osm" --bounding-polygon file="$NAME" --write-xml file="../../regioni/$nome.osm"
  done
  cd ../../
  cd regioni/
  #crea il file .img per ogni regione
  for NAME_REG in $(find *.osm -type f)
  do
	  #assegna il nome e crea la directory per il file diviso
	  nome_reg=`echo "$NAME_REG" | cut -d'.' -f1`
	  mkdir $nome_reg
	  cd $nome_reg
	  #divide il file osm della regione se troppo grande
	  java -Xmx1000M -jar ../../splitter.jar --overlap=2500 ../$NAME_REG 
	  #per tutti i file della regione che trova
	  for NAME in $(find *.osm.gz -type f)
	  do
		  gzip -d $NAME
		  nome=`echo "$NAME" | cut -d'.' -f1`
		  #crea la stringa del nome
		  filename=regioni/${nome_reg}/${nome}/${nome}.img" "
		  #crea la stringa per poi unire i singoli file della regione
		  stringa=${stringa}${filename}
		  serie_reg="Mappa di $nome_reg creata da ital.img"
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
  done

  cd ..
}

### CREA IL FILE DELL'ITALIA ##

function italia {
    #divide il file osm, se si cambia regione ricordarsi di cambiare il nome
    java -Xmx1000M -jar splitter.jar --overlap=2000 italy.osm
    #crea il file .img dei singoli pezzi dell'italia
    for NAME in $(find *.osm.gz -type f)
    do
	    gzip -d $NAME
	    nome=`echo "$NAME" | cut -d'.' -f1`
	    filename=${nome}/${nome}.img" "
	    stringa=${stringa}${filename} 
	    mkdir $nome
	    cd $nome
	    java -Xmx1000M -jar ../mkgmap.jar --style-file=$style_it --net --route --latin1 --country-name="$name" --country-abbr="$abbr" --draw-priority=$priority --add-pois-to-areas --series-name="$serie" ../$nome.osm  #--style-file=$style
	    cd ..

	    #CREA LO STILE ESCURSIONISTICO
	    nome_escu=$nome"_escu"
	    filename_escu=${nome_escu}/${nome}.img" "
	    stringa_escu=${stringa_escu}${filename_escu} 
	    mkdir $nome_escu
	    cd $nome_escu
	    java -Xmx1000M -jar ../mkgmap.jar  --style-file=$style_escu --check-roundabouts --route --latin1 --country-name="$name" --country-abbr="$abbr" --draw-priority=$priority --add-pois-to-areas --series-name="$serie" --ignore-maxspeeds --ignore-turn-restrictions  ../$nome.osm #--style-file=$style
	    cd ..
    done

    echo $stringa
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

##### SCRIP #####
# scarica i dati dell'italia, per altri stati basta cambiare il path, ricordarsi di cambiare anche il bzip e il comando dopo per lo splitt
wget -c http://download.geofabrik.de/osm/europe/italy.osm.bz2 
# estrae i dati, se si cambia regione ricordarsi di cambiare il nome
#bzip2 -f -d italy.osm.bz2 &> /dev/null 
bzcat italy.osm.bz2 > italy.osm

#crea i file per le regioni
regioni
#crea i file per l'italia
italia

#sposta i file da scaricare
mv -f output_img/*.osm.* output_osm_regioni/
#rimuove tutti i file non più utili
rm -rf *.bz
rm -rf 632400*
rm -rf *.img 
rm -rf *.IMG 
rm -rf *.osm
rm -rf regioni/*
 
