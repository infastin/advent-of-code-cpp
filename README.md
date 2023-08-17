# 🎄 Advent of Code Template for C++ 🎄

## Setup

This template only works on UNIX-like OS.

### Dependencies

Required:  
- C++ compiler with C++20 support: `g++`, `clang` or any other
- `bash`, `coreutils`, `curl`, `jq`, `ninja`

Optional:  
- `pandoc` - needed to convert html to markdown

### Create your repository

1. Open [the template repository](https://github.com/infastin/advent-of-code-cpp) on GitHub.
2. Click [Use this template](https://github.com/infastin/advent-of-code-cpp/generate) and create your repository.
3. Clone your repository to your computer.

### Configuration

Inside of `config.json` set the year and session cookie.
Also you can change the build directory, path to the compiler and compiler arguments.

```json
{
  "year": 2022,
  "session": "",
  "build_dir": "build",
  "compiler": {
    "path": "/usr/bin/g++",
    "args": [
      "-std=c++20",
      "-g",
      "-Wall",
      "-Wextra",
      "-Wpedantic",
      "-Werror=format=2",
      "-Werror=init-self",
      "-Werror=missing-include-dirs",
      "-Werror=pointer-arith",
      "-fsanitize=address",
      "-fdiagnostics-color=always"
    ]
  }
}
```

### Setup

Once you are done with configuration, run `./aoc setup`.
This will create all necessary directories and files.

## Usage

### Initialize a day

```bash
./aoc init <day>
```

This will download an input file and a puzzle description from the [Advent of Code](https://adventofcode.com) as html,
create a description as markdown (if `pandoc` is installed) and create the
`src/<day>` directory with `main.cpp`, `input.hpp`, `<day>.hpp` and `<day>.cpp`.

You can freely edit the `<day>.hpp` and `<day>.cpp` files,
but don't change the function names and parameters.

### Build a solution

```bash
./aoc build <day>
```

This will build the solution and tests for the given day.

Also you can write the following to build all solutions and tests:
```bash
./aoc build all
```

### Run a solution

```bash
./aoc run <day>
```

This will build and run the solution for the given day.

### Testing

Write your example input to file `data/examples/<day>/1.txt` or create
a new file inside of `data/examples/<day>` directory.

Then run `./aoc examples <day>` to regenerate header and object files for day `<day>`.
Then update expected values inside of `src/<day>/test.cpp` or add new tests
inside of that file. Then run `./aoc test <day>` to run the tests.

### compile_commands.json

If you need to use `compile_commands.json`, you can generate it with the following command:
```bash
./aoc compdb
```
