#!/bin/bash 
# getvir.sh - основной "управляющий" скрипт программы.


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
##                    #getvir.                    ##
##  Anti-malware software solution for websites.  ##
##                                                ##
##  website: getvir.org   email: dev@getvir.org   ##
##                                                ##
####################################################

declare -r _VERSION="#getvir version 0.6 by GETVIR.ORG"
declare -r _START_SCAN="$(date +%Y-%m-%d_%H-%M-%S)"
declare -r DEF_IFS=$IFS		# Saving IFS default values ( '\t\n' ).

ABSOLUTE_FILENAME=`readlink -e "$0"`
DIRECTORY=`dirname "$ABSOLUTE_FILENAME"`

_PATH=$DIRECTORY	# Default scanning path ( option -d ).
_BASE_VERSION="NOT FOUND"
dir_log="$DIRECTORY/var/log/getvir" # Root directory of log files.
getvir_base="$DIRECTORY/usr/share/getvir/getvir.base"	# Root directory of signatures database.
lang_path="$DIRECTORY/usr/share/getvir/getvir.translate"	# The path to the Localization file.

source "$DIRECTORY/etc/getvir.conf"	# Enable config file
source "$lang_path"	# Enable Localization file

# список список переменных, хранящих имена временных файлов:
declare -r list_all_files="/tmp/getvir_${_START_SCAN}_list_all_files"
declare -r list_files_with_php_code="/tmp/getvir_${_START_SCAN}_list_files_with_php_code"
declare -r total_scan_result="$dir_log/${_START_SCAN}_total_scan_result"

# создание временных файлов:
touch "$list_all_files" "$list_files_with_php_code" "$total_scan_result"
count_files_with_php_code=0

# массив, хранящий абсолютный полный путь временных файлов
declare -a list_tmp_files=( "$list_all_files" "$list_files_with_php_code" "$total_scan_result" )

# файлс результатом сканирования:

count_algorithm=0
declare -a array_split_ID
declare -a array_split_TEXT
declare -a array_split_CODE
declare -a array_split_SCORE

#-------------------------------------------------------------------------

# Show getvir command-line options.
function Print_Help() {
	echo -e "\033[1m$_VERSION\033[0m\n"
	tput sgr0
	echo -e "$help"
}

#-------------------------------------------------------------------------

# Check options 
if [[ $# -eq 0 && $critical = "FALSE" && $medium = "FALSE" && $low = "FALSE" && $zero = "FALSE" ]]; then
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

# возвращаем форматированную строку
function Design(){
	case "$1" in
		"DEF") # default
			echo -e "\e[1m$2\033[0m"
		;;
		
		"BOLD") # bold font
			echo -e "\e[1m$2\033[0m"
		;;
		
		"R") # red
			echo -e "\e[0;31m$2\e[0m"
		;;
	
		"RB") # red-bold
			echo -e "\e[1;31m$2\e[0m"
		;;
		
		"GN") # green
			echo -e "\e[0;32m$2\e[0m"
		;;
		
		"GNB") # green-bold
			echo -e "\e[1;32m$2\e[0m"
		;;
		
		"Y") # yellow
			echo -e "\e[0;33m$2\e[0m"
		;;
		
		"YB") # yellow-bold
			echo -e "\e[1;33m$2\e[0m"
		;;
		
		"BE") # blue
			echo -e "\e[0;34m$2\e[0m"
		;;
		
		"BEB") # blue-bold
			echo -e "\e[1;34m$2\e[0m"
		;;
		
		"M") # magenta
			echo -e "\e[0;35m$2\e[0m"
		;;
		
		"MB") # magenta-bold
			echo -e "\e[1;35m$2\e[0m"
		;;
		
		"C") # cyan
			echo -e "\e[0;36m$2\e[0m"
		;;
		
		"CB") # cyan-bold
			echo -e "\e[1;36m$2\e[0m"
		;;
		
		"W") # white
			echo -e "\e[0;37m$2\e[0m"
		;;
		
		"WB") # white-bold
			echo -e "\e[1;37m$2\e[0m"
		;;
	esac
}

#-------------------------------------------------------------------------

