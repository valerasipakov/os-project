#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [[ -z "${DATA_ROOT:-}" ]]; then
  if [[ -f "$PROJECT_ROOT/config/app.env" ]]; then
    set -a
    . "$PROJECT_ROOT/config/app.env"
    set +a
  fi
fi

if [[ -n "${DATA_ROOT:-}" ]]; then
  if [[ -d "$DATA_ROOT" ]]; then
    DATA_ROOT="$(cd "$DATA_ROOT" && pwd)"
  else
    echo "DATA_ROOT указывает на несуществующий каталог: $DATA_ROOT" >&2
    exit 1
  fi
fi
export DATA_ROOT

source "$SCRIPT_DIR/lib/io.sh"
source "$SCRIPT_DIR/lib/paths.sh"
source "$SCRIPT_DIR/lib/parser.sh" 2>/dev/null || true
source "$SCRIPT_DIR/lib/stats.sh"

trim() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

usage() {
  echo "Использование: $0 [--group=ГРУППА] [--subject=ПРЕДМЕТ] [--test=ТЕСТ] [--action=both|max-correct|max-wrong]"
}

GROUP=""
SUBJECT=""
TEST_NAME=""
ACTION="both"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --group=*)
      GROUP="${1#*=}"
      ;;
    --group)
      GROUP="$2"
      shift
      ;;
    --subject=*)
      SUBJECT="${1#*=}"
      ;;
    --subject)
      SUBJECT="$2"
      shift
      ;;
    --test=*)
      TEST_NAME="${1#*=}"
      ;;
    --test)
      TEST_NAME="$2"
      shift
      ;;
    --action=*)
      ACTION="${1#*=}"
      ;;
    --action)
      ACTION="$2"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Неизвестный аргумент: $1"
      usage
      exit 1
      ;;
  esac
  shift
done

GROUP="$(trim "$GROUP")"
SUBJECT="$(trim "$SUBJECT")"
TEST_NAME="$(trim "$TEST_NAME")"
ACTION="$(trim "$ACTION")"

if [[ -z "$GROUP" ]]; then
  read -rp "Введите номер группы: " GROUP
  GROUP="$(trim "$GROUP")"
fi

if [[ -z "$SUBJECT" ]]; then
  read -rp "Введите название предмета: " SUBJECT
  SUBJECT="$(trim "$SUBJECT")"
fi

if [[ -z "$ACTION" ]]; then
  ACTION="both"
fi

case "$ACTION" in
  both|max-correct|max-wrong)
    ;;
  *)
    echo "Некорректное значение --action: $ACTION"
    exit 1
    ;;
esac

SUBJECT_DIR="$(get_subject_tests_dir "$SUBJECT")"

if [[ ! -d "$SUBJECT_DIR" ]]; then
  echo "Предмет не найден: $SUBJECT"
  exit 1
fi

if ! group_exists_in_subject "$SUBJECT" "$GROUP"; then
  echo "Группа не найдена: $GROUP"
  exit 1
fi

TEST_DESC="по всем тестам"
TEST_FILE=""

if [[ -n "$TEST_NAME" ]]; then
  TEST_NAME="$(trim "$TEST_NAME")"
  if [[ -f "$SUBJECT_DIR/$TEST_NAME" ]]; then
    TEST_FILE="$SUBJECT_DIR/$TEST_NAME"
  elif [[ -f "$SUBJECT_DIR/$TEST_NAME.csv" ]]; then
    TEST_FILE="$SUBJECT_DIR/$TEST_NAME.csv"
  else
    echo "Тест не найден: $TEST_NAME"
    exit 1
  fi
  TEST_DESC="по тесту $TEST_NAME"
fi

if [[ -n "$TEST_FILE" ]]; then
  if [[ "$ACTION" == "both" || "$ACTION" == "max-correct" ]]; then
    correct_names="$(max_correct_names_one_file "$SUBJECT" "$GROUP" "$TEST_FILE")"
    correct_value="$(max_correct_value_one_file "$SUBJECT" "$GROUP" "$TEST_FILE")"
    echo "Студент(ы) с максимальным числом правильных ($correct_value) [$TEST_DESC]: $correct_names"
  fi
  if [[ "$ACTION" == "both" || "$ACTION" == "max-wrong" ]]; then
    wrong_names="$(max_wrong_names_one_file "$SUBJECT" "$GROUP" "$TEST_FILE")"
    wrong_value="$(max_wrong_value_one_file "$SUBJECT" "$GROUP" "$TEST_FILE")"
    echo "Студент(ы) с максимальным числом неправильных ($wrong_value) [$TEST_DESC]: $wrong_names"
  fi
else
  if [[ "$ACTION" == "both" || "$ACTION" == "max-correct" ]]; then
    correct_names="$(max_correct_names_all_tests "$SUBJECT" "$GROUP")"
    correct_value="$(max_correct_value_all_tests "$SUBJECT" "$GROUP")"
    echo "Студент(ы) с максимальным числом правильных ($correct_value) [по всем тестам]: $correct_names"
  fi
  if [[ "$ACTION" == "both" || "$ACTION" == "max-wrong" ]]; then
    wrong_names="$(max_wrong_names_all_tests "$SUBJECT" "$GROUP")"
    wrong_value="$(max_wrong_value_all_tests "$SUBJECT" "$GROUP")"
    echo "Студент(ы) с максимальным числом неправильных ($wrong_value) [по всем тестам]: $wrong_names"
  fi
fi
