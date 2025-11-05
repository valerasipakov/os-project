#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
export PROJECT_ROOT

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
source "$SCRIPT_DIR/lib/parser.sh"
source "$SCRIPT_DIR/lib/stats.sh"

parse_args "$@"

if [[ "${SHOW_HELP:-0}" -eq 1 ]]; then
  print_usage
  exit 0
fi

# Если действие не задано флагом, спросим у пользователя интерактивно
if [[ -z "${ACTION:-}" ]]; then
  ACTION="$(trim "$(ask_action)")"
fi

# Для специальных действий запросим недостающие параметры интерактивно
case "${ACTION:-}" in
  view-dossier|add-dossier|average-grade)
    [[ -z "${SUBJECT:-}" ]] && SUBJECT="$(trim "$(ask_subject)")"
    [[ -z "${STUDENT:-}" ]] && STUDENT="$(trim "$(ask_student)")"
    if [[ "$ACTION" == "add-dossier" && -z "${PHRASE:-}" ]]; then
      PHRASE="$(trim "$(ask_phrase)")"
    fi
    ;;
esac

case "${ACTION:-}" in
  view-dossier|add-dossier|average-grade)
    if [[ -z "${STUDENT:-}" ]]; then
      echo "Требуется --student для действия ${ACTION}" >&2
      exit 1
    fi
    if [[ -z "${SUBJECT:-}" ]]; then
      echo "Требуется --subject для действия ${ACTION}" >&2
      exit 1
    fi
    case "${ACTION}" in
      view-dossier)
        if ! student_exists_in_subject "${SUBJECT}" "${STUDENT}"; then
          echo "Студент не найден" >&2
          exit 1
        fi
        dossier_file="$(get_dossier_file "${SUBJECT}" "${STUDENT}")"
        if [[ ! -f "$dossier_file" ]]; then
          echo "Досье не найдено"
          exit 0
        fi
        if [[ ! -s "$dossier_file" ]]; then
          echo "Досье пустое"
          exit 0
        fi
        cat "$dossier_file"
        exit 0
        ;;
      add-dossier)
        # Разрешаем создавать/обновлять досье даже если студент ещё не встречался в тестах
        if [[ -z "${PHRASE:-}" ]]; then
          echo "Для add-dossier требуется --phrase" >&2
          exit 1
        fi
        dossier_file="$(get_dossier_file "${SUBJECT}" "${STUDENT}")"
        if [[ ! -f "$dossier_file" ]]; then
          {
            echo "Фамилия: ${STUDENT}"
            echo "Предмет: ${SUBJECT}"
            echo "Дата создания: $(date '+%Y-%m-%d %H:%M:%S')"
            echo "Последнее обновление: $(date '+%Y-%m-%d %H:%M:%S')"
            echo
            echo "ФРАЗЫ:"
          } >"$dossier_file"
        else
          tmpf="$(mktemp)"
          awk -v now="$(date '+%Y-%m-%d %H:%M:%S')" \
              '{if ($0 ~ /^Последнее обновление:/) {print "Последнее обновление: " now} else {print $0}}' \
              "$dossier_file" > "$tmpf" && mv "$tmpf" "$dossier_file"
        fi
        next_n="$(awk '/^[0-9]+\./{c++} END{print c+1}' "$dossier_file")"
        echo "${next_n}. ${PHRASE}" >> "$dossier_file"
        echo "OK"
        exit 0
        ;;
      average-grade)
        avg="$(average_grade_for_student "${SUBJECT}" "${STUDENT}")"
        if [[ "$avg" == "NOT_FOUND" ]]; then
          echo "Студент не найден"
          exit 0
        fi
        echo "Средняя оценка по предмету (${SUBJECT}) для ${STUDENT}: ${avg}"
        exit 0
        ;;
    esac
    ;;
esac

[[ -z "${GROUP:-}"   ]] && GROUP="$(trim "$(ask_group)")"
[[ -z "${SUBJECT:-}" ]] && SUBJECT="$(trim "$(ask_subject)")"
[[ -z "${TEST_NAME:-}" ]] && TEST_NAME="$(trim "$(ask_test "${SUBJECT}")")"
ACTION="${ACTION:-both}"

case "${ACTION}" in
  both|max-correct|max-wrong) ;;
  *)
    echo "Недопустимое значение --action: ${ACTION}. Разрешено: both | max-correct | max-wrong | view-dossier | add-dossier | average-grade" >&2
    exit 1
    ;;
esac

test_file="$(get_test_file "$SUBJECT" "$TEST_NAME")"
if [[ ! -f "$test_file" ]]; then
  echo "Файл теста не найден: $test_file" >&2
  exit 1
fi

if ! group_exists "$test_file" "$GROUP"; then
  echo "Группа '${GROUP}' не найдена в тесте '${TEST_NAME}'" >&2
  exit 1
fi

case "$ACTION" in
  max-correct)
    max_correct_names "$test_file" "$GROUP" | sort
    ;;
  max-wrong)
    max_wrong_names "$test_file" "$GROUP" "$SUBJECT" | sort
    ;;
  both)
    echo "=== MAX CORRECT ==="
    max_correct_names "$test_file" "$GROUP" | sort
    echo
    echo "=== MAX WRONG ==="
    max_wrong_names "$test_file" "$GROUP" "$SUBJECT" | sort
    ;;
esac
