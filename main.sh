#!/bin/bash

# Determine the directory where this script resides
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

print_usage() {
    cat <<EOF
Usage: ${0} [command] [options]

Commands:
  lokalise            Manage lokalisation tasks
  version             Manage versioning tasks

Use "${0} [command] -h" for more information about a command.
EOF
}

lokalise() {
    "$DIR/bin/lokalise.sh" "$@"
}

version() {
    "$DIR/bin/version.sh" "$@"
}

main() {
    if [[ $# -eq 0 ]]; then
        print_usage
        exit 1
    fi

    case "$1" in
        lokalise)
            shift
            lokalise "$@"
            ;;
        version)
            shift
            version "$@"
            ;;
        -h|--help)
            print_usage
            ;;
        *)
            echo "Unknown command: $1"
            print_usage
            exit 1
            ;;
    esac
}

main "$@"
