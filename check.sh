#!/bin/sh

REPO="pimalaya/himalaya"
DEBS_REPO="wcbing-build/himalaya-debs"

get_github_latest_tag() {
    curl -sw "%{redirect_url}" "https://github.com/$1/releases/latest" |
        sed -n 's|.*/releases/tag/[^0-9]*\([^_]*\).*|\1|p'
}

DEBS_VERSION=$(get_github_latest_tag "$DEBS_REPO")
if [ -z "$DEBS_VERSION" ]; then
    echo "Error: Can't get version tag from $DEBS_REPO."
    DEBS_VERSION="0"
fi

VERSION=$(get_github_latest_tag "$REPO")
if [ -z "$VERSION" ]; then
    echo "Error: Can't get version tag from $REPO."
    echo 0 > tag
    exit 1
elif [ "$DEBS_VERSION" = "$VERSION" ]; then
    echo "No update."
    echo 0 > tag
    exit 0
fi

echo "$VERSION" > tag
echo "Update to $VERSION from $DEBS_VERSION."
