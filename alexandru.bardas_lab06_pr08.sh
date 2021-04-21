#!/bin/bash

declare -A elements
deposit="depozit.csv";

while IFS= read -r line;
do
    IFS=',' read -r -a strarr <<< "$line";

	declare -i aux=${strarr[1]};
	elements["${strarr[0]}"]=$aux;

done < "$deposit"

IFS=$Field_Separator

for item in "$@";
do
	read -r line < "$item";
	tail -n +2 "$item" > "$item.new";

	if [ "$line" = "IN" ]; then

		while IFS= read -r line;
			do
				IFS=',' read -r -a strarr <<< "$line";

				if [ -z "$line" ];then
					break;
				fi

				if [ ${#strarr[*]} -lt 2 ]; then
					continue;
				fi

				check=`grep "${strarr[0]}" "$deposit"`;

				if [ -z "$check" ]; then
					declare -i aux=${strarr[1]};
					elements["${strarr[0]}"]=$aux;
					continue;
				fi

				elements["${strarr[0]}"]=$((${elements["${strarr[0]}"]}+${strarr[1]}));

			done < "$item.new"
	else

		while IFS= read -r line;
			do
				IFS=',' read -r -a strarr <<< "$line";

				if [ -z "$line" ];then
					break;
				fi

				if [ ${#strarr[*]} -lt 2 ]; then
					continue;
				fi

				check=`grep "${strarr[0]}" "$deposit"`;

				if [ -z "$check" ]; then
					continue;
				fi

				if [ $((${elements["${strarr[0]}"]}-${strarr[1]})) -lt 0 ]; then
					elements["${strarr[0]}"]=0;
					continue;
				fi

				elements["${strarr[0]}"]=$((${elements["${strarr[0]}"]}-${strarr[1]}));

			done < "$item.new"
	fi
	rm "$item.new"
done

IFS=$Field_Separator

for key in "${!elements[@]}";
do
	awk -v key="$key" -v value=${elements["$key"]} -F ',' 'BEGIN{OFS=",";} {if($1==key) $2=value;print $0}' "$deposit" > tmp && mv tmp "$deposit";
done
