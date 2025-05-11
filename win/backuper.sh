#!/bin/bash
# win version

echo 'Backuper is running now...'

command=(tar)

mode="archive"
flagsDefault="czvf"
srcPathDefault=/c/Users/$USERNAME/AppData/Roaming/librewolf/Profiles
destPathDefault=/d/backups
backupName=librewolf-backup-$(date "+%H-%M-%d-%m-%Y").tar.gz
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
srcPath=${param1:-$srcPath}
destPath=${param2:-$destPath}

if [ ! -e "$srcPath" ]; then
	echo "error 1: wrong source"
	exit 1
fi

if [[ "$srcPath" == *librewolf* || "$destPath" == *librewolf* ]]; then
# Replace Linux-specific pgrep/kill with Windows-compatible commands
	tasklist | grep -i librewolf > /dev/null
	if [ $? -eq 0 ]; then
		taskkill //F //IM librewolf.exe //T > /dev/null 2>&1
		while tasklist | grep -i librewolf > /dev/null; do
		    sleep 0.5
		done
	fi
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
