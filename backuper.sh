#!/bin/bash

echo 'Backuper is running now...'

# tar -czvf /d/backups/archive.tar.gz -C ~/AppData/Roaming/librewolf/profiles/*.default-default/ ./

# $() syntax allows to have result of the command (pgrep);
# -x flag makes strict search according to the word (librewolf)
procid=$( pgrep -x librewolf )
# $? stores execution code of the previous command (pgrep);
# $? can be 0 (execution success) and non-zero (error code)
if [ $? = 0 ]; then kill $procid; fi
# this two lines can be refactored to:
# if procid=$( pgrep -x librewolf ); then kill $procid; fi

# srcPath=/home/rd/.librewolf
srcPath=/home/rd/.var/app/io.gitlab.librewolf-community/.librewolf/
destPath=/mnt/C050F4F250F4F050/backups

# -e flag is specific to conditional expression [],
# check if file or directory exists;
# -d check if a directory;
# good practice to quote variables inside [],
# coz empty string or variable with the string that includes spaces,
# can be reason of an error
if [ ! -d "$srcPath" ]; then echo 'error 1: wrong source'; exit 1; fi

# if there is no profile's directory, bash will solve the glob,
# as a string '*.default-default' and basename will assign this string to $profile
profile=$(basename "$srcPath"/*.default-default)
if [ -z "$profile" ] || [ "$profile" = "*.default-default" ]; then
	echo 'error 2: no profile detected'
	exit 2
fi

# -f flag should stand right before the file path
# tar -czvf "$destPath/librewolf-backup-test.tar.gz" -C "$srcPath" "$profile"

# -e flag enables backslashes interpretation (escape sequences)
echo -e "Source to archive: $srcPath"
echo -e "Destination: $destPath"
echo 'Backuper done'

# bash designed to work with string,
# thats why c=$a+$b just will concat to strings
# a=2; b=3
# there are a few variants to do correct math:
# c=$[$a + $b + 2 + 5]
# does the same
# c=$(( $a + $b + 2 + 5 ))
# does the same
# let "c = a + b + 2 + 5"
# echo $c

# $* - all arguments
# * - also just wild card can be use (instead of $*), stores all files near this script
# arg - identifier (variable) with an argument itself (value was passed)
# for arg in $*
# do
# 	# $0 - name of the command (./backuper.sh)
# 	echo $0
# 	echo $arg
# 	# $# - number of arguments
# 	echo $#
# done
# another syntax to make for loop
# for (( i=1; i<4; i++ ))
# do echo $i; done

exit 0

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
