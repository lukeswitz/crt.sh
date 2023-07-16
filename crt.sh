#!/bin/bash

echo "
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|      ..| search crt.sh v1.1b1 |..   |
+   site : crt.sh Certificate Search  +
|            Twitter: az7rb           |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	"
	
# Helper function for printing usage
usage() {
    echo "Usage: $0 [-d domain_name | -o organization_name]"
    echo "Options:"
    echo "  -d  Search Domain Name       (e.g., $0 -d hackerone.com)"
    echo "  -o  Search Organization Name (e.g., $0 -o 'hackerone inc')"
    echo "  -h  Show this help message"
    exit 1
}

# Function for processing crt.sh response
process_response() {
    local req=$1
    local type=$2
    local response=$(curl -s "https://crt.sh?q=%.$req&output=json")

    if [[ -z "$response" ]]; then
        echo "No data received from crt.sh. Please check your query or try again later."
        exit 1
    fi

    local output_file="output/${type}.$req.txt"
    echo "$response" | \
        jq -r '.[] | .common_name, .name_value' | \
        sed -e 's/\\n/\n/g' -e 's/\*.//g' -e 's/\([A-Za-z0-9._%+-]*@[A-Za-z0-9.-]*\.[A-Za-z]{2,4}\)//g' | \
        sort -u > "$output_file"

    cat "$output_file"
    echo ""
    echo -e "\e[32m[+]\e[0m Total domains saved: \e[31m$(wc -l < "$output_file")\e[0m"
    echo -e "\e[32m[+]\e[0m Output saved in $output_file"
}

# Check if any option is passed
if [[ -z "$1" ]]; then
    usage
fi

# Ensure the output directory exists
mkdir -p output

# Parse options
while getopts "d:o:h" opt; do
    case ${opt} in
        d)
            process_response "$OPTARG" "domain"
            ;;
        o)
            process_response "$OPTARG" "org"
            ;;
        h|*)
            usage
            ;;
    esac
done
