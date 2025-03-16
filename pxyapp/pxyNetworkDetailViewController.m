#import "pxyNetworkDetailViewController.h"
#import "WFHeaders.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <ifaddrs.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

@interface detailGroup : NSObject

@property(nonatomic, copy) NSString *sectionHeader;
@property(nonatomic, strong) NSArray<NSString *> *items;

@end

@implementation detailGroup
- (instancetype)initWithSectionHeader:(NSString *)sectionHeader items:(NSArray *)items {
    if (self = [super init]) {
        _sectionHeader = sectionHeader;
        _items = items;
    }
    return self;
}
@end

@interface pxyNetworkDetailViewController ()
@property (nonatomic, strong) UITableView *tableView;

/*
[
    detailGroup{
        "sectionHeader": "WiFi",
        "items": [
            @"ssid : ssid1234"
        ]
    },
    detailGroup{
        "sectionHeader": "en0",
        "items": [
            @"ipv4: 192.168.1.134",
            @"ipv6: 20c:29ff:fe14:134f",
        ]
    }
]
*/
@property (nonatomic, strong) NSMutableArray<detailGroup *> *networkDataGroup;
@end

@implementation pxyNetworkDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"网络详情";
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    // 添加刷新按钮
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                target:self
                                                                                action:@selector(refreshButtonTapped:)];
    self.navigationItem.rightBarButtonItem = refreshButton;
    
    // 初始化网络数据数组
    self.networkDataGroup = [NSMutableArray array];
    
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
    [self refreshButtonTapped:nil];
}

- (void)refreshButtonTapped:(UIBarButtonItem *)sender {
    // 清空现有数据
    self.networkDataGroup = [NSMutableArray array];
    
    // 重新获取网络信息
    [self fetchNetworkInfo];
}

- (void)fetchNetworkInfo {
    // 获取WiFi信息
    [self fetchWifiName];
    
    // 获取IP信息
    [self fetchIpInfo];
}

-(void) fetchWifiName {
    WFClient *wifiClient = [WFClient sharedInstance];
	NSString *currentEssid = [[[wifiClient interface] currentNetwork] ssid];

    NSMutableArray<NSString *> *wifiNameInfo = [NSMutableArray array];
    [wifiNameInfo addObject:[NSString stringWithFormat:@"essid : %@", currentEssid]];

    [self addSection:@"WiFi" items:wifiNameInfo];
}

-(void) fetchIpInfo {
    NSMutableDictionary<NSString*, NSMutableArray*> *ipInfo = [NSMutableDictionary dictionary];
    // 获取所有网络接口信息
    struct ifaddrs *allInterfaces;
    
    if (getifaddrs(&allInterfaces) == 0) {
        struct ifaddrs *interface = allInterfaces;
        
        while (interface != NULL) {
            // 只处理IPv4和IPv6地址
            if (interface->ifa_addr->sa_family == AF_INET || interface->ifa_addr->sa_family == AF_INET6) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *ipAddressInfo;
                // 获取IP地址
                char ipAddress[INET6_ADDRSTRLEN];
                
                if (interface->ifa_addr->sa_family == AF_INET) {
                    // IPv4
                    struct sockaddr_in *addr = (struct sockaddr_in *)interface->ifa_addr;
                    inet_ntop(AF_INET, &addr->sin_addr, ipAddress, INET_ADDRSTRLEN);

                    ipAddressInfo = [NSString stringWithFormat:@"ipv4 : %s", ipAddress];

                } else if (interface->ifa_addr->sa_family == AF_INET6) {
                    // IPv6
                    struct sockaddr_in6 *addr = (struct sockaddr_in6 *)interface->ifa_addr;
                    inet_ntop(AF_INET6, &addr->sin6_addr, ipAddress, INET6_ADDRSTRLEN);

                    ipAddressInfo = [NSString stringWithFormat:@"ipv6 : %s", ipAddress];
                }

                if (!ipInfo[name]) {
                    ipInfo[name] = [NSMutableArray array];
                }
                [ipInfo[name] addObject:[NSString stringWithFormat:@"%@", ipAddressInfo]];
            }
            
            interface = interface->ifa_next;
        }
        freeifaddrs(allInterfaces);
    }

    for (NSString *name in ipInfo) {
        [self addSection:name items:ipInfo[name]];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.networkDataGroup.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.networkDataGroup[section].items count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.networkDataGroup[section].sectionHeader;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"NetworkInfoCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSString *item = self.networkDataGroup[indexPath.section].items[indexPath.row];
    cell.textLabel.text = item;
    
    return cell;
}


- (void)addSection:(NSString *)sectionName items:(NSArray<NSString *> *)items {
    if (sectionName && items) {
        detailGroup *group = [[detailGroup alloc] initWithSectionHeader:sectionName items:items];
        [self.networkDataGroup addObject:group];
        [self.tableView reloadData];
    }
}

@end