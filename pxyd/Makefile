#TARGET := iphone:clang:latest:10.0
# https://github.com/theos/theos/issues/311 
# 编译时，修改为自己设备上的SDK版本
# 我本地使用的是13.7的SDK，$THEOS/sdks/iPhoneOS13.7.sdk
# 支持运行在 iOS 13.0 及更高版本
TARGET = iphone:13.7:13.0

include $(THEOS)/makefiles/common.mk


TOOL_NAME = pxyd

pxyd_FILES = main.m
pxyd_PRIVATE_FRAMEWORKS = WiFiKit
pxyd_CFLAGS = -fobjc-arc
pxyd_CODESIGN_FLAGS = -Sentitlements.plist
pxyd_INSTALL_PATH = /usr/local/bin

include $(THEOS_MAKE_PATH)/tool.mk
