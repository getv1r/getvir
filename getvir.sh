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


#константы
declare -r _VERSION="getvir version 0.6 by GETVIR.ORG"
declare -r _START_SCAN="$(date +%Y-%m-%d_%H-%M-%S)"
declare -r DEF_IFS=$IFS		# Saving IFS default values ( '\t\n' ).

ABSOLUTE_FILENAME=`readlink -e "$0"`
DIRECTORY=`dirname "$ABSOLUTE_FILENAME"`

<<<<<<< HEAD

_PATH=$DIRECTORY	# Default scanning path.

STEP_TWO_BASE_VERSION="NOT FOUND"
dir_log="$DIRECTORY/var/log/getvir" # Root directory of log files.

=======
_PATH=$DIRECTORY	# Default scanning path ( option -d ).
STEP_ONE_BASE_VERSION="NOT FOUND"
STEP_TWO_BASE_VERSION="NOT FOUND"
dir_log="$DIRECTORY/var/log/getvir" # Root directory of log files.
step_one_base="$DIRECTORY/usr/share/getvir/step_one.base"	# Root directory of step one database.
>>>>>>> 6dd81d9f946f402dd734075cd2a78da37dfcd307
step_two_base="$DIRECTORY/usr/share/getvir/step_two.base"	# Root directory of step two database.
lang_path="$DIRECTORY/usr/share/getvir/getvir.translate"	# The path to the Localization file.

getvir_config="$DIRECTORY/etc/getvir.conf"

# загрузка конфига
source "$getvir_config"	# Enable config file
source "$lang_path"	# Enable Localization file

# список переменных, хранящих имена временных файлов:
declare -r list_all_files="/tmp/getvir_${_START_SCAN}_list_all_files"
declare -r list_files_with_php_code="/tmp/getvir_${_START_SCAN}_list_files_with_php_code"
declare -r total_scan_result="$dir_log/${_START_SCAN}_total_scan_result"

<<<<<<< HEAD
=======
count_all_files=0
count_files_with_php_code=0
>>>>>>> 6dd81d9f946f402dd734075cd2a78da37dfcd307

# переменная, хранящая пути к временным файлам
list_gc=""

# файлс результатом сканирования:




################################################################################################################
# вспомогательный функционал
################################################################################################################

# создаём нужные файлы
function Create_Files(){
	touch $*
	Add_GC $*
}

#-------------------------------------------------------------------------

