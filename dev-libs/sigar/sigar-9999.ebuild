# Distributed under the terms of the GNU General Public License v2

EAPI=5

if [[ ${PV} = 9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/hyperic/sigar.git"
else
	SRC_URI="mirror://sourceforge/project/${PN}/${PV}/hyperic-${P}-src.tar.gz =>
			 ${P}.tar.gz"
	KEYWORDS="~x86 ~amd64"
fi

# Using autotools since envoking cmake produces a library with missing symbols
inherit autotools

DESCRIPTION="System Information Gatherer And Reporter"
HOMEPAGE="http://sigar.hyperic.com"

LICENSE="Apache-2.0"
SLOT="0"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}"

src_prepare() {
	cd ${S} && ./autogen.sh
	eautoreconf
}
