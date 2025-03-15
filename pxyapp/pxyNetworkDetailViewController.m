#import "pxyNetworkDetailViewController.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <ifaddrs.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

@interface pxyNetworkDetailViewController ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *networkInterfaces;
@property (nonatomic, strong) NSMutableDictionary *networkInfo;
@end

@implementation pxyNetworkDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"网络详情";
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    // 初始化网络信息字典
    self.networkInfo = [NSMutableDictionary dictionary];
    
    // 创建表格视图
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tableView];
    
    // 设置表格视图约束
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    
    // 获取网络信息
    [self fetchNetworkInfo];
}

- (void)fetchNetworkInfo {
    // 获取所有网络接口信息
    NSMutableArray *interfaces = [NSMutableArray array];
    struct ifaddrs *allInterfaces;
    
    if (getifaddrs(&allInterfaces) == 0) {
        struct ifaddrs *interface = allInterfaces;
        
        while (interface != NULL) {
            // 只处理IPv4和IPv6地址
            if (interface->ifa_addr->sa_family == AF_INET || interface->ifa_addr->sa_family == AF_INET6) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                
                if (![interfaces containsObject:name]) {
                    [interfaces addObject:name];
                }
                
                // 获取IP地址
                char ipAddress[INET6_ADDRSTRLEN];
                
                if (interface->ifa_addr->sa_family == AF_INET) {
                    // IPv4
                    struct sockaddr_in *addr = (struct sockaddr_in *)interface->ifa_addr;
                    inet_ntop(AF_INET, &addr->sin_addr, ipAddress, INET_ADDRSTRLEN);
                    
                    NSString *key = [NSString stringWithFormat:@"%@_ipv4", name];
                    self.networkInfo[key] = [NSString stringWithUTF8String:ipAddress];
                } else if (interface->ifa_addr->sa_family == AF_INET6) {
                    // IPv6
                    struct sockaddr_in6 *addr = (struct sockaddr_in6 *)interface->ifa_addr;
                    inet_ntop(AF_INET6, &addr->sin6_addr, ipAddress, INET6_ADDRSTRLEN);
                    
                    NSString *key = [NSString stringWithFormat:@"%@_ipv6", name];
                    self.networkInfo[key] = [NSString stringWithUTF8String:ipAddress];
                }
            }
            
            interface = interface->ifa_next;
        }
        
        freeifaddrs(allInterfaces);
    }
    
    // 保存接口列表
    self.networkInterfaces = [interfaces copy];
    
    // 刷新表格
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.networkInterfaces.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *interface = self.networkInterfaces[section];
    NSInteger count = 0;
    
    // 检查是否有IPv4地址
    NSString *ipv4Key = [NSString stringWithFormat:@"%@_ipv4", interface];
    if (self.networkInfo[ipv4Key]) {
        count++;
    }
    
    // 检查是否有IPv6地址
    NSString *ipv6Key = [NSString stringWithFormat:@"%@_ipv6", interface];
    if (self.networkInfo[ipv6Key]) {
        count++;
    }
    
    return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.networkInterfaces[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"NetworkInfoCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSString *interface = self.networkInterfaces[indexPath.section];
    NSString *ipv4Key = [NSString stringWithFormat:@"%@_ipv4", interface];
    NSString *ipv6Key = [NSString stringWithFormat:@"%@_ipv6", interface];
    
    if (self.networkInfo[ipv4Key] && indexPath.row == 0) {
        cell.textLabel.text = @"IPv4";
        cell.detailTextLabel.text = self.networkInfo[ipv4Key];
    } else {
        cell.textLabel.text = @"IPv6";
        cell.detailTextLabel.text = self.networkInfo[ipv6Key];
    }
    
    return cell;
}

@end