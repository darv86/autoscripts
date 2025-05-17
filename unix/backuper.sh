#!/bin/bash
# unix version

echo 'Backuper is running now...'

command=(sudo tar)

currentDate=$(date "+%H-%M-%d-%m-%Y")
backupExt=tar.gz
mode="archive"
flagsDefault="czvf"
srcPathDefault=/home/$USERNAME/.var/app/io.gitlab.librewolf-community/.librewolf
destPathDefault=/mnt/C050F4F250F4F050/backups
backupName=librewolf-backup-$currentDate.$backupExt
archiveName=$(basename "${destPathDefault}"/*librewolf-backup-*)
targetName=$(basename "${srcPathDefault}"/*.default-default)

flags=$flagsDefault
flagsCustom=""
strip=--strip-components=1
while getopts "cxszvf" option; do
    case $option in
		c|x|z|v|f) flagsCustom=$flagsCustom$option;;
		s) strip=--strip-components=0;;
    esac
done

[ -n "$flagsCustom" ] && flags=$flagsCustom
[ "$flags" == "x" ] && flags=${flagsDefault/c/x}

if [[ "$flags" == *x* ]]; then
	flags=${flags//c/}
	mode="extract"
fi

command+=("$flags")

if [ "${mode}" == "archive" ]; then
	srcPath=$(echo $srcPathDefault/${targetName})
	destPath=$(echo $destPathDefault/${backupName})
elif [ "${mode}" == "extract" ]; then
	srcPath=$(echo $destPathDefault/$archiveName)
	destPath=$(echo $srcPathDefault/$targetName)
fi

param1=${@:OPTIND:1}; param1=${param1%/}
param2=${@:OPTIND+1:1}; param2=${param2%/}
# adds current date to an backup name
if [ "${mode}" == "archive" ] && [ -n "${param2}" ]; then
	param2=${param2%.$backupExt}-$currentDate.$backupExt
fi
srcPath=${param1:-$srcPath}
destPath=${param2:-$destPath}

if [ ! -e "$srcPath" ]; then
	echo "error 1: wrong source"
	exit 1
fi

if [[ "$srcPath" == *librewolf* || "$destPath" == *librewolf* ]]; then
	procid=$( pgrep -x librewolf )
	[ $? -eq 0 ] && kill $procid
	while pgrep -x librewolf > /dev/null; do
		sleep 0.5
	done
fi

if [ "${mode}" == "archive" ]; then
	targetName=$(basename "${srcPath}")
	srcPath=${srcPath/"/$targetName"/}
	command+=("$destPath" -C "$srcPath" "$targetName")
elif [ "${mode}" == "extract" ]; then
	command+=("$srcPath" "$strip" -C "$destPath")
fi

"${command[@]}"
echo ${command[@]}

if [ $? -ne 0 ]; then
	echo "error 2: tar command failed"
	exit 2
fi

echo 'Backuper done'

exit 0
