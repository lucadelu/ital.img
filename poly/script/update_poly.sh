#!/bin/bash

for i in `ls -1 *.poly`; do
  mv $i ${i}_old
done


for i in abruzzo apulia basilicata calabria campania emilia-romagna friuli-venezia_giulia lazio liguria lombardia marche molise piemonte sardegna sicily toscana trentino-alto_adige umbria valle_d_aosta veneto; do 

  wget -c http://downloads.cloudmade.com/europe/southern_europe/italy/${i}/${i}.poly;

  if [ "$i" = "apulia" ] ; then
    mv ${i}.poly puglia.poly
  fi

  if [ "$i" = "sicily" ] ; then
    mv ${i}.poly sicilia.poly
  fi

done

