#! /bin/bash
# shellcheck disable=SC2154

source _compilers/consts.sh

pr_chkfile "$1"
read_from_file "$1"
