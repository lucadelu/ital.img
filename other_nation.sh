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
NO_ARG=0
#percorso al directory di lavoro
#bisogna lanciare il comando dalla directory di italimg.sh
MYPATH=`pwd`
###  FUNZIONE PER L'HELP ##
usage()
{
  echo "Utilizzo: `basename $0` file.osm.bz2/pbf opzioni

Opzioni:
    -o          osm file not compressed
    -p          usa file pbf
"

}
#controlla se non ci sono parametri ed stampa l'help
if [ $# -eq "$NO_ARG" ] 
then
    usage
    exit
fi

file_in=$1;
name_nation=`echo $1 | cut -d'.' -f'1';`
prefix=`echo ${1##*.}`

#####VARIABILI DA SETTARE#####
#nome della zona rappresentata
name=$name_nation
#abbreviazione della zona
#abbr="IT"
#nome dello style
style_it="../../styles/gfoss"
style_escu="../../styles/hiking"
mkgmap="mkgmap-r2734"
splitter="splitter-r311"
#nome della mappa
serie=${name_nation}" creata da ital.img"
#assegna il livello della mappa se sul dispositivo sono presenti più mappe
priority="10"

##### SCRIP #####
function create()
{
if [ "$EXT" = bz2 ] ; then
  bzcat $file_in > ${name_nation}.osm
fi

### CREA IL FILE DELLA NAZIONE ###
#divide il file osm, se si cambia regione ricordarsi di cambiare il nome
if [ "$EXT" = bz2 -o "$EXT" = osm ] ; then
  java -Xmx2500M -jar $splitter/splitter.jar ${name_nation}.osm
else
  java -Xmx2500M -jar $splitter/splitter.jar $file_in
fi
cd tmp/nations
#crea il file img
java -Xmx2000M -jar ${MYPATH}/$mkgmap/mkgmap.jar --style-file=$style_it --net --route --latin1 --country-name="$name" --country-abbr="$abbr" --draw-priority=$priority --add-pois-to-areas --series-name="$serie" ${MYPATH}/6*.osm.pbf  #--style-file=$style
java -Xmx1000M -jar ${MYPATH}/$mkgmap/mkgmap.jar --gmapsupp *.img
tar -cf ${MYPATH}/output_img/${name_nation}.tar gmapsupp.img ${MYPATH}/README_data.txt
gzip -9 -f ${MYPATH}/output_img/${name_nation}.tar
cd ${MYPATH}
rm -rf tmp/nations/*
}
#ciclo per vedere le opzioni scelte
while getopts ":po" Opzione
do
    case $Opzione in
        #scarica file pbf invece che bz2
        p ) PBF=1;;
        #scarica file pbf invece che bz2
        o ) OSM=1;;        
    esac
done

#controlla se scaricare bz2 o pbf
if [ "$PBF" ] ; then
    EXT=pbf
elif [ "$OSM" ]; then
    EXT=osm
else
    EXT=bz2
fi

echo $EXT

create

#rimuove tutti i file non più utili
rm -rf 632400*
rm -rf *.img 
rm -rf *.IMG 
# rm -rf *.osm
 
