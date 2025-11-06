#!/usr/bin/env bash
set -euo pipefail

max_correct_names_one_file() {
  local subject="$1" group="$2" test_file="$3"
  awk -F';' -v g="$group" '
    $1==g {
      corr[$2]+=($4+0)
      if (corr[$2]>max) max=corr[$2]
    }
    END {
      for(n in corr) if (corr[n]==max) printf "%s (%d)\n", n, corr[n]
    }
  ' "$test_file"
}

max_wrong_names_one_file() {
  local subject="$1" group="$2" test_file="$3" total
  total="$(get_total_questions "$subject")"
  awk -F';' -v g="$group" -v T="$total" '
    $1==g {
      wrong[$2]+= (T>0 ? (T-($4+0)) : -($4+0))
      if (wrong[$2]>max) max=wrong[$2]
    }
    END {
      for(n in wrong) if (wrong[n]==max) print n
    }
  ' "$test_file"
}

max_correct_value_one_file() {
  local subject="$1" group="$2" test_file="$3"
  awk -F';' -v g="$group" '
    $1==g { corr[$2]+=($4+0) }
    END {
      for(n in corr) if (corr[n]>max) max=corr[n]
      print (max+0)
    }
  ' "$test_file"
}

max_wrong_value_one_file() {
  local subject="$1" group="$2" test_file="$3" total
  total="$(get_total_questions "$subject")"
  awk -F';' -v g="$group" -v T="$total" '
    $1==g { wrong[$2]+= (T>0 ? (T-($4+0)) : -($4+0)) }
    END {
      for(n in wrong) if (wrong[n]>max) max=wrong[n]
      print (max+0)
    }
  ' "$test_file"
}

max_correct_names_all_tests() {
  local subject="$1" group="$2"
  local dir
  dir="$(get_subject_tests_dir "$subject")"
  awk -F';' -v g="$group" '
    $1==g { corr[$2]+=($4+0) }
    END {
      for(n in corr) if (corr[n]>max) max=corr[n]
      for(n in corr) if (corr[n]==max) printf "%s (%d)\n", n, corr[n]
    }
  ' "$dir"/*
}

max_wrong_names_all_tests() {
  local subject="$1" group="$2" total
  local dir
  dir="$(get_subject_tests_dir "$subject")"
  total="$(get_total_questions "$subject")"
  awk -F';' -v g="$group" -v T="$total" '
    $1==g { wrong[$2]+= (T>0 ? (T-($4+0)) : -($4+0)) }
    END {
      for(n in wrong) if (wrong[n]>max) max=wrong[n]
      for(n in wrong) if (wrong[n]==max) print n
    }
  ' "$dir"/*
}

group_exists_in_subject() {
  local subject="$1" group="$2"
  local dir
  dir="$(get_subject_tests_dir "$subject")"
  [[ -d "$dir" ]] || return 1
  local f
  for f in "$dir"/*; do
    [[ -f "$f" ]] || continue
    awk -F';' -v g="$group" '$1==g{found=1; exit} END{exit(found?0:1)}' "$f" && return 0
  done
  return 1
}

max_correct_value_all_tests() {
  local subject="$1" group="$2"
  local dir
  dir="$(get_subject_tests_dir "$subject")"
  awk -F';' -v g="$group" '
    $1==g { corr[$2] += ($4+0) }
    END {
      for (n in corr) if (corr[n] > max) max = corr[n]
      print (max+0)
    }
  ' "$dir"/*
}

max_wrong_value_all_tests() {
  local subject="$1" group="$2" total
  local dir
  dir="$(get_subject_tests_dir "$subject")"
  total="$(get_total_questions "$subject")"
  awk -F';' -v g="$group" -v T="$total" '
    $1==g { wrong[$2] += (T>0 ? (T-($4+0)) : -($4+0)) }
    END {
      for (n in wrong) if (wrong[n] > max) max = wrong[n]
      print (max+0)
    }
  ' "$dir"/*
}
