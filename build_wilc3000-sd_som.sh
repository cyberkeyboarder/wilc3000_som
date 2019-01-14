#!/bin/bash

# ******************************************************************************
# o	Build Script for SOM & WILC3000-SD ---> Buildroot
# ******************************************************************************
#
# o	 Date:		Nov 2018
#
# o	 Target:	SAMA5D27-SOM1-EK1 Development Board ( atsama5d27-som1-ek1 )
# o  Target:    ATWILC3000 SD Card Evaluation Kit   ( AC164158 )
# o  Host:		Linux Ubunutu 16.04.5 LTS	 
# o	 J1:  		Debug header w/ FTDI TTL-232R USB-to-TTL Cable
# o  J11: 		(A5-USB-A) micro-USB to host
# o	 SOURCE:	https://github.com/LeoZhang-ATMEL/buildroot-external-wilc	 
# o  TERMINAL:	minicom 2.7
#
# ******************************************************************************
# o TODO: 
# o 
# ******************************************************************************


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# TERMINAL COLORS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 
# https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux


# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# High Intensity
IBlack='\033[0;90m'       # Black
IRed='\033[0;91m'         # Red
IGreen='\033[0;92m'       # Green
IYellow='\033[0;93m'      # Yellow
IBlue='\033[0;94m'        # Blue
IPurple='\033[0;95m'      # Purple
ICyan='\033[0;96m'        # Cyan
IWhite='\033[0;97m'       # White

# Bold High Intensity
BIBlack='\033[1;90m'      # Black
BIRed='\033[1;91m'        # Red
BIGreen='\033[1;92m'      # Green
BIYellow='\033[1;93m'     # Yellow
BIBlue='\033[1;94m'       # Blue
BIPurple='\033[1;95m'     # Purple
BICyan='\033[1;96m'       # Cyan
BIWhite='\033[1;97m'      # White

# No color
NC='\033[0m' # No Color

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# SYSTEM VARIABLES
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SECONDS=0
ORIG_WORKSPACE=$(pwd)
#BREAKPOINTS=YES
BREAKPOINTS=
unset CROSS_COMPILE
unset ARCH

# TODO: re-evaluate what packages are needed here (see the Dockerfile )

packages=(
	subversion 
	build-essential 
	bison 
	flex 
	gettext 
	libncurses5-dev 
	texinfo 
	autoconf 
	automake 
	libtool 
	mercurial 
	git-core
	gperf 
	gawk 
	expat 
	curl 
	cvs 
	libexpat-dev 
	bzr 
	unzip 
	bc 
	python-dev
	minicom
	sed
    make
    binutils
    gcc
    g++
    bash
    patch
    gzip
    bzip2
    perl
    tar
    cpio
    python
    unzip
    rsync
    file
    wget
)

##
## For development ...
##
function break_point()
{
	# -p: prompt
	# -r: backslash is not an escape char.
	if [ "$BREAKPOINTS" == "YES" ]; then 
		echo
		while true; do
			read -r -p "---> BREAKPOINT:  $1 -- [Y] to continue [Q] to exit  ..." user_input
			case $user_input in
				[Yy]* ) 
					break
					;;
				[Nn]* )
					echo "no"
					;;
				[Qq]* )
					echo; echo "Exiting ..."; echo
					exit 1
					;;
				* ) 
					echo ".. < try again > .."
					;;
			esac
		done
		echo
	fi
}	# END: function break_point()

# ------------------------------------------------------------------------------
# CHECK HOST
# ------------------------------------------------------------------------------

echo  
echo " *** --------------------------------------"
echo " *** WORKSPACE: "
echo " *** --------------------------------------"
echo 
echo "     $ORIG_WORKSPACE "
echo
echo
echo "* Current directory: $ORIG_WORKSPACE"
cat /etc/os-release
echo
cat /etc/lsb-release
echo 
lsb_release --all
echo 
 
 


## lsb_release - print distro-specific info 
## LSB 			- Linux Standard Base 

# ------------------------------------------------------------------------------
# INSTALL PACKAGES
# ------------------------------------------------------------------------------

echo  
echo " *** --------------------------------------"
echo " *** System package (APT) Update ... "
echo " *** --------------------------------------"
echo 
sudo apt update

echo  
echo " *** --------------------------------------"
echo " *** System package (APT) Upgrade ..."
echo " *** --------------------------------------"
echo 
sudo apt --assume-yes upgrade

echo  
echo " *** --------------------------------------"
echo " *** Install missing packages ..."
echo " *** --------------------------------------"
echo 
 
