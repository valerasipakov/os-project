#!/usr/bin/env bash

GROUP=""
SUBJECT=""
TEST_NAME=""
ACTION=""
SHOW_HELP=0

trim() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

_take_next_value_or_die() {
  local flag="$1"; shift
  local next="$1"
  if [[ -z "$next" || "$next" == --* ]]; then
    echo "Ошибка: для флага $flag требуется значение." >&2
    exit 1
  fi
  printf '%s' "$next"
}

print_usage() {
  cat <<'USAGE'
Использование:
  script.sh --group <строка> --subject <строка> --test <строка> --action <строка>
  script.sh --group=<строка> --subject=<строка> --test=<строка> --action=<строка>

Флаги:
  --group     Название группы (строка). Пробелы по краям будут обрезаны.
  --subject   Название предмета (строка). Пробелы по краям будут обрезаны.
  --test      Название/код теста (строка). Пробелы по краям будут обрезаны.
  --action    Действие (строка). Пробелы по краям будут обрезаны.
  -h, --help  Показать эту справку.

Примеры:
  script.sh --group="  Ae-21-22  " --subject "  Цирковое_Дело  " --test=TEST-1 --action both
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
      --help|-h)
        SHOW_HELP=1
        shift
        ;;
      --) # явное окончание списка опций
        shift
        break
        ;;
      --*)
        echo "Неизвестный флаг: $1" >&2
        exit 1
        ;;
      *)
        echo "Неожиданный позиционный аргумент: $1" >&2
        exit 1
        ;;
    esac
  done

}
