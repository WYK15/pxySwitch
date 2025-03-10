#import "pxyProxyServiceScanner.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <ifaddrs.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

@implementation ProxyServiceScanner

+ (void)scanProxyServicesOnPort:(NSInteger)port completion:(void (^)(NSArray<NSString *> *services))completion {
    dispatch_queue_t scanQue = dispatch_queue_create("scan", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t scanGroup = dispatch_group_create();
    
    NSMutableArray *services = [NSMutableArray array];
    NSString *ipaddr = [self getLocalIPAddressForCurrentWiFi];
    NSMutableArray *ipCom = [NSMutableArray arrayWithArray:[ipaddr componentsSeparatedByString:@"."]];
    [ipCom removeLastObject];
    NSString *baseIP = [ipCom componentsJoinedByString:@"."];

    for (int i = 1; i <= 255; i++) {
        NSString *ip = [NSString stringWithFormat:@"%@.%d", baseIP, i];
        
        dispatch_group_async(scanGroup, scanQue, ^{
            BOOL canReach = [self checkProxyAtIP:ip port:port];
            if (canReach) {
                @synchronized (services) {  // 线程安全
                    [services addObject:[ip stringByAppendingFormat:@":%ld", port]];
                }
            }
        });
    }

    // 扫描完成后回调
    dispatch_group_notify(scanGroup, dispatch_get_main_queue(), ^{
        completion(services);
    });
}

+ (NSString*) getLocalIPAddressForCurrentWiFi {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if (temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    return address;
}


+ (BOOL)checkProxyAtIP:(NSString *)ip port:(int)port {
    int sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock < 0) {
        return NO;
    }

    // 设置 socket 为非阻塞模式
    fcntl(sock, F_SETFL, O_NONBLOCK);

    struct sockaddr_in addr;
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port);
    inet_pton(AF_INET, [ip UTF8String], &addr.sin_addr);

    connect(sock, (struct sockaddr *)&addr, sizeof(addr));

    // 用 select 等待连接结果
    fd_set writeSet;
    FD_ZERO(&writeSet);
    FD_SET(sock, &writeSet);

    struct timeval timeout;
    timeout.tv_sec = 0;
    timeout.tv_usec = 200 * 1000; // 200 ms

    int ready = select(sock + 1, NULL, &writeSet, NULL, &timeout);

    int error = -1;
    if (ready > 0) {
        socklen_t len = sizeof(error);
        getsockopt(sock, SOL_SOCKET, SO_ERROR, &error, &len);
        
        if (error == 0) {
            NSLog(@"🔓 Found open port at %@:%d", ip, port);
        }
    }

    close(sock);
    return error == 0;
}

@end
