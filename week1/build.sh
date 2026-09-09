#!/usr/bin/env bash

# exec > build.log 2>&1

./steady.sh

source ../.venv/bin/activate
./analysis.py

latexmk -pdf main.tex


