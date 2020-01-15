# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGIT_REPO_URI="https://github.com/hyperic/sigar.git"
KEYWORDS="~x86 ~amd64"

# Using autotools since envoking cmake produces a library with missing symbols
inherit autotools git-r3

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
	eapply_user
}
