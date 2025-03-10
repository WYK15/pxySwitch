# pxySwitch

支持rootless和rootful越狱，便捷的设置代理

## 编译
项目编译需要私有库，WiFiKit, 在 $THEOS/sdks 目录下存在
需要修改 Makefile 为 iphone:$THSOS/sdks/iPhoneOSVer:TARGET_OS_VER，如
iphone:16.5:13.0

```
make
make package 
```

若要编译rootless版本：
```
make package THEOS_PACKAGE_SCHEME=rootless
```

## 借鉴
[appstraction](https://github.com/tweaselORG/appstraction/issues/25#issuecomment-1447926111)