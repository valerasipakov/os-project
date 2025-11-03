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
  esac
done

[[ -z "${GROUP}" ]] && GROUP="$(ask_group)"
[[ -z "${SUBJECT}" ]] && SUBJECT="$(ask_subject)"
[[ -z "${TEST_NAME}" ]] && TEST_NAME="$(ask_test "${SUBJECT}")"

TEST_FILE="$(get_tests_file "${SUBJECT}" "${TEST_NAME}")"
TOTAL_QUESTIONS="$(get_total_questions "${SUBJECT}")"

if [[ ! -f "${TEST_FILE}" ]]; then
  printf "Файл теста не найден: %s\n" "${TEST_FILE}" >&2
  exit 1
fi

if ! group_exists "${TEST_FILE}" "${GROUP}"; then
  printf "Группа не найдена: %s\n" "${GROUP}" >&2
  printf "Доступные группы в тесте %s/%s:\n" "${SUBJECT}" "${TEST_NAME}" >&2
  list_groups "${TEST_FILE}" >&2
  exit 1
fi

RESULT="$(find_max_for_group "${TEST_FILE}" "${GROUP}" "${TOTAL_QUESTIONS}")"

MAX_CORRECT="$(echo "${RESULT}" | grep '^MAX_CORRECT=' | cut -d'=' -f2)"
MAX_CORRECT_NAMES="$(echo "${RESULT}" | grep '^MAX_CORRECT_NAMES=' | cut -d'=' -f2-)"
MAX_WRONG="$(echo "${RESULT}" | grep '^MAX_WRONG=' | cut -d'=' -f2)"
MAX_WRONG_NAMES="$(echo "${RESULT}" | grep '^MAX_WRONG_NAMES=' | cut -d'=' -f2-)"

echo "Группа: ${GROUP}"
echo "Предмет: ${SUBJECT}"
echo "Тест: ${TEST_NAME}"
case "${ACTION}" in
  max-correct)
    echo "Студент(ы) с максимальным числом правильных (${MAX_CORRECT}): ${MAX_CORRECT_NAMES}"
    ;;
  max-wrong)
    echo "Студент(ы) с максимальным числом неправильных (${MAX_WRONG}): ${MAX_WRONG_NAMES}"
    ;;
  both|*)
    echo "Студент(ы) с максимальным числом правильных (${MAX_CORRECT}): ${MAX_CORRECT_NAMES}"
    echo "Студент(ы) с максимальным числом неправильных (${MAX_WRONG}): ${MAX_WRONG_NAMES}"
    ;;
esac
