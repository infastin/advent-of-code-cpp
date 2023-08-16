#!/bin/env sh

set -e

function usage() {
	cat <<EOF
Usage: $0 [options] <input file>
Options:
  -h           Display this message
	-s <suffix>  Suffix of the input variable
	             (default: name of the input file)
  -o <file>    Output header file
  -b <file>    Output binary file
EOF
}

HEADER=""
BINARY=""
SUFFIX=""

while getopts "ho:b:s:" opt; do
	case $opt in
	h) usage; exit 0 ;;
	o) HEADER="$OPTARG" ;;
	b) BINARY="$OPTARG" ;;
	s) SUFFIX="$OPTARG" ;;
	*) usage; exit 1 ;;
	esac
done

shift $((OPTIND-1))

if [[ -z "$HEADER" ]]; then
	echo "Output header file is required"
	exit 1
fi

if [[ -z "$BINARY" ]]; then
	echo "Output binary file is required"
	exit 1
fi

if [[ $# != 1 ]]; then
	echo "Input file is required"
	exit 1
else
	INPUT="$1"
	if ! [[ -f "$INPUT" ]]; then
		echo "Input file does not exist"
		exit 1
	fi
fi

if [[ -z "$SUFFIX" ]]; then
	SUFFIX=$(basename "${INPUT%.*}")
fi

BASE=$(basename ${HEADER%.*})
SYMBOL=${INPUT//[.\/-]/_}
UPPER_SYMBOL=$(echo "$SYMBOL" | tr '[:lower:]' '[:upper:]')

ld -r -z noexecstack -b binary "$INPUT" -o "$BINARY"

cat <<EOF > "$HEADER"
#ifndef AOC_$UPPER_SYMBOL
#define AOC_$UPPER_SYMBOL

#include <cstdint>
#include <string_view>

namespace aoc {

namespace detail {

extern "C" {
	extern const char _binary_${SYMBOL}_start[];
	extern const char _binary_${SYMBOL}_end[];
}

static const std::size_t _binary_${SYMBOL}_size = _binary_${SYMBOL}_end - _binary_${SYMBOL}_start;

} // namespace detail

static const std::string_view input_${SUFFIX}{detail::_binary_${SYMBOL}_start, detail::_binary_${SYMBOL}_size};

} // namespace aoc

#endif /* end of include guard: AOC_$UPPER_SYMBOL */
EOF
