#!/bin/bash

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
     ./bin/lokalise.sh "$@"
}

version() {
      ./bin/version.sh "$@"
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
