#############################################################
#
# monit
#
#############################################################
MONIT_VERSION:=5.0.3
MONIT_SOURCE:=monit-$(MONIT_VERSION).tar.gz
MONIT_SITE:=http://www.mmonit.com/monit/dist
MONIT_DIR:=$(BUILD_DIR)/monit-$(MONIT_VERSION)
MONIT_BINARY:=monit
MONIT_TARGET_BINARY:=usr/bin/monit

$(DL_DIR)/$(MONIT_SOURCE):
	$(call DOWNLOAD,$(MONIT_SITE),$(MONIT_SOURCE))

$(MONIT_DIR)/.source: $(DL_DIR)/$(MONIT_SOURCE)
	$(ZCAT) $(DL_DIR)/$(MONIT_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	touch $@

$(MONIT_DIR)/.configured: $(MONIT_DIR)/.source
	(cd $(MONIT_DIR); rm -rf config.cache; \
		CC="$(TARGET_CC)" CFLAGS="$(TARGET_CFLAGS) -I$(MONIT_DIR) -I$(MONIT_DIR)/protocols -I$(MONIT_DIR)/http -I$(MONIT_DIR)/process -I$(MONIT_DIR)/device" LDFLAGS="$(TARGET_LDFLAGS)" ./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=$(TARGET_DIR)/usr \
		--without-ssl \
		$(DISABLE_NLS) \
	)	
	touch $@

$(MONIT_DIR)/$(MONIT_BINARY): $(MONIT_DIR)/.configured
	cp /buildroot/setup/packages/monit/file.c $(MONIT_DIR)
	$(MAKE) CC="$(TARGET_CC)" CFLAGS="$(TARGET_CFLAGS) -I$(MONIT_DIR) -I$(MONIT_DIR)/protocols -I$(MONIT_DIR)/http -I$(MONIT_DIR)/process -I$(MONIT_DIR)/device" LDFLAGS="$(TARGET_LDFLAGS)" -C $(MONIT_DIR)

$(TARGET_DIR)/$(MONIT_TARGET_BINARY): $(MONIT_DIR)/$(MONIT_BINARY)
	$(MAKE) -C $(MONIT_DIR) install
	rm -Rf $(TARGET_DIR)/usr/man
	rm -Rf $(TARGET_DIR)/usr/share/doc
	rm -Rf $(TARGET_DIR)/usr/share/man

monit: uclibc $(TARGET_DIR)/$(MONIT_TARGET_BINARY)

monit-clean:
	$(MAKE) prefix=$(TARGET_DIR) -C $(MONIT_DIR) uninstall
	-$(MAKE) -C $(MONIT_DIR) clean

monit-dirclean:
	rm -rf $(MONIT_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(BR2_PACKAGE_MONIT),y)
TARGETS+=monit
endif
