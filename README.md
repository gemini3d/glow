
# GLOW

[![Actions Status](https://github.com/gemini3d/GLOW/workflows/ci/badge.svg)](https://github.com/gemini3d/GLOW/actions)

The GLobal airglOW Model

This directory contains:
   Fortran-90 source code files,
   Makefiles,
   Example input and output files,
   Example job script,
   Subdirectory data/ contains input data files,
   Subdirectory data/iri90 contains IRI input data files


# Getting Started

Building GLOW from the base directory:

```
cmake -B build
cmake --build build
```

Running the basic program from the base directory:  
```
./build/glowbasic ./basic.nml
```
