#TARGET := iphone:clang:latest:10.0
# https://github.com/theos/theos/issues/311 
# 编译时，修改为自己设备上的SDK版本
# 我本地使用的是13.7的SDK，$THEOS/sdks/iPhoneOS13.7.sdk
# 支持运行在 iOS 13.0 及更高版本
TARGET = iphone:13.7:13.0

INSTALL_TARGET_PROCESSES = SpringBoard


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = pxy4sp

pxy4sp_FILES = Tweak.x
pxy4sp_CFLAGS = -fobjc-arc
pxy4sp_PRIVATE_FRAMEWORKS = WiFiKit


include $(THEOS_MAKE_PATH)/tweak.mk
