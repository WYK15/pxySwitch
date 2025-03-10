#import "pxyUtil.h"

void resetProxy(NSString *host, NSNumber *port, NSString *username, NSString *password) {
    NSMutableDictionary *proxySettings = [[NSMutableDictionary alloc] init];
	proxySettings[@"host"] = safeStr(host);
	if (port != nil) {
		proxySettings[@"port"] = port;
	}
	if (username && username.length > 0) {
		proxySettings[@"username"] = safeStr(username);
	}
	if (password && password.length > 0) {
		proxySettings[@"password"] = safeStr(password);
	}

    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:proxySettings requiringSecureCoding:NO error:nil];

	// ! 注意，不添加unsandbox签名，会导致CFMessagePortCreateRemote失败
    CFMessagePortRef setProxyPort = CFMessagePortCreateRemote(NULL, CFSTR("com.springboard.setproxy"));
    if (setProxyPort) {
        CFMessagePortSendRequest(setProxyPort, 0, (__bridge CFDataRef)data, 1, 1, NULL, NULL);
        CFRelease(setProxyPort);
		NSLog(@"leotag post proxy settings!");
    }else {
		NSLog(@"leotag post proxy settings failed");
	}
}

void clearProxy() {
	resetProxy(nil, nil, nil, nil);
}