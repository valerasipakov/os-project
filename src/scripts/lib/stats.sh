#!/usr/bin/env bash

max_correct_names_one_file() {
  local subject="$1"
  local group="$2"
  local file="$3"
  awk -F';' -v g="$group" '
    $1 == g && ($5 + 0) > 2 {
      a[$2] += ($4 + 0)
    }
    END {
      max = 0
      for (s in a) if (a[s] > max) max = a[s]
      for (s in a) if (a[s] == max) printf "%s ", s
    }
  ' "$file" | sed 's/ $//'
}

max_correct_value_one_file() {
  local subject="$1"
  local group="$2"
  local file="$3"
  awk -F';' -v g="$group" '
    $1 == g && ($5 + 0) > 2 {
      a[$2] += ($4 + 0)
    }
    END {
      max = 0
      for (s in a) if (a[s] > max) max = a[s]
      print max
    }
  ' "$file"
}

max_wrong_names_one_file() {
  local subject="$1"
  local group="$2"
  local file="$3"
  local total
  total="$(get_total_questions "$subject")"
  awk -F';' -v g="$group" -v total="$total" '
    $1 == g {
      c = ($4 + 0)
      corr[$2] += c
      cnt[$2]++
    }
    END {
      max = 0
      for (s in corr) {
        wrong = cnt[s] * total - corr[s]
        a[s] = wrong
        if (wrong > max) max = wrong
      }
      for (s in a) if (a[s] == max) printf "%s ", s
    }
  ' "$file" | sed 's/ $//'
}

max_wrong_value_one_file() {
  local subject="$1"
  local group="$2"
  local file="$3"
  local total
  total="$(get_total_questions "$subject")"
  awk -F';' -v g="$group" -v total="$total" '
    $1 == g {
      c = ($4 + 0)
      corr[$2] += c
      cnt[$2]++
    }
    END {
      max = 0
      for (s in corr) {
        wrong = cnt[s] * total - corr[s]
        if (wrong > max) max = wrong
      }
      print max
    }
  ' "$file"
}

group_exists_in_subject() {
  local subject="$1"
  local group="$2"
  local dir
  dir="$(get_subject_tests_dir "$subject")"
  awk -F';' -v g="$group" '
    $1 == g { found=1; exit 0 }
    END { if (!found) exit 1 }
  ' "$dir"/TEST-* 2>/dev/null
}

max_correct_names_all_tests() {
  local subject="$1"
  local group="$2"
  local dir
  dir="$(get_subject_tests_dir "$subject")"
  awk -F';' -v g="$group" '
    $1 == g && ($5 + 0) > 2 {
      a[$2] += ($4 + 0)
    }
    END {
      max = 0
      for (s in a) if (a[s] > max) max = a[s]
      for (s in a) if (a[s] == max) printf "%s ", s
    }
  ' "$dir"/TEST-* 2>/dev/null | sed 's/ $//'
}

max_correct_value_all_tests() {
  local subject="$1"
  local group="$2"
  local dir
  dir="$(get_subject_tests_dir "$subject")"
  awk -F';' -v g="$group" '
    $1 == g && ($5 + 0) > 2 {
      a[$2] += ($4 + 0)
    }
    END {
      max = 0
      for (s in a) if (a[s] > max) max = a[s]
      print max
    }
  ' "$dir"/TEST-* 2>/dev/null
}

max_wrong_names_all_tests() {
  local subject="$1"
  local group="$2"
  local dir
  dir="$(get_subject_tests_dir "$subject")"
  local total
  total="$(get_total_questions "$subject")"
  awk -F';' -v g="$group" -v total="$total" '
    $1 == g {
      c = ($4 + 0)
      corr[$2] += c
      cnt[$2]++
    }
    END {
      max = 0
      for (s in corr) {
        wrong = cnt[s] * total - corr[s]
        a[s] = wrong
        if (wrong > max) max = wrong
      }
      for (s in a) if (a[s] == max) printf "%s ", s
    }
  ' "$dir"/TEST-* 2>/dev/null | sed 's/ $//'
}

max_wrong_value_all_tests() {
  local subject="$1"
  local group="$2"
  local dir
  dir="$(get_subject_tests_dir "$subject")"
  local total
  total="$(get_total_questions "$subject")"
  awk -F';' -v g="$group" -v total="$total" '
    $1 == g {
      c = ($4 + 0)
      corr[$2] += c
      cnt[$2]++
    }
    END {
      max = 0
      for (s in corr) {
        wrong = cnt[s] * total - corr[s]
        if (wrong > max) max = wrong
      }
      print max
    }
  ' "$dir"/TEST-* 2>/dev/null
}
