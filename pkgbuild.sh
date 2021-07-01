#!/bin/bash


pkgname=keepass
pkgver=2.48.1
pkgrel=1
pkgdesc='Easy-to-use password manager for Windows, Linux, Mac OS X and mobile devices'
arch=('any')
url='https://keepass.info/'
license=('GPL')
depends=('mono' 'desktop-file-utils' 'xdg-utils' 'shared-mime-info' 'gtk-update-icon-cache')
makedepends=('icoutils')
optdepends=('xdotool: if you want to use auto-type'
            'xsel: clipboard operations in order to work around Mono clipboard bugs')


install="$pkgname.install"
source=("https://downloads.sourceforge.net/keepass/KeePass-$pkgver-Source.zip"
        "https://keepass.info/integrity/v2/KeePass-$pkgver-Source.zip.asc"
        'keepass'
        'keepass.1'
        'keepass.desktop'
        'keepass.xml')

	
repare() {
  # Extract icons
  icotool -x KeePass/KeePass.ico

  pushd Build &>/dev/null
  LANG=en_US.UTF-8 bash PrepMonoDev.sh
  popd &>/dev/null
}

build() {
  xbuild /target:KeePass /property:Configuration=Release
  cp Ext/KeePass.exe.config Build/KeePass/Release/
}


package() {
  install -dm755 "$pkgdir"/usr/bin
  install -dm755 "$pkgdir"/usr/share/keepass/XSL

  install -Dm755 keepass "$pkgdir"/usr/bin/keepass
  install -Dm755 Build/KeePass/Release/KeePass.exe "$pkgdir"/usr/share/keepass/KeePass.exe
  install -Dm755 Ext/KeePass.config.xml "$pkgdir"/usr/share/keepass/KeePass.config.xml
  install -Dm755 Ext/KeePass.exe.config "$pkgdir"/usr/share/keepass/KeePass.exe.config

  install -m644 Ext/XSL/* "$pkgdir"/usr/share/keepass/XSL

  install -Dm644 keepass.1 "$pkgdir"/usr/share/man/man1/keepass.1

  # Proper installation of .desktop file
  desktop-file-install -m 644 --dir "$pkgdir"/usr/share/applications/ keepass.desktop

  # Install icons
  for size in 16 32 48 256; do
    install -Dm644 \
    KeePass_*_${size}x${size}x32.png \
    "$pkgdir"/usr/share/icons/hicolor/${size}x${size}/apps/keepass.png
  done

  # Needed for postinst with xdg-utils
  install -Dm644 keepass.xml "$pkgdir"/usr/share/mime/packages/keepass.xml
}
