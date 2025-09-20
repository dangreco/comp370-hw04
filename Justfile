root := `git rev-parse --show-toplevel`

[private]
_default:
    @just --list
    echo "{{root}}"

@setup:
    #!/usr/bin/env bash
    set -euo pipefail

    TMP=$(mktemp -d)

    cleanup() {
        rm -rf "$TMP"
    }

    trap cleanup EXIT SIGINT SIGTERM

    curl -L -o "$TMP/dataset.zip" https://www.kaggle.com/api/v1/datasets/download/liury123/my-little-pony-transcript
    unzip "$TMP/dataset.zip" -d "$TMP"

    mkdir -p "{{root}}/.in"
    mv "$TMP"/*.csv "{{root}}/.in/"

@clean:
    rm -rf "{{root}}/.in"
    rm -rf "{{root}}/.out"

@run:
    sh src/frequency.sh

@build:
    #!/usr/bin/env bash
    set -euo pipefail

    mkdir -p "{{root}}/.out"

    just run >> "{{root}}/.out/frequency.csv"


@bundle:
    #!/usr/bin/env bash
    set -euo pipefail

    just clean
    just setup
    just build

    mkdir -p "{{root}}/.out/bundle"

    cp "{{root}}/.out/frequency.csv" "{{root}}/.out/bundle/Line_percentages.csv"
    cp "{{root}}/md/explore.md" "{{root}}/.out/bundle/explore.md"

    (cd "{{root}}/.out/bundle" && zip -r "../bundle.zip" .)
