#!/bin/sh

set -x

pwd
ls -la
(cd .. && ls -la)
python3 -m pip install -r src-gen/requirements.txt