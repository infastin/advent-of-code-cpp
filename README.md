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

Inside of `config.json` set the year. Also you change the build directory,
path to the compiler and compiler arguments.

```json
{
  "year": 2022,
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
      "-fdiagnostics-color=always",
      "-funsigned-char"
    ]
  }
}
```

Inside of `.aoc_session` file set your session cookie from the [Advent of Code](https://adventofcode.com),
if you want to download inputs and puzzle descriptions.

> In order to download inputs, you must be logged into your Advent of Code account.
> 
> In Chromium-based browsers, you can get your session cookie by pressing F12, going to the Application tab,
> and copying the value of the `session` cookie.
> 
> In Firefox, you can get your session cookie by pressing F12, going to the Storage tab,
> and copying the value of the `session` cookie.

### Setup

Once you are done with configuration, run `./aoc setup`.
This will create all necessary directories and files:
```bash
.
├── build                     # Build directory
├── build.ninja               # Ninja build file
├── data                      # Data directory
│   ├── examples              # Examples directory
│   │   └── <day>             # Directory containing examples for day <day> 
│   │       └── <example>.txt # Text files with examples of input data
│   ├── html                  # Directory containing html files with puzzle descriptions
│   │   └── <day>.html        # Html file with puzzle description for day <day>
│   ├── inputs                # Directory containing input files
│   │   └── <day>.txt         # Input file for day <day>
│   ├── markdown              # Directory containing markdown files with puzzle descriptions
│   │   └── <day>.md          # Markdown file with puzzle description for day <day>
│   └── objects               # Directory containing object files, that contain examples and input as binary data
│       ├── examples<day>.o   # Object file with examples for day <day>
│       └── input<day>.o      # Object file with input for day <day>
└── src                       # Directory containing solutions and tests
    └─── <day>                # Directory containing solutions and tests for day <day>
```

## Usage

### Initialize a day

```bash
./aoc init <day>
```

If session cookie inside of `config.json` is set, this will download
an input file and a puzzle description from the [Advent of Code](https://adventofcode.com) as html,
create a description as markdown (if `pandoc` is installed).
Otherwise, it will just create an empty input file.

In both cases it will create the `src/<day>` directory with a bunch of files:
```bash
src/<day>
├── <day>.cpp     # Source file with solution
├── <day>.hpp     # Header file for the solution
├── examples.hpp  # Header file with examples, do not edit
├── input.hpp     # Header file with an input, do not edit
├── main.cpp      # File that runs the solution
└── test.cpp      # File that contains tests
```

### Download an input and a puzzle description

First of all, you need to set the session cookie inside of `config.json`.
Then you can run the following command:
```bash
./aoc download <day>
```

This will download an input file and a puzzle description from the [Advent of Code](https://adventofcode.com) as html,
create a description as markdown (if `pandoc` is installed).

The you need to regenerate an input's header and object files. See below.

### Regenerate an input's header and object files

If you have updated the input file, you need to regenerate its header and object files:
```bash
./aoc input <day>
```

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
