# yeah I know yocto does not want us to change this
PACKAGECONFIG:append = "${@bb.utils.contains('BBFILE_COLLECTIONS', 'clang-layer', ' clang', '', d)}"
