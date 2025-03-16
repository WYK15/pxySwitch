
INSTALL_TARGET_PROCESSES = pxyapp

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = pxyapp

pxyapp_FILES = $(wildcard *.m)
pxyapp_FRAMEWORKS = UIKit CoreGraphics CoreTelephony
pxyapp_PRIVATE_FRAMEWORKS = WiFiKit
pxyapp_CFLAGS = -fobjc-arc
pxyapp_CODESIGN_FLAGS = -Sentitlements.xml

include $(THEOS_MAKE_PATH)/application.mk
