#include <stdio.h>
#import <Foundation/Foundation.h>

#import "privateHeaders/WFHeaders.h"



// `host`, `port`, `username`, `password`. `username` and `password` are optional. If both of them are provided, the
// proxy will be configured to use authentication.
void setProxySettingsForCurrentWifiNetwork(NSDictionary * proxySettings) {
    WFClient *wifiClient = [WFClient sharedInstance];
	NSLog(@"leotag wifiClient : %@", wifiClient);

	NSString *currentEssid = [[[wifiClient interface] currentNetwork] ssid];

	NSLog(@"leotag currentEssid : %@", currentEssid);

	WFSettingsProxy *defaultProxySettings = [WFSettingsProxy defaultProxyConfiguration];
	NSMutableDictionary *newSettingsDict = [[NSMutableDictionary alloc] initWithDictionary:(NSDictionary*)defaultProxySettings];

	newSettingsDict[@"HTTPEnable"] = @(1);
	newSettingsDict[@"HTTPPort"] = @(7777);
	newSettingsDict[@"HTTPProxy"] = @"192.168.1.199";

	newSettingsDict[@"HTTPSEnable"] = @(1);
	newSettingsDict[@"HTTPSPort"] = @(7777);
	newSettingsDict[@"HTTPSProxy"] = @"192.168.1.199";
   
   	WFSettingsProxy *newSettings = [[WFSettingsProxy alloc] initWithDictionary:newSettingsDict];

	NSMutableArray *arrayWithNewSettings = [NSMutableArray new];
	[arrayWithNewSettings addObject:newSettings];

	NSLog(@"leotag arrayWithNewSettings : %@", arrayWithNewSettings);

	WFSaveSettingsOperation *saveSettingsOperation = [[WFSaveSettingsOperation alloc] initWithSSID:currentEssid settings:arrayWithNewSettings];
	NSLog(@"leotag saveSettingsOperation : %@", saveSettingsOperation);

	[saveSettingsOperation setCurrentNetwork:YES];
	[saveSettingsOperation start];

	NSLog(@"leotag saveSettingsOperation done!");

}

void testSBAdd() {
	NSDictionary *proxySettings = @{
        @"host": @"192.168.123.123",
        @"port": @(7777),
		// @"username": @"leotag",
		// @"password": @"123456"
    };

    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:proxySettings requiringSecureCoding:NO error:nil];

    CFMessagePortRef port = CFMessagePortCreateRemote(NULL, CFSTR("com.springboard.setproxy"));
    if (port) {
        CFMessagePortSendRequest(port, 0, (__bridge CFDataRef)data, 1, 1, NULL, NULL);
        CFRelease(port);
    }
}

int main(int argc, char *argv[], char *envp[]) {
	@autoreleasepool {

		setuid(0);
		setgid(0);

		int uid = getuid();
		int gid = getuid();

		printf("uid: %d\n", uid);
		printf("gid: %d\n", gid);

		//setProxySettingsForCurrentWifiNetwork(nil);
		testSBAdd();

		printf("Hello world!\n");
		return 0;
	}
}
