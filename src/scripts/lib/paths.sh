#!/usr/bin/env bash

if [[ -n "${DATA_ROOT:-}" && -d "$DATA_ROOT" ]]; then
  LAB_ROOT="$DATA_ROOT"
else
  LAB_ROOT="${PROJECT_ROOT}/labfiles"
fi
export LAB_ROOT

get_total_questions() {
  local subject="$1"
  case "$subject" in
    "Цирковое_Дело") echo 25 ;;
    "Поп-Культуроведение") echo 5 ;;
    *) echo 0 ;;
  esac
}

get_subject_tests_dir() {
  local subject="$1"
  echo "${LAB_ROOT}/${subject}/tests"
}

get_test_file() {
  local subject="$1"
  local test_name="$2"
  local dir
  dir="$(get_subject_tests_dir "$subject")"
  echo "${dir}/${test_name}"
}

get_dossier_file() {
  local subject="$1"
  local student="$2"
  local dir="${LAB_ROOT}/${subject}/dossiers"
  mkdir -p "$dir"
  echo "${dir}/${student}.dossier"
}
