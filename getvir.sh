f#!/bin/bash 

# Copyright 2015 getvir.org e-mail: dev@getvir.org
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

####################################################
##                                                ##
##                    GETVIR.                     ##
##  Anti-malware software solution for websites.  ##
##                                                ##
##  website: getvir.org   email: dev@getvir.org   ##
##                                                ##
####################################################

ABSOLUTE_FILENAME=`readlink -e "$0"`
DIRECTORY=`dirname "$ABSOLUTE_FILENAME"`

declare -r _VERSION="\033[1mGETVIR version 0.5 by GETVIR.ORG\033[0m"
declare -r _START_SCAN="$(date +%Y-%m-%d_%H-%M-%S)"


# Default scanning path ( option -d ).
_PATH=$DIRECTORY
# Root directory of log files.
dir_log="$DIRECTORY/var/log/getvir"
# Root directory of signatures database.
getvir_base="$DIRECTORY/usr/share/getvir/getvir.base"
# The path to the Localization file.
lang_path="$DIRECTORY/usr/share/getvir/getvir.translate"

# Enable config file
source "$DIRECTORY/etc/getvir.conf"
# Enable Localizatio file
source "$lang_path"

_BASE_VERSION="NOT FOUND"

declare -r DEF_IFS=$IFS		# Saving IFS default values ( '\t\n' ).

# Сritical level signatures.
declare -a critical_base_uid
declare -a critical_base_name
declare -a critical_base_code
# Medium level signatures.
declare -a medium_base_uid
declare -a medium_base_name
declare -a medium_base_code
# Low level signatures.
declare -a low_base_uid
declare -a low_base_name
declare -a low_base_code
# Zero level signatures.
declare -a zero_base_uid
declare -a zero_base_name
declare -a zero_base_code

#-------------------------------------------------------------------------

# Show getvir command-line options.
function Print_Help() {
	echo -e "\033[1m$_VERSION\033[0m\n"
	tput sgr0
	echo -e "$help"
}

#-------------------------------------------------------------------------

# Check options 
if [[ $# = 0 && $critical = FALSE && $medium = FALSE && $low = FALSE && $zero = FALSE ]]; then
	Print_Help
	exit 0
fi

#-------------------------------------------------------------------------

# Output text on the screen. Write text to a file log file. (write a log file)
function Print_String() {
	echo -e "$1"
	# If logging is enabled..
	if [[ $log_enable = "TRUE" ]]; then
		if [[ -n $2 ]]; then
			data_log+="\n$2\n"
		else
			data_log+="\n$1\n"
		fi
	fi
} 

#-------------------------------------------------------------------------

# Find .php files.
function Php_List(){
	IFS=$'\n'
	local count_files=0

	Print_String "[$(date +%Y/%m/%d\ %H:%M:%S)]: $php001"
	# If the argument of the -t option is specified and is correct.
	if [[ $mtime > 0 ]];then
		for a in `find $_PATH -mtime -$mtime -daystart -type f -regex ".*\.\(php\|phps\|phtml\|php4\|php5\|htm\|html\)"`; do
			PHP_LIST+="$a#"
			let "count_files += 1"
		done
	else
		for a in `find $_PATH -type f -regex ".*\.\(php\|phps\|phtml\|php4\|php5\|htm\|html\)"`;do
			PHP_LIST+="$a#"
			let "count_files += 1"
		done
	fi
	
	# Files are not found?
	if [[ -n "$PHP_LIST" ]]; then
		Print_String "[$(date +%Y/%m/%d\ %H:%M:%S)]: $all001 $all006 $count_files.\n-------------------------------------------------------------------------------------\n"
	else
		echo -e "$php002\n-------------------------------------------------------------------------------------\n"
	fi
	
	IFS=$DEF_IFS
}

#-------------------------------------------------------------------------

# Get signatures from databases and sort by levels.
function Processing_Base(){
	# Change IFS character.
	IFS=$'#'
	
	# Line counters.
	Crt_Rows=0
	Med_Rows=0
	Low_Rows=0
	Zero_Rows=0
	
	Print_String "[$(date +%Y/%m/%d\ %H:%M:%S)]:загрузка базы сигнатур."

	# Read from signatures database.
	while read -r uid name code level; do
		if [[ -z $uid && -z $name && -z $code ]]; then
			continue; # LICENSE
		fi
		if [[ -z $uid && -z $name && -z $level ]]; then
			_BASE_VERSION=$code
			Print_String "Версия: $_BASE_VERSION."
		else
			case $level in
			3) # This is critical level.
			critical_base_uid[$Crt_Rows]="$uid"
			critical_base_name[$Crt_Rows]="$name"
			critical_base_code[$Crt_Rows]="$code"
			let "Crt_Rows += 1"
			;;
			2) # This is medium level.
			medium_base_uid[$Med_Rows]="$uid"
			medium_base_name[$Med_Rows]="$name"
			medium_base_code[$Med_Rows]="$code"
			let "Med_Rows += 1"
			;;
			1) # This is low level.
			low_base_uid[$Low_Rows]="$uid"
			low_base_name[$Low_Rows]="$name"
			low_base_code[$Low_Rows]="$code"
			let "Low_Rows += 1"
			;;
			0) # This is test level.
			zero_base_uid[$Zero_Rows]="$uid"
			zero_base_name[$Zero_Rows]="$name"
			zero_base_code[$Zero_Rows]="$code"
			let "Zero_Rows += 1"
			;;
			*) echo -e "\033[1m$base001 \"\E[31m$level\033[0m\033[1m\" $base002\033[0m\n-------------------------------------------------------------------------------------\n"
			;;
			esac
			
			# If you need to check the signature and indicated it found.
			if [[ -n $check_ID && "$uid" == "$check_ID" ]]; then
				check_name="$name"
				check_code="$code"
				check_ID_status="TRUE"
				break
			fi
		fi
	done < "$getvir_base"

	local count_sign=0
	let "count_sign += $Crt_Rows + $Med_Rows + $Low_Rows + $Zero_Rows"
	Print_String "Количество сигнатур: $count_sign ."
	Print_String "[$(date +%Y/%m/%d\ %H:%M:%S)]:выполнено.\n-------------------------------------------------------------------------------------\n"
	# IFS assign the default value.
	IFS=$DEF_IFS
}

