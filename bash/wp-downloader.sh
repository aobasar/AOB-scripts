#!/bin/bash
# WordPress Downloader (Latest version)
# Ahmet O. Basar
# 3:14 PM 1/25/2022"
clear

Title="WP Downloader v0.2"
WordPress_File="latest.zip"
WordPress_Folder="wordpress"
WordPress_Latest_File="https://wordpress.org/latest.zip"

start=$(date +%s)

echo $Title
echo "--------------------------------"
echo " "
echo "👮‍♂️"
read -r -p "Would you like to download WordPress latest.zip? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
        #yes answer
        echo " "
        echo $(date -u) " "
        echo " "
        echo -n "Download started 😄 : "
        if [ -f "$WordPress_File" ] ; then
            rm "$WordPress_File"
        fi
        wget $WordPress_Latest_File
        echo " "
        echo $(date -u) " "
        echo " "
	;;
    [nN]|[qQ])
        #no answer
        echo "Ok, The download has been skipped. 🤔"
	echo " "
        ;;
    *)
        #do_something_else
	echo "😵"
        ;;
esac

echo "👮‍♂️"
read -r -p "Would you like to extract latest.zip [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
        #yes answer
        if [ -d "$WordPress_Folder" ]
        then
            mv $WordPress_Folder $WordPress_Folder.tmp
            rm -rf $WordPress_Folder.tmp &
        fi
        echo " "
        echo "Latest.zip extracting right now, please wait...🧟‍♂️"
        echo " "
        echo $(date -u) " "
        echo " "
        unzip -x -o $WordPress_File | awk 'BEGIN {ORS=" "} {print "⭐"}'
        echo " "
        echo " "
        echo $(date -u) " "
        echo " "
        echo "The process has been completed. 😘"
        echo " "
        ;;
    [nN]|[qQ])
    	echo "Ok, bye!!!👋"
	echo " "
        ;;
    *)
        #do_something_else
    	echo "Ok, bye!!!👋"
        ;;
esac

end=$(date +%s)
echo "Elapsed Time: $(($end-$start)) seconds."
