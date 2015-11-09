#!/bin/bash 
# classic_metod.sh - реализация классического метода сканирования.


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


CM_BASE_VERSION="NOT FOUND"

count_cm_algorithm=0
declare -a array_split_CM_ID
declare -a array_split_CM_TEXT
declare -a array_split_CM_CODE


classic_method_base="$DIRECTORY/usr/share/getvir/step_one.base"	# Root directory of step one database.

##########################################################################
#
##########################################################################

#-------------------------------------------------------------------------

# получаем версию базы алгоритмов
function ClassicMethodBase_Version(){
	local temp=`head -n 1 "$classic_method_base"`
	
	if [[ "`echo $temp | grep -w  "CM_BASE_VERSION"`" != "" ]];then
		CM_BASE_VERSION=${temp#*=}
	fi
}

#-------------------------------------------------------------------------

# обрабатываем базу алгоритмов поиска, сохраняем информацию в ОЗУ
function Read_CM_Base(){
	IFS=
	local trigger=0
	while read -r str_base; do
		# отсеить строку с версией базы
		if [[ "`echo $str_base | grep 'CM_BASE_VERSION'`" == "" && "$str_base" != "" ]];then
			# сортируем данные алгоритма по массивав
			if [[ $trigger -eq 0 ]]; then
				array_split_CM_ID[$count_cm_algorithm]=`echo $str_base | awk '{split($0,a,"##"); print a[1]}'`
				array_split_CM_TEXT[$count_cm_algorithm]=`echo $str_base | awk '{split($0,a,"##"); print a[2]}'`
				array_split_CM_SCORE[$count_cm_algorithm]=`echo $str_base | awk '{split($0,a,"##"); print a[3]}'`
				
				trigger=1
			else
				array_split_CM_CODE[$count_cm_algorithm]="$str_base"

				count_cm_algorithm=$(( $count_cm_algorithm+1 ))
				trigger=0
			fi
		fi
		done < "$classic_method_base"

	IFS=$DEF_IFS
}

#-------------------------------------------------------------------------

# запускаем сканирование
function Search_Virus(){
	IFS=
	
	# по очереди проходим по всем алгоритмам поиска
	for (( i=0; i < count_cm_algorithm; i++ )); do
		
		# переменные, необходимые для вывода progress bar'a
		local current_list_files=$list_files_with_php_code # используемый список файлов для проверки
		local progress_bar_count=0 # количество файлов для проверки
		local current_count_files=$count_files_with_php_code # счётчик проверенных файлов
		local result=0 # счётчик найденных файлов
		
		# если критерий комбинированный
		if [[ "`echo ${array_split_CM_ID[i]} | grep '\ ' `" != "" ]]; then
			child_id=`echo ${array_split_CM_ID[i]} | awk '{split($0,a," "); print a[1]}'`
			parent_id=`echo ${array_split_CM_ID[i]} | awk '{split($0,a," "); print a[2]}'`
			current_list_files="/tmp/"$parent_id"_${_START_SCAN}"
			current_count_files=`wc -l "$current_list_files" | awk '{print $1}'`
			Print_String "\n$(Design "BOLD" "[$(( $i+1 ))/$count_cm_algorithm] ") $(Design "MB" "$child_id") (из результатов $parent_id)"
		# если критерий обычный
		else 
			child_id=${array_split_CM_ID[i]}
			Print_String "\n$(Design "BOLD" "[$(( $i+1 ))/$count_cm_algorithm] ") $(Design "MB" "$child_id")"
		fi

		Print_String "$(Design "BOLD" "${array_split_CM_TEXT[$i]}:")"
		Print_Separator
		
		# временный файл для хранения результатов текущего алгоритма
		local current_id_result_file="/tmp/"$child_id"_${_START_SCAN}"
		Create_Files $current_id_result_file

		# проверяем все файлы по очереди
		while read file_path; do

			progress_bar_count=$(( $progress_bar_count+1 ))
			Progress_Bar_One $progress_bar_count $current_count_files $result
			
			temp_result=`eval ${array_split_CM_CODE[i]}`
			# если в проверяемом файле найдена искомая комбинация
			if [[ "$temp_result" != "" ]]; then
				
				# обновляем progress bar
				result=$(( $result+1 ))
				Progress_Bar_One $progress_bar_count $current_count_files $result
				
				# то добавляем его во временный файл:
				echo "$file_path" >> $current_id_result_file

			fi
		done < "$current_list_files"
						
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
}

#-------------------------------------------------------------------------

##########################################################################
#
##########################################################################


Print_String ""
# cmm1 = Выбран метод сканирования
Print_String "$(Design "BOLD" "$cmm1:") $(Design "MB" "classic method.")"
# получаем версию базы алгоритмов
ClassicMethodBase_Version
# сохраняем базу в ОЗУ
Read_CM_Base
# ps3=Версия базы алгоритмов поиска
Print_String "$(Design "BOLD" "$ps3:") $(Design "MB" "$CM_BASE_VERSION")"
# ps4=Количество алгоритмов поиска
Print_String "$(Design "BOLD" "$ps4:") $(Design "MB" "$count_cm_algorithm")"
Print_Separator
# Запускаем сканирование
Search_Virus
