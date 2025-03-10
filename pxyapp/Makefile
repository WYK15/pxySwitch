
INSTALL_TARGET_PROCESSES = pxyapp

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = pxyapp

pxyapp_FILES = main.m pxyAppDelegate.m pxyRootViewController.m pxyProxyServiceScanner.m pxyManager.m pxyUtil.m
pxyapp_FRAMEWORKS = UIKit CoreGraphics CoreTelephony
pxyapp_CFLAGS = -fobjc-arc
pxyapp_CODESIGN_FLAGS = -Sentitlements.xml

include $(THEOS_MAKE_PATH)/application.mk