for index in ${!packages[*]}
do
    printf "%4d: %s\n" $index ${packages[$index]}

	dpkg -s ${packages[$index]} &> /dev/null
	if [ $? -eq 0 ]; then
		echo -e "${Yellow}${packages[$index]}${NC}: is installed!"
	else
		echo -e "${BIRed}${packages[$index]}: is missing"; echo -e "${BICyan}"
		sudo apt --assume-yes install ${packages[$index]} ; echo -e "${NC}"
	fi 
	echo 
done
echo

# pip install argparse

 
# ------------------------------------------------------------------------------
# DOWNLOAD & BUILD COMPONENTS of BUILDROOT
# ------------------------------------------------------------------------------

echo  
echo " *** --------------------------------------"
echo " *** GIT BuildRoot AT91 \"linux4sam 6.0\" "
echo " *** --------------------------------------"
echo 

if [ ! -d buildroot-at91 ]; then
	time git clone https://github.com/linux4sam/buildroot-at91.git -b linux4sam_6.0
else
	echo " NOTE:  \"/buildroot-at91\" folder already exists"
	echo
fi
echo
 
echo  
echo " *** --------------------------------------"
echo " *** GIT \"BuildRoot External\" "
echo " *** --------------------------------------"
echo 
if [ ! -d buildroot-external-wilc  ]; then
	time git clone https://github.com/LeoZhang-Atmel/buildroot-external-wilc.git
else
	echo " NOTE:  \"/buildroot-external-wilc\" folder already exists"
	echo
fi
echo
 

echo  
echo " *** --------------------------------------"
echo " *** Building Configuration: "
echo " *** \"sama5d27_som1_ek_wilc_defconfig\" "
echo " *** --------------------------------------"
echo 
 
cd buildroot-at91

BR2_EXTERNAL=../buildroot-external-wilc/ make sama5d27_som1_ek_wilc_defconfig
echo
 

################################################################################################################################################################
break_point "BEFORE  MAKE"
################################################################################################################################################################
 
#
# Note: create (declare) array indexed w/ integers 
# using "declare" to create a variable WITH ATTRIBUTES.
#
# was: time make
	#declare -a make_array=( $( { time make; } 2>&1 >/dev/null ))
	#echo
	#BUILD_TIME=${make_array[-5]}
	#show all 'time' elements: real, user, sys
	# [0]:real 			-6
	# [1]:<real time>	-5 == Fifth last element written out ...
	# [2]: user			-4
	# [3]: <user time>	-3
	# [4]: sys			-2
	# [5]: <sys time>	-1
	#echo ${make_array[*]}
time make


echo  
echo " *** --------------------------------------"
echo " *** POST BUILD: make check "
echo " *** --------------------------------------"
echo 
 
# Noticed: During 'make':
# CAUTION, ....run 'make check'
# ...but compilers are all too often release w/ serious bugs.
# GMP tends to explore interesting corners in compilers & has hit bugs
# on quite a few occasions.
#
# ------------------------------------------------------------------------------
#
# Note: create (declare) array indexed w/ integers 
# using "declare" to create a variable WITH ATTRIBUTES.
#
# was: time make check
	#declare -a make_check_array=( $( { time make check; } 2>&1 >/dev/null ))
	#CHECK_TIME=${make_check_array[-5]}
	#show all 'time' elements: real, user, sys
	# [0]:real 			-6
	# [1]:<real time>	-5 == Fifth last element written out ...
	# [2]: user			-4
	# [3]: <user time>	-3
	# [4]: sys			-2
	# [5]: <sys time>	-1
	#echo ${make_check_array[*]} 
time make check

echo
echo

echo  
echo " *** --------------------------------------"
echo " *** Create uSD card with:  "
echo " *** --------------------------------------"
echo 

echo -e "${BICyan}"
ls $ORIG_WORKSPACE/buildroot-at91/output/images/sdcard.img 
echo -e "${NC}"

echo


# ------------------------------------------------------------------------------
# SECONDS is a bash builtin that tracks # of seconds since shell started
# ------------------------------------------------------------------------------
#
echo " *** --------------------------------------"
echo " *** SCRIPT Stats... "
echo " *** --------------------------------------"
echo

echo "     Total 'MAKE' time:       $BUILD_TIME"
echo "     Total 'MAKE check' time: $CHECK_TIME"

echo
duration=$SECONDS 
# test duration=100

MY_MINUTES=$((duration / 60))
MY_SECONDS=$((duration % 60))
 

echo "     Build Date:              $(date)"
echo "     Total script execution:  $MY_MINUTES" minutes and $MY_SECONDS seconds
echo


