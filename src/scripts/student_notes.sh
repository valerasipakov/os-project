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
  echo "Использование: $0 ФамилияИО [--add]" >&2
}

if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage
  exit 1
fi

STUDENT="$(trim "$1")"
if [[ -z "$STUDENT" ]]; then
  echo "Не указана фамилия студента" >&2
  usage
  exit 1
fi

MODE="view"
if [[ $# -eq 2 ]]; then
  if [[ "$2" == "--add" ]]; then
    MODE="add"
  else
    echo "Неизвестный флаг: $2" >&2
    usage
    exit 1
  fi
fi

NOTES_FILE="$(get_notes_file_for_student "$STUDENT")"
NOTES_DIR="$(dirname "$NOTES_FILE")"
mkdir -p "$NOTES_DIR"
if [[ ! -f "$NOTES_FILE" ]]; then
  touch "$NOTES_FILE"
fi

LINES=()
while IFS= read -r line; do
  LINES+=("$line")
done <"$NOTES_FILE"
N=${#LINES[@]}

find_student_block() {
  STUDENT_INDEX=-1
  START_DESC=-1
  END_DESC=-1
  local i j t tj
  for ((i=0; i<N; i++)); do
    t="$(trim "${LINES[i]}")"
    if [[ "$t" == "$STUDENT" ]]; then
      STUDENT_INDEX=$i
      j=$((i+1))
      while (( j < N )); do
        tj="$(trim "${LINES[j]}")"
        if [[ "$tj" == "" ]]; then
          j=$((j+1))
          continue
        fi
        if [[ "$tj" == "===="* ]]; then
          break
        fi
        if [[ $START_DESC -eq -1 ]]; then
          START_DESC=$j
        fi
        END_DESC=$j
        j=$((j+1))
      done
      break
    fi
  done
}

if [[ "$MODE" == "view" ]]; then
  find_student_block
  if [[ $STUDENT_INDEX -eq -1 ]]; then
    echo "Досье студента $STUDENT: досье не найдено"
    exit 0
  fi
  if [[ $START_DESC -eq -1 ]]; then
    echo "Досье студента $STUDENT: досье пустое"
    exit 0
  fi
  DESC=""
  for ((i=START_DESC; i<=END_DESC; i++)); do
    t="$(trim "${LINES[i]}")"
    if [[ -n "$t" ]]; then
      if [[ -n "$DESC" ]]; then
        DESC="$DESC $t"
      else
        DESC="$t"
      fi
    fi
  done
  if [[ -z "$DESC" ]]; then
    echo "Досье студента $STUDENT: досье пустое"
  else
    echo "Досье студента $STUDENT: $DESC"
  fi
  exit 0
fi

printf "Введите новую запись: " >&2
IFS= read -r PHRASE
PHRASE="$(trim "$PHRASE")"
if [[ -z "$PHRASE" ]]; then
  echo "Пустая запись не добавлена" >&2
  exit 0
fi

find_student_block
if [[ $STUDENT_INDEX -eq -1 ]]; then
  echo "Досье студента $STUDENT не найдено" >&2
  exit 1
fi

if [[ $START_DESC -eq -1 ]]; then
  NEW_LINES=()
  for ((i=0; i<N; i++)); do
    NEW_LINES+=("${LINES[i]}")
    if [[ $i -eq $STUDENT_INDEX ]]; then
      NEW_LINES+=("$PHRASE")
    fi
  done
  LINES=("${NEW_LINES[@]}")
else
  NEW_LINES=()
  for ((i=0; i<N; i++)); do
    NEW_LINES+=("${LINES[i]}")
    if [[ $i -eq $END_DESC ]]; then
      NEW_LINES+=("$PHRASE")
    fi
  done
  LINES=("${NEW_LINES[@]}")
fi

{
  for ((i=0; i<${#LINES[@]}; i++)); do
    echo "${LINES[i]}"
  done
} >"$NOTES_FILE"

echo "Запись добавлена"
