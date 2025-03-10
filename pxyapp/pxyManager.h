#import <Foundation/Foundation.h>

#ifndef pxyManager_h
#define pxyManager_h

// host: 代理服务器地址
// port: 代理服务器端口
// username: 代理服务器用户名, 非必须
// password: 代理服务器密码, 非必须
void resetProxy(NSString *host, NSNumber *port, NSString *username, NSString *password);

void clearProxy();

#endif /* pxyManager_h */