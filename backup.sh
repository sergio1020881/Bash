#!/bin/bash
#author: sergio manuel salazar dos santos
#sergio.salazar.santos@gmail.com
#mobile: 916919898
#CVS: $Header$
#help improving is always welcome
#####################################################################
shopt -s -o nounset
#Global declaraions
declare -rx SCRIPT=${0##*/}
#Sanity check
if test -z "$BASH"; #-z
then
	printf "$SCRIPT please run this script with the BASH shell"
	exit 192
fi
RED=1
GREEN=2
echo "$(tput setaf $GREEN)-------------------------------------------------------------------------- $(tput sgr0)"
#preset
IFS_OLD=$IFS
IFS=$'\0'
#function exit on interrupt catch
control_c()
{
	#Cleanup
	IFS=$IFS_OLD
	exit #all is well
}
TIMESTAMP=$(date +%Y:%m:%d-%H:%M:%S)
echo "$(tput setaf $GREEN)INICIO $TIMESTAMP $(tput sgr0)"
echo "$(tput setaf $GREEN)-------------------------------------------------------------------------- $(tput sgr0)"
#filter
if (( $# < 3 || $# > 3 )); 
then
	echo "Usage: $0 SOURCE EXTENSION LOCATION"
	echo "PARAMETER MISSING !!!"
	exit
else
	echo "Entry: $0 $1 $2 $3"
fi
###################################USAGE#########################################
#example: backup.sh . txt ~							#
#example: backup.sh ~ pdf "/media/workspace/Hard Disk"				#
###################################USAGE#########################################
#INIC VAR
TERMDIR=$(pwd)
SOURCEVAR="$1"
if [[ $SOURCEVAR == . ]];
then
	SOURCE=$TERMDIR
	echo "---------------$SOURCE---------------"
else
	if [[ $SOURCEVAR == .. ]];
	then
		SOURCE=${TERMDIR%/*}
		echo "---------------$SOURCE---------------"
	else
		SOURCE=$SOURCEVAR
		echo "---------------$SOURCE---------------"
	fi
fi
FOLDER=${SOURCE##*/}
echo -n "Folder = $SOURCE"
#
if [[ ! -d $SOURCE ]];
then
	echo " Folder «$SOURCE» does not exist!"
	exit
else
	echo " Confirmed «$FOLDER»"
fi
#
EXTVAR=$2
extension=${EXTVAR##*.}
#echo "Typefile = $extension"
echo -n "Extension = $EXTVAR"
echo " Confirmed «$extension»"
#
LOCATIONVAR="$3";
if [[ $LOCATIONVAR == . ]];
then
	LOCATION=$TERMDIR
	echo "---------------$LOCATION---------------"
else
	if [[ $LOCATIONVAR == .. ]];
	then
		LOCATION=${TERMDIR%/*}
		echo "---------------$LOCATION---------------"
	else
		LOCATION=$LOCATIONVAR
		echo "---------------$LOCATION---------------"
	fi
fi
FOLDER=${LOCATION##*/}
echo -n "Folder = $LOCATION"
#
if [[ ! -d $LOCATION ]];
then
	echo " Folder «$LOCATION» does not exist!"
	exit
else
	echo " Confirmed «$FOLDER»"
fi
##
trap control_c SIGINT
##
echo "At $TIMESTAMP backup $extension files"
echo "Source $SOURCE"
echo "Detination $LOCATION"
#####make sure youwant to proceed
read -p "Press [Enter] key to start"
#
echo "CYCLE START"

LOCATIONPATH="$LOCATION/${extension^^}ALL"
mkdir -pv "$LOCATIONPATH"
find "$SOURCE" -iname "*.$extension" -type f -print0 | xargs -0 cp --verbose --update --target-directory="$LOCATIONPATH"

echo "CYCLE END"
TIMESTAMP=$(date +%Y:%m:%d-%H:%M:%S)
#Cleanup
IFS=$IFS_OLD
exit #all is well
