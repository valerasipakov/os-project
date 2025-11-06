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

GROUP=""
SUBJECT=""
TEST_NAME=""
ACTION="both"

for arg in "$@"; do
  case "$arg" in
    --group=*) GROUP="${arg#*=}" ;;
    --subject=*) SUBJECT="${arg#*=}" ;;
    --test=*) TEST_NAME="${arg#*=}" ;;
    --action=*) ACTION="${arg#*=}" ;;
    *) ;;
  esac
done

if [[ -z "$GROUP" || -z "$SUBJECT" ]]; then
  echo "Необходимо указать --group и --subject" >&2
  exit 1
fi

case "$ACTION" in
  both|max-correct|max-wrong) ;;
  *)
    echo "Недопустимое значение --action: $ACTION" >&2
    exit 1
    ;;
esac

if [[ -z "${TEST_NAME:-}" ]]; then
  if ! group_exists_in_subject "$SUBJECT" "$GROUP"; then
    echo "Группа не найдена: $GROUP" >&2
    exit 1
  fi

  if [[ "$ACTION" == "both" || "$ACTION" == "max-correct" ]]; then
    best_names="$(max_correct_names_all_tests "$SUBJECT" "$GROUP")"
    best_val="$(max_correct_value_all_tests "$SUBJECT" "$GROUP")"
    echo "Студент(ы) с максимальным числом правильных (${best_val}) [по всем тестам]:"
    echo "$best_names" | tr '\n' ' '; echo
  fi

  if [[ "$ACTION" == "both" || "$ACTION" == "max-wrong" ]]; then
    worst_names="$(max_wrong_names_all_tests "$SUBJECT" "$GROUP")"
    worst_val="$(max_wrong_value_all_tests "$SUBJECT" "$GROUP")"
    echo "Студент(ы) с максимальным числом неправильных (${worst_val}) [по всем тестам]:"
    echo "$worst_names" | tr '\n' ' '; echo
  fi

  exit 0
fi

TEST_PATH="$(get_subject_tests_dir "$SUBJECT")/$TEST_NAME"
if [[ ! -f "$TEST_PATH" ]]; then
  echo "Файл теста не найден: $TEST_PATH" >&2
  exit 1
fi

if [[ "$ACTION" == "both" || "$ACTION" == "max-correct" ]]; then
  best_names="$(max_correct_names_one_file "$SUBJECT" "$GROUP" "$TEST_PATH")"
  best_val="$(max_correct_value_one_file "$SUBJECT" "$GROUP" "$TEST_PATH")"
  echo "Студент(ы) с максимальным числом правильных (${best_val}) [тест: $TEST_NAME]:"
  echo "$best_names" | tr '\n' ' '; echo
fi

if [[ "$ACTION" == "both" || "$ACTION" == "max-wrong" ]]; then
  worst_names="$(max_wrong_names_one_file "$SUBJECT" "$GROUP" "$TEST_PATH")"
  worst_val="$(max_wrong_value_one_file "$SUBJECT" "$GROUP" "$TEST_PATH")"
  echo "Студент(ы) с максимальным числом неправильных (${worst_val}) [тест: $TEST_NAME]:"
  echo "$worst_names" | tr '\n' ' '; echo
fi
