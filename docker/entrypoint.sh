#!/bin/bash --login
set -euo pipefail
conda activate lume-test
exec python /lume-impact-live-demo/lume-impact-live-demo.py
