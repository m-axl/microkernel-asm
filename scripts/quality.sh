#!/usr/bin/env sh
set -eu

fail() {
    printf '%s\n' "quality: $1" >&2
    exit 1
}

command -v nasm >/dev/null 2>&1 || fail "nasm is required"
command -v make >/dev/null 2>&1 || fail "make is required"

test -f README.md || fail "README.md is missing"
test -f docs/architecture.md || fail "docs/architecture.md is missing"
test -f docs/testing.md || fail "docs/testing.md is missing"
test -f docs/error-analysis.md || fail "docs/error-analysis.md is missing"

grep -q "Milestone 0" README.md || fail "README.md must describe the current milestone"
grep -q "microkernel" docs/architecture.md || fail "architecture doc must describe the microkernel"
grep -q "make check" docs/testing.md || fail "testing doc must document make check"

find boot kernel include servers docs scripts -type f \
    ! -path '*/.git/*' \
    -exec sh -c '
        for file do
            [ -s "$file" ] || {
                printf "%s\n" "quality: empty file: $file" >&2
                exit 1
            }
        done
    ' sh {} +

printf '%s\n' "quality: static checks passed"
