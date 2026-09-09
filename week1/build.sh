#!/usr/bin/env bash

# exec > build.log 2>&1

# ./perf.sh
# ./steady.sh

./hardware-info.sh > hardware-info.tex

source ../.venv/bin/activate

./analysis.py
./perfanalysis.py

latexmk -pdf main.tex


