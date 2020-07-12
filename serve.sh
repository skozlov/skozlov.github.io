#!/usr/bin/env bash
set -euo pipefail

(cd $(realpath $(dirname $0)) && bundle install && bundle exec jekyll serve)