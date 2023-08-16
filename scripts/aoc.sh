#!/bin/env sh

set -e

function usage() {
	cat <<EOF
Usage: $0 <command> [args]
Commands:
  help     Display this message
  setup    Setup the project
  init     Initialise a new day
  build    Build a day's solution
  run      Run a day's solution
  compdb   Generate a compilation database
EOF
}

CONFIG=config.json
SRC_DIR=src
DATA_DIR=data
SCRIPTS_DIR=scripts

BIN2C=$SCRIPTS_DIR/bin2c.sh
DOWNLOAD=$SCRIPTS_DIR/download.sh

BUILD_DIR=""
SESSION=""
YEAR=0

function prepare() {
	if ! [[ -f "$CONFIG" ]]; then
		echo "Config file not found"
		exit 1
	fi

	BUILD_DIR=$(jq -r '.build_dir' "$CONFIG")
	YEAR=$(jq -r '.year' "$CONFIG")
	SESSION=$(jq -r '.session' "$CONFIG")
}

function setup() {
	compiler_path=$(jq -r '.compiler.path' "$CONFIG")
	compiler_args=$(jq -r '.compiler.args[]' "$CONFIG")

	mkdir "$BUILD_DIR"
	mkdir "$DATA_DIR"
	mkdir "$DATA_DIR/html"
	mkdir "$DATA_DIR/inputs"
	mkdir "$DATA_DIR/markdown"
	mkdir "$DATA_DIR/objects"

	cat <<EOF > "build.ninja"
cxx = ${compiler_path}
cpp_args = $(echo $compiler_args)

rule cpp_compiler
  command = \$cxx \$cpp_args \$ARGS -MD -MQ \$out -MF \$DEPFILE -o \$out -c \$in
  depfile = \$DEPFILE
  description = Compiling C++ object \$out

rule cpp_linker
  command = \$cxx \$cpp_args \$ARGS -o \$out \$in \$LINK_ARGS
  description = Linking C++ executable \$out
EOF
}

function init() {
	day=$1

	if ! [[ -f "build.ninja" ]]; then
		echo "Please run setup first"
		exit 1
	fi

	if [[ -z "$day" ]]; then
		echo "Please specify a day"
		exit 1
	fi

	if ! [[ $day =~ ^[0-9]{1,2}$ ]] && [[ $day > 0 && day < 32 ]]; then
		echo "Day must be a one- or two-digit number between 1 and 31"
		exit 1
	fi

	if [[ -d "$SRC_DIR/$day" ]]; then
		echo "Day $day already exists"
		exit 1
	fi

	mkdir -p "$SRC_DIR/$day"

	./$DOWNLOAD \
		-s "$SESSION" \
		-d "$day" \
		-y "$YEAR" \
		-o "$DATA_DIR/inputs/$day.txt" \
		-t "$DATA_DIR/html/$day.html" \
		-m "$DATA_DIR/markdown/$day.md"

	./$BIN2C \
		-o "$SRC_DIR/$day/input.hpp" \
		-b "$DATA_DIR/objects/$day.o" \
		"$DATA_DIR/inputs/$day.txt"

	cat <<EOF > "$SRC_DIR/$day/$day.hpp"
#ifndef AOC_DAY_$day
#define AOC_DAY_$day

#include <cstdint>
#include <optional>
#include <string_view>

std::optional<uint64_t>
part_one(std::string_view);

std::optional<uint64_t>
part_two(std::string_view);

#endif /* end of include guard: AOC_DAY_$day */
EOF

	cat <<EOF > "$SRC_DIR/$day/$day.cpp"
#include "$day.hpp"

std::optional<uint64_t>
part_one(std::string_view input)
{ return std::nullopt; }

std::optional<uint64_t>
part_two(std::string_view input)
{ return std::nullopt; }
EOF

	cat <<EOF > "$SRC_DIR/$day/main.cpp"
#include <cstddef>
#include <cstdint>
#include <optional>
#include <string_view>

#include "$day.hpp"
#include "input.hpp"
#include "aoc.hpp"

int main()
{
  std::string_view input = aoc::input_$day;

  std::cout << "🎄 Part One 🎄\n";
  aoc::run(input, part_one);

  std::cout << "🎄 Part Two 🎄\n";
  aoc::run(input, part_two);
}
EOF

	cat <<EOF >> "build.ninja"

build $BUILD_DIR/$SRC_DIR/$day/$day.cpp.o: cpp_compiler $SRC_DIR/$day/$day.cpp
  DEPFILE = $BUILD_DIR/$SRC_DIR/$day/$day.cpp.o.d
  ARGS = -I$SRC_DIR
build $BUILD_DIR/$SRC_DIR/$day/main.cpp.o: cpp_compiler $SRC_DIR/$day/main.cpp
  DEPFILE = $BUILD_DIR/$SRC_DIR/$day/main.cpp.o.d
  ARGS = -I$SRC_DIR
build $BUILD_DIR/$SRC_DIR/$day/main: cpp_linker $BUILD_DIR/$SRC_DIR/$day/main.cpp.o $BUILD_DIR/$SRC_DIR/$day/$day.cpp.o $DATA_DIR/objects/$day.o
EOF
}

function run() {
	day=$1

	if ! [[ -f "build.ninja" ]]; then
		echo "Please run setup first"
		exit 1
	fi

	if [[ -z "$day" ]]; then
		echo "Please specify a day"
		exit 1
	fi

	if ! [[ $day =~ ^[0-9]{1,2}$ ]] && [[ $day > 0 && day < 32 ]]; then
		echo "Day must be a one- or two-digit number between 1 and 31"
		exit 1
	fi

	if ! [[ -d "$SRC_DIR/$day" ]]; then
		echo "Day $day doesn't exist"
		exit 1
	fi

	ninja "$BUILD_DIR/$SRC_DIR/$day/main"
	./$BUILD_DIR/$SRC_DIR/$day/main
}

function build() {
	day=$1

	if ! [[ -f "build.ninja" ]]; then
		echo "Please run setup first"
		exit 1
	fi

	if [[ $1 == "all" ]]; then
		ninja
		exit 0
	fi

	if [[ -z "$day" ]]; then
		echo "Please specify a day"
		exit 1
	fi

	if ! [[ $day =~ ^[0-9]{1,2}$ ]] && [[ $day > 0 && day < 32 ]]; then
		echo "Day must be a one- or two-digit number between 1 and 31"
		exit 1
	fi

	if ! [[ -d "$SRC_DIR/$day" ]]; then
		echo "Day $day doesn't exist"
		exit 1
	fi

	ninja "$BUILD_DIR/$SRC_DIR/$day/main"
}

function compdb() {
	if ! [[ -f "build.ninja" ]]; then
		echo "Please run setup first"
		exit 1
	fi

	ninja -t compdb > compile_commands.json
}

if [[ $# < 1 ]]; then
	usage
	exit 1
fi

prepare

case $1 in
	help) usage ;;
	setup) setup ;;
	init) init $2 ;;
	build) build $2 ;;
	run) run $2 ;;
	compdb) compdb ;;
	*) usage; exit 1 ;;
esac
