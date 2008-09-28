/*                                                                -*- C -*-
   +----------------------------------------------------------------------+
   | PHP Version 5                                                        |
   +----------------------------------------------------------------------+
   | Copyright (c) 1997-2007 The PHP Group                                |
   +----------------------------------------------------------------------+
   | This source file is subject to version 3.01 of the PHP license,      |
   | that is bundled with this package in the file LICENSE, and is        |
   | available through the world-wide-web at the following url:           |
   | http://www.php.net/license/3_01.txt                                  |
   | If you did not receive a copy of the PHP license and are unable to   |
   | obtain it through the world-wide-web, please send a note to          |
   | license@php.net so we can mail you a copy immediately.               |
   +----------------------------------------------------------------------+
   | Author: Stig Sæther Bakken <ssb@php.net>                             |
   +----------------------------------------------------------------------+
*/

/* $Id: build-defs.h.in,v 1.15.2.2.2.2 2007/07/15 15:10:04 jani Exp $ */

#define CONFIGURE_COMMAND " './configure'  '--prefix=/coreroot/applications/php' '--sysconfdir=/coreroot/applications/php/etc' '--with-layout=GNU' '--with-config-file-path=/coreroot/applications/php/etc' '--with-config-file-scan-dir=/coreroot/applications/php/etc' '--enable-inline-optimization' '--disable-rpath' '--disable-static' '--enable-shared' '--enable-zend-multibyte' '--disable-debug' '--with-zlib=shared' '--enable-bcmath=shared' '--with-bz2=shared' '--enable-calendar=shared' '--enable-exif=shared' '--with-pcre-regex' '--enable-ctype' '--with-gd=shared' '--with-jpeg-dir=shared' '--with-png-dir=shared' '--with-gettext=shared' '--with-kerberos' '--enable-xml' '--disable-xmlreader' '--disable-xmlwriter' '--with-curl=shared' '--enable-mbstring' '--with-mysql=shared,/usr/mysql' '--with-mysqli=shared,/usr/mysql/bin/mysql_config' '--enable-pdo=shared' '--with-pdo-mysql=shared,/usr/mysql' '--without-pgsql' '--without-pdo-pgsql' '--without-sqlite' '--without-pdo-sqlite' '--enable-soap=shared' '--enable-dom=shared' '--with-xsl=shared' '--enable-zip=shared' '--enable-xml' '--enable-simplexml' '--enable-session' '--with-regex=php' '--enable-mbstring=all' '--enable-mbregex' '--enable-sockets=shared' '--enable-posix=shared' '--enable-pcntl=shared' '--enable-json=shared' '--without-iconv' '--with-xmlrpc=shared' '--enable-fastcgi' '--enable-force-cgi-redirect' '--disable-cli'"
#define PHP_ADA_INCLUDE		""
#define PHP_ADA_LFLAGS		""
#define PHP_ADA_LIBS		""
#define PHP_APACHE_INCLUDE	""
#define PHP_APACHE_TARGET	""
#define PHP_FHTTPD_INCLUDE      ""
#define PHP_FHTTPD_LIB          ""
#define PHP_FHTTPD_TARGET       ""
#define PHP_CFLAGS		"$(CFLAGS_CLEAN) -prefer-non-pic -static"
#define PHP_DBASE_LIB		""
#define PHP_BUILD_DEBUG		""
#define PHP_GDBM_INCLUDE	""
#define PHP_IBASE_INCLUDE	""
#define PHP_IBASE_LFLAGS	""
#define PHP_IBASE_LIBS		""
#define PHP_IFX_INCLUDE		""
#define PHP_IFX_LFLAGS		""
#define PHP_IFX_LIBS		""
#define PHP_INSTALL_IT		"@echo "Installing PHP CGI binary: $(INSTALL_ROOT)$(bindir)/"; $(INSTALL) -m 0755 $(SAPI_CGI_PATH) $(INSTALL_ROOT)$(bindir)/$(program_prefix)php-cgi$(program_suffix)$(EXEEXT)"
#define PHP_IODBC_INCLUDE	""
#define PHP_IODBC_LFLAGS	""
#define PHP_IODBC_LIBS		""
#define PHP_MSQL_INCLUDE	""
#define PHP_MSQL_LFLAGS		""
#define PHP_MSQL_LIBS		""
#define PHP_MYSQL_INCLUDE	"-I/usr/mysql/include/mysql"
#define PHP_MYSQL_LIBS		"-L/usr/mysql/lib/mysql -lmysqlclient "
#define PHP_MYSQL_TYPE		"external"
#define PHP_ODBC_INCLUDE	""
#define PHP_ODBC_LFLAGS		""
#define PHP_ODBC_LIBS		""
#define PHP_ODBC_TYPE		""
#define PHP_OCI8_SHARED_LIBADD 	""
#define PHP_OCI8_DIR			""
#define PHP_OCI8_VERSION		""
#define PHP_ORACLE_SHARED_LIBADD 	"@ORACLE_SHARED_LIBADD@"
#define PHP_ORACLE_DIR				"@ORACLE_DIR@"
#define PHP_ORACLE_VERSION			"@ORACLE_VERSION@"
#define PHP_PGSQL_INCLUDE	""
#define PHP_PGSQL_LFLAGS	""
#define PHP_PGSQL_LIBS		""
#define PHP_PROG_SENDMAIL	"/usr/sbin/sendmail"
#define PHP_SOLID_INCLUDE	""
#define PHP_SOLID_LIBS		""
#define PHP_EMPRESS_INCLUDE	""
#define PHP_EMPRESS_LIBS	""
#define PHP_SYBASE_INCLUDE	""
#define PHP_SYBASE_LFLAGS	""
#define PHP_SYBASE_LIBS		""
#define PHP_DBM_TYPE		""
#define PHP_DBM_LIB		""
#define PHP_LDAP_LFLAGS		""
#define PHP_LDAP_INCLUDE	""
#define PHP_LDAP_LIBS		""
#define PHP_BIRDSTEP_INCLUDE     ""
#define PHP_BIRDSTEP_LIBS        ""
#define PEAR_INSTALLDIR         ""
#define PHP_INCLUDE_PATH	".:"
#define PHP_EXTENSION_DIR       "/coreroot/applications/php/lib/php/20060613"
#define PHP_PREFIX              "/coreroot/applications/php"
#define PHP_BINDIR              "/coreroot/applications/php/bin"
#define PHP_LIBDIR              "/coreroot/applications/php/lib/php"
#define PHP_DATADIR             "/coreroot/applications/php/share/php"
#define PHP_SYSCONFDIR          "/coreroot/applications/php/etc"
#define PHP_LOCALSTATEDIR       "/coreroot/applications/php/var"
#define PHP_CONFIG_FILE_PATH    "/coreroot/applications/php/etc"
#define PHP_CONFIG_FILE_SCAN_DIR    "/coreroot/applications/php/etc"
#define PHP_SHLIB_SUFFIX        "so"
