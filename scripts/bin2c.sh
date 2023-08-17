#!/bin/env sh

set -e

function usage() {
	cat <<EOF
Usage: $0 [options] <input files>
Options:
  -h           Display this message
	-p <prefix>  Prefix for the generated variables
	             (default: name of the header file without extension)
  -o <file>    Output header file
  -b <file>    Output binary file
EOF
}

HEADER=""
BINARY=""
PREFIX=""

while getopts "ho:b:p:" opt; do
	case $opt in
	h) usage; exit 0 ;;
	o) HEADER="$OPTARG" ;;
	b) BINARY="$OPTARG" ;;
	p) PREFIX="$OPTARG" ;;
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

if [[ -z "$PREFIX" ]]; then
	PREFIX=$(basename ${HEADER%.*})
fi

if [[ $# < 1 ]]; then
	echo "At least one input file is required"
	exit 1
fi

ld -r -z noexecstack -o "$BINARY" -b binary "$@"

NAME=$(basename ${HEADER%.*})
UPPER_NAME=${NAME^^}

cat <<EOF > "$HEADER"
#ifndef AOC_${UPPER_NAME}_HPP
#define AOC_${UPPER_NAME}_HPP

#include <cstdint>
#include <string_view>
#include <ranges>
#include <algorithm>

namespace aoc {

namespace detail {

extern "C" {
EOF

for INPUT in "$@"; do
	SYMBOL=${INPUT//[.\/-]/_}
	echo "extern const char _binary_${SYMBOL}_start[];" >> "$HEADER"
	echo "extern const char _binary_${SYMBOL}_end[];" >> "$HEADER"
done

echo -e "}\n" >> "$HEADER"

for INPUT in "$@"; do
	SYMBOL=${INPUT//[.\/-]/_}
	echo "static const size_t _binary_${SYMBOL}_size = _binary_${SYMBOL}_end - _binary_${SYMBOL}_start;" >> "$HEADER"
	echo "static const std::string_view _binary_${SYMBOL}{detail::_binary_${SYMBOL}_start, detail::_binary_${SYMBOL}_size};" >> "$HEADER"
done

echo -e "\n} // namespace detail\n" >> "$HEADER"

for INPUT in "$@"; do
	BASE=$(basename "${INPUT%.*}")
	SYMBOL=${INPUT//[.\/-]/_}

	cat <<EOF >> "$HEADER"
static const std::string_view ${PREFIX}_${BASE}{
	detail::_binary_${SYMBOL}.begin(),
	std::ranges::find_if_not(detail::_binary_${SYMBOL} | std::views::reverse,
		[](char c) { return std::isspace(c); }).base()
};
EOF
done

cat <<EOF >> "$HEADER"

} // namespace aoc

#endif /* end of include guard: AOC_${UPPER_NAME}_HPP */
EOF
