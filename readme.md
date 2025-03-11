# pxySwitch

支持rootless和rootful越狱，便捷的设置代理

## 使用方式
1. 输入想要查找的端口号，点击"查找"
2. 选择查找到的可以连接的ip
3. 若需要认证，则长按开启认证
4. 点击"设置代理"，即可设置代理，经过测试，有时可能需要点击两次生效
5. 点击"清楚代理"，即可取消代理

## 编译
项目编译需要私有库，WiFiKit, 在 $THEOS/sdks 目录下存在
需要修改 Makefile 为 iphone:$THSOS/sdks/iPhoneOS_Ver:TARGET_OS_VER，如
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