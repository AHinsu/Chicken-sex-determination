#!/bin/env bash
for i in *.bam; do
  echo "$i"
  samtools idxstats "$i" > "$i".stats
done