#-------------------------------------------------------------------------

# CRITICAL level 
function Search_Critical(){
	# Change IFS character.
	IFS=$'#'
	Print_String "\033[1mCRITICAL level. $all002\033[0m\n-------------------------------------------------------------------------------------"
	for((i=0;i<$Crt_Rows;i++)); do
		local date_time="[$(date +%Y/%m/%d\ %H:%M:%S)]:"
		local uid="${critical_base_uid[$i]}"
		local name="${critical_base_name[$i]}"
		local code=`eval ${critical_base_code[$i]}`
		# If files are found.
		if [ -n "$code" ];then
			# Add separator.
			code=`echo -e "$code" | sed '/^$/d;G'`
			# Output scan result.
			local display="\033[1m${date_time} $uid $name: \n[\E[31mTRUE\033[0m\033[1m]\033[0m\n$code\n"
			local log_write="${date_time} $uid $name: \n[TRUE]\n$code\n"
			Print_String $display $log_write
			tput sgr0
		else
			local display="\033[1m${date_time} $uid $name:\n[\E[32mFALSE\033[0m\033[1m]\033[0m\n"
			local log_write="${date_time} $uid $name:\n[FALSE]\n"
			Print_String $display $log_write 
			tput sgr0
		fi
	done
	# IFS assign the default value.
	IFS=$DEF_IFS
}

#-------------------------------------------------------------------------

# MEDIUM level 
function Search_Medium(){
	# Change IFS character.
	IFS=$'#'
	Print_String "\033[1mMEDIUM level. $all002\033[0m\n-------------------------------------------------------------------------------------"
	for((i=0;i<$Med_Rows;i++)); do
		local date_time="[$(date +%Y/%m/%d\ %H:%M:%S)]:"
		local uid="${medium_base_uid[$i]}"
		local name="${medium_base_name[$i]}"
		local code=`eval ${medium_base_code[$i]}`
		# If files are found.
		if [ -n "$code" ];then
			# Add separator.
			code=`echo -e "$code" | sed '/^$/d;G'`
			# Output scan result.
			local display="\033[1m${date_time} $uid $name: \n[\E[31mTRUE\033[0m\033[1m]\033[0m\n$code\n"
			local log_write="${date_time} $uid $name: \n[TRUE]\n$code\n"
			Print_String $display $log_write
			tput sgr0
		else
			local display="\033[1m${date_time} $uid $name:\n[\E[32mFALSE\033[0m\033[1m]\033[0m\n"
			local log_write="${date_time} $uid $name:\n[FALSE]\n"
			Print_String $display $log_write 
			tput sgr0
		fi
	done
	# IFS assign the default value.
	IFS=$DEF_IFS
}

