#!/bin/bash

echo 'Backuper is running now...'

command=(tar)

mode="archive"
flagsDefault="czvf"
srcPathDefault=/home/rd/.var/app/io.gitlab.librewolf-community/.librewolf
destPathDefault=/mnt/C050F4F250F4F050/backups
backupName=librewolf-backup-$(date "+%H-%M-%d-%m-%Y").tar.gz
archiveName=$(basename "${destPathDefault}"/*librewolf-backup-*)
targetName=$(basename "${srcPathDefault}"/*.default-default)

flags=$flagsDefault
flagsCustom=""
while getopts "cxzvf" option; do
    case $option in
		c|x|z|v|f) flagsCustom=$flagsCustom$option;;
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
	srcPath=$(echo $srcPathDefault)
	destPath=$(echo $destPathDefault/${backupName})
elif [ "${mode}" == "extract" ]; then
	srcPath=$(echo $destPathDefault/$archiveName)
	destPath=$(echo $srcPathDefault/$targetName)
fi

param1=${@:OPTIND:1}
param2=${@:OPTIND+1:1}
srcPath=${param1:-$srcPath}
destPath=${param2:-$destPath}

if [ ! -e "$srcPath" ]; then
	echo "error 1: wrong source"
	exit 1
fi

if [[ "$srcPath" == *librewolf* || "$destPath" == *librewolf* ]]; then
	procid=$( pgrep -x librewolf )
	[ $? -eq 0 ] && kill $procid
	# loop until there is no precess
	while pgrep -x librewolf > /dev/null; do
		sleep 0.5
	done
fi

if [ "${mode}" == "archive" ]; then
	command+=("$destPath" -C "$srcPath" "$targetName")
elif [ "${mode}" == "extract" ]; then
	command+=("$srcPath" --strip-components=1 -C "$destPath")
fi

"${command[@]}"
echo ${command[@]}

if [ $? -ne 0 ]; then
	echo "error 2: tar command failed"
	exit 2
fi

echo 'Backuper done'

exit 0

# -f flag should stand right before the file path
# tar -czvf /d/backups/archive.tar.gz -C ~/AppData/Roaming/librewolf/profiles/*.default-default/ ./
# tar -xzvf test/dest/backup-13-17-07-05-2025.tar.gz -C test/dest/
# tar -xzvf test/dest/backup-17-08-07-05-2025.tar.gz --strip-components=1 -C test/dest/subdir
# tar -tzvf test/dest/backup-13-49-08-05-2025.tar.gz

# assigns default value (e.g. srcPath),
# if 1st operand (e.g. param1) is unset or empty
# param1=${param1:-$srcPath}
# instead of these:
# if [ -z "$param1" ]; then param1="$srcPath"; fi

# to expose wildcard * of the srcPathDefault, need two conditions:
# 1. use command (e.g. echo)
# 2. use variable (e.g. srcPathDefault) without quotes
# srcPath=$(echo $srcPathDefault)
# destPath=$(echo $destPathDefault)

# profile=$(basename "$srcPath"/*.default-default)
# if [ -z "$profile" ] || [ "$profile" = "*.default-default" ]; then
# 	echo 'error 2: no profile detected'
# 	exit 2
# fi

# to check if string includes substring
# if [[ "$flags" == *x* ]]; then
# 	flags=${flags//c/}
# fi
# more heavier alternative
# if echo "$flags" | grep -q "x"; then echo founded; fi

# OPTIND - built-in variable (init value: 1);
#          getopts increments OPTIND while looping over optional arguments
#          so when getopts is done,
#          OPTIND will have index of the 1st non-optional argument

# array creation using brackets ();
# "$@" expands every param as an array element;
# quotes "" keeps params non-split, which have spaces inside
# (e.g. "my param", not "my" "param")
# original_args=("$@")
# echo ${original_args[$(($OPTIND-1+1))]}
# array length number
# echo ${#original_args[@]}
# array of each element index
# echo ${!original_args[@]}
# take element by index
# echo ${original_args[0]}
# // to take 2 elements from 1st index
# echo ${original_args[@]:1:2}

# there are a few variants to do correct math:
# c=$[$a + $b + 2 + 5]
# c=$(( $a + $b + 2 + 5 ))

# $* - similar to `$@` but treats all arguments
#      as a single string when quoted
# $* - all arguments
# * - also just wild card can be use (instead of $*),
#     stores all files near this script
# arg - identifier (variable) with an argument itself (value was passed)
# for arg in $*
# do
# 	# $0 - name of the command (./backuper.sh)
# 	echo $0
# 	echo $arg
# 	$# - number of arguments
# 	echo $#
# done
# another syntax to make for loop
# for (( i=1; i<4; i++ ))
# do echo $i; done

# File Tests
# 	-e file → Exists (file or directory)
# 	-f file → Regular file
# 	-d file → Directory
# 	-s file → File exists and is not empty
# 	-r file → Readable
# 	-w file → Writable
# 	-x file → Executable
# String Tests
# 	-z string → String is empty
# 	-n string → String is not empty
# 	str1 = str2 → Strings are equal
# 	str1 != str2 → Strings are not equal
# Numeric Tests
# 	n1 -eq n2 → Equal
# 	n1 -ne n2 → Not equal
# 	n1 -lt n2 → Less than
# 	n1 -le n2 → Less than or equal
# 	n1 -gt n2 → Greater than
# 	n1 -ge n2 → Greater than or equal
