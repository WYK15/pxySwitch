export TARGET = iphone:16.5:13.0

ifeq ($(THEOS_PACKAGE_SCHEME),rootless)
	export ARCHS = arm64 arm64e
else
	export ARCHS = arm64
endif


include $(THEOS)/makefiles/common.mk


SUBPROJECTS += pxyapp
SUBPROJECTS += pxy4sp

# make package THEOS_PACKAGE_SCHEME=rootless  
# for release : FINALPACKAGE=1

include $(THEOS_MAKE_PATH)/aggregate.mk

all::

stage::


package::


# after-install::
# 	install.exec "killall backboardd"
