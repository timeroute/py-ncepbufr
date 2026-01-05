#!/usr/bin/env bash
set -e

PYTHON=python
F2PY="$PYTHON -m numpy.f2py"

echo "Using python: $($PYTHON --version)"
echo "Using f2py: $($F2PY --version || true)"

###############################################################################
# 1. build NCEP bufrlib
###############################################################################

if [ ! -f src/libbufr.a ]; then
    echo "Building bufrlib..."
    (cd src && sh makebufrlib.sh)
else
    echo "bufrlib already exists"
fi

###############################################################################
# 2. build _bufrlib
###############################################################################

export LIBRARY_PATH="$PWD/src:$LIBRARY_PATH"
export LD_LIBRARY_PATH="$PWD/src:$LD_LIBRARY_PATH"

echo "Building _bufrlib..."
$F2PY \
    -c src/_bufrlib.pyf \
    -Lsrc -lbufr \
    --fcompiler=gnu95

###############################################################################
# 3. build _read_convobs
###############################################################################

echo "Building _read_convobs..."
$F2PY \
    -c src_diag/readconvobs.f90 \
    -m _read_convobs \
    --fcompiler=gnu95

###############################################################################
# 4. build _read_satobs
###############################################################################

echo "Building _read_satobs..."
$F2PY \
    -c \
    src_diag/_readsatobs.pyf \
    src_diag/readsatobs.f90 \
    src_diag/read_diag.f90 \
    -m _read_satobs \
    --fcompiler=gnu95

echo "Build finished"
