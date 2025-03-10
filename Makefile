ifeq ($(THEOS_PACKAGE_SCHEME),rootless)
	export TARGET = iphone:clang:latest:14.0
	export ARCHS = arm64 arm64e
else
	export TARGET = iphone:clang:latest:11.0
	export ARCHS = arm64
endif


include $(THEOS)/makefiles/common.mk


SUBPROJECTS += pxyapp
SUBPROJECTS += pxy4sp

# make package THEOS_PACKAGE_SCHEME=rootless


include $(THEOS_MAKE_PATH)/aggregate.mk

all::

stage::


package::


# after-install::
# 	install.exec "killall backboardd"
