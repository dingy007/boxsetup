#!/bin/bash

# This script will download and setup programs
# Dropbox
# Chrome
# Eclipse
# 

program=""
dropbox_ubuntu=""
download_links_file="download_links"

echo "Starting the box setup script."
echo "Enter the Linux Box type:"
#read linux_type
linux_type="ubunTU"



inputfile="$1"
echo $linux_type

while read -r line
do
	program=$line 
	echo "Program name is: $line"
done < "$inputfile"

shopt -s nocasematch 

awk -F':=' '{print $2}' $download_links_file;

function ubuntu {
	echo "Installing programs for UBUNTU"
	echo "wget https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_1.6.2_amd64.deb"
}

function fedora {
	echo "Installing programs for UBUNTU"
}

function debian {
	echo "Installing programs for UBUNTU"
}


if [[ $linux_type == "ubuntu" ]];
	then
	ubuntu
fi
