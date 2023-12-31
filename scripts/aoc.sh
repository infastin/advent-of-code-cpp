#!/bin/env sh

set -e

function usage() {
	cat <<EOF
Usage: $0 <command> [args]
Commands:
  help      Display this message
  setup     Setup the project
  init      Initialise a new day
  build     Build a day's solution and tests
  run       Run a day's solution
  test      Run a day's tests
  compdb    Generate a compilation database
  examples  Regenerate an examples' header and object files
  input     Regenarate an input's header and object files
  download  Download a day's input and HTML
EOF
}

CONFIG=config.json
SRC_DIR=src
DATA_DIR=data
SCRIPTS_DIR=scripts
SESSION_FILE=.aoc_session

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

	if [[ -f "$SESSION_FILE" ]]; then
		SESSION=$(cat "$SESSION_FILE")
	fi
}

function assert_buildfile() {
	if ! [[ -f "build.ninja" ]]; then
		echo "Please run setup first"
		exit 1
	fi
}

function assert_day() {
	day=$1

	if [[ -z "$day" ]]; then
		echo "Please specify a day"
		exit 1
	fi

	if ! [[ $day =~ ^[0-9]{1,2}$ ]] && [[ $day > 0 && day < 32 ]]; then
		echo "Day must be a one- or two-digit number between 1 and 31"
		exit 1
	fi
}

function assert_day_exists() {
	day=$1
	assert_day $day

	if ! [[ -d "$SRC_DIR/$day" ]]; then
		echo "Day $day doesn't exist"
		exit 1
	fi
}

function assert_day_not_exists() {
	day=$1
	assert_day $day

	if [[ -d "$SRC_DIR/$day" ]]; then
		echo "Day $day already exists"
		exit 1
	fi
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
	mkdir "$DATA_DIR/examples"

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

	assert_buildfile
	assert_day_not_exists $day

	mkdir -p "$SRC_DIR/$day"
	mkdir -p "$DATA_DIR/examples/$day"
	touch "$DATA_DIR/examples/$day/1.txt"

	if [[ -n "$SESSION" ]]; then
		command $DOWNLOAD \
			-s "$SESSION" \
			-d "$day" \
			-y "$YEAR" \
			-o "$DATA_DIR/inputs/$day.txt" \
			-t "$DATA_DIR/html/$day.html" \
			-m "$DATA_DIR/markdown/$day.md"
	else
		touch "$DATA_DIR/inputs/$day.txt"
	fi

	command $BIN2C \
		-o "$SRC_DIR/$day/input.hpp" \
		-b "$DATA_DIR/objects/input$day.o" \
		-p "input" \
		"$DATA_DIR/inputs/$day.txt"

	command $BIN2C \
		-o "$SRC_DIR/$day/examples.hpp" \
		-b "$DATA_DIR/objects/examples$day.o" \
		-p "example" \
		$DATA_DIR/examples/$day/*.txt

	cat <<EOF > "$SRC_DIR/$day/$day.hpp"
#ifndef AOC_DAY_${day}_HPP
#define AOC_DAY_${day}_HPP

#include <cstdint>
#include <optional>
#include <string_view>

// You can adjust return types,
// but not function names and arguments

std::optional<uint64_t>
part_one(std::string_view);

std::optional<uint64_t>
part_two(std::string_view);

#endif /* end of include guard: AOC_DAY_${day}_HPP */
EOF

	cat <<EOF > "$SRC_DIR/$day/$day.cpp"
#include "$day.hpp"

// You can adjust return types,
// but not function names and arguments

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
#include <string_view>

#include "$day.hpp"
#include "input.hpp"
#include "aoc.hpp"

int main()
{
  // You may need to adjust the template parameters
  aoc::run_all<uint64_t>(aoc::input_${day}, part_one, part_two);
}
EOF

cat <<EOF >> "$SRC_DIR/$day/test.cpp"
#include <cstddef>
#include <cstdint>
#include <string_view>
#include <cassert>
#include <optional>

#include "$day.hpp"
#include "examples.hpp"
#include "aoc.hpp"

int main()
{
  // Write your tests here
  // Don't forget to adjust expected values
  // You may also need to adjust the template parameters
  aoc::run_test_all<uint64_t>(aoc::example_1, part_one, part_two, std::nullopt, std::nullopt);
}
EOF

	cat <<EOF >> "build.ninja"

build $BUILD_DIR/$SRC_DIR/$day/$day.cpp.o: cpp_compiler $SRC_DIR/$day/$day.cpp
  DEPFILE = $BUILD_DIR/$SRC_DIR/$day/$day.cpp.o.d
  ARGS = -I$SRC_DIR
build $BUILD_DIR/$SRC_DIR/$day/main.cpp.o: cpp_compiler $SRC_DIR/$day/main.cpp
  DEPFILE = $BUILD_DIR/$SRC_DIR/$day/main.cpp.o.d
  ARGS = -I$SRC_DIR
build $BUILD_DIR/$SRC_DIR/$day/test.cpp.o: cpp_compiler $SRC_DIR/$day/test.cpp
  DEPFILE = $BUILD_DIR/$SRC_DIR/$day/test.cpp.o.d
  ARGS = -I$SRC_DIR
build $BUILD_DIR/$SRC_DIR/$day/main: cpp_linker $BUILD_DIR/$SRC_DIR/$day/main.cpp.o $BUILD_DIR/$SRC_DIR/$day/$day.cpp.o $DATA_DIR/objects/input$day.o
build $BUILD_DIR/$SRC_DIR/$day/test: cpp_linker $BUILD_DIR/$SRC_DIR/$day/test.cpp.o $BUILD_DIR/$SRC_DIR/$day/$day.cpp.o $DATA_DIR/objects/examples$day.o
EOF
}

