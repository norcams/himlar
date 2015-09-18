#!/bin/bash -eu

validate_yaml() {
  ruby -ryaml -e "YAML.load_file '$1'"
}

while [[ $# -gt 0 ]]; do
  validate_yaml "$1"
  shift
done

