#!/bin/bash -e
#
# Build a NREC flavoured skyline-console wheel.
#
# The console is a webpack bundle, so the menu and the branding are decided
# when the wheel is built, not by puppet. This script clones our fork, applies
# provision/skyline/nrec-console.patch (menu entries we do not want, same list
# horizon unregisters in profile/files/openstack/horizon/overrides.py),
# replaces the logos and runs "make package".
#
# The resulting wheel goes to $BUILD_DIR/skyline-console/dist and should be
# uploaded to our package repo. Point
# profile::openstack::skyline::pip_packages at it afterwards.
#
# Build host requirements (see the install guide):
#   dnf install git python3-pip python3-wheel make tar wget
#   nodejs 16 (lts/gallium) and yarn, easiest through nvm
#
# Usage: ./build-console.sh [build directory]
#

BUILD_DIR=${1:-/tmp/skyline-build}
REPO_URL=${REPO_URL:-https://github.com/caleno/skyline-console.git}
REPO_REF=${REPO_REF:-master}

HIMLAR_DIR=$(cd "$(dirname "$0")/../.." && pwd)
PATCH_FILE="${HIMLAR_DIR}/provision/skyline/nrec-console.patch"
LOGO_DIR="${HIMLAR_DIR}/profile/files/openstack/horizon/img"

if [ ! -f "${PATCH_FILE}" ]; then
  echo "Could not find ${PATCH_FILE}"
  exit 1
fi

mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

if [ -d skyline-console/.git ]; then
  echo "== updating existing checkout"
  cd skyline-console
  git checkout -- .
  git fetch origin "${REPO_REF}"
  git checkout "${REPO_REF}"
  git reset --hard "origin/${REPO_REF}"
else
  echo "== cloning ${REPO_URL}"
  git clone "${REPO_URL}" skyline-console
  cd skyline-console
  git checkout "${REPO_REF}"
fi

echo "== applying ${PATCH_FILE}"
git apply --verbose "${PATCH_FILE}"

echo "== replacing logos"
# These four are emitted with a stable file name by config/webpack.common.js,
# everything else gets a content hash.
cp "${LOGO_DIR}/logo.svg"         src/asset/image/cloud-logo.svg
cp "${LOGO_DIR}/logo.svg"         src/asset/image/cloud-logo-white.svg
cp "${LOGO_DIR}/logo_neic.png"    src/asset/image/logo.png
cp "${LOGO_DIR}/favicon.ico"      src/asset/image/favicon.ico

echo "== building wheel"
make package

echo
echo "Wheel(s) built:"
ls -1 dist/*.whl
echo
echo "Install with:"
echo "  python3 -m pip install --force-reinstall dist/skyline_console-*.whl"
