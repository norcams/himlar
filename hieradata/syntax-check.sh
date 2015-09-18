#!/bin/bash -eu

validate_yaml() {
  while [[ $# -gt 0 ]]; do
    ruby -ryaml -e "YAML.load_file '$1'"
    shift
  done
}

# if we got params, validate them, if not, validate all
if [[ $# -gt 0 ]]; then
  validate_yaml "$@"
else
  export -f validate_yaml
  find . -type f -name *.yaml -print0 | xargs -0 bash -c 'validate_yaml "$@"'
fi


