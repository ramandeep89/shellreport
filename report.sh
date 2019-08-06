#!/bin/bash


usage="Usage: $(basename $0) {-f path} {-s path} {-t path} {-a path}
  -f   list all files in a path excluding dirs
  -s   list all symlinks in a path including dirs
  -t   list dir tree structure in a path
  -a   list combining all 3 options above"

while getopts "f:s:t:a:" opt; do
    case $opt in
        f) files+=("$OPTARG");;
        s) symlinks+=("$OPTARG");;
        t) trees+=("$OPTARG");;
        a) alls+=("$OPTARG");;
        :) printf "missing argument for -%s\n" "$OPTARG" >&2
          echo "$usage" >&2
          exit 1
          ;;
        \?) printf "illegal option: -%s\n" "$OPTARG" >&2
          echo "$usage" >&2
          exit 1
          ;;
    esac
done
shift $((OPTIND -1))

list_dirs_recursive() {
  readlink -f "${1}"

  for child in "${1}"/*
  do
    if [[ -d "${child}" ]]
    then
      list_dirs_recursive "${child}"
    fi
  done
}

list_all_recursive() {
  if [[ -L "${1}" ]]
  then
    readlink -n "${child}"
    echo "-^>"
    readlink -f "${child}"
  else
    readlink -f "${1}"
  fi

  for child in "${1}"/*
  do
    if [[ -d "${child}" ]]
    then
      list_all_recursive "${child}"
    fi
  done
}

list_files() {
  for file in "${files[@]}"
  do
    for child in "${file}"/*
    do
      if [[ -f "{child}" ]]
      then
        readlink -f "${child}"
      fi
    done
  done
}

list_symlinks() {
  for symlink in "${symlinks[@]}"
  do
    for child in "${symlink}"/*
    do
      if [[ -L "${child}" ]]
      then
        readlink -n "${child}"
        echo "-^>"
        readlink -f "${child}"
      fi
    done
  done
}

list_trees() {
  for tree in "${trees[@]}"
  do
    list_dirs_recursive "${tree}"
  done
}

list_alls() {
  for all in "${alls[@]}"
  do
    list_all_recursive "${all}"
  done
}

### MAIN
list_files
list_symlinks
list_trees
list_alls
