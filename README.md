# TLALOC - Ada 83 Compiler

```
                            |
                         \\ | //
                       \\ u ^ u //                 /-------_______------\
                     \ )Y|Y|Y|Y|Y( /               |  T  h e            |
                       / /o o o\ \                 |  L  o n e s o m e  |
                      \|H|H|H|H|H|/                |  A  d a            |
                     G))  Q   Q  ((G               |  L  o v i n g      |
                      / \   "   / \                |  O  l't i m e r    |
                     /_/  \V¨V/  \_\               |  C  o m p i l e r  |
                         \vvvvv/                   \-------______-------/
                       \ooooooooo/
```

**Preserving the legacy of Ada 83 (MIL-STD-1815A-1983)**

[![Ada 83](https://img.shields.io/badge/Ada-83-blue.svg)](https://ada83.org)
[![License](https://img.shields.io/badge/license-check_repo-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Linux%20x86--64-lightgrey.svg)](https://github.com/ViMoBr/Ada83_TLALOC)

---

## 🚀 Why Ada 83 Matters

Ada 83 powered some of the most critical systems in computing history:
- **🚀 Aerospace**: Ariane 5 launcher, space missions
- **✈️ Aviation**: Boeing 777 flight control systems
- **🛡️ Defense**: Military embedded systems worldwide
- **🏭 Industrial**: Real-time control systems

TLALOC is an experimental compiler that preserves this heritage by implementing the full Ada 83 standard using modern development tools.

---

## ✨ Features

- **📜 Full Ada 83 Compliance**: Implements MIL-STD-1815A-1983 standard
- **🌳 DIANA 86 Representation**: Descriptive Intermediate Attributed Notation for Ada
- **🔧 Modern Toolchain**: Built with GNAT 13.3.0, generates text FASM assembly
- **📚 Separate Compilation**: Full library management with `.DCL`, `.BDY`, `.SUB` files
- **🐛 Debug-Friendly**: Multiple compilation phases with inspection options
- **⚡ Stack Machine Backend**: LLIR (Low Level Intermediate Representation) code generation for x86-64 and aarch64 v8

---

## 🏗️ Architecture

```
Source Code (.ada)
        ↓
   [PAR_PHASE]  ──→  Lexical & Syntax Analysis
        ↓
   [LIB_PHASE]  ──→  Library & Dependencies
        ↓
   [SEM_PHASE]  ──→  Semantic Analysis (65% of compiler)
        ↓
   [EXPANDER]   ──→  LLIR/FASM Generation  ─────────────→  FASM (fasmg)
        ↓                                                     ↓      
   [WRITE_LIB]  ──→  Library Output (.DCL/.BDY/.SUB)          ELF Executable
```

### Key Components

| Module | Lines | Role |
|--------|-------|------|
| **SEM_PHASE** | 22,193 | Semantic analysis (28 subunits) |
| **EXPANDER** | 5,971 | Code generation to FASM |
| **PAR_PHASE** | 1,924 | Lexical and syntactic analysis |
| **LIB_PHASE** | 1,230 | Library and dependency management |
| **IDL** | 2,123 | DIANA graph management |

---

## 🎯 Quick Start

### Prerequisites

- **Linux** (Ubuntu 24.04 or compatible)
- **GNAT** 13.3+ (Ada compiler for building TLALOC)
- **FASM** (Flat Assembler - g.kd3c or compatible)

### Installation

```bash
# Clone the repository
git clone https://github.com/ViMoBr/Ada83_TLALOC.git
cd Ada83_TLALOC
# make a build directory if not already present
mkdir ./build
# Recompile the compiler
make_ada_comp.sh

```

### First Program Uee

In the bin directory, there is a bash script named **a83.sh**.

The **a83.sh** script launches the executable **ada_comp** (in the same bin directory) with 3 required parameters :

 - the path to a so-called projet directory containing an **ADA__LIB** sub-directory (start with "./" that is the bin directory where you are, it contains the development **ADA__LIB**)
 - the path from the executable to the Ada 83 source text (for example **./dis_bonjour.adb** which is a french hello world)
 - a single option letter in S,s, L,l, M,m, C, c, W, w, U, A, P (the normal choice is W)

So the first command when in the **bin** directory is :

<pre> ./a83.sh  ./  ./dis_bonjour.adb  W  </pre>

(note : the first parameter ./ is the project directory path. The second path is project directory relative)
Then enter the **bin/ADA__LIB** sub-directory

<pre> cd ./ADA__LIB </pre>

 It contains a **DIS_BONJOUR.fas**, a **DIS_BONJOUR.FINC** and the fasmg assembly engine executable.

Enter the command :

<pre>./fasmg ./DIS_BONJOUR.fas</pre>

This creates an ELF executable **DIS_BONJOUR** in the **ADA__LIB** where you are.

Now finally enter the command :

<pre>./DIS_BONJOUR</pre>

The program displays **" Bonjour "**.

Hope it works on your computer...

## 📖 Compilation Options

TLALOC offers fine-grained control over compilation phases:

| Option | Phase | Description |
|--------|-------|-------------|
| **S**, **s** | Parse | Stop after syntax analysis |
| **L**, **l** | Library | Stop after library phase |
| **M**, **m** | Semantic | Stop after semantic analysis |
| **C**, **c** | Expand | Generate code (no library write) |
| **W** | Write | Full compilation with library output |
| **w** | Write (debug) | Library write without code generation |
| **U**, **P**, **A** | Pretty-print | Display DIANA tree (various formats) |

### Example: Debugging Semantic Analysis

```bash
# Stop after semantic phase and inspect DIANA tree
./ada_comp ./my_project my_program.ada M
./ada_comp ./my_project my_program.ada P  # Pretty-print DIANA
```

---

## 🧬 DIANA: The Heart of TLALOC

**DIANA** (Descriptive Intermediate Attributed Notation for Ada) is a standardized graph-based intermediate representation for Ada programs.

- **Nodes**: Represent language constructs (declarations, expressions, statements)
- **Attributes**: Semantic information attached to nodes
- **Graph Structure**: Captures program structure and dependencies
- **Storage**: Binary format in `ADA__LIB/$$$.TMP` during compilation

DIANA enables:
- Clear separation of compiler phases
- Easy debugging with `PRETTY_DIANA` tool
- Standardized intermediate format for Ada tools

---

## 📁 Project Structure

```
Ada83_TLALOC/
├── src/
│   ├── ada_comp/          # Main compiler driver
│   ├── par_phase/         # Parsing (LEX, GRMR_OPS, GRMR_TBL)
│   ├── sem_phase/         # Semantic analysis (28 subunits!)
│   ├── expander/          # Code generation
│   ├── pretty/            # DIANA pretty-printer
│   └── communs/           # Shared utilities (IDL management)
├── bin/
│   └── idl_tools/         # DIANA node definitions
└── examples/              # Example Ada 83 programs
```

---

## 🔬 Technical Details

### Target Platform
- **OS**: Linux (Ubuntu 24.04+)
- **Architecture**: x86-64
- **Assembler**: FASM (Flat Assembler)
- **Output**: ELF executables

### Compilation Statistics
- **Total code**: 34,344 lines
- **Number of files**: 82
- **Largest module**: SEM_PHASE (64.6% of codebase)
- **Frontend/Backend ratio**: 4.8:1 (typical for research compilers)

### Ada 83 Specifics
- ✅ Full separate compilation model
- ✅ Generic units and instantiation
- ✅ Tasking (concurrent programming)
- ✅ Representation clauses
- ❌ No Ada 95+ features (no child packages, protected types, etc.)

---

## 📚 Documentation

- **[Ada 83 Memory Wiki](https://ada83.org/wiki/)**: Language reference and tutorials
- **[Project Documentation](docs/)**: Compiler internals and architecture
- **[MIL-STD-1815A-1983](https://ada83.org/)**: Official Ada 83 standard (~270 pages)

### Key Documents
- `structure_TLALOC_compiler.md`: Module-by-module breakdown
- `RESUME_ANALYSE_TLALOC.txt`: Statistical analysis and metrics
- `doc_mise_en_place.md`: Project organization and setup

---

## 🤝 Contributing

TLALOC is a heritage preservation project. Contributions are welcome!

### Areas for Contribution
- 🧪 **Testing**: Ada 83 validation suite
- 📝 **Documentation**: User guides, tutorials
- 🐛 **Bug fixes**: Compiler issues
- ✨ **Features**: Optimization passes, better diagnostics
- 🎓 **Education**: Teaching materials for compiler construction

### Getting Started
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Test with Ada 83 programs
5. Submit a pull request

**Note**: TLALOC targets Ada 83 only. Please do not submit features from later Ada standards (Ada 95, 2005, 2012, 2022).

---

## 🎓 Educational Value

TLALOC serves as an excellent resource for:
- **Compiler Construction**: Clear phase separation, well-documented passes
- **Programming Language Theory**: Ada's type system, generics, tasking
- **Software Archaeology**: Understanding 1980s compiler technology
- **Formal Methods**: Ada's design-by-contract philosophy

### Code Quality
- **Modular Design**: 82 well-organized files
- **Clear Responsibilities**: Each subunit has a focused purpose
- **Extensive Comments**: Comprehensive inline documentation
- **Research-Grade**: Academic-quality implementation

---

## 🌐 Related Resources

- **[Ada 83 Official Site](https://ada83.org/)**: Language resources and community
- **[Framagit Mirror](https://framagit.org/VMo/ada-83-compiler-tools)**: Alternative repository
- **[Ada Information Clearinghouse](http://www.adaic.org/)**: Historical Ada information
- **[Ada 83 LRM](https://ada83.org/wiki/)**: Language Reference Manual

---

## 📜 Historical Context

Ada 83 was developed by the U.S. Department of Defense in the early 1980s to address the "software crisis" in embedded systems. Named after Augusta Ada Lovelace, the world's first programmer, Ada introduced revolutionary concepts:

- **Strong Typing**: Catch errors at compile-time
- **Generics**: Reusable, type-safe templates
- **Tasking**: Built-in concurrent programming
- **Packages**: Modular program organization
- **Exceptions**: Structured error handling

TLALOC preserves this heritage by providing a working implementation of the original 1983 standard.

---

## 📊 Project Status

**Current State**: ✅ Functional experimental compiler

- ✅ Parsing and lexical analysis complete
- ✅ Semantic analysis fully implemented
- ✅ Code generation to FASM working
- ✅ Library management operational
- 🔄 Ongoing: Bug fixes and validation
- 📝 Ongoing: Documentation improvements

---

## 🙏 Acknowledgments

- **Vincent Morin**: Project maintainer and primary developer
- **Jelle Hermsen**: Ada 83 Memory website collaboration
- **Ada Community**: For keeping the Ada legacy alive
- **Historical Compilers**: DEC Ada, Verdix Ada, Alsys Adaworld, Ada/Ed, Ada-minus - inspirations for this work
- **Current Compiler**: GNAT with -gnat83 flag

---

## 📬 Contact & Community

- **Website**: [https://ada83.org](https://ada83.org)
- **GitHub**: [https://github.com/ViMoBr/Ada83_TLALOC](https://github.com/ViMoBr/Ada83_TLALOC)
- **Framagit**: [https://framagit.org/VMo/ada-83-compiler-tools](https://framagit.org/VMo/ada-83-compiler-tools)

---

## ⚖️ License


TLALOC/Ada 83 uses SPDX license identifiers in its maintained source files.

The compiler sources and runtime are licensed under GPL-3.0-or-later, with the
GCC Runtime Library Exception 3.1 where applicable.

The development repository may contain archival, experimental, or research
material that is not part of the official distribution. Official release archives
are intended to contain only files with explicit licensing information.

See directory [LICENSES](LICENSES) and files for details.

---


**TLALOC** - *The Lonesome Ada Loving Ol'timer Compiler*

*Preserving 1980s software engineering excellence for future generations*

**[Explore the Code](https://github.com/ViMoBr/Ada83_TLALOC)** • **[Read the Docs](https://ada83.org/wiki/)** • **[Try Examples](examples/)**

---

Made with ❤️ for Ada and software heritage preservation

---
