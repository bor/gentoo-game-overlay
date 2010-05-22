# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

inherit games

DESCRIPTION="Half-Life Software Development Kit for mod authors"
HOMEPAGE="http://metamod.sourceforge.net/files/sdk/"
SRC_URI="http://metamod.sourceforge.net/files/sdk/${P/_/-}.tar.gz"

LICENSE="ValveSDK"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
RESTRICT="mirror"

S=${WORKDIR}/${P/_/-}
MY_PV=${PV/_/-}

src_compile() {
	find -iname '*.orig' -exec rm -f '{}' \;
}

src_install() {
	insinto "$(games_get_libdir)"/${PN}
	dodoc SDK_EULA.txt metamod.hlsdk-${MY_PV}.txt metamod.hlsdk-${MY_PV}.patch
	doins -r multiplayer singleplayer || die "doins failed"
	prepgamesdirs
}
