#!/bin/bash

PROJECT_DIR="$(dirname "$0")/.."
VERSION_FILES=""
VERSION_FIELD="version"

if [ -f "$PROJECT_DIR/.env" ]; then
    . "$PROJECT_DIR/.env"
fi

while getopts "d:f:" opt; do
  case $opt in
    d) PROJECT_DIR="$OPTARG" ;;
    f) VERSION_FILES="$OPTARG" ;;
    \?) echo "Invalid option -$OPTARG" >&2; exit 1 ;;
  esac
done

shift $((OPTIND -1))

if [ -z "$PROJECT_DIR" ] then
    PROJECT_DIR="."
fi

if [ -z "$VERSION_FILES" ] then
    if [ -f "$PROJECT_DIR/package.json" ]; then
        VERSION_FILES="package.json"
    fi
fi

if [ -z "$VERSION_FILES" ] then
    echo "Cannot determine the version files, bailing out" >&2
    exit 1
fi

print_usage() {
    cat <<EOF
Usage: ${0} [options] <command>

Options:
  -d <dir>      Root directory of the project
  -f <files>    List of files to update version in

Commands:
  read        read the current version
  bump        bump the package version
EOF
}

read_ver() {
    grep "\"$VERSION_FIELD\"" "$PROJECT_DIR/$VERSION_FILE" | sed 's/.*: *"\(.*\)".*/\1/'
}

write_ver() {
    local new_version="$1"
    local file="$PROJECT_DIR/$VERSION_FILE"
    sed "s/\"$VERSION_FIELD\" *: *\".*\",/\"$VERSION_FIELD\": \"$new_version\",/" "$file" > "$file.new"
    mv "$file.new" "$file"
}

inc_ver() {
    local current_version="$1"
    local value=$(echo "$current_version" | sed "s/.*[^0-9]\([0-9]*\)/\1/")
    local new_value=$((value + 1))
    echo "$current_version" | sed "s/\(.*[^0-9]\)[0-9]*$/\1$new_value/"
}

set_ver() {
    write_ver "$1"
    git commit -am "Change version to $1" --no-verify
    git tag "build-$1"
}

bump_ver() {
    local ver=$(read_ver)
    ver=$(inc_ver "$ver")
    set_ver "$ver"
    git push
    git push --tags
}

main() {
    case "$1" in
        read)
            read_ver
            ;;
        bump)
            bump_ver
            ;;
        *)
            print_usage
            exit 1
            ;;
    esac
}

main "$@"
