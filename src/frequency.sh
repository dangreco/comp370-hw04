#!/usr/bin/env bash

ROOT=$(git rev-parse --show-toplevel)
total=$(csvtool drop 1 $ROOT/.in/clean_dialog.csv | wc -l)

echo "pony_name,total_line_count,percent_all_lines"

for pony in "Twilight Sparkle" "Applejack" "Rarity" "Pinkie Pie" "Rainbow Dash" "Fluttershy"
do
    lines=$(csvtool drop 1 $ROOT/.in/clean_dialog.csv  | csvtool col 3 - | grep "^$pony$" | wc -l)
    percent=$(echo "scale=10; $lines / $total * 100" | bc)
    echo "$pony,$lines,$percent"
done
