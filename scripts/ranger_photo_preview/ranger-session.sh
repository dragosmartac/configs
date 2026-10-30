#!/bin/bash
# Give each ranger invocation a private thumbnail cache, reused until exit.
session_cache=$(mktemp -d "${TMPDIR:-/tmp}/ranger-photo-preview.XXXXXXXX") || exit 1
cleanup() {
    # Only remove the directory created by this invocation, never ranger's
    # persistent cache or a cache directory supplied by the caller.
    rm -rf -- "$session_cache"
}
trap cleanup EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

/opt/homebrew/bin/ranger --cachedir="$session_cache" "$@"
exit $?