# поэтапно запускаем процесс сканирования
function Start_Scanning() {
	Print_String "$(Design "RB" "-------------------------------------------------------------------------------------")"
	Print_String "$(Design "BOLD" "Подгатовка к сканированию:")\n"
	Print_String "$(Design "BOLD" "Путь для проверки")\n$(Design "MB" "$_PATH")"
	
	# получаем версию базы алгоритмов
	Get_Base_Version
	Print_String "$(Design "BOLD" "Версия базы алгоритмов поиска:") $(Design "MB" "$_BASE_VERSION")"
	# сортируем и сохраняем данные базы в ОЗУ
	Read_Base
	Print_String "$(Design "BOLD" "Количество алгоритмов поиска:") $(Design "MB" "$count_algorithm")"
	# создаем все необходимые списки
	Create_Lists
	# запускаем сканирование
	Search_Virus
}


#-------------------------------------------------------------------------

# получаем версию базы алгоритмов
function Get_Base_Version(){
	local temp=`head -n 1 "$getvir_base"`

	if [[ "`echo $temp | grep -w  "_BASE_VERSION"`" != "" ]];then
		_BASE_VERSION=${temp#*=}
	fi
}

#-------------------------------------------------------------------------

# создаем все необходимые списки
function Create_Lists(){
	# список всех объектов для проверки, удовлетворяющих начальным условиям
	Create_List_All_Files
	# список файлов содержащих и способных содержать PHP код
	Create_List_Files_With_Php_Code	
}

#-------------------------------------------------------------------------

# список всех объектов для проверки, удовлетворяющих начальным условиям
function Create_List_All_Files(){
	# если задан промежуток времени
	if [[ $mtime > 0 ]];then
		find $_PATH -mtime -$mtime -type f >> "$list_all_files"rm -f 
	else
		find $_PATH -type f >> "$list_all_files"
	fi
	
	local count=`wc -l "$list_all_files" | awk '{print $1}'`
	Print_String "$(Design "BOLD" "Количество сканируемых файлов:") $(Design "MB" "$count")"
}

#-------------------------------------------------------------------------

# список файлов содержащих и способных содержать PHP код
function Create_List_Files_With_Php_Code(){
	# фильтруем список по типу файлов
	egrep -i "*\.php$|*\.phps$|*\.phtml$|*\.php4$|*\.php5$|*\.htm$|*\.html$|*\.pl$" $list_all_files >> "$list_files_with_php_code"
	
	# выводим информацию:
	count_files_with_php_code=`wc -l "$list_files_with_php_code" | awk '{print $1}'`
	Print_String "$(Design "BOLD" "Количество файлов с расширением, допускающим использование PHP кода:") $(Design "MB" "$count_files_with_php_code")"
	
	if [[ "$PHP_NOPHP" == "TRUE" ]]; then
		# фильтруем оставшиеся по содержимому
		while read file_path; do
			if [[ "`echo $file_path |egrep -i "*\.php$|*\.phps$|*\.phtml$|*\.php4$|*\.php5$|*\.htm$|*\.html$|*\.pl$"`" == "" ]] && [[ "`grep -ilsr '<?php' "$file_path"`" != "" ]]; then
				echo "$file_path" >> "$list_files_with_php_code"
				echo "$file_path:1:PHP-NOPHP" >> "$total_scan_result"
			fi
		done < "$list_all_files"
				
		local count2=`wc -l "$total_scan_result" | awk '{print $1}'`
		count_files_with_php_code=$(( $count_files_with_php_code+$count2 ))
		# выводим информацию:
		Print_String "$(Design "BOLD" "Количество файлов с расширением, НЕ допускающим использование PHP кода, но содержащие его:") $(Design "MB" "$count2")"
		Print_String "$(Design "RB" "-------------------------------------------------------------------------------------")"
	fi
}

#-------------------------------------------------------------------------

# обрабатываем базу алгоритмов поиска, сохраняем информацию в ОЗУ
function Read_Base(){
	IFS=
	local trigger=0
	while read -r str_base; do
		# отсеить строку с версией базы
		if [[ "`echo $str_base | grep '_BASE_VERSION'`" == "" && "$str_base" != "" ]];then
			# сортируем данные алгоритма по массивав
			if [[ $trigger -eq 0 ]]; then
				array_split_ID[$count_algorithm]=`echo $str_base | awk '{split($0,a,"##"); print a[1]}'`
				array_split_TEXT[$count_algorithm]=`echo $str_base | awk '{split($0,a,"##"); print a[2]}'`
				array_split_SCORE[$count_algorithm]=`echo $str_base | awk '{split($0,a,"##"); print a[3]}'`
				
				trigger=1
			else
				array_split_CODE[$count_algorithm]="$str_base"
				
				count_algorithm=$(( $count_algorithm+1 ))
				trigger=0
			fi
		fi
	done < "$getvir_base"
	
	IFS=$DEF_IFS
}

#-------------------------------------------------------------------------

function Search_Virus(){
	IFS=
	for (( i=0; i < count_algorithm; i++ )); do
# 		local text_count_algorithm=
		Print_String "\n$(Design "BOLD" "[$(( $i+1 ))/$count_algorithm] ") $(Design "MB" "${array_split_ID[$i]}")"
		Print_String "$(Design "BOLD" "${array_split_TEXT[$i]}:")"
		Print_String "$(Design "RB" "-------------------------------------------------------------------------------------")"
		
		# временный файл для хранения результатов текущего алгоритма
		local current_id_result_file="/tmp/${array_split_ID[$i]}_${_START_SCAN}"
		touch "$current_id_result_file"
		
		# проверяем все файлы по очереди
		local progress_bar_count=0
		while read file_path; do
			# progress bar
			progress_bar_count=$(( $progress_bar_count+1 ))
			echo -ne "\rПроверяется файл $progress_bar_count из $count_files_with_php_code"
			
			temp_result=`eval ${array_split_CODE[i]}`
			# если в проверяемом файле найдена искомая комбинация
			if [[ "$temp_result" != "" ]]; then
				# то добавляем его во временный файл:
				echo "$file_path" >> $current_id_result_file
				
				# и проверяем, есть ли этот файл среди уже "пойманных"
				string_result=`grep "$file_path" $total_scan_result`
				if [[ "$string_result" != "" ]]; then
					old_score=`echo $string_result | awk '{split($0,a,":"); print a[2]}'`
					new_score=$(( $old_score+${array_split_SCORE[$i]} ))
					
					# экранируем слэш в строке
					file_path=`echo $file_path | sed 's|/|\\\/|g'`
					# и суммируем баллы
					sed -i "s/^$file_path:$old_score:/$file_path:$new_score:${array_split_ID[$i]}\ /g" $total_scan_result			
				else # если нет, то добавляем
					echo "$file_path:${array_split_SCORE[$i]}:${array_split_ID[$i]}" >> $total_scan_result
				fi
			fi
		done < "$list_files_with_php_code"
		
		local  current_id_result=`cat $current_id_result_file`
		if [[ "$current_id_result" != "" ]]; then
			Print_String "\n$(Design "RB" "Файлы, содержащие данную уязвимость:")"
			Print_String "$current_id_result"
			
		else
			Print_String "\n$(Design "GNB" "Файлы, содержащие данную уязвимость, не найдены.")"
		fi
		Print_String ""

	done
	
	IFS=$DEF_IFS
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


#################################################################################################

# поиск и проверка на валидность пути
for n in $@; do
	if [ -d "$n" ]; then
		_PATH=$n
	fi
done


while getopts ":ht:L" opt;
do
	case $opt in
		h) # Print help screen
			Print_Help
			exit 0
		;;
		t) # Checking the argument passed to the option -t
			Check_Mtime
		;;
		L) # Enable / disable logging file.
			if [[ $log_enable = "FALSE" ]]; then log_enable="TRUE"
				else log_enable="FALSE"; fi
		;;
		I)
			Check_ID
		;;
		*) # An invalid option
			Print_Helptotal_scan_result
		;;
	esac
done
shift $(($OPTIND - 1))

##################################################################################################

# выводим приветствие
Print_String "\n$(Design "BOLD" "$_VERSION")\n$(Design "RB" "===================================")\n\n$_START_SCAN: $all004"

Start_Scanning
Print_String "$(Design "RB" "-------------------------------------------------------------------------------------\n")"
Print_String "$(date +%Y-%m-%d_%H-%M-%S): $all005"
Create_Log_File
Print_String "$(Design "BOLD" "Файл с результатами сканирования:")"
echo $total_scan_result

rm -f "$list_php_files $list_files_with_php_code"

exit 0
