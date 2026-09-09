#!/usr/bin/env bash

# exec > build.log 2>&1

./hardware-info.sh > hardware-info.tex
./steady.sh

source ../.venv/bin/activate
./analysis.py
./perfanalysis.py

latexmk -pdf main.tex


