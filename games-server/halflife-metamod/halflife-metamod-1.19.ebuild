# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

inherit toolchain-funcs games

DESCRIPTION="plugin manager for Half-Life server"
HOMEPAGE="http://www.metamod.org/"
SRC_URI="!src? ( x86? ( mirror://sourceforge/metamod/metamod-${PV}-linux.tar.gz )
				amd64? ( mirror://sourceforge/metamod/metamod-${PV}-linux-amd64.tar.gz ) )
	src? ( mirror://sourceforge/metamod/metamod-${PV}-linux.src.tar.gz )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="src"

RDEPEND="|| ( games-server/halflife-steam games-server/halflife-server )"
DEPEND="${RDEPEND}
	src? ( >=dev-games/hlsdk-2.3_p2 )"

RESTRICT="mirror"

S="${WORKDIR}/metamod-${PV}"

cfg_files="plugins.ini config.ini"
INST_DIR=${GAMES_PREFIX_OPT}/halflife/addons/metamod

src_unpack() {
	unpack ${A}
	if use src ; then
		for cfg_file in $cfg_files ; do
			mv "${S}/doc/$cfg_file" "${S}/doc/$cfg_file.example"
		done
		sed -i 's:-malign-:-falign-:g' `find -name Makefile`
	else
		mkdir "${S}" "${S}"/doc "${S}"/dlls
		mv *.so "${S}"/dlls
		for cfg_file in $cfg_files ; do
			cp "${FILESDIR}/$cfg_file" "${S}/doc/$cfg_file.example"
		done
	fi
}

src_compile() {
	use src || return 0
	emake \
		CC="$(tc-getCC)" \
		CCO="${CFLAGS}" \
		SDKTOP="$(games_get_libdir)"/hlsdk \
		OPT=opt \
	|| die
}

src_test() {
	use src || return 0
	mkdir "$WORKDIR"/test
	emake \
		SDKTOP="$(games_get_libdir)"/hlsdk \
		TEST_DIR=$WORKDIR/test \
		OPT=opt \
		test \
	|| die
}

src_install() {
	dodir ${INST_DIR} ${INST_DIR}/dlls
	insinto ${INST_DIR}

	if use src ; then
		emake \
			SDKTOP="$(games_get_libdir)"/hlsdk \
			INST_DIR=$D/${INST_DIR}/dlls \
			OPT=opt \
			install \
		|| die
		insinto "$(games_get_libdir)"/metamod
		doins metamod/*.h
		dodoc doc/Changelog doc/README.txt doc/TODO doc/txt/*
		dohtml -r doc/html/*
	else
		exeinto ${INST_DIR}/dlls
		doexe dlls/*.so
	fi

	# install cfg's
	for cfg_file in $cfg_files ; do
		doins doc/$cfg_file.example
		# install default cfg's unless exists
		if [ ! -d ${INST_DIR} -o ! -e "${INST_DIR}/$cfg_file" ] ; then
			newins doc/$cfg_file.example $cfg_file;
		fi
	done
	prepgamesdirs
}

# vim: set ts=4 noexpandtab :
