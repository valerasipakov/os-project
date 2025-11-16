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

# Notes directory that stores dossiers grouped by first letter
get_notes_dir() {
  local d1="${LAB_ROOT}/students/general/notes"
  local d2="${LAB_ROOT}/students/general"
  if [[ -d "$d1" ]]; then
    echo "$d1"
  elif [[ -d "$d2" ]]; then
    echo "$d2"
  else
    echo "$d1"
  fi
}

# Heuristic: pick notes file by the first letter of the student's surname
get_notes_file_for_student() {
  local student="$1"
  local notes_dir
  notes_dir="$(get_notes_dir)"
  local letter
  letter="${student:0:1}"
  # Prefer existing files starting with the same letter
  local candidate
  candidate="$(LC_ALL=C ls -1 "$notes_dir" 2>/dev/null | awk -v l="$letter" 'index($0,l)==1 && $0 ~ /\.log$/ {print; exit}')"
  if [[ -n "$candidate" ]]; then
    echo "${notes_dir}/${candidate}"
  else
    echo "${notes_dir}/${letter}.log"
  fi
}
