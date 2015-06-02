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


_PATH=$DIRECTORY	# Default scanning path.

STEP_TWO_BASE_VERSION="NOT FOUND"
dir_log="$DIRECTORY/var/log/getvir" # Root directory of log files.

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

# добавляем файлы в сборщик мусора
function Add_GC(){
	list_gc+=" $*"
}

#-------------------------------------------------------------------------

# Show getvir command-line options.
function Print_Help() {
	Greeting
	
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
}

#-------------------------------------------------------------------------

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
	
	# claf1 = Количество сканируемых файлов
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

Print_Separator

# main2=сканирование завершено
Print_String "$(date +%Y-%m-%d_%H-%M-%S): $main2."

# main3=Файл с результатами сканирования
# Print_String "\n$(Design "BOLD" "$main3:")"
# echo $total_scan_result

Print_String "\n$main4:"
Print_Separator

echo $list_gc | tr " " "\n"

Clear_Temp_File

exit 0
