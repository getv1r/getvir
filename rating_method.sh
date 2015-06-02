#!/bin/bash 
# rating_metod.sh - реализация рейтингового метода поиска.


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


count_all_files=0
count_files_with_php_code=0

count_algorithm=0
declare -a array_split_ID
declare -a array_split_TEXT
declare -a array_split_CODE
declare -a array_split_SCORE


#-------------------------------------------------------------------------
################# ЭТАП ВТОРОЙ #######################################################################
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
}


#-------------------------------------------------------------------------

# получаем версию базы алгоритмов
function Get_Step_One_Base_Version(){
	local temp=`head -n 1 "$step_one_base"`
	
	if [[ "`echo $temp | grep -w  "STEP_ONE_BASE_VERSION"`" != "" ]];then
		STEP_ONE_BASE_VERSION=${temp#*=}
	fi
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

# # если в конфиге включена проверка по всем файлам
# if [[ "$PHP_NOPHP" == "TRUE" ]]; then
# 	
# 	### progress bar ###
# 	local progress_bar_count=0
# 	local result=0
# 	
# 	while read file_path; do
# 		# обновляем progress bar
# 		progress_bar_count=$(( $progress_bar_count+1 ))
# 		echo -ne "\r$(Design "BOLD" "$clfwpc2:") [$progress_bar_count/$count_all_files] $(Design "MB" "$result")"
# 		
# 		if [[ "`echo $file_path |egrep -i "*\.php$|*\.phps$|*\.phtml$|*\.php4$|*\.php5$|*\.htm$|*\.html$|*\.pl$"`" == "" ]] && [[ "`grep -ilsr '<?php' "$file_path"`" != "" ]]; then
# 			
# 			# обновляем progress bar
# 			result=$(( $result+1 ))
# 			echo -ne "\r$(Design "BOLD" "$clfwpc2:") [$progress_bar_count/$count_all_files] $(Design "MB" "$result")"
# 			
# 			echo "$file_path" >> "$list_files_with_php_code"
# 			echo "$file_path:1:PHP-NOPHP" >> "$total_scan_result"
# 		fi
# 	done < "$list_all_files"
# 			
# 	echo -ne "\r$(Design "BOLD" "$clfwpc2:") $(Design "MB" "$result")                                         \n"
# 			
# 	count_files_with_php_code=$(( $count_files_with_php_code+$result ))
# 			
# 	# выводим информацию:
# 	# clfwpc2=Количество файлов с расширением, НЕ допускающим использование PHP кода, но содержащие его
# 			
# 	Print_Separator
# fi


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
}

#-------------------------------------------------------------------------
################# ЭТАП ВТОРОЙ #######################################################################
#-------------------------------------------------------------------------


# Этап второй - обработка результатов.
function Step_Two(){
	Step_Two_Print_Titul	
}

#-------------------------------------------------------------------------

function Step_Two_Print_Titul(){
	Print_Separator_Two
	# st1=ЭТАП 2
	# st2=обработка результатов
	Print_String "\n$(Design "MB" "$stpt1:") $(Design "BOLD" "$stpt2.")"
	Print_Separator
}

#-------------------------------------------------------------------------

# получаем версию базы комбинаций алгоритмов
function Get_Step_Two_Base_Version(){
	local temp=`head -n 1 "$step_two_base"`
	
	if [[ "`echo $temp | grep -w  "STEP_TWO_BASE_VERSION"`" != "" ]];then
		STEP_TWO_BASE_VERSION=${temp#*=}
	fi
}

#-------------------------------------------------------------------------

# обрабатываем базу комбинированных критериев
function Step_Two_Read_Base(){
	IFS=
	local trigger=0
	while read -r str_base; do
		# отсеить строку с версией базы
		if [[ "`echo $str_base | grep 'STEP_TWO_BASE_VERSION'`" == "" && "$str_base" != "" ]];then
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
	done < "$step_two_base"

	IFS=$DEF_IFS
}

touch $total_scan_result