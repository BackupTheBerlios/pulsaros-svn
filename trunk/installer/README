
1.0 Introduction

With the advent of Solaris 10 Update 1 and its migration to the grub(5)
bootloader, it becomes quite feasible and straightforward to consider creating
small footprint "embedded" versions of Solaris which boot directly into RAM.
This project is based upon work done by Shudong Zhou to create a minimized
Solaris for embedded use.  The doc/ directory contains some of the original
documentation and scripts used to build such an environment.

It is expected that entities may want to provide further functionality and 
customizations to this environment. In order to assist in this endeavor,
the original work has been enhanced to utilize the Java-based
ant(1) build tool. For a further description on how a miniroot image
is created, see the section on "Understanding the ant(1) build process".


2.0 Requirements

In order to build a version of the miniroot within this environment, there are
a few requirements that must be met:

   2.1. Solaris 10 x86 Update 2 or later needed as the host build platform.

   2.2. Access to the Solaris version of ant(1), typically installed in
        /usr/sfw/bin/ant.

   2.3. Solaris 10 x86 Update 2 or newer Installation DVD ISO image.  For the
        default build, it is assumed that the Solaris Installation DVD ISO is
        mounted on the '/iso' mount point.  If you wish to wish to change that
        mount point, you'll need to modify the build.xml file.

   2.4. Root access.  ****WARNING WARNING WARNING**** There is tremendous
        potential to inflict serious damage to your system, as in effect this
        build environment is creating a whole new instance of Solaris.  Within
        this environment all installation/modifications are performed inside a
        'miniroot/' subdirectory, but as customizations are made it is
        extremely easy to overlook the miniroot subdirectory and modify
        the real OS system files.

        One potential solution to this problem would be to work inside a Zone,
        thus limiting potential damage to that Zone and not the overall system.
        Unfortunately, installation of certain Solaris packages required for
        this image is not permitted inside a Zone.

        Maybe something could be done with chroot(1M) here?

  
3.0 Pertinent files/directories

README           - This file
baseline/        - Directory containing baseline list of packages and
                   script to install into miniroot
boot/            - Directory containing grub(5) bootloader and ultimate
                   location for the compressed miniroot image
build.xml        - Used by ant(1) to create the customized miniroot image
doc/             - Some info describing, among others, How to create a
                   small footprint Solaris, Grub on a USB Stick and
                   minimal tftp network booting.
include/         - Directory containing shell utility functions shared
                   by scripts in this subsystem
miniroot/        - Directory where the miniroot image gets created
misc/            - Diectory containing scripts to further customize the
                   miniroot (e.g. fiximage, trim)
platform/        - Directory where platform specific tasks (e.g. add
                   drivers) should be contained
smf/             - Directory containing custom service manifests and scripts
                   needed for the miniroot's Service Management Facility (SMF)
tftpboot.sample/ - Sample directory demonstrating how Solaris could be
                   configured as a DHCP server where an x86 client could
                   PXE boot the custom miniroot.


4.0 Understanding the ant(1) build process

Assuming requirements have been met, the miniroot image can be created
by issuing:

   # ant makeimage

from the base directory containing the 'build.xml' file.  The 'makeimage'
calls a series of sub targets.  They are described below:

   4.1 delete-miniroot
       Cleans (i.e. removes) the 'miniroot/' directory.  This directory will
       utimately hold the custom miniroot, and will be created by the
       subsequent 'addpkgs' target.

   4.2 addpkgs
       This target runs the 'addpkgs.sh' script found in the 'baseline/'
       directory.  It reads a list of packages from the 'PACKAGES' file
       found in that directory, and installs them into the 'miniroot/'
       directory.  This target first checks to see that a Solaris
       installation image is mounted on the '/iso' mount point.  If a
       different mount point is required, the 'build.xml' file,
       specifically the ${solaris-media-root} variable, will need to be
       modified.

   4.3 add-platform-specific
       Modifications needed to support specific hardware platforms has been
       isolated in the 'platform/' directory.  For this sample implementation,
       the iGoLogic i84810 motherboard uses the rtls network driver which is
       not initially installed in the miniroot. The 'addrtls.sh' script adds
       the SUNWrtls package to the miniroot.

   4.4 setupsmf
       Modifications to the Solaris Service Management Facility (SMF) must
       be made to support this environment.  Custom manifests and scripts
       should be placed in the 'smf/' directory and the 'setupsmf.sh'
       script should be modified accordingly. 

   4.5 setupnet
       Miscellaneous customizations are placed in the 'misc/' directory.
       the setupnet target configures the network interface via the
       'setupnet.sh' script.  For this implementation, a static IP
       address is assigned.  Any changes here (e.g. DHCP, DNS ...) must
       be reflected in the 'setupnet.sh' script.

   4.6 fiximage
       Also placed in the 'misc/' directory, the fiximage target calls the
       'fiximage.sh' script, which among others, sets the nodename,
       modifies the vfstab, and performs other kludgery.

   4.7 trim
       Within the 'misc/' directory, the 'trim.sh' script eliminates
       unnecessary components from the miniroot.  For example, 64-bit support
       is currently not available for the miniroot, therefore all
       64-bit binaries and references should be removed.  In addition,
       the beginnings of a more aggressive trimming script are present.
       Use at your own risk.

   4.8 make-boot-archive
       Also within the 'misc/' directory, the 'bootarchive.sh' script
       will compress the miniroot into a format suitable for grub(5) booting.
       The compressed file will be placed in the 'boot/' directory.
