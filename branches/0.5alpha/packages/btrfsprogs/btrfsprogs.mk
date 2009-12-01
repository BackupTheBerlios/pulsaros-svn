#############################################################
#
# btrfsprogs
#
#############################################################
BTRFSPROGS_VERSION:=0.19
BTRFSPROGS_SOURCE:=btrfs-progs-$(BTRFSPROGS_VERSION).tar.gz
BTRFSPROGS_SITE:=http://www.kernel.org/pub/linux/kernel/people/mason/btrfs
BTRFSPROGS_DIR:=$(BUILD_DIR)/btrfs-progs-$(BTRFSPROGS_VERSION)
BTRFSPROGS_BINARY:=src/btrfsctl
BTRFSPROGS_TARGET_BINARY:=bin/btrfsctl

$(DL_DIR)/$(BTRFSPROGS_SOURCE):
	$(call DOWNLOAD,$(BTRFSPROGS_SITE),$(BTRFSPROGS_SOURCE))

$(BTRFSPROGS_DIR)/.source: $(DL_DIR)/$(BTRFSPROGS_SOURCE)
	$(ZCAT) $(DL_DIR)/$(BTRFSPROGS_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	touch $@

$(BTRFSPROGS_DIR)/.configured: $(BTRFSPROGS_DIR)/.source
	cd $(BTRFSPROGS_DIR); rm -rf config.cache; 
	cp /buildroot/0.5alpha/packages/btrfsprogs/Makefile $(BTRFSPROGS_DIR)
	touch $@

$(BTRFSPROGS_DIR)/$(BTRFSPROGS_BINARY): $(BTRFSPROGS_DIR)/.configured
	$(MAKE) CC="$(TARGET_CC)" CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" -C $(BTRFSPROGS_DIR)

$(TARGET_DIR)/$(BTRFSPROGS_TARGET_BINARY): $(BTRFSPROGS_DIR)/$(BTRFSPROGS_BINARY)
	$(MAKE) PREFIX=$(TARGET_DIR) -C $(BTRFSPROGS_DIR) install
	rm -Rf $(TARGET_DIR)/usr/man
	rm -Rf $(TARGET_DIR)/usr/share/doc
	rm -Rf $(TARGET_DIR)/usr/share/man

btrfsprogs: uclibc $(TARGET_DIR)/$(BTRFSPROGS_TARGET_BINARY)

btrfsprogs-clean:
	$(MAKE) prefix=$(TARGET_DIR) -C $(BTRFSPROGS_DIR) uninstall
	-$(MAKE) -C $(BTRFSPROGS_DIR) clean

btrfsprogs-dirclean:
	rm -rf $(BTRFSPROGS_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(BR2_PACKAGE_BTRFSPROGS),y)
TARGETS+=btrfsprogs
endif
