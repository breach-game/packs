#!/bin/sh
# Publishes the uploader script that customers run in their CI.
# Used by the release job. --check only tests that the key is accepted.
scp -i /opt/deploy/release.key uploader.sh release@get.covera.test:/srv/get/uploader.sh
