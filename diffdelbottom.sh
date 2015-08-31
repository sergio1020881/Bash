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
#IFS metacharacter list.
#very impotante this parameter
IFS=$'\0'
#function exit on interrupt catch
control_c()
{
 	TIMESTAMP=$(date +%Y:%m:%d-%H:%M:%S)
	#troubleshooting
	rm $LOCATION/.diffdelog.txt -v
	#
	echo "$(tput setaf $GREEN)Stopped due to Interrupt «ctr-c» $(tput sgr0)"
	echo "$TIMESTAMP stopped" >> "$LOGFILE"
	chmod 444 "$LOGFILE" -v
	#Cleanup
	IFS=$IFS_OLD
	exit #all is well
}
#The main
#GLOBAL VAR
TIMESTAMP=$(date +%Y:%m:%d-%H:%M:%S)
echo "$(tput setaf $GREEN)INICIO $TIMESTAMP $(tput sgr0)"
echo "$(tput setaf $GREEN)-------------------------------------------------------------------------- $(tput sgr0)"
#filter
if (( $# < 3 || $# > 3 )); 
then
	echo "Usage: $0 LOCATION EXTENSION DEPTH"
	echo "PARAMETER MISSING !!!"
	exit
else
	echo "Entry: $0 $1 $2 $3"
fi
###################################USAGE#########################################
#example: diffdel.sh . txt 3							#
#example: diffdel.sh ~ pdf 6							#
###################################USAGE#########################################
#INIC VAR
DIRVAR="$1"
TERMDIR=$(pwd)
if [[ $DIRVAR == . ]];
then
	LOCATION=$TERMDIR
	echo "---------------$LOCATION---------------"
else
	if [[ $DIRVAR == .. ]];
	then
		LOCATION=${TERMDIR%/*}
		echo "---------------$LOCATION---------------"
	else
		LOCATION=$DIRVAR
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
#
EXTVAR=$2
extension=${EXTVAR##*.}
#echo "Typefile = $extension"
echo -n "Extension = $EXTVAR"
echo " Confirmed «$extension»"
#
DEPTHVAR="$3";
echo -n "Depth = $DEPTHVAR"
#
if [[ ! $DEPTHVAR =~ ^[0-9]$ ]];
then
	echo " Arg 2 must be between 0 and 9!"
	exit
else
	echo " Confirmed «$DEPTHVAR»"
fi
#Temporary working file of bash
TEMPLOGFILE="$LOCATION/.diffdelog.txt"
touch $TEMPLOGFILE
chmod 664 $TEMPLOGFILE -v
LOGFOLDER="$HOME/REMOVELOG"
LOGFILE="$LOGFOLDER/remove_$extension.txt"
#testes
if [[ -d $LOGFOLDER ]];
then
	echo -n ""
else
	echo "Creating «$LOGFOLDER»"
	mkdir $LOGFOLDER -v
fi
if [[ -f $LOGFILE ]];
then
	echo "Updating «$LOGFILE»"
	chmod 664 $LOGFILE -v
else
	echo "Creating «$LOGFILE»"
	touch "$LOGFILE"
	chmod 664 $LOGFILE -v
fi
trap control_c SIGINT
#QUANT=$(ls -R | egrep [!.]\*[.]$extension$ | wc -l)
echo "$(tput setaf $RED)At $TIMESTAMP remove duplicate $extension files $(tput sgr0)"
echo "$(tput setaf $RED)Folder $LOCATION with depth of $DEPTHVAR: $(tput sgr0)"
echo "--------------------------------------------------------------------------------" >> $LOGFILE
echo "At $TIMESTAMP remove duplicate $extension files" >> $LOGFILE
echo "Folder $LOCATION with depth of $DEPTHVAR" >> $LOGFILE
echo "--------------------------------------------------------------------------------" >> $LOGFILE
#
j=1
k=$DEPTHVAR
for (( j=1; j<=k ; j++ ))
do
	find $LOCATION -mindepth $j -maxdepth $j -iname [!.]\*[.]$extension -type f >> $TEMPLOGFILE
done
QUANT=$(wc -l $TEMPLOGFILE | grep -o "[0-9]*")
echo "TOTAL $QUANT"
read -p "Press [Enter] key to start"
#
echo "CYCLE START"
tmp="Ignition"
while [[ -n "$tmp" ]];
do
	tmp=$(grep -F $extension $TEMPLOGFILE)
	echo "$tmp" | while read -r line;
	do
		#line="$(head -1 $TEMPLOGFILE)"
		tmp=$(grep -vF "$line" $TEMPLOGFILE) #-F
		echo "$tmp" > $TEMPLOGFILE #faster
		QUANT=$(wc -l $TEMPLOGFILE | grep -o "[0-9]*")
		#
		echo "Compare «$line» with «$QUANT» file:"
		echo "$(tput setaf $GREEN)-------------------------------------------------------------------------- $(tput sgr0)"
		echo "Search duplicate of $line from $QUANT files:" >> $LOGFILE
		echo "-------------------------------------------------------------------------- " >> $LOGFILE
		sleep 5
		if [[ -n "$line" ]];
		then
			echo "$tmp" | while read -r nextline;
			do
				
				if [[ -f "$nextline" ]];
				then
					echo -n "-> «$nextline»"
					charcount=$(diff -N "$line" "$nextline" | wc -c) #-N if not exist treat as empty file
					echo " Count $charcount"
					if [[ $charcount -eq 0 ]] && [[ -f "$line" ]] && [[ -f "$nextline" ]]; #safety
					then
						#
						rm "$nextline" -v >> $LOGFILE
						echo "Removed"
						tmp=$(grep -vF "$nextline" $TEMPLOGFILE) #-F
						echo "$tmp" > $TEMPLOGFILE
					else
						echo "Stays"
						continue
					fi
				else # $nextline does not exist
					echo "TARGET EMPTY"
					tmp=$(grep -vF "$nextline" $TEMPLOGFILE) #-F
					echo "$tmp" > $TEMPLOGFILE
				fi
			done
			break
		else # $line does not exist
			echo "SOURCE EMPTY"
			continue
		fi
	done
done
echo "CYCLE END"
TIMESTAMP=$(date +%Y:%m:%d-%H:%M:%S)
#troubleshooting
rm $TEMPLOGFILE -v
#
echo "$TIMESTAMP finished" >> $LOGFILE
chmod 444 $LOGFILE -v
echo "$(tput setaf $GREEN)Ficheiro «$LOGFILE» finished $(tput sgr0)"
#Cleanup
IFS=$IFS_OLD
exit #all is well
##########################################################################################################
###############DIR="./PDFALL";mkdir -pv $DIR;find . -iname "*.pdf" -type f -print0 | xargs -0 mv -ut $DIR
##########################################################################################################
