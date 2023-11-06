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

main() {
    if [[ $# -eq 0 ]]; then
        print_usage
        exit 1
    fi

        lokalise)
            shift
            ./lokalise.sh "$@"
            ;;
        module1)
            shift # Remove 'module1' from the arguments list
            module1 "$@"
            ;;
        module2)
            shift # Remove 'module2' from the arguments list
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

