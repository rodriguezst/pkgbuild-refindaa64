# Maintainer: David Runge <dvzrv@archlinux.org>

pkgbase=refind
pkgname=(refind-nabu refind-nabu-docs)
pkgver=0.14.2
pkgrel=2
pkgdesc="An EFI boot manager"
arch=(aarch64)  # we build architecture-specific EFI binaries
url="https://www.rodsbooks.com/refind/"
provides=(refind)
conflicts=(refind)
makedepends=(
  bash
  dosfstools
  efibootmgr
  python2
)
source=(https://sourceforge.net/projects/refind/files/$pkgver/$pkgbase-src-$pkgver.tar.gz
        https://github.com/tianocore/edk2/releases/download/vUDK2018/edk2-vUDK2018.tar.gz)
sha512sums=('76a52ed422ab3d431e6530fae4d13a51e8ed100568d4290207aaee87a84700b077bb79c4f4917027f5286de422954e1872fca288252ec756072d6c075b102e1e'
            '8fd9316f08a5c30f8684b2fde73906a943bb067ec91699f41796e27679af73dbc38efaa100a57d4b835656b402d9c08896abc5c10fd0d607a7e0173b3d7a60b2')
b2sums=('987acb29d4d81c01db245cd8e1c9761072e34cf3dfaa3e4fa77e549ee2c1dc4c3f8cbd9218f42e4eb77478df3453095dba8b36324c289c6a10b81f1ecb202743'
        'a10171659451d7d3df737066ec0471db1e5055bd52556d4d0654b244e827512db8d88e2b74b4dfe0189f768e0eab7a705aa32a720e047555995cf339ea50c62f')
_arch='aa64'

prepare() {
  pushd edk2-vUDK2018
  export EDK2BASE=$(pwd)
  echo EDK2BASE=${EDK2BASE}
  source edksetup.sh
  sed -i 's/-Werror //g' BaseTools/Source/C/Makefiles/header.makefile
  cat BaseTools/Source/C/Makefiles/header.makefile
  sed -i 's/^ACTIVE_PLATFORM .*/ACTIVE_PLATFORM = MdePkg\/MdePkg.dsc/g' Conf/target.txt
  sed -i 's/^TARGET .*/TARGET = RELEASE/g' Conf/target.txt
  sed -i 's/^TARGET_ARCH .*/TARGET_ARCH = AARCH64/g' Conf/target.txt
  sed -i 's/^TOOL_CHAIN_TAG .*/TOOL_CHAIN_TAG = GCC5/g' Conf/target.txt
  sed -i 's/ENV(GCC5_AARCH64_PREFIX)/\/usr\/bin\/aarch64-linux-gnu-/g' Conf/tools_def.txt
  sed -i 's/^DEFINE GCC5_AARCH64_CC_FLAGS .*/DEFINE GCC5_AARCH64_CC_FLAGS = DEF(GCC49_AARCH64_CC_FLAGS) -fno-unwind-tables/g' Conf/tools_def.txt
  cat Conf/target.txt
  cat Conf/tools_def.txt
  make -C BaseTools
  make -C BaseTools/Source/C
  popd
  cd $pkgbase-$pkgver
  # remove the path prefix from the css reference, so that the css can live
  # in the same directory
  sed -e 's|../Styles/||g' -i docs/$pkgbase/*.html
  # hardcode RefindDir, so that refind-install can find refind_x64.efi
  sed -e 's|RefindDir=\"\$ThisDir/refind\"|RefindDir="/usr/share/refind/"|g' -i refind-install
  # add vendor line to the sbat file
  printf 'refind.%s,%s,%s,refind,%s,%s\n' 'arch' '1' 'Arch Linux' "${epoch:+${epoch}:}${pkgver}-${pkgrel}" 'https://archlinux.org/packages/?q=refind' >> refind-sbat.csv
  # disable the cross compiler for aarch64
  #sed -i 's/aarch64-linux-gnu-//g' Make.common
  # fix for SBAT on aarch64
  sed -i 's/-O binary/--target=efi-app-aarch64/g' Make.common
  # unset EDK2BASE, we will set the variable manually
  sed -i 's/^export EDK2BASE=.*//g' Makefile
  # modify up/down keys behaviour to use volume keys on Xiaomi Pad 5
  sed -i 's/UpdateScroll(\&State, SCROLL_LINE_UP)/UpdateScroll(\&State, SCROLL_LINE_LEFT)/g' refind/menu.c
  sed -i 's/UpdateScroll(\&State, SCROLL_LINE_DOWN)/UpdateScroll(\&State, SCROLL_LINE_RIGHT)/g' refind/menu.c
}

build() {
  cd $pkgbase-$pkgver
  make edk2 ARCH=aarch64
  make fs_edk2 ARCH=aarch64
}

package_refind-nabu() {
  license=(
    BSD-2-Clause
    CC-BY-SA-3.0
    CC-BY-SA-4.0
    GPL-2.0-only
    GPL-2.0-or-later
    GPL-3.0-or-later
    LGPL-2.1-or-later
    'LGPL-3.0-or-later OR CC-BY-SA-3.0'
  )
  depends=(
    bash
    dosfstools
    efibootmgr
  )
  optdepends=(
    'gptfdisk: for finding non-vfat ESP with refind-install'
    'imagemagick: for refind-mkfont'
    'openssl: for generating local certificates with refind-install'
    'python: for refind-mkdefault'
    'refind-docs: for HTML documentation'
    'sbsigntools: for EFI binary signing with refind-install'
    'sudo: for privilege elevation in refind-install and refind-mkdefault'
  )

  cd $pkgbase-$pkgver
  # NOTE: the install target calls refind-install, therefore we install things
  # manually
  # efi binaries
  install -vDm 644 refind/*.efi -t "$pkgdir/usr/share/$pkgbase/"
  install -vDm 644 drivers_*/*.efi -t "$pkgdir/usr/share/refind/drivers_$_arch/"
  install -vDm 644 gptsync/*.efi -t "$pkgdir/usr/share/$pkgbase/tools_$_arch/"
  # sample config
  install -vDm 644 $pkgbase.conf-sample -t "$pkgdir/usr/share/$pkgbase/"
  # keys
  install -vDm 644 keys/*{cer,crt} -t "$pkgdir/usr/share/$pkgbase/keys/"
  # keysdir
  install -vdm 700 "$pkgdir/etc/refind.d/keys"
  # fonts
  install -vDm 644 fonts/*.png -t "$pkgdir/usr/share/$pkgbase/fonts/"
  # icons
  install -vDm 644 icons/*.png -t "$pkgdir/usr/share/$pkgbase/icons"
  install -vDm 644 icons/svg/*.svg -t "$pkgdir/usr/share/$pkgbase/icons/svg/"
  # scripts
  install -vDm 755 {refind-{install,mkdefault,sb-healthcheck},mkrlconf,mvrefind} -t "$pkgdir/usr/bin/"
  install -vDm 755 fonts/mkfont.sh "$pkgdir/usr/bin/$pkgbase-mkfont"
  # man pages
  install -vDm 644 docs/man/*.8 -t "$pkgdir/usr/share/man/man8/"
  # docs
  install -vDm 644 {CREDITS,NEWS,README}.txt -t "$pkgdir/usr/share/doc/$pkgbase/"
  install -vDm 644 fonts/README.txt "$pkgdir/usr/share/doc/$pkgbase/README.$pkgbase-mkfont.txt"
  install -vDm 644 icons/README "$pkgdir/usr/share/doc/$pkgbase/README.icons.txt"
  install -vDm 644 keys/README.txt "$pkgdir/usr/share/doc/$pkgbase/README.keys.txt"
  # license
  install -vDm 644 LICENSE.txt -t "$pkgdir/usr/share/licenses/$pkgbase/"
}

package_refind-nabu-docs() {
  pkgdesc+=" - documentation"
  license=(FDL-1.3-or-later)

  cd $pkgbase-$pkgver
  install -vDm 644 docs/$pkgbase/*.{html,png,svg,txt} -t "$pkgdir/usr/share/doc/$pkgbase/html/"
  install -vDm 644 docs/Styles/*.css -t "$pkgdir/usr/share/doc/$pkgbase/html/"
  install -vDm 644 images/$pkgbase-banner.{png,svg} -t "$pkgdir/usr/share/doc/$pkgbase/html/"
}
