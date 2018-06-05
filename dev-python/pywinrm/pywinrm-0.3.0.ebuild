# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python{2_7,3_4,3_5,3_6} )

inherit distutils-r1

DESCRIPTION="Python library for Windows Remote Management (WinRM)"
HOMEPAGE="https://github.com/diyan/pywinrm"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86 "
IUSE="examples"

RDEPEND="
	dev-python/requests-kerberos[${PYTHON_USEDEP}]
	dev-python/requests-credssp[${PYTHON_USEDEP}]
	dev-python/six[${PYTHON_USEDEP}]
	dev-python/requests-ntlm[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/xmltodict[${PYTHON_USEDEP}]"

DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"

# Testsuite is still not convincing in its completeness
RESTRICT="test"

src_prepare() {
	distutils-r1_src_prepare
}

# https://code.google.com/p/python-twitter/issues/detail?id=259&thanks=259&ts=1400334214
python_test() {
	esetup.py test
}
