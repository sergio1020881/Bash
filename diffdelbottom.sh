#!/bin/bash
#author: sergio santos
#sergio1020881@gmail.com
#mobile: 916919898
#CVS: $Header$
shopt -s -o nounset
#Global declaraions
declare -rx SCRIPT=${0##*/}
#Sanity check
if test -z "$BASH"; #-z
then
  printf "$SCRIPT please run this script with the BASH shell"
  exit 192
fi
#preset
IFS_OLD=$IFS
#IFS metacharacter list.
#very impotante this parameter
IFS=$'\0'
#function exit on interrupt catch
control_c()
{
  timestamp=$(date +%Y:%m:%d-%H:%M:%S)
  #troubleshooting
  rm $diffdelocation/.diffdelog.txt -v
  #
  echo "Stopped due to Interrupt «ctr-c»"
  echo "$timestamp stopped" >> "$rmlogfile"
  chmod 444 "$rmlogfile" -v
  #Cleanup
  IFS=$IFS_OLD
  exit #all is well
}
#The main
echo "INICIO"
timestamp=$(date +%Y:%m:%d-%H:%M:%S)
#filter
if (( $# < 3 || $# > 3 )); 
then
  echo "Usage: $0 location typefile depth"
  exit
fi
#example: diffdel.sh . txt 3
#example: diffdel.sh ~ pdf 6
diffdelocation="$1";
#
if [[ ! -d $diffdelocation ]];
then
  echo "Dir «$diffdelocation» does not exist!"
  exit
fi
#
extension="$2"
echo "Typefile = $extension"
#
diffdeldepth="$3";
#
if [[ ! $diffdeldepth =~ ^[0-9]$ ]];
then
  echo "Arg 2 must be between 0 and 9!"
  exit
fi
#
touch $diffdelocation/.diffdelog.txt
chmod 644 $diffdelocation/.diffdelog.txt -v
rmlogfolder="$diffdelocation/removelog"
rmlogfile="$rmlogfolder/remove_$extension.txt"
#testes
if [[ -d $rmlogfolder ]];
then
  echo "Pasta «$rmlogfolder» updated"
else
  mkdir $rmlogfolder -v
fi
if [[ -f $rmlogfile ]];
then
  echo "Ficheiro «$rmlogfile» updated"
  chmod 777 $rmlogfile -v
  echo "$timestamp remove $extension files:" >> $rmlogfile
  echo "location: $diffdelocation" >> $rmlogfile
else
  echo "Ficheiro «$rmlogfile» created"
  touch "$rmlogfile"
  chmod 777 $rmlogfile -v
  echo "$timestamp remove $extension files:" > $rmlogfile
  echo "location: $diffdelocation" >> $rmlogfile
fi
#
# sort by depth, removes deeper files
#wildcard expands where it is refered
#find "$diffdelocation" -mindepth 1 -maxdepth 1 -type f -and -iname [!.]\*[.]$extension > $diffdelocation/.diffdelog.txt
k=$diffdeldepth
for (( j=0; j<=k ; j++ ))
do
  find $diffdelocation -mindepth $j -maxdepth $j -iname [!.]\*[.]$extension -type f >> $diffdelocation/.diffdelog.txt
done
#Interrupt catch (control_c function jump)
trap control_c SIGINT
#
echo "CYCLE START"
tmp="Ignition"
while [[ -n "$tmp" ]];
do
  line="$(head -1 $diffdelocation/.diffdelog.txt)"
  tmp=$(grep -vF "$line" $diffdelocation/.diffdelog.txt) #-F
  echo "$tmp" > $diffdelocation/.diffdelog.txt #faster
  #
  printf "Comparator:\t«%s»\n" $line
  if [[ -n "$line" ]];
  then
    echo "$tmp" |
    while read -r nextline;
    do
      if [[ -f "$nextline" ]];
      then
        echo "Compare:«$line»	with:«$nextline»"
        charcount=$(diff -N "$line" "$nextline" | wc -c) #-N if not exist treat as empty file
        echo "Count $charcount"
        if [[ $charcount -eq 0 ]] && [[ -f "$line" ]] && [[ -f "$nextline" ]]; #safety
        then
          #
          rm "$nextline" -v
          echo "Removed:«$nextline» place:«$line»" >> $rmlogfile
          tmp=$(grep -vF "$nextline" $diffdelocation/.diffdelog.txt) #-F
          echo "$tmp" > $diffdelocation/.diffdelog.txt
        else
          echo "Files are different"
          continue
        fi
      else # $nextline does not exist
        echo "Does not exist «$nextline»"
        tmp=$(grep -vF "$nextline" $diffdelocation/.diffdelog.txt) #-F
        echo "$tmp" > $diffdelocation/.diffdelog.txt
        continue
      fi
    done
  else # $line does not exist
    echo "Has already been removed"
  fi
done
echo "CYCLE END"
timestamp=$(date +%Y:%m:%d-%H:%M:%S)
#troubleshooting
rm $diffdelocation/.diffdelog.txt -v
#
echo "$timestamp finished" >> $rmlogfile
chmod 444 $rmlogfile -v
echo "Ficheiro «$rmlogfile» finished"
#Cleanup
IFS=$IFS_OLD
exit #all is well
