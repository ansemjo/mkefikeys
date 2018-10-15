# Maintainer: Anton Semjonov <anton@semjonov.de>

pkgname="mkefikeys"
pkgdesc="Generate signing keys and authenticated efivar updates for SecureBoot systems."

pkgver=0.0.1
pkgrel=1

arch=('any')
url="https://github.com/ansemjo/$pkgname"
license=('MIT')

depends=('systemd' 'bash' 'make' 'openssl' 'util-linux' 'efitools')
makedepends=('make')

provides=($pkgname)
conflicts=($pkgname)
source=("$pkgname"
        "README.md"
        "install.mk")
package() {
	make -f install.mk DESTDIR="$pkgdir/" install
}
sha256sums=('21974dd15b56eb10e51e0a8af8b9f11d4869ceb6b955a72bf17a1bc27de2de28'
            '96629adb0be428ac2180833f83b5e88bb70facd30f08e31b2c40a14b3f208a74'
            'b7c7e525ef763bf8f1e9e8bf48ee76ea892a21eba7b0284df6bcbdc9486a632b')
