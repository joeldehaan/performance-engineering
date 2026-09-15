#!/usr/bin/env bash

cd 2/
sudo ./mem-info.sh
./l3-bench.sh
./run-benchmark.sh
./analysis.py

cd ..
pdflatex main.tex
