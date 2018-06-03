#!/usr/bin/env bash
set -e

PKG_NAME=$1
PKG_NAME_WITH_DASH=$(echo $MODULE_NAME | sed 's/_/-/g')
MODULE_NAME=$2
USE_TEST_IDX=${3:-0}

THIS_DIR="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"

PROD_IDX_URL=https://pypi.org/simple
TEST_IDX_URL=https://test.pypi.org/simple
LOCAL_IDX_URL=http://127.0.0.1:9000/

if [ -z "$PKG_NAME" -o -z "$MODULE_NAME" -o "$1" = "-h" -o "$1" = "--help" ]; then
    echo 'Run this script like `'"$(basename ${BASH_SOURCE[0]})"' <package name> <module name> [<which index (0 or 1 or 2)>]`'
    echo "    If \"which index\" is 0 --> $PROD_IDX_URL (default)"
    echo "    If \"which index\" is 1 --> $TEST_IDX_URL"
    echo "    If \"which index\" is 2 --> $LOCAL_IDX_URL"
    exit 0
fi

IDX_URL=''
if [ ${USE_TEST_IDX} -eq 1 ]; then
    IDX_URL=${TEST_IDX_URL}
elif [ ${USE_TEST_IDX} -eq 2 ]; then
    IDX_URL=${LOCAL_IDX_URL}
else
    IDX_URL=${PROD_IDX_URL}
fi
echo ">>> Using index url $IDX_URL"

PYSCRIPTS="$(ls "$THIS_DIR"/../Tests/*.py)"
mkdir -p "$THIS_DIR"/../pip-tests
PY_TMPDIR=$(mktemp -d "$THIS_DIR"/../pip-tests/$(date +%Y%m%d_%H%M%S)-XXXX)

SVR_PROC=-1
function setup_local_idx() {
    PKG_DIR="$THIS_DIR/../dist/$PKG_NAME_WITH_DASH"
    ARCHIVE="$(ls "$THIS_DIR"/../dist/ | grep -E '\.tar\.gz|\.zip')"
    echo "Creating \"$PKG_NAME_WITH_DASH\""
    mkdir -p "$PKG_DIR"
    echo "Copying \"$THIS_DIR/../dist/$ARCHIVE\" to \"$PKG_DIR\""
    cp "$THIS_DIR/../dist/$ARCHIVE" "$PKG_DIR"/
    echo "Entering $THIS_DIR/../dist"
    cd "$THIS_DIR/../dist"
    python -m SimpleHTTPServer 9000 &
    SVR_PROC=$(jobs -lr %+ | head -n1 | cut -d' ' -f2)
    echo "Started SimpleHTTPServer as process $SVR_PROC"
    echo "Entering $THIS_DIR"
    cd "$THIS_DIR"
}

function test_in_venv() {
    pynum=$1
    # test installing
    echo ">>> Testing install in Python${pynum} virtualenv"
    virtualenv --always-copy --python=python${pynum} "$PY_TMPDIR/.venv${pynum}" && \
        source "$PY_TMPDIR/.venv${pynum}/bin/activate" && \
        echo ">>> Using $(which python)"
        pip install --no-cache-dir --index-url ${PROD_IDX_URL} 'cffi>=1.0.0' && \
        pip install --no-cache-dir --index-url ${IDX_URL} ${PKG_NAME} && \
        echo ">>> $PKG_NAME installed successfully" && \
        python -c "from $PKG_NAME import $MODULE_NAME" && \
        echo ">>> $MODULE_NAME successfully imported"

    # test against all .py scripts in this same directory
    for py in ${PYSCRIPTS}; do
        echo ">>> Running $py"
        python "$py"
        RTN=$?
        if [ ${RTN} -ne 0 ]; then
            echo ">>> Problem running ${py}."
            return 1
        else
            echo ">>> Successfully ran ${py}."
        fi
    done
}

function delete_venv_tmpdir() {
    read -p "Delete $PY_TMPDIR (which holds the virtualenvs)? [y/N]: " D
    if [[ "$D" == "y" ]] || [[ "$D" == "Y" ]]; then
        rm -rf "$PY_TMPDIR"
    fi
}

#if [ ${USE_TEST_IDX} -eq 2 ]; then setup_local_idx; fi
test_in_venv 2 || delete_venv_tmpdir
test_in_venv 3 || delete_venv_tmpdir
if [ ${USE_TEST_IDX} -eq 2 ]; then kill ${SVR_PROC}; fi
delete_venv_tmpdir

echo "Done."
exit 0
