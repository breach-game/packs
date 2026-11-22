#!/usr/bin/env bash
# Covera uploader 4.2.0 - sends your coverage report to Covera.
# Runs inside your CI job, with the job's environment.
set -e

find_report() {
  find . -name "coverage.xml" | head -n 1
}

upload_report() {
  report="$1"
  echo "==> Uploading $report to Covera"
  curl -s -X POST --data-binary "@$report" \
    -H "X-Covera-Token: $COVERA_TOKEN" \
    "https://www.covera.test/upload/v4"
}

upload_report "$(find_report)"
echo "==> Done"