function run() {
	day=$1

	assert_buildfile
	assert_day_exists $day

	ninja "$BUILD_DIR/$SRC_DIR/$day/main"
	command $BUILD_DIR/$SRC_DIR/$day/main
}

function test() {
	day=$1

	assert_buildfile
	assert_day_exists $day

	ninja "$BUILD_DIR/$SRC_DIR/$day/test"
	command $BUILD_DIR/$SRC_DIR/$day/test
}

function build() {
	day=$1

	assert_buildfile

	if [[ -z $day ]] || [[ $day == "all" ]]; then
		ninja
		exit 0
	fi

	assert_day_exists $day

	ninja "$BUILD_DIR/$SRC_DIR/$day/main"
	ninja "$BUILD_DIR/$SRC_DIR/$day/test"
}

function compdb() {
	assert_buildfile
	ninja -t compdb > compile_commands.json
}

function examples() {
	day=$1

	assert_buildfile
	assert_day_exists $day

	command $BIN2C \
		-o "$SRC_DIR/$day/examples.hpp" \
		-b "$DATA_DIR/objects/examples$day.o" \
		-p "example" \
		$DATA_DIR/examples/$day/*.txt
}

function input() {
	day=$1

	assert_buildfile
	assert_day_exists $day

	command $BIN2C \
		-o "$SRC_DIR/$day/input.hpp" \
		-b "$DATA_DIR/objects/input$day.o" \
		-p "input" \
		"$DATA_DIR/inputs/$day.txt"
}

function download() {
	day=$1

	assert_buildfile
	assert_day_exists $day

	if [[ -z "$SESSION" ]]; then
		echo "Please set your session cookie in $SESSION_FILE"
		exit 1
	fi

	command $DOWNLOAD \
		-s "$SESSION" \
		-d "$day" \
		-y "$YEAR" \
		-o "$DATA_DIR/inputs/$day.txt" \
		-t "$DATA_DIR/html/$day.html" \
		-m "$DATA_DIR/markdown/$day.md"
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
	test) test $2 ;;
	compdb) compdb ;;
	examples) examples $2 ;;
	input) input $2 ;;
	download) download $2 ;;
	*) usage; exit 1 ;;
esac
