# translations -> locale packages

DEPENDS += "qttools-native"

# default location
QT_TRANSLATION_FILES ??= "${datadir}/*/translations/*.qm ${datadir}/*/translations/*/*.qm ${datadir}/*/translations/*/*/*.qm"

FILES:${PN}-locale = "${datadir}/*/translations"

python qt_do_split_locales() {
    import glob
    import collections

    if (d.getVar('PACKAGE_NO_LOCALE') == '1'):
        bb.debug(1, "package requested not splitting locales")
        return

    packages = collections.deque((d.getVar('PACKAGES') or "").split())

    datadir = d.getVar('datadir')
    if not datadir:
        bb.note("datadir not defined")
        return

    dvar = d.getVar('PKGD')
    pn = d.getVar('LOCALEBASEPN')

    if pn + '-locale' in packages:
        packages.remove(pn + '-locale')

    # extract locales from *.qm files into list in locales
    locales = []
    for transvar in d.getVar('QT_TRANSLATION_FILES').split():
        translocation = '%s%s' % (dvar, transvar)
        transfiles = glob.glob(translocation)
        for l in sorted(transfiles):
            lib, locale = os.path.basename(l.replace('.qm', '')).split("_",1)
            if not locale in locales:
                locales.append(locale)

    if not locales:
        bb.warn("No locale files for recipe %s. Remove qt5-translation from inherit?" % d.getVar('PN'))
        return

    summary = d.getVar('SUMMARY') or pn
    description = d.getVar('DESCRIPTION') or ""
    locale_section = d.getVar('LOCALE_SECTION')
    mlprefix = d.getVar('MLPREFIX') or ""
    for l in sorted(locales):
        ln = legitimize_package_name(l)
        pkg = pn + '-locale-' + ln
        packages.appendleft(pkg)
        files = ''
        for transvar in d.getVar('QT_TRANSLATION_FILES').split():
            files = '%s %s' % (files, transvar.replace('*.qm', '*_%s.qm' % l))
        d.setVar('FILES:' + pkg, files )
        d.setVar('RRECOMMENDS:' + pkg, '%svirtual-locale-%s' % (mlprefix, ln))
        d.setVar('RPROVIDES:' + pkg, '%s-locale %s%s-translation' % (pn, mlprefix, ln))
        d.setVar('SUMMARY:' + pkg, '%s - %s translations' % (summary, l))
        d.setVar('DESCRIPTION:' + pkg, '%s  This package contains language translation files for the %s locale.' % (description, l))
        if locale_section:
            d.setVar('SECTION:' + pkg, locale_section)

    d.setVar('PACKAGES', ' '.join(list(packages)))
}

PACKAGESPLITFUNCS:prepend = "qt_do_split_locales "

