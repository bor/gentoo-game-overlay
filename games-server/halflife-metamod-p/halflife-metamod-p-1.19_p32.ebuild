# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

inherit toolchain-funcs games

MY_PV=${PV/_/}

DESCRIPTION="plugin manager for Half-Life server"
HOMEPAGE="http://metamod-p.sourceforge.net/"
SRC_URI="!src? ( mirror://sourceforge/metamod-p/metamod-p-${MY_PV}-linux_i586.tar.gz )
	src? ( mirror://sourceforge/metamod-p/metamod-p-${MY_PV}.tar.bz2 )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="src"

RDEPEND="games-server/halflife-steam"
DEPEND="${RDEPEND}
	src? ( >=dev-games/hlsdk-2.3_p2 )"

RESTRICT="mirror"

S="${WORKDIR}/metamod-p-${MY_PV}"

cfg_files="plugins.ini config.ini"
case ${CHOST} in
	i686*-linux*)   TARGET=i686 ;;
	x86_64*-linux*) TARGET=amd64 ;;
	*-linux*)       TARGET=compat-i386 ;;
	*)            die "Unknown target, you suck" ;;
esac

src_unpack() {
	unpack ${A}
	if use src ; then
		for cfg_file in $cfg_files ; do
			mv "${S}/doc/$cfg_file" "${S}/doc/$cfg_file.example"
		done
		epatch "${FILESDIR}/metamod-p-${PV}-asm-page-h.patch"
	else
		mkdir "${S}" "${S}/doc" "${S}/dlls"
		mv *.so "${S}"/dlls
		for cfg_file in $cfg_files ; do
			cp "${FILESDIR}/$cfg_file" "${S}/doc/$cfg_file.example"
		done
	fi
}

src_compile() {
	use src || return 0
	einfo "Compile for TARGET ${TARGET}"
	emake \
		CC="$(tc-getCC)" \
		CCO="${CFLAGS}" \
		TARGET=${TARGET} \
		SDKTOP="$(games_get_libdir)"/hlsdk \
		OPT=opt \
	|| die
}

src_test() {
	use src || return 0
	mkdir "$WORKDIR"/test
	emake \
		CC="$(tc-getCC)" \
		TARGET=${TARGET} \
		SDKTOP="$(games_get_libdir)"/hlsdk \
		TEST_DIR=$WORKDIR/test \
		OPT=opt \
		test \
	|| die
}

src_install() {
	local INST_DIR=${GAMES_PREFIX_OPT}/halflife/addons/metamod-p
	dodir ${INST_DIR} ${INST_DIR}/dlls
	insinto ${INST_DIR}

	if use src ; then
		emake \
			CC="$(tc-getCC)" \
			TARGET=${TARGET} \
			SDKTOP="$(games_get_libdir)"/hlsdk \
			INST_DIR=${D}/${INST_DIR}/dlls \
			OPT=opt \
			install \
		|| die
		insinto "$(games_get_libdir)"/metamod-p
		doins metamod/*.h
		dodoc doc/Changelog doc/README.txt doc/TODO doc/txt/*
		dohtml -r doc/html/*
	else
		exeinto ${INST_DIR}/dlls
		doexe dlls/*.so
	fi
	insinto ${INST_DIR}
	# install cfg's
	for cfg_file in $cfg_files ; do
		doins doc/$cfg_file.example
		# install default cfg's unless exists
		if [ ! -d ${INST_DIR} -o ! -e "${INST_DIR}/$cfg_file" ] ; then newins doc/$cfg_file.example $cfg_file; fi
	done
	prepgamesdirs
}
