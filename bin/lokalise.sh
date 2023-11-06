#!/bin/bash

PROJECT_NAME=""
LOKALISE_DIR=""
SRC_LANG=""
I18N_LANGS=""
LOKALISE_CMD="./bin/lokalise2"
FILENAME_STRUCTURE="$PROJECT_NAME-strings-%LANG_ISO%.json"

while getopts "p:d:s:l:c:f:" opt; do
  case $opt in
    p) PROJECT_NAME="$OPTARG" ;;
    d) LOKALISE_DIR="$OPTARG" ;;
    s) SRC_LANG="$OPTARG" ;;
    l) I18N_LANGS="$OPTARG" ;;
    c) LOKALISE_CMD="$OPTARG" ;;
    f) FILENAME_STRUCTURE="$OPTARG" ;;
    \?) echo "Invalid option -$OPTARG" >&2; exit 1 ;;
  esac
done

# Remove the options that have been parsed above
shift $((OPTIND -1))

if [ -z "$PROJECT_NAME" ] || [ -z "$LOKALISE_DIR" ] || [ -z "$SRC_LANG" ] || [ -z "$I18N_LANGS" ] || [ -z "$LOKALISE_CMD" ]; then
    echo "All parameters are required."
    exit 1
fi

print_usage() {
    cat <<EOF
Usage: ${0} [options] <command>

Options:
  -p PROJECT_NAME       Name of the project
  -d LOKALISE_DIR       Directory for translations
  -s SRC_LANG           Source language
  -l I18N_LANGS         Comma-separated list of international languages
  -c LOKALISE_CMD       Path to lokalise command
  -f FILENAME_STRUCTURE Filename structure for the localization files

Commands:
  lokalise-install        install lokalise support
  lokalise-push           push translations to lokalise
  lokalise-push-all       push all translations to lokalise
  lokalise-pull           pull translations from lokalise
EOF
}

lokalise_install() {
    curl -sfL https://raw.githubusercontent.com/lokalise/lokalise-cli-2-go/master/install.sh | sh
}

ensure_lokalise_cmd() {
    if ! [ -x "$LOKALISE_CMD" ]; then
        echo "Cannot find $LOKALISE_CMD command, attempting auto-install"
        lokalise_install
    fi

    if ! [ -x "$LOKALISE_CMD" ]; then
        echo "Cannot find $LOKALISE_CMD command, try running lokalise-install first"
        exit 1
    fi
}

lokalise_cmd() {
    ensure_lokalise_cmd
    $LOKALISE_CMD --token "$LOKALISE_TOKEN" --project-id "$LOKALISE_PROJECT_ID" "$@"
}

lokalise_pull() {
    if [ -n "$(git status -s $LOKALISE_DIR)" ]; then
        echo "Tree should be not modified before the pull"
        return 1
    fi

    local opts="--format json --original-filenames=false --bundle-structure $FILENAME_STRUCTURE --filter-filenames $FILENAME_STRUCTURE --export-empty-as base --export-sort first_added --plural-format icu --placeholder-format icu --escape-percent --indentation 4sp --replace-breaks=true"
    lokalise_cmd file download $opts --filter-langs $I18N_LANGS --unzip-to $LOKALISE_DIR

    if ! [ -n "$(git status -s $LOKALISE_DIR)" ]; then
        echo "Nothing changed in Lokalise at the moment."
        return 0
    fi

    git diff $LOKALISE_DIR

    local opt
    PS3='Commit changes? '
    select opt in yes no; do
        case $opt in
            yes)
                git commit -m "Lokalise updates" $LOKALISE_DIR
                return 0
                ;;
            no)
                return 0
                ;;
            *)
                echo "Invalid option $REPLY"
                ;;
        esac
    done
}

lokalise_push() {
    local lang=${1:-$SRC_LANG}
    local file="$LOKALISE_DIR/$(echo $FILENAME_STRUCTURE | sed "s/%LANG_ISO%/$lang/")"

    if ! [ -f "$file" ]; then
        echo "Lang $lang file $file does not exist, bailing out"
        exit 1
    fi

    local opts="--replace-modified --slashn-to-linebreak=true --convert-placeholders=false --apply-tm --detect-icu-plurals --distinguish-by-file"
    local outfile
    outfile=$(mktemp)
    lokalise_cmd file upload $opts --poll --poll-timeout 600s --lang-iso "$lang" --file "$file" | tee "$outfile"

    local inserted updated
    inserted=$(grep 'key_count_inserted' "$outfile" | sed 's/.*: //' | tr -d ',')
    updated=$(grep 'key_count_updated' "$outfile" | sed 's/.*: //' | tr -d ',')
    rm -f "$outfile"

    if [ "$inserted" != '0' ] || [ "$updated" != '0' ]; then
        notify any lokalise "$inserted" "$updated"
    fi
}

lokalise_push_all() {
    for lang in $SRC_LANG ${I18N_LANGS//,/ }; do
        echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>"
        echo ">>>   Pushing language: $lang"
        echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>"
        lokalise_push "$lang"
    done
}

main() {
    case "$1" in
        lokalise-install)
            lokalise_install
            ;;
        lokalise-push)
            shift # Remove the first argument
            lokalise_push "$@"
            ;;
        lokalise-push-all)
            lokalise_push_all
            ;;
        lokalise-pull)
            lokalise_pull
            ;;
        *)
            print_usage
            exit 1
            ;;
    esac
}

main "$@"

