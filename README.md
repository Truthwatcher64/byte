This is an unofficial fork of the original Byte project with some changes that I wanted for personal use. If you are interested in or have questions about the official or flatpak versions please see the this [repository](https://github.com/ellie-commons/byte). Credit goes to the elementary team for basically every part of the code, all my changes have been ascetic. If you want to support the project please donate directly to them through their patreon or paypall links found in their repository. 

## Handy features:

* Light and Dark themes.
* Add up to 100 items under "Recently Added" for songs.
* Sort individual playlists by album, title, play count or recently added.
* Advanced Media Details and Artist Info.
* Group Playlists, Albums, Artists, Songs, etc.
* Search, add and play your favorite online radio stations.

Coming soon
* Play music by folder

## Building and Installation

**There is no prebuild artifact that I am hosting, so you will need to build the project yourself.**

You'll need the following dependencies:
* libgtk-3-dev
* libgee-0.8-dev
* libgstreamer-plugins-base1.0-dev
* libtagc0-dev
* libsqlite3-dev
* libsoup2.4-dev
* libjson-glib-dev
* libgranite-dev (>=0.5)
* meson
* valac >= 0.40.3

For Fedora

    sudo dnf install granite-devel gtk3-devel glib2-devel libgee-devel libxml2-devel vala meson ninja-build pkgconfig gettext json-glib-devel

## Building  

Run `meson build` to configure the build environment. Change to the build directory and run `ninja` to build

    meson build --prefix=/usr
    cd build
    ninja

To install, use `ninja install`, then execute with `com.github.alainm23.byte`

    sudo ninja install
    com.github.alainm23.byte
