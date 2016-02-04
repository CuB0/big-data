# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils java-pkg-2

DESCRIPTION="Yahoo! Cloud Serving Benchmark (YCSB)"
HOMEPAGE="https://github.com/brianfrankcooper/YCSB/wiki"
SRC_URI="https://github.com/brianfrankcooper/YCSB/releases/download/${PV}/${PN/-bin}-${PV}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND=">=virtual/jre-1.7"

S="${WORKDIR}/${PN/-bin}-${PV}"

src_prepare() {
	epatch ${FILESDIR}/${P}.patch
	}

src_install() {
	dodoc *.txt

	for DIR in core *binding
	do
		cd ${S}/${DIR}
		java-pkg_dojar lib/*.jar
	done

	dobin ${S}/bin/*
}
