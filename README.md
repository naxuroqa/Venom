![Venom](.github/banner/venom.svg)
=====

[![Build Status](https://travis-ci.org/naxuroqa/Venom.png?branch=develop)](https://travis-ci.org/naxuroqa/Venom) [![tip for next commit](http://tip4commit.com/projects/634.svg)](http://tip4commit.com/projects/634) [![codecov](https://codecov.io/gh/naxuroqa/Venom/branch/develop/graph/badge.svg)](https://codecov.io/gh/naxuroqa/Venom)

###### a modern [Tox](https://github.com/TokTok/c-toxcore) client for the GNU/Linux desktop

Features
--------

* Secure, private messaging
* Read receipts
* Contact aliases
* Customizable avatars
* Emojis 👍
* File transfers
* Screenshot sharing
* Group chats
* Socks5 Proxy support
* Spell checking
* Sound notifications
* [Faux offline messaging](https://wiki.tox.chat/users/offline_messaging)

Roadmap
-------

See [projects](https://github.com/naxuroqa/Venom/projects) for planned features.

Translations
------------

Translations are done via the [venom project on poeditor](https://poeditor.com/join/project/5weMhrvGjN).
Don't create pull requests for translations here. Updated translations from poeditor will be merged in this repository on every release.

Dependencies
------------

* `gtk+-3.0 >= 3.22`
* `glib-2.0 >= 2.56`
* `json-glib-1.0`
* `libcanberra >= 0.30`
* `libgee >= 0.20`
* `libsoup-2.4`
* `gspell >= 1.8`
* `sqlite3`
* `toxcore >= 0.2`

Build-Dependencies
------------------
* `meson >= 0.46`
* `vala >= 0.40`

Compiling
---------
```bash
meson ./build && cd build
ninja
ninja install
```

Testing
-------
```bash
ninja test
```

Contact
-------

Join the `#tox` IRC channel on [freenode](https://freenode.net/)
