#!/bin/bash

# This script will download and setup programs
# Dropbox
# Chrome
# Eclipse
# 

program=""
dropbox_ubuntu=""
download_links_file="download_links"
# Defining the different installers for different distribution
ubuntu_autoinstaller="sudo apt-get install "
fedora_autoinstaller="sudo yum install "
debian_autoinstaller="sudo apt-get install "
http_downloads_log_file="installation.log"
# Defining the different types of downloadable file formats
# tar
# tar.gz
# tar.bz2
# gzip
# zip
# rpm
# deb
int=0
declare -a programs
declare -a download_links
declare -a ubuntu_download_links # contains the narrowed down list (based on the 'distro' and User preference) of links
declare -a ubunutu_downloads_program_name # Holds an array of names of programs for an item from 'download_links' file
declare -a ubunutu_downloads_installer_type # Holds an array of installer types for an item from 'download_links' file
declare -a ubuntu_executable_name # Holds an array of executable names for an item from 'download_links' file
declare -a ubunutu_installer_location # Holds an array of locations (for 'http' type) or names (for 'auto-installer' type) for an item from 'download_links' file
num_of_programs_to_install=0
user_requested_program_count=0
temp_downloads_dir="/tmp/boxsetup/downloads_dir/"
temp_extract_dir="/tmp/boxsetup/extract_dir/"
program_install_dir="/opt/"
extracted_dir_name=""
app_bin_dir="/usr/bin/"



# Check if the input text file was provided as option param;
# Else use the default file in the current location
if [[ -z $1 ]]; 
then
	inputfile="program.txt"
else
	inputfile=$1
fi

shopt -s nocasematch 

# The set_dir function checks if a directory exists, 
#if it doesnt exist, it creates
function set_dir {
	if [ ! -d "$1" ]
		then
		echo "Directory did not exist, creating new directory $1"
		mkdir -p $1
	fi
}

# Read the input file
# Obtain the program names as 'programs' Array, size of array is 'int'
function readProgramfile {
	echo "--------------------------------------"
	echo "	Reading the programs for installation from '$1'"
	local int=0

	old_IFS=$IFS
	IFS=$'\n'
	lines=($(cat $1)) # returns each line as an array
	IFS=$old_IFS
	echo "The following programs will be installed for $linuxDistro"
	for each_line in ${lines[@]}
	do
		programs[ int ]=$each_line
		echo ${programs[int]}
		int=$((int+1))
	done 
	user_requested_program_count=$int
}

# Function to print all of the required programs
function printAllPrograms {
	for program in ${programs[@]}
	do
		echo "Program name: $program"
	done
}



function readDownloadLinksFile {
	echo "--------------------------------------"
	echo "	Parsing the download links file '$download_links_file'"
	old_IFS=$IFS
	IFS=$'\n'
	local int=0
	while read -r line
	do
		#download_links=$line 
		download_links[ $int ]=$line
		int=$((int+1))
		
	done < "$download_links_file" 
	IFS=$old_IFS # Reset the field separator variable 'IFS'
	echo "Succesfully obtained information about ${int} installers."
	# Enable the below for debugging
	# for downloadsEntry in ${download_links[@]}
	# do
	# echo $downloadsEntry
	# done
}

function get_ubuntu_downloads_list {
	
	local counter=0
	local distro=""
	local program_name=""
	echo "Getting the list of programs for Ubuntu..."
	
	#declare -a download_links
	#download_links=$1
	#echo ${download_links[@]}
	for downloadsEntry in ${download_links[@]}
	do
		distro=$(echo $downloadsEntry | awk -F':==:' {'print $1'})
		program_name=$(echo $downloadsEntry | awk -F':==:' {'print $2'})
		for program in ${programs[@]}
		do
			if [[ "${distro}" == "ubuntu" ]] && [[ "${program_name}" == "${program}" ]]
			then
				ubuntu_download_links[ counter ]=${downloadsEntry}
				echo "Found entry for program: ${program_name} ,for distro: ${distro};"
				counter=$((counter+1))
			fi
		done
	done

	echo "Found '${counter}' programs for Ubuntu."
	# Enable the below for debugging
	#for ubuntu_entry in ${ubuntu_download_links[@]}
	#do
	#	echo $ubuntu_entry
	#done
	#echo "wget $programs"
}

function get_ubuntu_install_details {
	echo "Getting install details for Ubuntu"
	echo "wget ${programs[@]}"
	local installer_type=""
	local executable_name=""
	local program_name=""
	local installer_location=""
	local counter=0
	echo "INSTALLING THE FOLLOWING PROGRAMS:"
	for ubuntu_entry in ${ubuntu_download_links[@]}
	do
		program_name=$(echo $ubuntu_entry | awk -F':==:' {'print $2'})
		installer_type=$(echo $ubuntu_entry | awk -F':==:' {'print $3'})
		executable_name=$(echo $ubuntu_entry | awk -F':==:' {'print $4'})
		installer_location=$(echo $ubuntu_entry | awk -F':==:' {'print $5'})

		ubunutu_downloads_program_name[counter]="${program_name}"
		ubunutu_downloads_installer_type[counter]="${installer_type}"
		ubuntu_executable_name[counter]="${executable_name}"
		ubunutu_installer_location[counter]="${installer_location}"
	echo " 			program: ${ubunutu_downloads_program_name[counter]}	
 			installer: ${ubunutu_downloads_installer_type[counter]}	
 			executable name: ${ubuntu_executable_name[counter]}
 			installer location: ${ubunutu_installer_location[counter]}"
		counter=$((counter+1))
	done
	num_of_programs_to_install=$counter
}

