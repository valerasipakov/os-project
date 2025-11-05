#!/usr/bin/env bash

GROUP="${GROUP:-}"
SUBJECT="${SUBJECT:-}"
TEST_NAME="${TEST_NAME:-}"
ACTION="${ACTION:-}"
SHOW_HELP="${SHOW_HELP:-0}"
STUDENT="${STUDENT:-}"
PHRASE="${PHRASE:-}"

trim() {
  local s
  s=$*
  s="${s#${s%%[!$'\t\n\r ']*}}"
  while :; do
    case "$s" in
      *[!$'\t\n\r ']) break ;;
      *) s="${s%?}" ;;
    esac
  done
  printf '%s' "$s"
}

print_usage() {
  cat <<'USAGE'
Использование:
  main.sh --group <строка> --subject <строка> --test <строка> --action <строка>
  main.sh --group=<строка> --subject=<строка> --test=<строка> --action=<строка>

Доп. режимы (task2):
  main.sh --student=<ФамилияИО> --subject=<Предмет> --action=view-dossier
  main.sh --student=<ФамилияИО> --subject=<Предмет> --action=add-dossier --phrase="<фраза>"
  main.sh --student=<ФамилияИО> --subject=<Предмет> --action=average-grade

Флаги:
  --group
  --subject
  --test
  --action
  --student
  --phrase
  -h, --help
USAGE
}

parse_args() {
  while (($#)); do
    case "$1" in
      --group=*)
        GROUP="$(trim "${1#--group=}")"
        shift
        ;;
      --group)
        GROUP="$(trim "$(_take_next_value_or_die --group "${2-}")")"
        shift 2
        ;;
      --subject=*)
        SUBJECT="$(trim "${1#--subject=}")"
        shift
        ;;
      --subject)
        SUBJECT="$(trim "$(_take_next_value_or_die --subject "${2-}")")"
        shift 2
        ;;
      --test=*)
        TEST_NAME="$(trim "${1#--test=}")"
        shift
        ;;
      --test)
        TEST_NAME="$(trim "$(_take_next_value_or_die --test "${2-}")")"
        shift 2
        ;;
      --action=*)
        ACTION="$(trim "${1#--action=}")"
        shift
        ;;
      --action)
        ACTION="$(trim "$(_take_next_value_or_die --action "${2-}")")"
        shift 2
        ;;
      --student=*)
        STUDENT="$(trim "${1#--student=}")"
        shift
        ;;
      --student)
        STUDENT="$(trim "$(_take_next_value_or_die --student "${2-}")")"
        shift 2
        ;;
      --phrase=*)
        PHRASE="$(trim "${1#--phrase=}")"
        shift
        ;;
      --phrase)
        PHRASE="$(trim "$(_take_next_value_or_die --phrase "${2-}")")"
        shift 2
        ;;
      --help|-h)
        SHOW_HELP=1
        shift
        ;;
      --)
        shift
        break
        ;;
      *)
        break
        ;;
    esac
  done
}
