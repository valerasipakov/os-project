#!/usr/bin/env bash

group_exists() {
  local file="$1"
  local group="$2"
  awk -F';' -v g="$group" 'BEGIN{found=0} $1==g{found=1; exit} END{exit(found?0:1)}' "$file"
}

list_groups() {
  local file="$1"
  cut -d';' -f1 "$file" | sed '/^$/d' | sort -u
}

find_max_for_group() {
  local file="$1"
  local group="$2"
  local total="$3"

  local max_correct=-1
  local max_wrong=-1
  local max_correct_names=()
  local max_wrong_names=()

  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    local g
    g=$(echo "$line" | cut -d';' -f1)
    [[ "$g" != "$group" ]] && continue
    local name correct
    name=$(echo "$line" | cut -d';' -f2)
    correct=$(echo "$line" | cut -d';' -f4)
    if (( correct > max_correct )); then
      max_correct=$correct
      max_correct_names=("$name")
    elif (( correct == max_correct )); then
      max_correct_names+=("$name")
    fi
    local wrong=$(( total - correct ))
    if (( wrong > max_wrong )); then
      max_wrong=$wrong
      max_wrong_names=("$name")
    elif (( wrong == max_wrong )); then
      max_wrong_names+=("$name")
    fi
  done < "$file"

  echo "MAX_CORRECT=${max_correct}"
  echo "MAX_CORRECT_NAMES=${max_correct_names[*]}"
  echo "MAX_WRONG=${max_wrong}"
  echo "MAX_WRONG_NAMES=${max_wrong_names[*]}"
}
