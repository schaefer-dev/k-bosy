#!/usr/bin/env bash
/usr/bin/time -v ./run.sh -i "$1".json -d "$1".gv --benchmark --aalta
