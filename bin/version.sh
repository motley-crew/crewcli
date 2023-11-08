#!/bin/bash

PROJECT_DIR=""
FILE_STRUCTURE="package-%VERSION%.json"
VERSION_CMD="./bin/version_bump"
VERSION_FILE="package.json"
VERSION_PATTERN="version"

print_usage() {
    cat <<EOF
Usage: ${0} [options] <command>

Options:
  -d PROJECT_DIR      Directory of the project with package.json
  -f FILE_STRUCTURE   Filename structure for the package files
  -c VERSION_CMD      Path to version command
  -p VERSION_PATTERN  Version pattern in package.json

Commands:
  version-read        read the current version
  version-bump        bump the package version
EOF
}

read_ver() {
    grep "\"$VERSION_PATTERN\"" "$PROJECT_DIR/$VERSION_FILE" | sed 's/.*: *"\(.*\)".*/\1/'
}

write_ver() {
    local new_version="$1"
    local file="$PROJECT_DIR/$VERSION_FILE"
    sed "s/\"$VERSION_PATTERN\" *: *\".*\",/\"$VERSION_PATTERN\": \"$new_version\",/" "$file" > "$file.new"
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

while getopts "d:f:c:p:" opt; do
  case $opt in
    d) PROJECT_DIR="$OPTARG" ;;
    f) FILE_STRUCTURE="$OPTARG" ;;
    c) VERSION_CMD="$OPTARG" ;;
    p) VERSION_PATTERN="$OPTARG" ;;
    \?) echo "Invalid option -$OPTARG" >&2; exit 1 ;;
  esac
done

shift $((OPTIND -1))

if [ -z "$PROJECT_DIR" ] || [ -z "$FILE_STRUCTURE" ] || [ -z "$VERSION_CMD" ] || [ -z "$VERSION_PATTERN" ]; then
    echo "All parameters are required."
    exit 1
fi

main() {
    case "$1" in
        version-read)
            read_ver
            ;;
        version-bump)
            bump_ver
            ;;
        *)
            print_usage
            exit 1
            ;;
    esac
}

main "$@"
