#############################################################
#
# syslinux
#
#############################################################
SYLINUX_VERSION:=3.83
SYLINUX_SOURCE:=syslinux-$(SYLINUX_VERSION).tar.gz
SYLINUX_SITE:=http://www.kernel.org/pub/linux/utils/boot/syslinux
SYLINUX_DIR:=$(BUILD_DIR)/syslinux-$(SYLINUX_VERSION)
SYLINUX_BINARY:=linux/syslinux
SYLINUX_TARGET_BINARY:=usr/bin/syslinux

$(DL_DIR)/$(SYLINUX_SOURCE):
	$(call DOWNLOAD,$(SYLINUX_SITE),$(SYLINUX_SOURCE))

$(SYLINUX_DIR)/.source: $(DL_DIR)/$(SYLINUX_SOURCE)
	$(ZCAT) $(DL_DIR)/$(SYLINUX_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	touch $@

$(SYLINUX_DIR)/.configured: $(SYLINUX_DIR)/.source
	cd $(SYLINUX_DIR); rm -rf config.cache; 
	cp /buildroot/0.5alpha/packages/syslinux/Makefile $(SYLINUX_DIR)
	touch $@

$(SYLINUX_DIR)/$(SYLINUX_BINARY): $(SYLINUX_DIR)/.configured
	$(MAKE) CC="$(TARGET_CC)" -C $(SYLINUX_DIR)

$(TARGET_DIR)/$(SYLINUX_TARGET_BINARY): $(SYLINUX_DIR)/$(SYLINUX_BINARY)
	$(MAKE) INSTALLROOT=$(TARGET_DIR) -C $(SYLINUX_DIR) install
	rm -Rf $(TARGET_DIR)/usr/man
	rm -Rf $(TARGET_DIR)/usr/share/doc
	rm -Rf $(TARGET_DIR)/usr/share/man

syslinux: uclibc $(TARGET_DIR)/$(SYLINUX_TARGET_BINARY)

syslinux-clean:
	$(MAKE) prefix=$(TARGET_DIR) -C $(SYLINUX_DIR) uninstall
	-$(MAKE) -C $(SYLINUX_DIR) clean

syslinux-dirclean:
	rm -rf $(SYLINUX_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(BR2_PACKAGE_SYSLINUX),y)
TARGETS+=syslinux
endif
