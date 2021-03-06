#!/usr/bin/env bash

set -ex

CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $CWD/../..
ROOT=$PWD

/c/Python36-x64/python -m pip install --upgrade pip

cat appveyor/pip/numpy/numpy-1.14.0+mkl-cp36* > appveyor/pip/numpy-1.14.0+mkl-cp36-cp36m-win_amd64.whl
/c/Python36-x64/Scripts/pip install appveyor/pip/numpy-1.14.0+mkl-cp36-cp36m-win_amd64.whl
/c/Python36-x64/Scripts/pip install appveyor/pip/numpydoc-0.7.0-py2.py3-none-any.whl
/c/Python36-x64/Scripts/pip install appveyor/pip/scipy-1.0.0-cp36-cp36m-win_amd64.whl
/c/Python36-x64/Scripts/pip install -r requirements.txt
/c/Python36-x64/Scripts/pip install tensorflow

set +e
/c/Python36-x64/python setup.py build_ext -j 2 --inplace
rm -rf build/lib # force relinking of libraries in case of failure
set -e
/c/Python36-x64/python setup.py build_ext --inplace
/c/Python36-x64/python -m unittest discover -v . "*_test.py"

export MKN_CL_PREFERRED=1 # forces mkn to use cl even if gcc/clang are found
# export MKN_COMPILE_THREADS=1 # mkn use 1 thread heap space issue
export SWIG=0 # disables swig for mkn
export CXXFLAGS="-EHsc"
./sh/mkn.sh
./sh/gtest.sh
/c/Python36-x64/python setup.py bdist_wheel

rm -rf build
rm -rf lib/bin
