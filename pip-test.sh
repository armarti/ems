#!/usr/bin/env bash
set -e

PKG_NAME=$1
MODULE_NAME=$2
USE_TEST_IDX=${3:-0}

THIS_DIR="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"

if [ -z "$PKG_NAME" -o -z "$MODULE_NAME" -o "$1" = "-h" -o "$1" = "--help" ]; then
    echo 'Run this script like `'"$(basename ${BASH_SOURCE[0]})"' <package name> <module name> [<use test.pypi.org index? (1 or 0)>]`'
    exit 0
fi

TEST_IDX_URL=https://test.pypi.org/simple
PROD_IDX_URL=https://pypi.org/simple
IDX_URL=''
if [ $USE_TEST_IDX -ne 0 ]; then
    IDX_URL=$TEST_IDX_URL
else
    IDX_URL=$PROD_IDX_URL
fi
echo ">>> Using index url $IDX_URL"

PYSCRIPTS="$(ls "$THIS_DIR"/*.py)"
PY_TMPDIR=$(mktemp -d XXXX)

function test_in_venv() {
    pynum=$1
    # test installing
    echo ">>> Testing install in Python${pynum} virtualenv"
    virtualenv --always-copy --python=python${pynum} "$PY_TMPDIR/.venv${pynum}" && \
        source "$PY_TMPDIR/.venv${pynum}/bin/activate" && \
        pip install --index-url $PROD_IDX_URL 'cffi>=1.0.0'  # there's no cffi on the test idx
        pip install --index-url $IDX_URL $PKG_NAME && \
        echo ">>> $PKG_NAME installed successfully" && \
        python -c "from $PKG_NAME import $MODULE_NAME" && \
        echo ">>> $MODULE_NAME successfully imported"
    cd "$THIS_DIR"

    # test against all .py scripts in this same directory
    for py in $PYSCRIPTS; do
        python "$py" || \
            (
                echo ">>> Problem running ${py}. Exiting."
                exit 1
            ) && \
            echo ">>> Successfully run ${py}."
    done
}

function delete_venv_tmpdir() {
    read -p "Delete $PY_TMPDIR (which holds the virtualenvs)? [y/N]: " D
    if [[ "$D" == "y" || "$D" == "Y" ]]; then
        rm -rf "$PY_TMPDIR"
    fi
}

test_in_venv 2 || (delete_venv_tmpdir && exit 1)
test_in_venv 3 || (delete_venv_tmpdir && exit 1)
delete_venv_tmpdir

echo "Done."
exit 0
