# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

inherit toolchain-funcs games

DESCRIPTION="AMX Mod X is a versatile Half-Life metamod plugin which is targetted toward server administration."
HOMEPAGE="http://amxmodx.org/"
SRC_URI="!src? ( mirror://sourceforge/amxmodx/amxmodx-${PV}-base.tar.gz )
	src? ( mirror://sourceforge/amxmodx/amxmodx-source-${PV}.tar.gz )"

LICENSE="GPL-1"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="doc hl-cstrike hl-dod hl-esf hl-ns hl-tfc hl-ts src"

DEPEND="|| ( >=games-server/halflife-metamod-1.19 >=games-server/halflife-metamod-p-1.19_p28 )
	src? ( >=dev-games/hlsdk-2.3_p2 )"
RDEPEND="|| ( games-server/halflife-server games-server/halflife-steam )"

MODS="cstrike dod esf ns tfc ts"

if use src ; then
	S=${WORKDIR}/amxmodx-${PV}
else
	for MOD in $MODS; do
		SRC_URI="${SRC_URI} hl-${MOD}? ( mirror://sourceforge/amxmodx/amxmodx-${PV}-${MOD}.tar.gz )"
	done
	S=${WORKDIR}/addons/amxmodx
fi
INSTALL_DIR=${GAMES_PREFIX_OPT}/halflife/addons/amxmodx

pkg_setup() {
	local use_mods=''
	local n_mods=0
	for MOD in $MODS; do
		if use hl-${MOD}; then
			let n_mods++
			use_mods="${use_mods} hl-${MOD}"
	    fi
	done
	if [[ ${n_mods} -gt 1 ]]; then
		die "Please use only one hl-MOD USE directive !!! Now ${use_mods_n} mods: ${use_mods}"
	fi
}

src_compile() {
	# move cfg's to .example
	for cfg_file in `ls configs/*.ini configs/*.cfg` ; do mv $cfg_file $cfg_file.example ; done
	if use src ; then
		cd "${S}"/amxmodx
		ewarn "Compile from source too buggy - not work now!" && die
		emake \
			CPP="$(tc-getCC)" \
			HLSDK="$(games_get_libdir)"/hlsdk/multiplayer \
			MM_ROOT="$(games_get_libdir)"/metamod \
		|| die
	fi
}

src_install() {
	if use src ; then
		cd "${S}"/amxmodx
		emake install || die
	fi
	if use doc; then dodoc doc/*; fi
	rm -rf doc
	dodir "${INSTALL_DIR}"
	insinto "${INSTALL_DIR}"
	doins -r *
	exeinto "${INSTALL_DIR}"/scripting
	doexe scripting/amxxpc scripting/compile.sh
	keepdir "${INSTALL_DIR}"/logs "${INSTALL_DIR}"/scripting/compiled
	prepgamesdirs
}

pkg_postinst() {
	einfo ""
	einfo "Don't forget run"
	einfo " emerge --config games-server/halflife-amxmodx"
	einfo "for coping new config files if need"
	einfo ""
	einfo "You can use 'addons/amxmodx/scripting' directory      "
	einfo " for place and compile here your custom plugins."
	einfo "And for this you can use compile.sh script.     "
	einfo ""
	einfo "! See changelog for changes you need make !"
	einfo "http://wiki.alliedmods.net/AMX_Mod_X_${PV}_Changes"
	einfo ""
}

pkg_config() {
	# install default cfg's unless exists custom
	for example_cfg_file in `ls ${INSTALL_DIR}/configs/*.ini.example ${INSTALL_DIR}/configs/*.cfg.example`; do
		cfg_file=`echo $example_cfg_file | sed s:\.example$:: | sed s:^.*/::`
		if [ ! -e "${INSTALL_DIR}/configs/$cfg_file" ] ; then
			einfo "Coping $cfg_file.example to $cfg_file";
			cp "${INSTALL_DIR}/configs/$cfg_file.example" "${INSTALL_DIR}/configs/$cfg_file";
		fi
	done
}

# vim: set ts=4 noexpandtab :
