
Here you can find some ebuilds for Gentoo Linux.
Be carefull for use it!
You must undestand what you do.


USAGE

emerge layman (if you don't have it yet)

1) Run:
    layman --overlays=http://github.com/bor/gentoo-game-overlay/raw/master/overlay.xml -L
    layman --overlays=http://github.com/bor/gentoo-game-overlay/raw/master/overlay.xml -a game-server-stuff

2) Edit /etc/layman/layman.cfg and add this: (second line)

overlays  : http://www.gentoo.org/proj/en/overlays/layman-global.txt
            http://github.com/bor/gentoo-game-overlay/tree/master/overlay.xml?raw=true

Then:
    layman -L
    layman -a game-server-stuff


After this you can emerge everything from this overlay.

