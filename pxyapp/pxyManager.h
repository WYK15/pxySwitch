#import <Foundation/Foundation.h>

#ifndef pxyManager_h
#define pxyManager_h

// host: Proxy server address
// port: Proxy server port
// username: Proxy server username, optional
// password: Proxy server password, optional
BOOL resetProxy(NSString *host, NSNumber *port, NSString *username, NSString *password);

BOOL clearProxy();

#endif /* pxyManager_h */