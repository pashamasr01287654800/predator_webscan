#!/bin/bash
# Predator_WebScan - A Savage Multi-tool Web Scanner
# Version: 1.0
#
# This script performs:
#   Web Directory/Fuzz Scanning by recursively replacing FUZZ placeholders.
#   If the target URL does NOT contain "FUZZ" but a wordlist is provided via -w,
#   the tool assumes directory scanning mode.
#
# IMPORTANT: If your URL contains special characters (e.g., &, ;, or |),
# either enclose the URL in quotes.
#
# Usage examples:
#   Web Fuzzing (with FUZZ placeholders):
#       ./predator_webscan.sh -u "http://example.com/FUZZ/FUZZ1" -w wordlist.txt -w1 wordlist1.txt
#
#   Directory Scanning (without FUZZ in the URL):
#       ./predator_webscan.sh -u "http://example.com/" -w pass.txt
#
# Use -h to display help.

# ----------------------- Colors & Style -----------------------
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
BOLD="\033[1m"
RESET="\033[0m"

# Tool version
TOOL_VERSION="1.0"

print_header() {
    echo -e "${CYAN}${BOLD}=========================================="
    echo -e "       $1"
    echo -e "       Predator_WebScan v${TOOL_VERSION}"
    echo -e "==========================================${RESET}"
}

# ----------------------- Global Variables -----------------------
target_url=""

# For FUZZ placeholders:
declare -A wordlist_data
declare -A wordlist_count
declare -A wordlist_filename  # Stores the filename as provided by the user

# ----------------------- Web Scanning / Fuzzing Functions -----------------------

print_wordlist_summary() {
    echo -e "${YELLOW}Wordlists used for FUZZ placeholders:${RESET}"
    for key in $(printf "%s\n" "${!wordlist_filename[@]}" | sort -n); do
        if [ "$key" -eq 0 ]; then
            echo -e "${YELLOW}FUZZ   : ${BOLD}${wordlist_filename[$key]}${RESET}"
        else
            echo -e "${YELLOW}FUZZ${key}: ${BOLD}${wordlist_filename[$key]}${RESET}"
        fi
    done
    echo ""
}

process_fuzz_url() {
    local url="$1"
    if [[ "$url" =~ FUZZ([0-9]*) ]]; then
        local placeholder="${BASH_REMATCH[0]}"
        local index="${BASH_REMATCH[1]}"
        if [ -z "$index" ]; then
            index=0
        fi
        local prefix="${url%%FUZZ*}"
        local suffix="${url#*$placeholder}"
        if [ -z "${wordlist_data[$index]}" ]; then
            process_fuzz_url "${prefix}${suffix}"
            return
        fi
        for word in ${wordlist_data[$index]}; do
            local new_url="${prefix}${word}${suffix}"
            process_fuzz_url "$new_url"
        done
    else
        local http_code
        http_code=$(curl -s -o /dev/null -w "%{http_code}" "$url")
        if [ "$http_code" != "404" ]; then
            echo -e "${BLUE}[WEB]${RESET} $url -> ${GREEN}$http_code${RESET}"
        fi
    fi
}

run_web_scanner() {
    if [ -z "$target_url" ]; then
        echo -e "${RED}No target URL provided for web scanning.${RESET}"
        return
    fi
    # If URL does NOT contain "FUZZ" but wordlist for index 0 is provided, assume directory scanning.
    if [[ "$target_url" != *"FUZZ"* ]] && [ -n "${wordlist_data[0]}" ]; then
        if [[ "$target_url" != */ ]]; then
            target_url="${target_url}/"
        fi
        print_header "DIRECTORY SCAN REPORT"
        echo -e "${YELLOW}Scanning target directory: ${BOLD}$target_url${RESET}"
        if [ -n "${wordlist_filename[0]}" ]; then
            echo -e "${YELLOW}Using wordlist: ${BOLD}${wordlist_filename[0]}${RESET}\n"
        fi
        for word in ${wordlist_data[0]}; do
            new_url="${target_url}${word}"
            http_code=$(curl -s -o /dev/null -w "%{http_code}" "$new_url")
            if [ "$http_code" != "404" ]; then
                echo -e "${BLUE}[DIR]${RESET} $new_url -> ${GREEN}$http_code${RESET}"
            fi
        done
    else
        print_header "WEB SCAN REPORT"
        echo -e "${YELLOW}Scanning URL: ${BOLD}$target_url${RESET}\n"
        if [[ "$target_url" == *"FUZZ"* ]]; then
            print_wordlist_summary
        fi
        process_fuzz_url "$target_url"
    fi
}

# ----------------------- Argument Parsing -----------------------

print_usage() {
    cat <<EOF
Usage: $0 [options]

Options:
  -u <target-url>      : Specify target URL for web scanning/fuzzing.
                         IMPORTANT: If your URL contains special characters
                         (e.g., &, ;, or |), enclose it in quotes "<target-url>".
  -w[<num>] <wordlist> : Specify wordlist for FUZZ placeholders.
                         Use -w for FUZZ (index 0), -w1 for FUZZ1, -w2 for FUZZ2, -w3 for FUZZ3 etc.
  -h                   : Display this help message.
EOF
}

if [ $# -eq 0 ]; then
    print_usage
    exit 1
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        -u)
            shift
            target_url="$1"
            shift
            while [[ $# -gt 0 && "$1" != -* ]]; do
                target_url="$target_url $1"
                shift
            done
            ;;
        -w*)
            opt="$1"
            key="${opt:2}"
            if [ -z "$key" ]; then
                key=0
            fi
            if [ -n "$2" ]; then
                file="$2"
                if [ ! -f "$file" ]; then
                    echo -e "${RED}Wordlist file '$file' not found.${RESET}"
                    exit 1
                fi
                wordlist_data["$key"]=$(sed '/^\s*$/d' "$file" | tr '\n' ' ')
                wordlist_count["$key"]=$(wc -l < "$file")
                wordlist_filename["$key"]="$file"
                shift 2
            else
                echo -e "${RED}Missing wordlist file for option $opt${RESET}"
                exit 1
            fi
            ;;
        -h)
            print_usage
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${RESET}"
            print_usage
            exit 1
            ;;
    esac
done

# ----------------------- Main Execution -----------------------

if [ -n "$target_url" ]; then
    run_web_scanner
else
    echo -e "${RED}No target URL provided. Use -h for help.${RESET}"
    exit 1
fi