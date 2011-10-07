#!/sbin/runscript
# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

depend() {
    after hlds
    need mysql
}

start() {
    ebegin "Starting hlstats"
    start-stop-daemon --start \
        --exec /usr/bin/hlstats -b -n hlstats \
        -m --pidfile /var/run/hlstats.pid
    eend $?
}

stop() {
	ebegin "Stopping hlstats"
    start-stop-daemon --stop \
        --pidfile /var/run/hlstats.pid
    # need fix: clear child hlstats.pl
    killall hlstats.pl > /dev/null
    eend $?
}
