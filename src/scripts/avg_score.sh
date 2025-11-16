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

source "$SCRIPT_DIR/lib/paths.sh"

trim() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

usage() {
  echo "Использование: $0 ФамилияИО ПРЕДМЕТ" >&2
}

if [[ $# -ne 2 ]]; then
  usage
  exit 1
fi

STUDENT="$(trim "$1")"
SUBJECT="$(trim "$2")"

if [[ -z "$STUDENT" ]]; then
  echo "Не указана фамилия студента" >&2
  usage
  exit 1
fi

if [[ -z "$SUBJECT" ]]; then
  echo "Не указан предмет" >&2
  usage
  exit 1
fi

TESTS_DIR="$(get_subject_tests_dir "$SUBJECT")"

if [[ ! -d "$TESTS_DIR" ]]; then
  echo "Каталог с тестами для предмета '$SUBJECT' не найден: $TESTS_DIR" >&2
  exit 1
fi

AVG_SCORE=$(
  awk -F';' -v s="$STUDENT" '
    {
      raw = $5
      gsub(/[[:space:]]/, "", raw)
      gsub(/[+-]/, "", raw)
      gsub(/,/, ".", raw)
      grade = raw + 0
      if ($2 == s) {
        sum += grade
        cnt++
      }
    }
    END {
      if (cnt == 0) {
        print "NA"
      } else {
        printf "%.2f", sum / cnt
      }
    }
  ' "$TESTS_DIR"/TEST-* 2>/dev/null
)

if [[ "$AVG_SCORE" == "NA" || -z "$AVG_SCORE" ]]; then
  echo "Оценки студента $STUDENT по предмету $SUBJECT не найдены"
  exit 0
fi

echo "Средняя оценка студента $STUDENT по предмету $SUBJECT: $AVG_SCORE"
