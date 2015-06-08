# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit git-r3 cmake-utils user

DESCRIPTION="A flexible database focused on performance and scalability"
HOMEPAGE="http://hypertable.com"
EGIT_BRANCH="python3"
EGIT_REPO_URI="https://github.com/ljrepos/hypertable.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="
	app-admin/cronolog
	dev-libs/boost:=[python]
	dev-libs/expat
	dev-libs/libedit
	dev-libs/re2
	dev-libs/sigar
	=dev-libs/thrift-9999:=[event]
	net-analyzer/rrdtool
	net-libs/libssh
	sys-apps/keyutils
	sys-libs/libselinux
	"
RDEPEND="${DEPEND}"

HT_GROUP=hyper
HT_USER=hyper

src_configure() {
	CMAKE_BUILD_TYPE=Release
	local mycmakeargs=(
		# Due to https://bugs.gentoo.org/show_bug.cgi?id=400969 &
		# http://public.kitware.com/Bug/view.php?id=12955-DBOOST_PYTHON_LIB=/usr/lib64/libboost_python-3.4.so
		# Not sure why CMake isn\'t detecting this -DBDB_INCLUDE_DIR=/usr/include/db6.0
		# Not on by default	-DBUILD_SHARED_LIBS=on
		# Gentoo overrides this to /usr if not set -DCMAKE_INSTALL_PREFIX=/opt/${PN}/${PV}
	)
	cmake-utils_src_configure
}

src_install() {
	dodir /opt/${PN} || die
	dodir /opt/${PN}/${PV}/lib || die
	dodir /etc/${PN} || die
	dodir /var/db/${PN} || die

	# Maybe ht-fhsize.sh should be done by the ebuild?
	sed	-i "s:varhome=.*:varhome=/var/db/${PN}:" ${S}/bin/ht-fhsize.sh || ewarn
	sed -i "s:etchome=.*:etchome=/etc/${PN}:" ${S}/bin/ht-fhsize.sh || ewarn

	cmake-utils_src_install
	dosym /opt/${PN}/${PV} /opt/${PN}/current || ewarn "symlink exists? you need to change it manually"
}

pkg_preinst() {
	enewgroup ${HT_GROUP}
	enewuser ${HT_USER} -1 -1 /opt/${PN} ${HT_GROUP} ||
		ewarn "unable to create user ${HT_USER}"

	fowners	-R ${HT_USER}. /opt/${PN} || ewarn
	fowners	-R ${HT_USER}. /etc/${PN} || ewarn
	fowners	-R ${HT_USER}. /var/db/${PN} || ewarn
}

pkg_postinst() {
	elog "You may need to run ht-fhsize.sh:
	sudo -u ${HT_USER} /opt/${PN}/${PV}/bin/ht-fhsize.sh"
	elog "All configs are placed to /etc/${PN}, database files are in /var/db/${PN}."
	elog "To run the server - edit /etc/${PN}/${PN}.cfg and execute
	sudo -u ${HT_USER} /opt/${PN}/current/bin/ht-start-all-servers.sh"
	elog "For more information see:
	http://hypertable.com/documentation/installation/quick_start_standalone/"
}
