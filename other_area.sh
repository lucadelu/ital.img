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

# For large area 10GB could be not enough
: ${XMX:=8000M}

NO_ARG=0
#percorso al directory di lavoro
#bisogna lanciare il comando dalla directory di italimg.sh
MYPATH=`pwd`
###  FUNZIONE PER L'HELP ##
usage()
{
  echo "Utilizzo: `basename $0` opzioni file.osm.bz2/pbf

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

if [ $# -eq "1" ]
then
  file_in=$1;
  name_nation=`echo $1 | cut -d'.' -f'1' | rev | cut -d"/" -f"1" | rev;`
elif [ $# -eq "2" ]
then
  file_in=$2;
  name_nation=`echo $2 | cut -d'.' -f'1' | rev | cut -d"/" -f"1" | rev;`
fi

#####VARIABILI DA SETTARE#####
#nome della zona rappresentata
name=$name_nation
#abbreviazione della zona
#abbr="IT"
#nome dello style
style_it="styles/gfoss"
style_escu="styles/hiking"
mkgmap="mkgmap-r4916"
splitter="splitter-r653"
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
  java -Xmx${XMX} -jar ${MYPATH}/${splitter}/splitter.jar --max-areas=4096 --max-nodes=3000000 --wanted-admin-level=8 --geonames-file=cities15000.txt ${name_nation}.osm
else
  java -Xmx${XMX} -jar ${MYPATH}/${splitter}/splitter.jar --max-areas=4096 --max-nodes=3000000 --wanted-admin-level=8 --geonames-file=cities15000.txt $file_in
fi
#crea il file img

java -Xmx${XMX} -jar ${MYPATH}/${mkgmap}/mkgmap.jar \
    --style-file=$style_it \
    --latin1 \
    --country-name=Italia \
    --country-abbr="$name_nation" \
    --region-name="$name_nation" \
    --area-name="$name_nation" \
    --family-name="OpenStreetMap: $name_nation" \
    --description="$name_nation" \
    --precomp-sea=${MYPATH}/sea/ \
    --generate-sea \
    --bounds=${MYPATH}/bounds/ \
    --max-jobs \
    --route \
    --drive-on=detect,right \
    --process-destination \
    --process-exits \
    --location-autofill=is_in,nearest \
    --index \
    --split-name-index \
    --housenumbers \
    --add-pois-to-areas \
    --link-pois-to-ways \
    --preserve-element-order \
    --verbose \
    --name-tag-list=name,name:it,loc_name,reg_name,nat_name \
    --draw-priority=$priority \
    --reduce-point-density=3.2 \
    --make-opposite-cycleways \
    --keep-going \
    --gmapsupp \
    6*.osm.pbf

tar -cf ${MYPATH}/output_img/${name_nation}.tar gmapsupp.img ${MYPATH}/README_data.txt
gzip -9 -f ${MYPATH}/output_img/${name_nation}.tar
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
# rm -rf 632400*
# rm -rf *.img
# rm -rf *.IMG
# rm -rf *.osm
