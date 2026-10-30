#!/bin/bash
# Cached photo previews for macOS ranger, small enough for tmux passthrough.
source_file=$1
cache_file=$4
extension=$(printf '%s' "${source_file##*.}" | tr '[:upper:]' '[:lower:]')
if [ "$5" = True ]; then
    # Never generate thumbnails of thumbnails in ranger's cache.
    cache_directory=$(cd "$(dirname "$cache_file")" && pwd -P) || exit 1
    source_directory=$(cd "$(dirname "$source_file")" && pwd -P) || exit 1
    case "$source_directory/" in
        "$cache_directory/"*) exit 7 ;;
    esac
    case "$extension" in
        heic|heif|jpg|jpeg|png|tif|tiff)
            if [ -s "$cache_file" ] && [ "$cache_file" -nt "$source_file" ]; then
                exit 6
            fi
            temp_file=$(mktemp "${cache_file}.XXXXXX") || exit 1
            trap 'rm -f "$temp_file"' EXIT
            for dimension in 800 400; do
                /usr/bin/sips -s format jpeg -s formatOptions 65 -Z "$dimension" "$source_file" --out "$temp_file" >/dev/null 2>&1 || exit 1
                # Leave ample room for base64 expansion and escape sequences.
                byte_count=$(/usr/bin/stat -f %z "$temp_file")
                if [ "$byte_count" -lt 500000 ]; then
                    mv -f "$temp_file" "$cache_file" || exit 1
                    exit 6
                fi
            done
            exit 1
            ;;
    esac
fi
# Preserve ranger's standard previews for other file types.
default_scope=$(/opt/homebrew/opt/ranger/libexec/bin/python -c 'import os, ranger; print(os.path.join(os.path.dirname(ranger.__file__), "data", "scope.sh"))') || exit 1
exec /bin/bash "$default_scope" "$@"