<<<<<<< HEAD
# добавляем файлы в сборщик мусора
function Add_GC(){
	list_gc+=" $*"
=======
# создаём нужные файлы
function Create_Files(){
	touch $*
	Add_GC $*
>>>>>>> 6dd81d9f946f402dd734075cd2a78da37dfcd307
}

#-------------------------------------------------------------------------

<<<<<<< HEAD
# Show getvir command-line options.
function Print_Help() {
	Greeting
=======
# добавляем файлы в сборщик мусора
function Add_GC(){
	list_gc+=" $*"
}


#-------------------------------------------------------------------------

# Show getvir command-line options.
function Print_Help() {
	Print_Titul
>>>>>>> 6dd81d9f946f402dd734075cd2a78da37dfcd307
	
	echo -e "$help"
}

#-------------------------------------------------------------------------

# Output text on the screen.
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

################################################################################################################
# Функции оформления
################################################################################################################

#-------------------------------------------------------------------------

# выводим на экран линию-разделитель
function Print_Separator(){
	Print_String "$(Design "RB" "-------------------------------------------------------------------------------------")"	
}

#-------------------------------------------------------------------------

# выводим на экран линию-разделитель
function Print_Separator_Two(){
	Print_String "$(Design "RB" "=====================================================================================")"	
}

#-------------------------------------------------------------------------

# выводим приветствие
function Step_One_Print_Titul(){
	# выводим приветствие
	Print_String "\n$(Design "BOLD" "$_VERSION")\n$(Design "RB" "===================================")\n"
}

#-------------------------------------------------------------------------

# выводим на экран линию-разделитель
function Print_Separator(){
	Print_String "$(Design "RB" "-------------------------------------------------------------------------------------")"	
}

#-------------------------------------------------------------------------

# выводим на экран линию-разделитель
function Print_Separator_Two(){
	Print_String "$(Design "RB" "=====================================================================================")"	
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

<<<<<<< HEAD
################################################################################################################
# 
################################################################################################################

function Greeting(){
	# выводим приветствие
	
	Print_String "\n $(Design "BOLD" "#")   #"
	Print_String "$(Design "BOLD" "#######")"
	Print_String " $(Design "BOLD" "#")   #  $(Design "BOLD" "$_VERSION")"
	Print_String " $(Design "BOLD" "#")   #  $(Design "RB" "===================================")"
	Print_String "#$(Design "BOLD" "#")#####"
	Print_String " $(Design "BOLD" "#")   #\n"
	
# 	Print_String "\n$(Design "BOLD" "$_VERSION")\n$(Design "RB" "===================================")\n"
=======
#-------------------------------------------------------------------------
# первая фаза - сканирование файлов
function Step_One(){
	# выводим приветствие
	Step_One_Print_Titul
	
	# so1=начало работы программы
	Print_String "$_START_SCAN: $so1."
	
	# подготовка к сканированию
	Step_One_PreScanning
	
	# so2=ЭТАП 1
	# so3=проверка файлов
	Print_String "\n$(Design "MB" "$so2:") $(Design "BOLD" "$so3.")"
	Print_Separator
	
	# начинаем сканирование
	Search_Virus
}

#-------------------------------------------------------------------------

# подготовка к сканированию
function Step_One_PreScanning(){
	# выводим линию-разделитель
	Print_Separator
	
	# ps1=Подгатовка к сканированию
	Print_String "$(Design "BOLD" "$ps1:")\n"
	# ps2=Путь для проверки
	Print_String "$(Design "BOLD" "$ps2:")\n$(Design "MB" "$_PATH")"
	
	# получаем версию базы алгоритмов
	Get_Step_One_Base_Version
	
	# ps3=Версия базы алгоритмов поиска
	Print_String "$(Design "BOLD" "$ps3:") $(Design "MB" "$STEP_ONE_BASE_VERSION")"
	
	# сортируем и сохраняем данные базы в ОЗУ
	Step_One_Read_Base
	
	# ps4=Количество алгоритмов поиска
	Print_String "$(Design "BOLD" "$ps4:") $(Design "MB" "$count_algorithm")"
	
	# создаем все необходимые списки
	Create_Lists
>>>>>>> 6dd81d9f946f402dd734075cd2a78da37dfcd307
}

#-------------------------------------------------------------------------

<<<<<<< HEAD
# подготовка к сканированию
function PreScanning(){
	# выводим линию-разделитель
	Print_Separator
	
	# ps1=Подгатовка к сканированию
	Print_String "$(Design "BOLD" "$ps1:")\n"
	# ps2=Путь для проверки
	Print_String "$(Design "BOLD" "$ps2:")\n$(Design "MB" "$_PATH")"
	
	# создаем список всех файлов в указанной директории
	Create_Lists

=======
# получаем версию базы алгоритмов
function Get_Step_One_Base_Version(){
	local temp=`head -n 1 "$step_one_base"`

	if [[ "`echo $temp | grep -w  "STEP_ONE_BASE_VERSION"`" != "" ]];then
		STEP_ONE_BASE_VERSION=${temp#*=}
	fi
>>>>>>> 6dd81d9f946f402dd734075cd2a78da37dfcd307
}


#-------------------------------------------------------------------------

# обрабатываем базу алгоритмов поиска, сохраняем информацию в ОЗУ
function Step_One_Read_Base(){
	IFS=
	local trigger=0
	while read -r str_base; do
		# отсеить строку с версией базы
		if [[ "`echo $str_base | grep 'STEP_ONE_BASE_VERSION'`" == "" && "$str_base" != "" ]];then
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
	done < "$step_one_base"
	
	IFS=$DEF_IFS
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

	count_all_files=`wc -l "$list_all_files" | awk '{print $1}'`
	
<<<<<<< HEAD
	# claf1 = Количество сканируемых файлов
=======
	count_all_files=`wc -l "$list_all_files" | awk '{print $1}'`
	
	# text: Количество сканируемых файлов
>>>>>>> 6dd81d9f946f402dd734075cd2a78da37dfcd307
	Print_String "$(Design "BOLD" "$claf1:") $(Design "MB" "$count_all_files")"
}

#-------------------------------------------------------------------------

# список файлов содержащих и способных содержать PHP код
function Create_List_Files_With_Php_Code(){
	# фильтруем список по типу файлов
	egrep -i "*\.php$|*\.phps$|*\.phtml$|*\.php4$|*\.php5$|*\.htm$|*\.html$|*\.pl$" $list_all_files >> "$list_files_with_php_code"
	
	# выводим информацию:
	count_files_with_php_code=`wc -l "$list_files_with_php_code" | awk '{print $1}'`
	
	# text: Количество файлов с расширением, допускающим использование PHP кода
	Print_String "$(Design "BOLD" "$clfwpc1:") $(Design "MB" "$count_files_with_php_code")"
<<<<<<< HEAD
}


#-------------------------------------------------------------------------

function Clear_Temp_File(){
	rm -f $list_gc
=======
	
	# если в конфиге включена проверка по всем файлам
	if [[ "$PHP_NOPHP" == "TRUE" ]]; then
		
		### progress bar ###
		local progress_bar_count=0
		local result=0
		
		while read file_path; do
			# обновляем progress bar
			progress_bar_count=$(( $progress_bar_count+1 ))
			echo -ne "\r$(Design "BOLD" "$clfwpc2:") [$progress_bar_count/$count_all_files] $(Design "MB" "$result")"
			
			if [[ "`echo $file_path |egrep -i "*\.php$|*\.phps$|*\.phtml$|*\.php4$|*\.php5$|*\.htm$|*\.html$|*\.pl$"`" == "" ]] && [[ "`grep -ilsr '<?php' "$file_path"`" != "" ]]; then
				
				# обновляем progress bar
				result=$(( $result+1 ))
				echo -ne "\r$(Design "BOLD" "$clfwpc2:") [$progress_bar_count/$count_all_files] $(Design "MB" "$result")"
				
				echo "$file_path" >> "$list_files_with_php_code"
				echo "$file_path:1:PHP-NOPHP" >> "$total_scan_result"
			fi
		done < "$list_all_files"
		
		echo -ne "\r$(Design "BOLD" "$clfwpc2:") $(Design "MB" "$result")                                         \n"
					
		count_files_with_php_code=$(( $count_files_with_php_code+$result ))
		
		# выводим информацию:
		# clfwpc2=Количество файлов с расширением, НЕ допускающим использование PHP кода, но содержащие его
		
		Print_Separator
	fi
}

#-------------------------------------------------------------------------

# запускаем сканирование
function Search_Virus(){
	IFS=
	
	# по очереди проходим по всем алгоритмам поиска
	for (( i=0; i < count_algorithm; i++ )); do
		
		local result=0
		
		# вывод информации о заголовке
		Print_String "\n$(Design "BOLD" "[$(( $i+1 ))/$count_algorithm] ") $(Design "MB" "${array_split_ID[$i]}")"
		Print_String "$(Design "BOLD" "${array_split_TEXT[$i]}:")"
		Print_Separator
		
		# временный файл для хранения результатов текущего алгоритма
		local current_id_result_file="/tmp/${array_split_ID[$i]}_${_START_SCAN}"
		Create_Files $current_id_result_file
		
		# проверяем все файлы по очереди
		local progress_bar_count=0
		while read file_path; do
			### progress bar ###
			progress_bar_count=$(( $progress_bar_count+1 ))
			# sv1=Проверяется файл
			# sv2=из
			echo -ne "\r$sv1 $progress_bar_count $sv2 $count_files_with_php_code [$(Design "MB" "$result")]"
			
			temp_result=`eval ${array_split_CODE[i]}`
			# если в проверяемом файле найдена искомая комбинация
			if [[ "$temp_result" != "" ]]; then
				# обновляем progress bar
				result=$(( $result+1 ))
				echo -ne "\r$sv1 $progress_bar_count $sv2 $count_files_with_php_code [$(Design "MB" "$result")]"
				
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
			
			# sv3=Файлы, содержащие данную уязвимость
			Print_String "\n$(Design "RB" "$sv3:")"
			Print_String "$current_id_result"
			
		else
			
			# sv4=Файлы, содержащие данную уязвимость, не найдены
			Print_String "\n$(Design "GNB" "$sv4.")"
		fi
		Print_String ""

	done
	
	IFS=$DEF_IFS
>>>>>>> 6dd81d9f946f402dd734075cd2a78da37dfcd307
}


#-------------------------------------------------------------------------

function Clear_Temp_File(){
	rm -f $list_gc
}


#-------------------------------------------------------------------------

# Checking the argument passed with option -t
function Check_Mtime(){
	if [[ -z "${OPTARG//[0-9]/}" ]];then
		mtime="$OPTARG"
	fi
}

#-------------------------------------------------------------------------

#################################################################################################

# Check options 
if [[ $# -eq 0 ]]; then
	Print_Help
	exit 0
	fi
	
#-------------------------------------------------------------------------

# поиск и проверка на валидность пути
for n in $@; do
	if [ -d "$n" ]; then
		_PATH=$n
	fi
done


while getopts ":ht:" opt;
do
	case $opt in
		h) # Print help screen
			Print_Help
			exit 0
		;;
		t) # Checking the argument passed to the option -t
			Check_Mtime
		;;
		*) # An invalid option
			Print_Help
		;;
	esac
done
shift $(($OPTIND - 1))

##################################################################################################


### main #########################################################################################

<<<<<<< HEAD
# touch $total_scan_result
Create_Files $list_all_files $list_files_with_php_code 

# Сначала поздороваемся 
Greeting
# выводим общую начальную информацию
PreScanning


# затем за работу
case $scanning_method in
classic)
	# запускаем сканирование классическим методом
	source "$DIRECTORY/classic_method.sh"
;;

rating)
	# запускаем сканирование на основе рейтинговой системы
	source "$DIRECTORY/rating_method.sh"
;;

all)
	# поочередно сканируем всеми методами.
	source "$DIRECTORY/classic.method"
	source "$DIRECTORY/rating.method"
;;

*)
	Print_String "Ошибка в конфигурационном файле:\n$getvir_config\n\nНедопустимое значение переменной scanning_method"
	
	# удаляем временные файлы
	Clear_Temp_File
	# завершаем приложение с ошибкой
	exit 1
;;
esac

=======
touch $total_scan_result
Create_Files $list_all_files $list_files_with_php_code 

# первый этап - сканирование
Step_One


>>>>>>> 6dd81d9f946f402dd734075cd2a78da37dfcd307
Print_Separator

# main2=сканирование завершено
Print_String "$(date +%Y-%m-%d_%H-%M-%S): $main2."

# main3=Файл с результатами сканирования
<<<<<<< HEAD
# Print_String "\n$(Design "BOLD" "$main3:")"
# echo $total_scan_result

Print_String "\n$main4:"
Print_Separator

echo $list_gc | tr " " "\n"

=======
Print_String "\n$(Design "BOLD" "$main3:")"
echo $total_scan_result


Print_String "\n$main4:"
Print_Separator

echo $list_gc | tr " " "\n"

>>>>>>> 6dd81d9f946f402dd734075cd2a78da37dfcd307
Clear_Temp_File

exit 0
