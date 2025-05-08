#!/bin/sh

PACKAGE="himalaya"
REPO="pimalaya/himalaya"

VERSION="$(cat tag)"

ARCH="amd64 arm64"
AMD64_FILENAME="himalaya.x86_64-linux.tgz"
ARM64_FILENAME="himalaya.aarch64-linux.tgz"

get_url_by_arch() {
    case $1 in
    "amd64") echo "https://github.com/$REPO/releases/latest/download/$AMD64_FILENAME" ;;
    "arm64") echo "https://github.com/$REPO/releases/latest/download/$ARM64_FILENAME" ;;
    esac
}

build() {
    # Prepare
    BASE_DIR="$PACKAGE"_"$VERSION"-1_"$1"
    cp -r templates "$BASE_DIR"
    sed -i "s/Architecture: arch/Architecture: $1/" "$BASE_DIR/DEBIAN/control"
    sed -i "s/Version: version/Version: $VERSION-1/" "$BASE_DIR/DEBIAN/control"
    # Download and move file
    curl https://api.github.com/repos/$REPO/releases/latest | jq -r '.body' > $BASE_DIR/usr/share/doc/$PACKAGE/CHANGELOG.md
    curl -sLo "$PACKAGE-$VERSION-$1.tgz" "$(get_url_by_arch $1)"
    tar -xzf "$PACKAGE-$VERSION-$1.tgz"
    mv share/applications $BASE_DIR/usr/share/applications
    mv share/man $BASE_DIR/usr/share/man
    mkdir -p $BASE_DIR/usr/share/bash-completion/completions && mv share/completions/himalaya.bash $BASE_DIR/usr/share/bash-completion/completions
    mkdir -p $BASE_DIR/usr/share/fish/completions && mv share/completions/himalaya.fish $BASE_DIR/usr/share/fish/completions
    mkdir -p $BASE_DIR/usr/share/zsh/vendor-completions && mv share/completions/himalaya.zsh $BASE_DIR/usr/share/zsh/vendor-completions
    mkdir -p $BASE_DIR/usr/share/elvish/lib && mv share/completions/himalaya.elvish $BASE_DIR/usr/share/elvish/lib/himalaya.elvish
    # mv share/completions/himalaya.powershell $BASE_DIR/usr/share/
    rm -rf share
    mv "$PACKAGE" "$BASE_DIR/usr/bin/$PACKAGE"
    chmod 755 "$BASE_DIR/usr/bin/$PACKAGE"
    # Build
    dpkg-deb --build --root-owner-group -Z xz "$BASE_DIR"
}

for i in $ARCH; do
    echo "Building $i package..."
    build "$i"
done

# Create repo files
apt-ftparchive packages . > Packages
apt-ftparchive release . > Release
