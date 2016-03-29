# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit rpm user

# Change package name from hypertable-bin to just hypertable
NPN=${PN::10}

DESCRIPTION="A flexible database focused on performance and scalability"
HOMEPAGE="http://hypertable.com"
SRC_URI="http://cdn.hypertable.com/packages/${PV}/${NPN}-${PV}-linux-x86_64.rpm"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="x86"

DEPEND="
	sys-apps/keyutils
	sys-libs/readline
	sys-libs/libselinux
	dev-libs/expat
	dev-libs/thrift
	"
RDEPEND="${DEPEND}"

HT_GROUP=hyper
HT_USER=hyper

S=${WORKDIR}/opt/${NPN}/${PV}

src_install() {
	dodir /opt/${NPN} || die
	dodir /opt/${NPN}/${PV}/lib || die
	dodir /etc/${NPN} || die
	dodir /var/lib/${NPN} || die
	dodir /var/lib/${NPN}/hyperspace || die
	dodir /var/lib/${NPN}/fs || die
	dodir /var/log/${NPN} || die
	dosym /var/log/hypertable /var/lib/${NPN}/log || die

	sed	-i "s:varhome=.*:varhome=/var/lib/${NPN}:" ${S}/bin/ht-fhsize.sh || ewarn
	sed -i "s:etchome=.*:etchome=/etc/${NPN}:" ${S}/bin/ht-fhsize.sh || ewarn

    # Remove nodeunit symlink because is mmissing in original package
    rm ${S}/lib/js/node/node_modules/hypertable/node_modules/thrift/node_modules/.bin/nodeunit
	# Remove packaged Thrift
	rm -rf ${S}/lib/py/thrift || ewarn
	# Remove included Thrift generated code
	rm -rf ${S}/lib/py/gen-py || ewarn
	# Regenerate with system Thrift
	thrift --gen py -o ${S}/lib/py ${S}/include/ThriftBroker/Client.thrift || ewarn
	thrift --gen py -o ${S}/lib/py ${S}/include/ThriftBroker/Hql.thrift || ewarn

	cp -a ${S}/ ${D}/opt/${NPN} || die "install failed"

	dosym /opt/${NPN}/${PV} /opt/${NPN}/current || ewarn "symlink exists? you need to change it manually"
}

pkg_preinst() {
	enewgroup ${HT_GROUP}
	enewuser ${HT_USER} -1 -1 /opt/${NPN} ${HT_GROUP} ||
		ewarn "unable to create user ${HT_USER}"

	fowners	-R ${HT_USER}. /opt/${NPN} || ewarn
	fowners	-R ${HT_USER}. /etc/${NPN} || ewarn
	fowners	-R ${HT_USER}. /var/lib/${NPN} || ewarn
	fowners	-R ${HT_USER}. /var/log/${NPN} || ewarn

	newinitd "${FILESDIR}/${PN}.init" ${NPN}
	newconfd "${FILESDIR}/${PN}.confd" ${NPN}
}

pkg_postinst() {
	elog "You may need to run ht-fhsize.sh:
	sudo -u ${HT_USER} /opt/${NPN}/${PV}/bin/ht-fhsize.sh"
	elog "All configs are placed to /etc/${NPN}, database files are in /var/lib/${NPN}."
	elog "To run the server - edit /etc/${NPN}/${NPN}.cfg and execute
	/etc/init.d/hypertable start"
	elog "For more information see:
	http://hypertable.com/documentation/installation/quick_start_standalone/"
}
