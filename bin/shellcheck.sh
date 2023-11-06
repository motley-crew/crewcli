#!/bin/bash

# This script wraps shellcheck to enforce project-wide settings

IGNORES="SC2148,SC2154"

OPTIONS="--exclude=$IGNORES"

find . -type f -name "*.sh" ! -path "./bin/*" -exec shellcheck $OPTIONS {} +
