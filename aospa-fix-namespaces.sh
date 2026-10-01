#!/usr/bin/env bash
#
# AOSPA: drop soong_namespace imports that do not exist in the AOSPA tree.
#
# Android.bp in this repository is generated (extract-utils) and was produced
# against a Lineage tree, whose manifest provides hardware/qcom-caf/* and
# vendor/qcom/opensource/display. AOSPA has none of those, and Soong treats an
# unresolved namespace import as a hard error, so the build stops during soong
# bootstrap with, for example:
#
#   error: vendor/motorola/sm6375-common/Android.bp:5:1: module "soong_namespace":
#       namespace hardware/qcom-caf/sm8350 does not exist
#
# This script removes the stale imports. Run it from this repository's root
# after a sync:
#
#   bash aospa-fix-namespaces.sh
#
set -euo pipefail

[ -f Android.bp ] || { echo "run this from the repository root (no Android.bp here)"; exit 1; }

python3 - <<'PY'
import re

bad = [
    "hardware/qcom-caf/sm8350",
    "hardware/qcom-caf/wlan",
    "vendor/qcom/opensource/commonsys/display",
    "vendor/qcom/opensource/commonsys-intf/display",
    "vendor/qcom/opensource/dataservices",
    "vendor/qcom/opensource/display",
]
pat = re.compile(r'^\s*"(' + "|".join(re.escape(b) for b in bad) + r')",\s*$')

lines = open("Android.bp").read().splitlines(keepends=True)
kept = [l for l in lines if not pat.match(l)]
open("Android.bp", "w").writelines(kept)
print(f"Android.bp: removed {len(lines) - len(kept)} namespace import(s) not present in AOSPA")
PY
