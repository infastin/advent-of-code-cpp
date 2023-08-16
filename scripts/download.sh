#!/bin/env sh

set -e

function usage() {
	cat <<EOF
Usage: $0 [options]
Options:
  -h             Display this message
  -o <file>      Output input file
  -t <file>      Output html file
  -m <file>      Output markdown file
  -d <number>    Day
  -y <number>    Year
  -s <session>   Session cookie
EOF
}

OUTPUT=""
HTML=""
MARKDOWN=""
DAY=1
YEAR=2022

while getopts "ho:s:d:y:t:m:" opt; do
	case $opt in
	h) usage; exit 0 ;;
	o) OUTPUT="$OPTARG" ;;
	t) HTML="$OPTARG" ;;
	m) MARKDOWN="$OPTARG" ;;
	s) SESSION="$OPTARG" ;;
	d) DAY="$OPTARG" ;;
	y) YEAR="$OPTARG" ;;
	*) usage; exit 1 ;;
	esac
done

if [[ -z "$SESSION" ]]; then
	echo "Please specify a session cookie"
	exit 1
fi

if ! [[ $DAY =~ ^[0-9]{1,2}$ ]] && [[ $DAY > 0 && $DAY < 32 ]]; then
	echo "Day must be a one- or two-digit number between 1 and 31"
	exit 1
fi

if ! [[ $YEAR =~ ^[0-9]{4}$ ]] && [[ $YEAR > 2000 && $YEAR < 2100 ]]; then
	echo "Year must be a four-digit number between 2000 and 2099"
	exit 1
fi

if [[ -n "$OUTPUT" ]]; then
	curl -s -b "session=$SESSION" "https://adventofcode.com/$YEAR/day/$DAY/input" > "$OUTPUT"
elif [[ -z "$HTML" && -z "$MARKDOWN" ]]; then
	curl -s -b "session=$SESSION" "https://adventofcode.com/$YEAR/day/$DAY/input"
fi

if [[ -n "$HTML" ]]; then
	curl -s -b "session=$SESSION" "https://adventofcode.com/$YEAR/day/$DAY" | sed -n "/<main>/,/<\/main>/p" > "$HTML"
fi

if [[ -n "$MARKDOWN" ]]; then
	if [[ -n "$HTML" ]]; then
		sed -n "/<main>/,/<\/main>/p" "$HTML" | pandoc -f html -t markdown_strict-raw_html -o "$MARKDOWN"
	elif command -v pandoc &>/dev/null; then
		curl -s -b "session=$SESSION" "https://adventofcode.com/$YEAR/day/$DAY" \
			| sed -n "/<main>/,/<\/main>/p" \
			| pandoc -f html -t markdown_strict-raw_html -o "$MARKDOWN"
	fi
fi
