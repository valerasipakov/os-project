#!/usr/bin/env bash

ask_group() {
  printf "Введите номер группы: " >&2
  read -r v
  echo "$v"
}

ask_subject() {
  printf "Выберите предмет:\n" >&2
  printf "1) Цирковое_Дело\n" >&2
  printf "2) Поп-Культуроведение\n" >&2
  printf "Введите 1 или 2: " >&2
  read -r n
  if [[ "$n" == "1" ]]; then
    echo "Цирковое_Дело"
  else
    echo "Поп-Культуроведение"
  fi
}

ask_test() {
  local subject="${1-}"
  if [[ -z "$subject" ]]; then
    subject="$(ask_subject)"
  fi
  local files
  files=$(list_tests "$subject")
  printf "Доступные тесты:\n" >&2
  printf "%s\n" "$files" >&2
  printf "Введите имя теста (например, TEST-1): " >&2
  read -r t
  echo "$t"
}
