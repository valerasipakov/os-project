#!/usr/bin/env bash

group_exists() {
  local file="$1"
  local group="$2"
  awk -F';' -v g="$group" 'BEGIN{found=0} $1==g{found=1; exit} END{exit(found?0:1)}' "$file"
}

max_correct_names() {
  local file="$1" group="$2"
  awk -F';' -v g="$group" '
    $1==g {
      name=$2; corr=$4+0
      if (corr>max) {max=corr; delete best}
      if (corr==max) {best[name]=1}
    }
    END { for (n in best) print n }
  ' "$file"
}

max_wrong_names() {
  local file="$1" group="$2" subject="$3" total
  total="$(get_total_questions "$subject")"
  awk -F';' -v g="$group" -v T="$total" '
    $1==g {
      name=$2; corr=$4+0
      wrong = (T>0 ? (T-corr) : -corr)
      if (wrong>max) {max=wrong; delete worst}
      if (wrong==max) {worst[name]=1}
    }
    END { for (n in worst) print n }
  ' "$file"
}

student_exists_in_subject() {
  local subject="$1" student="$2"
  local dir
  dir="$(get_subject_tests_dir "$subject")"
  [[ -d "$dir" ]] || return 1
  local f
  for f in "$dir"/*; do
    [[ -f "$f" ]] || continue
    awk -F';' -v s="$student" '$2==s{found=1; exit} END{exit(found?0:1)}' "$f" && return 0
  done
  return 1
}

average_grade_for_student() {
  local subject="$1" student="$2"
  local dir
  dir="$(get_subject_tests_dir "$subject")"
  local sum=0 cnt=0 f
  for f in "$dir"/*; do
    [[ -f "$f" ]] || continue
    while IFS=';' read -r _g name _date _correct grade; do
      [[ "$name" == "$student" ]] || continue
      if [[ -n "$grade" ]]; then
        sum=$((sum + grade))
        cnt=$((cnt + 1))
      fi
    done < "$f"
  done
  if (( cnt == 0 )); then
    echo "NOT_FOUND"
  else
    awk -v s="$sum" -v c="$cnt" 'BEGIN{printf("%.2f", s/c)}'
  fi
}
