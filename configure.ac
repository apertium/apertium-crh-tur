AC_PREREQ(2.52)

AC_INIT([Apertium Crimean Turkish-Turkish], [0.3.0], [memduhg@gmail.com], [apertium-crh-tur], [http://wiki.apertium.org/wiki/Apertium-crh-tur])
AM_INIT_AUTOMAKE
AC_PROG_AWK

PKG_CHECK_MODULES(APERTIUM, apertium >= 3.7.1)
PKG_CHECK_MODULES(APERTIUM_LEX_TOOLS, apertium-lex-tools >= 0.2.6)
PKG_CHECK_MODULES(HFST, hfst >= 3.15.3)
PKG_CHECK_MODULES(CG3, cg3 >= 1.3.2)

AC_PATH_PROGS(ZCAT, [gzcat zcat], [false])
AS_IF([test x$ZCAT = xfalse], [AC_MSG_ERROR([You don't have zcat nor gzcat installed])])

m4_ifdef([AP_CHECK_LING],[],[AC_MSG_ERROR([AP_CHECK_LING not defined, is apertium.m4 in ACLOCAL_PATH? See: http://wiki.apertium.org/wiki/Installation_troubleshooting])])

AP_CHECK_LING([1], [apertium-crh])
AP_CHECK_LING([2], [apertium-tur])

AP_MKINCLUDE

AC_OUTPUT([Makefile])
