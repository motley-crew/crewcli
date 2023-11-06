#!/bin/bash

print_usage() {
    cat <<EOF
Usage: ${0} [command] [options]

Commands:
  lokalise            Manage lokalisation tasks
  module1             Description for module1
  module2             Description for module2
  ...

Use "${0} [command] -h" for more information about a command.
EOF
}

module1() {
    echo "Module1 functionality goes here..."
}

module2() {
    echo "Module2 functionality goes here..."
}

lokalise() {
    echo "Lokalise functionality goes here..."
     ./bin/lokalise.sh "$@"
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
        module1)
            shift
            module1 "$@"
            ;;
        module2)
            shift
            module2 "$@"
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