#-------------------------------------------------------------------------

# LOW level 
function Search_Low(){
	# Change IFS character.
	IFS=$'#'
	Print_String "\033[1mLOW level. $all002\033[0m\n-------------------------------------------------------------------------------------"
	
	for((i=0;i<$Low_Rows;i++)); do
		local date_time="[$(date +%Y/%m/%d\ %H:%M:%S)]:"
		local uid="${low_base_uid[$i]}"
		local name="${low_base_name[$i]}"
		local code=`eval ${low_base_code[$i]}`
		# If files are found.
		if [ -n "$code" ];then
			# Add separator.
			code=`echo -e "$code" | sed '/^$/d;G'`
			# Output scan result.
			local display="\033[1m${date_time} $uid $name: \n[\E[31mTRUE\033[0m\033[1m]\033[0m\n$code\n"
			local log_write="${date_time} $uid $name: \n[TRUE]\n$code\n"
			Print_String $display $log_write
			tput sgr0
		else
			local display="\033[1m${date_time} $uid $name:\n[\E[32mFALSE\033[0m\033[1m]\033[0m\n"
			local log_write="${date_time} $uid $name:\n[FALSE]\n"
			Print_String $display $log_write 
			tput sgr0
		fi
	done
	# IFS assign the default value.
	IFS=$DEF_IFS
}

#-------------------------------------------------------------------------

# ZERO level 
function Search_Zero(){
	# Change IFS character.
	IFS=$'#'
	Print_String "\033[1mTESTING level. $all002\033[0m\n-------------------------------------------------------------------------------------"
	
	for((i=0;i<$Zero_Rows;i++)); do
		local date_time="[$(date +%Y/%m/%d\ %H:%M:%S)]:"
		local uid="${zero_base_uid[$i]}"
		local name="${zero_base_name[$i]}"
		local code=`eval ${zero_base_code[$i]}`
		# If files are found.
		if [ -n "$code" ];then
			# Add separator.
			code=`echo -e "$code" | sed '/^$/d;G'`
			# Output scan result.
			local display="\033[1m${date_time} $uid $name: \n[\E[31mTRUE\033[0m\033[1m]\033[0m\n$code\n"
			local log_write="${date_time} $uid $name: \n[TRUE]\n$code\n"
			Print_String $display $log_write
			tput sgr0
		else
			local display="\033[1m${date_time} $uid $name:\n[\E[32mFALSE\033[0m\033[1m]\033[0m\n"
			local log_write="${date_time} $uid $name:\n[FALSE]\n"
			Print_String $display $log_write 
			tput sgr0
		fi
	done
	# IFS assign the default value.
	IFS=$DEF_IFS
}

# Search indicated signature.
function Search_By_Check(){
	# Change IFS character.
	IFS=$'#'
	
	# If the signature found in the database.
	if [[ $check_ID_status = TRUE ]]; then
		Print_String "\033[1mScanning selected signature.\033[0m\n-------------------------------------------------------------------------------------"
		# Scan at indicated signature.
		local date_time="[$(date +%Y/%m/%d\ %H:%M:%S)]:"
		check_code=`eval $check_code`
		# If files are found.
		if [[ -n $check_code ]];then
			# Add separator.
			code=`echo -e "$code" | sed '/^$/d;G'`
			# Output scan result.
			local display="\033[1m${date_time} $check_ID $check_name:\n[\E[31mTRUE\033[0m\033[1m]\033[0m\n$check_code\n"
			local log_write="${date_time} $check_ID $check_name:\n$check_code\n"
			Print_String $display $log_write
		else
			local display="\033[1m${date_time} $check_ID $check_name:\n[\E[32mFALSE\033[0m\033[1m]\033[0m\n"
			local log_write="${date_time} $check_ID $check_name:\n$check_code\n"
			Print_String $display $log_write
		fi
	else
		Print_String "Указанная сигнатура не найдена!"
	fi
	# IFS assign the default value.
	IFS=$DEF_IFS
}

