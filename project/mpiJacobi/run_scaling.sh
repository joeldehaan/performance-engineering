#!/bin/bash
# run_scaling.sh - strong and weak scaling measurements of the MPI Jacobi solver.
#
#   ./run_scaling.sh                       # defaults below
#   PLIST="1 2 4 8 16" REPS=5 ./run_scaling.sh
#   MPIRUN_OPTS="--bind-to core" ./run_scaling.sh
#
# Then:  python3 analyze_scaling.py --dir results
#
# Grid sizes are LX x LY INTERIOR cells (compile-time NX=LX+2, NY=LY+2 incl. ghost
# layer). The domain is split along y, so P must be <= LY.
# The solver is run for a FIXED number of iterations (ITERS, EPS=1e-300 = never reached; EPS=0 would skip the loop): with
# convergence-based stopping the iteration count changes with the grid size and
# would distort the comparison. Latency = wall time of the solver loop (TIME_S);
# the analysis also reports it per iteration.
set -euo pipefail
cd "$(dirname "$0")"

ITERS=${ITERS:-1000}                    # iterations per run
PLIST=${PLIST:-"1 2 4 8"}               # MPI rank counts
REPS=${REPS:-3}                         # repetitions per (case, P)
STRONG_LX=${STRONG_LX:-1024}            # strong scaling: fixed global grid
STRONG_LY=${STRONG_LY:-1024}
WEAK_LX=${WEAK_LX:-1024}                # weak scaling: LX fixed, LY = P * WEAK_LY_LOCAL
WEAK_LY_LOCAL=${WEAK_LY_LOCAL:-128}     # interior rows per rank (constant local size)
MPI_SRC=${MPI_SRC:-"bench_mpi.c"}                    # MPI program (solver + main), includes basic.h
SER_SRC=${SER_SRC:-"bench_serial.c"}  # serial reference: timing driver + ORIGINAL solver
MPICC=${MPICC:-mpicc}
MPIRUN=${MPIRUN:-mpirun}                # launcher, called as: $MPIRUN $MPIRUN_OPTS -np P prog
MPIRUN_OPTS=${MPIRUN_OPTS:-}            # e.g. "--bind-to core" or "--oversubscribe"
SHIM=${SHIM:-0}                         # 1 = use the fork/pipe test stand-in (mpi_shim); only
                                        # checks that the scripts work - timings are meaningless
OUT=${OUT:-results}
BIN=$OUT/bin
CFLAGS=${CFLAGS:-"-O2 -march=native"}

mkdir -p "$BIN"
echo "case,P,LX,LY,iters,rep,time_s" > "$OUT/scaling.csv"

build() {   # build <tag> <LX> <LY>  -> $BIN/mpi_<tag>, $BIN/ser_<tag>
    local tag=$1 lx=$2 ly=$3
    local defs="-DNX=$((lx+2)) -DNY=$((ly+2)) -DNMAX=$ITERS -DEPS=1e-300"
    if [ "$SHIM" = 1 ]; then
        gcc $CFLAGS $defs -Impi_shim -o "$BIN/mpi_$tag" $MPI_SRC -lm
    else
        $MPICC $CFLAGS $defs -o "$BIN/mpi_$tag" $MPI_SRC -lm
    fi
    gcc $CFLAGS $defs -o "$BIN/ser_$tag" $SER_SRC -lm
}

run_mpi() { # run_mpi <binary> <P>  -> prints the TIME_S value
    local bin=$1 p=$2
    if [ "$SHIM" = 1 ]; then
        MPI_SHIM_NP=$p "$bin" | awk '/^TIME_S/{print $2}'
    else
        $MPIRUN $MPIRUN_OPTS -np "$p" "$bin" | awk '/^TIME_S/{print $2}'
    fi
}

# ---- strong scaling: fixed LX x LY -------------------------------------------
echo "== Strong scaling: ${STRONG_LX}x${STRONG_LY}, ${ITERS} iterations =="
tag="strong"
build "$tag" "$STRONG_LX" "$STRONG_LY"
for rep in $(seq 1 "$REPS"); do                       # serial reference (not MPI)
    t=$("$BIN/ser_$tag" | awk '/^TIME_S/{print $2}')
    echo "serial,0,$STRONG_LX,$STRONG_LY,$ITERS,$rep,$t" >> "$OUT/scaling.csv"
    echo "  serial        rep $rep: $t s"
done
for p in $PLIST; do
    if [ "$p" -gt "$STRONG_LY" ]; then echo "  skip P=$p (> LY)"; continue; fi
    for rep in $(seq 1 "$REPS"); do
        t=$(run_mpi "$BIN/mpi_$tag" "$p")
        echo "strong,$p,$STRONG_LX,$STRONG_LY,$ITERS,$rep,$t" >> "$OUT/scaling.csv"
        echo "  P=$p rep $rep: $t s"
    done
done

# ---- weak scaling: constant local grid WEAK_LX x WEAK_LY_LOCAL per rank -----------
echo "== Weak scaling: local ${WEAK_LX}x${WEAK_LY_LOCAL} per rank, ${ITERS} iterations =="
for p in $PLIST; do
    ly=$((p * WEAK_LY_LOCAL))
    tag="weak_$p"
    build "$tag" "$WEAK_LX" "$ly"
    for rep in $(seq 1 "$REPS"); do
        t=$(run_mpi "$BIN/mpi_$tag" "$p")
        echo "weak,$p,$WEAK_LX,$ly,$ITERS,$rep,$t" >> "$OUT/scaling.csv"
        echo "  P=$p (global ${WEAK_LX}x${ly}) rep $rep: $t s"
    done
done

echo "Done. Raw data: $OUT/scaling.csv"
echo "Analyse with:  python3 analyze_scaling.py --dir $OUT"
