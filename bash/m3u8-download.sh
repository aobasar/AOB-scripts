#!/bin/bash
# m3u8-download.sh
# Ahmet O. Basar
# 23:08 PM 5/3/2020 
# This script downloads m3u8 files and makes them into a single mp4 file. 

url=$1
outputfile=$2
clear
if [ $# -ne 2 ]
then
    echo 'Usage: m3u8-download.sh "fullurl.m3u8" "outputfile.mp4"'
    exit 1
fi

echo "m3u8 downloader - aobasar"
echo "_________________________________________________________"
echo " "
dt=$(date '+%d/%m/%Y %H:%M:%S');
echo "$dt"
echo " "
echo "m3u8 file download started."
echo " "
echo ffmpeg -loglevel error -hide_banner -nostats "'$url'" -c copy -bsf:a aac_adtstoasc "'$outputfile'"
ffmpeg -loglevel error -hide_banner -nostats -i $url -c copy -bsf:a aac_adtstoasc $outputfile
#ffmpeg -i $url -c copy -bsf:a aac_adtstoasc $outputfile
echo " "
echo "_________________________________________________________"
echo "$dt"
echo " "
echo "congrast! file downloaded $outputfile"
echo " "
