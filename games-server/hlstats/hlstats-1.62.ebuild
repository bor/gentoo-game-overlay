# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit games webapp

WEBAPP_MANUAL_SLOT="yes"

DESCRIPTION="Real-time player and clan rankings and statistics for Half-Life"
HOMEPAGE="http://www.hlstats-community.org/"
SRC_URI="mirror://sourceforge/hlstats/HLstats/${PV}/HLStats-${PV}.tar.gz"
#SRC_URI="http://www.hlstats-community.org/wordpulse/site/hlscom/upload/Multimedia/download/${PV}/HLStats-${PV}.tar.gz"

LICENSE="CDDL"
KEYWORDS="~amd64 ~x86"
IUSE=""
SLOT="0"

DEPEND=""
RDEPEND="dev-db/mysql
	dev-lang/perl
	virtual/httpd-php
	www-servers/apache"

S="${WORKDIR}/hlstats"

pkg_setup() {
	webapp_pkg_setup
	games_pkg_setup
}

src_install() {
	webapp_src_preinst
	insinto "${GAMES_SYSCONFDIR}"
	newins daemon/hlstats.conf.ini.example hlstats.conf
	dobin "${FILESDIR}/hlstats"
	dosed "s:GENTOO_DIR:${GAMES_BINDIR}:" /usr/bin/hlstats
	newinitd "${FILESDIR}/hlstats.init.d" hlstats
	sed -i \
		-e "s:^\$opt_libdir = dirname(__FILE__);:\$opt_libdir = \"$(games_get_libdir)/${PN}/\";:" \
		-e "s:^\$opt_configfile = \"\$opt_libdir:\$opt_configfile = \"${GAMES_SYSCONFDIR}:" \
		daemon/*.pl || die "sed pl failed"
	dogamesbin daemon/*.pl || die "dogamesbin failed"
	insinto "$(games_get_libdir)"/${PN}
	doins daemon/*.{pm,plib}
	insinto "${GAMES_DATADIR}"/${PN}
	doins upgrade/*.sql
	dodoc ChangeLog
	prepgamesdirs
	dodir ${MY_HTDOCSDIR}
	insinto ${MY_HTDOCSDIR}
	sed -i \
			"s:\$hlConfigFile = \"hlstats.conf\";:\$hlConfigFile = \"${GAMES_SYSCONFDIR}/hlstats.conf\";:" \
			web/index.php \
		|| die "sed php failed"
	doins -r web/*
	webapp_src_install
}

pkg_postinst() {
	games_pkg_postinst
	einfo "To setup:"
	einfo " 1. Start up the server and after go to"
	einfo "		http://1.2.3.4/hlstats/install/index.php"
	einfo "      (replace 1.2.3.4 with the IP of the server hlstats is running on)"
	einfo " 2. Edit the cfg files of the game servers you want to track ..."
	einfo "     add these lines to your config file:"
	einfo "      log on"
	einfo "      logaddress 1.2.3.4 27500"
	einfo "      (replace 1.2.3.4 with the IP of the server hlstats is running on)"
	einfo " 3. \`rc-update add hlstats default\`"
	einfo " 4. \`/etc/init.d/hlstats start\`"
	einfo " 5. If you want daily awards, setup a cronjob to run hlstats-awards.pl"
	einfo "     for example, run \`crontab -e\` and add this entry:"
	einfo "      30 00 * * *     ${GAMES_BINDIR}/hlstats-awards.pl"
	einfo " 6. Finally !  Start up the server and after a while goto"
	einfo "      http://1.2.3.4/hlstats/hlstats.php"
	einfo "To update:"
	einfo " 1. \`mysql hlstats < ${GAMES_DATADIR}/${PN}/upgrade_from_VERSION.sql\`"
	einfo "		replace 'VERSION' with previous installed version number,"
	einfo "		make this only if sql file exists for previous version"
	webapp_pkg_postinst
}