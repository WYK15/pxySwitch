#import <Foundation/Foundation.h>
#import "pxyAppDelegate.h"
#import "pxyUtil.h"

int main(int argc, char *argv[]) {
	@autoreleasepool {
		chineseWifiFixup();
		return UIApplicationMain(argc, argv, nil, NSStringFromClass(pxyAppDelegate.class));
	}
}
