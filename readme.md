# pxySwitch

Supports both rootless and rootful jailbreak, providing convenient proxy settings

## Usage
1. Enter the port number you want to search and click "Search"
2. Select the found IP that can be connected
3. If authentication is required, long press to enable authentication
4. Click "Set Proxy" to set up the proxy. After testing, sometimes it may need to be clicked twice to take effect
5. Click "Clear Proxy" to cancel the proxy

## Compilation
Project compilation requires private library, WiFiKit, located in the $THEOS/sdks directory
Need to modify Makefile to iphone:$THSOS/sdks/iPhoneOS_Ver:TARGET_OS_VER, such as
iphone:16.5:13.0

```
make
make package FINALPACKAGE=1
```

To compile the rootless version:
```
make package THEOS_PACKAGE_SCHEME=rootless FINALPACKAGE=1
```

## References
[appstraction](https://github.com/tweaselORG/appstraction/issues/25#issuecomment-1447926111)