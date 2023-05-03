#!/bin/bash
# Convert_ISO-8859-9_to_UTF-8.sh
# Convert Turkish ISO-8859-9 characters to UTF8  
# Ahmet O. Basar
# 2:29 PM 1/4/2022

echo "ISO (ISO-8859-9) Converter Started"
echo "___________________________________________________"

for file in *.php

do

	if [ ! -f $file ]; then
		
    echo "File(s) not found. :("
    
    else
        charset="$( file -bi "$file"|awk -F "=" '{print $2}')"

        if [ "$charset" != utf-8 ]; then
          echo -n "file: " ; file -i $file
          iconv -f ISO-8859-9 -t UTF-8 "$file" >"$file.new" &&
          mv -f "$file.new" "$file" &&
          # echo "$file"
          echo -n "✅ updated: " ; file -i $file
        fi
        echo " ";
  fi
        
done
echo "✅ finished" ;
