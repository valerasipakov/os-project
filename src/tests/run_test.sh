#!/usr/bin/env bash
set -e
pytest -q && echo "TESTS PASSED" || (echo "TESTS FAILED"; exit 1)
