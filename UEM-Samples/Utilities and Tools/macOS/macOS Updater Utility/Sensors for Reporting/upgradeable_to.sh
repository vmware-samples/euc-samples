#!/usr/bin/env bash

#compare version numbers of two OS versions or floating point numbers up to 3 dots
compare_numbers() {
    #echo "Comparing $1 and $2"
    IFS='.' read -r -a os1 <<< "$1"
    IFS='.' read -r -a os2 <<< "$2"

    counter=0

    if [[ "${#os1[@]}" -gt "${#os2[@]}" ]]; then
        counter="${#os1[@]}"
    else
        counter="${#os2[@]}"
    fi

    for (( k=0; k<counter; k++ )); do

        # If the arrays are different lengths and we get to the end, then whichever array is longer is greater
        if [[ "${os1[$k]:-}" ]] && ! [[ "${os2[$k]:-}" ]]; then
            echo "gt"
            return 0
        elif [[ "${os2[$k]:-}" ]] && ! [[ "${os1[$k]:-}" ]]; then
            echo "lt"
            return 0
        fi

        if [[ "${os1[$k]}" != "${os2[$k]}" ]]; then
            t1="${os1[$k]}"
            t2="${os2[$k]}"

            alphat1=${t1//[^a-zA-Z]}; alphat1=${#alphat1}
            alphat2=${t2//[^a-zA-Z]}; alphat2=${#alphat2}

            # replace alpha characters with ascii value and make them smaller for comparison
            if [[ "$alphat1" -gt 0 ]]; then
                temp1=""
                for (( j=0; j<${#t1}; j++ )); do
                    if [[ ${t1:$j:1} = *[[:alpha:]]* ]]; then
                        g=$(LC_CTYPE=C printf '%d' "'${t1:$j:1}")
                        g=$((g-40))
                        temp1="$temp1$g"
                    else
                        temp1="$temp1${t1:$j:1}"
                    fi

                done
                t1="$temp1"
            fi
            # replace alpha characters with ascii value and make them smaller for comparison
            if [[ "$alphat2" -gt 0 ]]; then
                temp2=""
                for (( j=0; j<${#t2}; j++ )); do
                    if [[ ${t2:$j:1} = *[[:alpha:]]* ]]; then
                        g=$(LC_CTYPE=C printf '%d' "'${t2:$j:1}")
                        g=$((g-40))
                        temp2="$temp2$g"
                    else
                        temp2="$temp2${t2:$j:1}"
                    fi

                done
                t2="$temp2"
            fi

            if [[ "$t1" -gt "$t2" ]]; then
                echo "gt"
                return 0
            elif [[ "$t1" -lt "$t2" ]]; then
                echo "lt"
                return 0
            fi
        fi
    done

    echo "eq"

}

# compares two numbers n1 > n2 including floating point numbers
gt() {
    result=$(compare_numbers "$1" "$2")
    if [[ "$result" == "gt" ]]; then
        return 0
    else
        return 1
    fi
}

# compares two numbers n1 > n2 including floating point numbers
lt() {
    result=$(compare_numbers "$1" "$2")
    if [[ "$result" == "lt" ]]; then
        return 0
    else
        return 1
    fi
}

# compares two numbers n1 >= n2 including floating point numbers
ge() {
    result=$(compare_numbers "$1" "$2")
    if [[ "$result" == "gt" ]]; then
        return 0
    elif [[ "$result" == "eq" ]]; then
        return 0
    else
        return 1
    fi
}

# compares two numbers n1 >= n2 including floating point numbers
le() {
    result=$(compare_numbers "$1" "$2")
    if [[ "$result" == "lt" ]]; then
        return 0
    elif [[ "$result" == "eq" ]]; then
        return 0
    else
        return 1
    fi
}

# compares two numbers n1 == n2 including floating point numbers
eq() {
    result=$(compare_numbers "$1" "$2")
    if [[ "$result" == "eq" ]]; then
        return 0
    else
        return 1
    fi
}

os_list=$(softwareupdate --list-full-installers | awk -F 'Version: |, Size' '/Title:/{print $2}')
IFS=$'\n'
os_list=($(sort -r --numeric-sort <<<"${os_list[*]}"))
currentOS=$(sw_vers -productVersion)
unset IFS
full_list=""
for os in "${os_list[@]}"; do
    if gt "$os" "$currentOS"; then
        full_list="$os,$full_list"
    fi
done
if [ -n "$full_list" ]; then
    full_list="${full_list:0:(${#full_list}-1)}"
else
    full_list="0"
fi

echo "Upgradable to: ${full_list}"
