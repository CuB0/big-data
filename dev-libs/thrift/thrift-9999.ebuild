# Distributed under the terms of the GNU General Public License v2

EAPI=5

if [[ ${PV} = 9999* ]]; then
	inherit git-r3
	EGIT_BRANCH="python3"
	EGIT_MIN_CLONE_TYPE="single"
	EGIT_REPO_URI="https://github.com/ljrepos/thrift.git"
else
	SRC_URI="mirror://apache/${PN}/${PV}/${P}.tar.gz"
	KEYWORDS="~x86 ~amd64"
fi

PYTHON_COMPAT=( python{3_1,3_2,3_3,3_4,3_5} )
GENTOO_DEPEND_ON_PERL="no"

inherit eutils autotools distutils-r1 perl-module

DESCRIPTION="Lightweight, language-independent software stack with associated code generation mechanism for RPC"
HOMEPAGE="http://thrift.apache.org"

LICENSE="Apache-2.0"
SLOT="0"
IUSE="+cpp +glib event perl php +python qt4 qt5 ruby static-libs test +zlib"

RDEPEND="cpp? ( dev-libs/boost:=[static-libs] )
	event? ( dev-libs/libevent )
	glib? ( dev-libs/glib:2 )
	perl? ( dev-lang/perl:= dev-perl/Bit-Vector )
	php? ( dev-lang/php )
	python? ( dev-python/six[${PYTHON_USEDEP}] )
	qt4? ( dev-qt/qtcore:4 )
	qt5? ( dev-qt/qtcore:5 )
	ruby? ( dev-lang/ruby )
	zlib? ( sys-libs/zlib )"

REQUIRED_USE="^^ ( qt4 qt5 )"

DEPEND="${RDEPEND}
	python? ( dev-python/setuptools[${PYTHON_USEDEP}] )
	virtual/pkgconfig"

src_unpack() {
	git-r3_fetch
	git-r3_checkout
}

src_prepare() {
	# bootstrap source
	cd ${S} && ./bootstrap.sh

	AT_NO_RECURSIVE=1 eautoreconf

	if use python ; then
		cd "${S}"/lib/py
		distutils-r1_src_prepare
	fi
}

src_configure() {
	econf \
		--without-{qt4,qt5}  \
		--without-{csharp,java,erlang,php,php_extension,ruby,haskell,go,d,nodejs}
		$(use_enable static-libs static) \
		$(use_enable test) \
		$(use_with cpp) \
		$(use_with cpp boost) \
		$(use_with event libevent) \
		$(use_with glib c_glib) \
		$(use_with php) \
		$(use_with qt4) \
		$(use_with qt5) \
		$(use_with ruby) \
		$(use_with zlib) \
		--without-{python,perl}

	if use perl ; then
		cd "${S}"/lib/perl
		perl-module_src_configure
	fi
}

src_compile() {
	default

	if use perl ; then
		cd "${S}"/lib/perl
		perl-module_src_compile
	fi

	if use python ; then
		cd "${S}"/lib/py
		distutils-r1_src_compile
	fi
}

src_install() {
	default
	prune_libtool_files

	if use perl ; then
		cd "${S}"/lib/perl
	perl-module_src_install
	fi

	if use python ; then
	cd "${S}"/lib/py
	distutils-r1_src_install
	fi
}
