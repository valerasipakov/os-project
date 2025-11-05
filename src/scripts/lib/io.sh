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

ask_action() {
  printf "Выберите действие:\n" >&2
  printf "1) both (показать максимум верных и неверных)\n" >&2
  printf "2) max-correct (максимум верных)\n" >&2
  printf "3) max-wrong (максимум неверных)\n" >&2
  printf "4) view-dossier (просмотр досье)\n" >&2
  printf "5) add-dossier (добавить фразу в досье)\n" >&2
  printf "6) average-grade (средняя оценка студента)\n" >&2
  printf "Введите 1-6: " >&2
  read -r n
  case "$n" in
    1) echo "both" ;;
    2) echo "max-correct" ;;
    3) echo "max-wrong" ;;
    4) echo "view-dossier" ;;
    5) echo "add-dossier" ;;
    6) echo "average-grade" ;;
    *) echo "both" ;;
  esac
}

ask_student() {
  printf "Введите ФамилияИО студента: " >&2
  read -r v
  echo "$v"
}

ask_phrase() {
  printf "Введите фразу для добавления в досье: " >&2
  read -r v
  echo "$v"
}

list_tests() {
  local subject="$1"
  local dir
  dir="$(get_subject_tests_dir "$subject")"
  [[ -d "$dir" ]] || return 0
  LC_ALL=C ls -1 "$dir" 2>/dev/null | sort
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
