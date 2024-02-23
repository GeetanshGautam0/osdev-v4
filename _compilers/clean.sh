#! /bin/bash
# shellcheck disable=SC2154

source _compilers/consts.sh

chk_and_rm "${obj_dir}"
mkdir -p "${obj_dir}"

chk_and_rm "${build_dir}"
mkdir -p "${build_dir}"
