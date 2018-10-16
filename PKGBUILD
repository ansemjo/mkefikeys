# Maintainer: Anton Semjonov <anton@semjonov.de>

pkgname="mkefikeys-git"
_pkgname="${pkgname%-git}"
pkgdesc="Generate signing keys and authenticated efivar updates for SecureBoot systems."

pkgver=0.0.2.r0.a003a43
pkgrel=1

arch=('any')
url="https://github.com/ansemjo/$_pkgname"
license=('MIT')

depends=('systemd' 'bash' 'make' 'openssl' 'util-linux' 'efitools')
makedepends=('make' 'git')

provides=($_pkgname)
conflicts=($_pkgname)
source=("$_pkgname"
        "README.md"
        "install.mk")

pkgver() {
  cd "$srcdir"
  printf "%s" "$(git describe --long | sed 's/\([^-]*-\)g/r\1/;s/-/./g')"
}

package() {
  make -f install.mk DESTDIR="$pkgdir/" install
}

sha256sums=('9f78fd35c0d7606c9ac59d71b247ed467a0d293df41c71a508a86d0b9d837c7c'
            '96629adb0be428ac2180833f83b5e88bb70facd30f08e31b2c40a14b3f208a74'
            'b7c7e525ef763bf8f1e9e8bf48ee76ea892a21eba7b0284df6bcbdc9486a632b')
