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
$NO_ARG=0
###  FUNZIONE PER L'HELP ##
usage()
{
  echo "Utilizzo: `basename $0` file.osm.bz2 "

}
#controlla se non ci sono parametri ed stampa l'help
if [ $# -eq "$NO_ARG" ] 
then
    usage
    exit 
fi

file_in=$1;
name_nation=`echo $1 | cut -d'.' -f'1';`


#####VARIABILI DA SETTARE#####
#nome della zona rappresentata 
name=$name_nation
#abbreviazione della zona
#abbr="IT"
#nome dello style
style_it="../resources/styles/gfoss"
style="../../../resources/styles/gfoss"

#nome della mappa
serie=${name_nation}" creata da ital.img"
#assegna il livello della mappa se sul dispositivo sono presenti più mappe
priority="10"

##### SCRIP #####
bzcat $file_in > ${name_nation}.osm

### CREA IL FILE DELLA NAZIONE ###
#divide il file osm, se si cambia regione ricordarsi di cambiare il nome
java -Xmx1000M -jar splitter.jar --overlap=2000 ${name_nation}.osm
#crea il file .img dei singoli pezzi della nazione
for NAME in $(find *.osm.gz -type f)
do
        gzip -d $NAME
        nome=`echo "$NAME" | cut -d'.' -f1`
        filename=${nome}/${nome}.img" "
        stringa=${stringa}${filename} 
        mkdir $nome
        cd $nome
        java -Xmx1000M -jar ../mkgmap.jar --style-file=$style_it --net --route --latin1 --country-name="$name" --draw-priority=$priority --add-pois-to-areas --series-name="$serie" ../$nome.osm  #--style-file=$style
        cd ..

done

echo $stringa
#unisce tutti i file in un unico file della nazione
java -Xmx1000M -jar mkgmap.jar --gmapsupp $stringa 
#comprime il file
tar -cf ${name_nation}.tar gmapsupp.img README_gfoss.txt 
gzip -9 -f ${name_nation}.tar

#rimuove tutti i file non più utili
rm -rf 632400*
rm -rf *.img 
rm -rf *.IMG 
rm -rf *.osm
rm -rf regioni/*
 
