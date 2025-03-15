export TARGET = iphone:16.5:14.0

include $(THEOS)/makefiles/common.mk


SUBPROJECTS += pxyapp
SUBPROJECTS += pxy4sp

# make package THEOS_PACKAGE_SCHEME=rootless  
# for release : FINALPACKAGE=1

include $(THEOS_MAKE_PATH)/aggregate.mk

all::

stage::


package::
	find . -name ".DS_Store" -delete


after-install::
#	install.exec "sbreload"
