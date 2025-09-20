root := `git rev-parse --show-toplevel`

[private]
_default:
    @just --list
    echo "{{root}}"

@run:
    sh src/frequency.sh

@clean:
    rm -rf "{{root}}/.out"

@bundle:
    #!/usr/bin/env bash
    set -euo pipefail

    mkdir -p "{{root}}/.out"
    mkdir -p "{{root}}/.out/bundle"

    just run >> "{{root}}/.out/frequency.csv"

    cp "{{root}}/.out/frequency.csv" "{{root}}/.out/bundle/Line_percentages.csv"
    cp "{{root}}/md/explore.md" "{{root}}/.out/bundle/explore.md"

    (cd "{{root}}/.out/bundle" && zip -r "../bundle.zip" .)
