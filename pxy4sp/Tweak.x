#import "privateHeaders/WFHeaders.h"
#import <Foundation/Foundation.h>

BOOL isEmptyOfString(NSString *str) {
	return str == nil || [str length] == 0;
}

%hook SpringBoard

// https://github.com/tweaselORG/appstraction/issues/25#issuecomment-1447926111
//refer : https://github.com/tweaselORG/appstraction/issues/25#issuecomment-1462043427
%new
+(void) setProxySettingsForCurrentWifiNetwork:(NSDictionary *) proxySettings {

	NSString *proxyHost = proxySettings[@"host"];
	NSNumber *proxyPort = proxySettings[@"port"];
	NSString *authUsername = proxySettings[@"username"];
	NSString *authPassword = proxySettings[@"password"];


	BOOL authenticated = !isEmptyOfString(authUsername) && !isEmptyOfString(authPassword);

	WFClient *wifiClient = [WFClient sharedInstance];

	NSString *currentEssid = [[[wifiClient interface] currentNetwork] ssid];

	WFSettingsProxy *defaultProxySettings = [WFSettingsProxy defaultProxyConfiguration];
	NSMutableDictionary *newSettingsDict = [[NSMutableDictionary alloc] initWithDictionary:(NSDictionary*)defaultProxySettings];

	// NSLog(@"leotag newSettingsDict : %@", newSettingsDict);

	if (!isEmptyOfString(proxyHost) && proxyPort != nil) {
		newSettingsDict[@"HTTPEnable"] = @(1);
		newSettingsDict[@"HTTPPort"] = proxyPort;
		newSettingsDict[@"HTTPProxy"] = proxyHost;

		newSettingsDict[@"HTTPSEnable"] = @(1);
		newSettingsDict[@"HTTPSPort"] = proxyPort;
		newSettingsDict[@"HTTPSProxy"] = proxyHost;
	}

	if(authenticated) {
		newSettingsDict[@"HTTPProxyAuthenticated"] = @(1);
		newSettingsDict[@"HTTPProxyUsername"] = authUsername;
	}
   
   	WFSettingsProxy *newSettings = [[WFSettingsProxy alloc] initWithDictionary:newSettingsDict];
	if(authenticated) {
		[newSettings setPassword:authPassword];
	}

	NSMutableArray *arrayWithNewSettings = [NSMutableArray new];
	[arrayWithNewSettings addObject:newSettings];

	WFSaveSettingsOperation *saveSettingsOperation = [[WFSaveSettingsOperation alloc] initWithSSID:currentEssid settings:arrayWithNewSettings];

	NSLog(@"leotag arrayWithNewSettings : %@", arrayWithNewSettings);

	[saveSettingsOperation setCurrentNetwork:YES];
	[saveSettingsOperation start];

	NSLog(@"leotag saveSettingsOperation done!");
}

%end


CFDataRef proxySettingsCallback(CFMessagePortRef local, SInt32 msgid, CFDataRef data, void *info) {
	NSLog(@"leotag proxySettingsCallback revice data : %@", data);

	//data to NSJson
	NSError *err;
    NSDictionary *proxySettings = [NSJSONSerialization JSONObjectWithData:(__bridge NSData*)data options:0 error:&err];
	if(err) {
		NSLog(@"leotag json to jsonData failed");
		return NULL;
	}

    if (proxySettings) {
        NSLog(@"leotag receive proxySettings : %@", proxySettings);
        Class SBClass = NSClassFromString(@"SpringBoard");
		[SBClass performSelector:@selector(setProxySettingsForCurrentWifiNetwork:) withObject:proxySettings];
    }
    return NULL;
}

%ctor {
	NSString* bundleId = [[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"];
	if ([bundleId isEqualToString:@"com.apple.springboard"]) {

		CFMessagePortRef localPort = CFMessagePortCreateLocal(NULL, CFSTR("com.springboard.setproxy"), proxySettingsCallback, NULL, NULL);
		if (localPort) {
			NSLog(@"leotag localPort is establised!");
			CFRunLoopSourceRef runLoopSource = CFMessagePortCreateRunLoopSource(NULL, localPort, 0);
			CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, kCFRunLoopCommonModes);
		}else {
			NSLog(@"leotag localPort establise failed!!!");
		}
	}
	NSLog(@"leotag pxy4sp loaded!, bundleId : %@", bundleId);
}