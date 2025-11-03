#!/usr/bin/env bash

if [[ -z "${DATA_ROOT:-}" ]]; then
  echo "DATA_ROOT не задан. Укажи его в config/app.env или через переменную окружения." >&2
  exit 1
fi

if [[ -d "$DATA_ROOT/labfiles-25/Цирковое_Дело" ]] || [[ -d "$DATA_ROOT/labfiles-25/Поп-Культуроведение" ]]; then
  LAB_ROOT="$DATA_ROOT/labfiles-25"
elif [[ -d "$DATA_ROOT/Цирковое_Дело" ]] || [[ -d "$DATA_ROOT/Поп-Культуроведение" ]]; then
  LAB_ROOT="$DATA_ROOT"
else
  echo "В DATA_ROOT нет ожидаемой структуры: $DATA_ROOT" >&2
  exit 1
fi

get_tests_file() {
  local subject="$1"
  local test_name="$2"
  echo "${LAB_ROOT}/${subject}/tests/${test_name}"
}

list_tests() {
  local subject="$1"
  local dir="${LAB_ROOT}/${subject}/tests"
  ls -1 "$dir" 2>/dev/null || true
}

get_total_questions() {
  local subject="$1"
  case "$subject" in
    "Цирковое_Дело") echo 25 ;;
    "Поп-Культуроведение") echo 5 ;;
    *) echo 0 ;;
  esac
}
