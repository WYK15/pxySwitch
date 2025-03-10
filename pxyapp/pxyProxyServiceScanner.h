#import <Foundation/Foundation.h>

@interface ProxyServiceScanner : NSObject

+ (void)scanProxyServicesOnPort:(NSInteger)port completion:(void (^)(NSArray<NSString *> *services))completion;

@end