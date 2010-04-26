# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit subversion

MY_PN="${PN}2"
ESVN_REPO_URI="https://${PN}.svn.sourceforge.net/svnroot/${PN}/trunk/${MY_PN}"

DESCRIPTION="Server statics collector supporting many FPS games"
HOMEPAGE="http://www.qstat.org/"
SRC_URI=""

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug"

DEPEND="!sys-cluster/torque"

S=${WORKDIR}/${MY_PN}

src_compile() {
	if [[ ! -e configure ]] ; then
		./autogen.sh || die "autogen failed"
	fi
	econf $(use_enable debug) || die
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	dosym qstat /usr/bin/quakestat
	dodoc CHANGES.txt COMPILE.txt template/README.txt
	dohtml template/*.html qstatdoc.html
}
