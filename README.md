# RPN Calculator in Zig

This is a simple Reverse Polish Notation (RPN) calculator written in Zig.

This program was created with the help of Google's Gemini.

## Features

- Calculates mathematical expressions in RPN.
- Supports addition (`+`), subtraction (`-`), multiplication (`*`), and division (`/`).
- Can read formulas from the command line, a file, or an interactive REPL.

## Requirements

- [Zig](https://ziglang.org/download/) (latest version recommended)

## Building

To build the calculator, run the following command:

```sh
zig build
```

This will create an executable at `zig-out/bin/rpn-calc-zig`.

## Usage

There are three ways to use the calculator:

### 1. Calculate a formula directly

Use the `--formula` flag to pass an RPN expression.

```sh
zig build run -- --formula "10 5 -"
5
```

```sh
zig build run -- --formula "5 3 4 + * 2 /"
17.5
```

### 2. Calculate from a file

Use the `--file` flag to specify a file containing one RPN expression per line.

An example `formulas.txt` is included:

```
1 2 +
10 5 -
2 3 *
10 2 /
```

```sh
zig build run -- --file formulas.txt
3
5
6
5
```

### 3. Interactive Mode (REPL)

Run the calculator without any arguments to start an interactive session. Type an RPN expression and press Enter. Type `quit` or `Ctrl+D` to exit.

```sh
zig build run
> 1 2 +
3
> 10 5 -
5
> quit
```

### Other Commands

#### Show Help

```sh
zig build run -- --help
```

#### Show Version

```sh
zig build run -- --version
```

## Testing

To run the unit tests and end-to-end tests, use the following commands:

```sh
# Run unit tests
zig build test

# Run end-to-end tests
zig build e2e
```