#-------------------------------------------------------------------------

# Start the scan at selected levels.
function Start_Scanning() {
	Print_String "\n$_VERSION\n===================================\n\n$_START_SCAN: $all004\n-------------------------------------------------------------------------------------"

	# Creating a list of files to scan.
	Php_List
	
	# Loading signature.
	Processing_Base
	if [[ -n $check_ID ]]; then
		Search_By_Check
	else
		if [ $critical = "TRUE" ];then	
			Search_Critical 
		fi
	
		if [ $medium = "TRUE" ];then
			Search_Medium
		fi
	
		if [ $low = "TRUE" ];then
			Search_Low
		fi
	
		if [ $zero = "TRUE" ];then
			Search_Zero
		fi
	fi
}

#-------------------------------------------------------------------------

# Checking the argument passed with option -d
function Check_Dir(){
	if [[ $OPTARG =~ ^-{0,1}[hdtcmlzLI]$ ]]; then
		echo -e "$OPTARG"
		echo "$check001 $OPTARG $check002 $opt!"
		exit 1
	else
		_PATH=`readlink -e $OPTARG`
	fi
}

#-------------------------------------------------------------------------

# Checking the argument passed with option -t
function Check_Mtime(){
	if [[ -z "${OPTARG//[0-9]/}" ]];then
		mtime="$OPTARG"
	fi
}

#-------------------------------------------------------------------------

# Enable / disable the creation of the log (option -L).
function Create_Log_File(){
	if [[ $log_enable = "TRUE" ]]; then
		url_log="$dir_log/getvir_$_START_SCAN.log"
		echo -e "$data_log" >> $url_log
		chmod 644 $url_log
		echo -e "\n$log001\n$url_log"
	fi
}

#-------------------------------------------------------------------------

# Checking the argument passed with option -I
function Check_ID(){
	if [[ $OPTARG =~ ^-{0,1}[hdtcmlzLI]$ ]]; then
		echo -e "$OPTARG"
		echo "$check001 $OPTARG $check002 $opt!"
		exit 1
	else
		check_ID=$OPTARG
		check_name=""
		check_code=""
		check_ID_status="FALSE"
	fi
}

#################################################################################################
while getopts ":hd:t:cmlzLI:" opt;
do
	case $opt in
		h) # Print help screen
			Print_Help
			exit 0
		;;
		d) # Checking the argument passed to the option -d
			Check_Dir
		;;
		t) # Checking the argument passed to the option -t
			Check_Mtime
		;;
		c) # Enables / disables the check at a critical level.
			if [[ $critical = "FALSE" ]]
				then critical="TRUE"
				else critical="FALSE"
			fi
		;;
		m) # Enables / disables the check at a medium level.
			if [[ $medium = "FALSE" ]]
				then medium="TRUE"
				else medium="FALSE"
			fi
		;;
		l) # Enables / disables the check at a low level.
			if [[ $low = "FALSE" ]]
				then low="TRUE"
				else low="FALSE"
			fi
		;;
		l) # Enables / disables the check at a low level.
			if [[ $low = "FALSE" ]]
				then low="TRUE"
				else low="FALSE"
			fi
		;;
		z) # Enables / disables the check at a zero level.
			if [[ $zero = "FALSE" ]]
				then zero="TRUE"
				else zero="FALSE"
			fi
		;;
		L) # Enable / disable logging file.
			if [[ $log_enable = "FALSE" ]]
				then log_enable="TRUE"
				else log_enable="FALSE"
			fi
		;;
		I)
			Check_ID
		;;
		*) # An invalid option
			Print_Help
		;;
	esac
done
shift $(($OPTIND - 1))

##################################################################################################

Start_Scanning
Print_String "-------------------------------------------------------------------------------------\n$(date +%Y-%m-%d_%H-%M-%S): $all005"
Create_Log_File

exit 0
