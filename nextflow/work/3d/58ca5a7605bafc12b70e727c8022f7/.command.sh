#!/bin/bash -ue
awk -F '\t' '
{
  gsub(".*/", "", $1); gsub(".*/", "", $2);
  gsub(".fasta", "", $1); gsub(".fasta", "", $2);
  m[$1][$2] = $3;
  samples[$1]; samples[$2];
}
END {
  n = asorti(samples, s);
  printf "\t";
  for (i = 1; i <= n; i++) printf "%s\t", s[i];
  printf "\n";
  for (i = 1; i <= n; i++) {
    printf "%s\t", s[i];
    for (j = 1; j <= n; j++) {
      printf "%s\t", m[s[i]][s[j]] ? m[s[i]][s[j]] : "NA";
    }
    printf "\n";
  }
}' all_vs_all.tsv > identity_matrix.tsv