function ubuntu_auto_install {
	echo "Installing applications for Ubuntu using '${ubuntu_autoinstaller} $1'"
	sh echo ${ubuntu_autoinstaller} $1 # Must remove the 'echo' to ensure proper command.
	if [[ $? ]]
	then
		echo "Installed chrome Succesfully."
	else
		echo "Some exception occured while trying to install '$1'"
		exit -1
	fi
}

function make_program_cli_accessible {
	# Function to add a soft-link to the program's executable bin/jar/sh
	# Note: auto installed programs DO NOT call this function

	# ln -s $target_name $link_name --target-directory="/usr/bin/"
	echo "Creating a symbolic link for program access."
	echo "${program_install_dir}"
	echo "${1}"
	echo "${2}"
	echo "${app_bin_dir}"
	ln -s "${2}"
	mv ${1} "${app_bin_dir}"
#--target-directory="${app_bin_dir}"
}

function create_desktop_icon {
	local shortcut_name="$1"
	local executable_location="${3}"
	echo "Creating a Desktop shortcut for the Program."
	
	# Function to create a desktop icon for the program
	# Note: auto installed programs DO NOT call this function
	#
	#
	# #!/bin/bash
	# variabl_inside="local var"
	# #desktop_loc="${HOME}/Desktop/"
	# desktop_loc="${HOME}/"
	# desktop_shortcut_name="Sublime.desktop"
	# echo "
	#       This is
	#       What that
	#       needs to go
	#       in the other file and this ${variabl_inside}" >$desktop_loc$desktop_shortcut_name
	# echo "Done!"

}

function http_wget_download {
	# param 1 -> program name; param 2 -> program URI; param 3 -> executable name
	local executable_location

	echo "Downloading files for '$1' from '$2'"
	echo "Files will be downloaded to the directory: ${temp_downloads_dir}."
	wget --restrict-file-names=unix -P ${temp_downloads_dir} -da ${http_downloads_log_file}_$1 -nc $2
	# TODO extract
	#exit 0;
	/bin/bash extract_installer.sh  "${temp_downloads_dir}*" "${temp_extract_dir}"
	if [[ $? ]]
		then
			echo "Succesfully extracted $1 to $temp_extract_dir"
		else
			echo "Some exception occured. Please check the log files."
			exit -1
		fi
	# TODO remove downloaded dirs/files
	# rm -rf "${temp_downloads_dir}/*"

	# TODO get the directory name into a var and use it for refernce
	extracted_dir_name="$(ls -1 ${temp_extract_dir})"
	echo "'$1' has been extracted to directory: '$extracted_dir_name'"
	# TODO move extracted files to /opt or user defined directory
	mv "${temp_extract_dir}"* "${program_install_dir}"
	# TODO call the make_program_cli_accessible function to make a symbolic link to the program's executable
	# provide the extracted directory name and the executable name to the function
	executable_location="${program_install_dir}${extracted_dir_name}/${3}"

	make_program_cli_accessible "${3}" "${executable_location}"
	create_desktop_icon "$3" "${executable_location}"

}

function ubuntu_install {
	echo "Installing Programs : ${num_of_programs_to_install}."
	local i=0
	while [[ $i -lt $num_of_programs_to_install ]]
	do
		echo "${ubunutu_downloads_program_name[i]}, ${ubunutu_downloads_installer_type[i]}, ${ubunutu_installer_location[i]}"
		if [[ ${ubunutu_downloads_installer_type[i]} == http ]]
		then
			# Type is 'http': Call the http_wget_download function to download, extract and install the program
			http_wget_download "${ubunutu_downloads_program_name[i]}" "${ubunutu_installer_location[i]}" "${ubuntu_executable_name[i]}"
		elif [[ ${ubunutu_downloads_installer_type[i]} == auto ]]
		then
			# Type is 'auto': Call the http_wget_download function to use the default package manager to download and install the program
			ubuntu_auto_install ${ubunutu_installer_location[i]}
		else
			echo "Unknown Installer type encountered, please check the installation file."
			exit -1
		fi
		i=$((i+1))
	done
}

# No Function calls should be defined below this, to provide clarity.
echo "STARTING THE SCRIPT..."
# Get the Distribution type from the User
echo "Enter the Linux Distribution type[ UBUNTU|RHEL|DEBIAN ] :"
#read linuxDistro
linuxDistro="ubuntu"
echo "User entered: '$linuxDistro'"
echo "Enter the location for the programs to be installed :"
#read program_install_dir
#program_install_dir="tempdir/" #hardcoded temporary location
# if the directory doesnt exist, create one
set_dir "$program_install_dir"

readProgramfile $inputfile
readDownloadLinksFile

#echo ${download_links[@]}
#printAllPrograms

if [[ $linuxDistro == "ubuntu" ]];
	then
		get_ubuntu_downloads_list ${download_links[@]}
		#ensure that only the required programs are selected...
		get_ubuntu_install_details
		echo "*****************"
		echo "Obtained the programs to install and their install/download details from the respective files."
		echo "now selecting the type of installer/downloader to use"
		echo "Creating an installation directory at '${temp_downloads_dir}' "
		set_dir ${temp_downloads_dir}
		set_dir ${temp_extract_dir}
		ubuntu_install
fi
shopt -u nocasematch
