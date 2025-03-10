#import "pxyRootViewController.h"
#import "pxyProxyServiceScanner.h"
#import "pxyManager.h"


@interface pxyRootViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UIStackView *mainStackView;
@property (nonatomic, strong) UIButton *connectionButton;
@property (nonatomic, strong) UIButton *disconnectButton;
@property (nonatomic, strong) UITextField *portTextField;
@property (nonatomic, strong) UITableView *tableView;  // 添加tableView属性
@property (nonatomic, strong) UIButton *searchButton;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) NSArray<NSString *> *proxyServices;
@end

@implementation pxyRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.proxyServices = @[]; // 确保初始化为空数组
    self.selectedIndex = -1;  // 初始化选中索引为-1
    self.title = @"代理助手";
    
    // 创建并设置tableView
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    // 创建主StackView
    self.mainStackView = [[UIStackView alloc] init];
    self.mainStackView.axis = UILayoutConstraintAxisVertical;
    self.mainStackView.spacing = 10;
    self.mainStackView.alignment = UIStackViewAlignmentFill; // 改为Fill
    self.mainStackView.distribution = UIStackViewDistributionFillEqually; // 添加distribution
    self.mainStackView.backgroundColor = [UIColor systemBackgroundColor]; // 使用系统背景色
    self.mainStackView.layoutMargins = UIEdgeInsetsMake(10, 10, 10, 10); // 添加内边距
    self.mainStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.mainStackView];

    // 设置view的背景色
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    // 创建按钮和输入框
    self.connectionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.connectionButton setTitle:@"设置代理" forState:UIControlStateNormal];
    [self.connectionButton addTarget:self action:@selector(connectionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    self.disconnectButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.disconnectButton setTitle:@"清除代理" forState:UIControlStateNormal];
    [self.disconnectButton addTarget:self action:@selector(disconnectButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    self.portTextField = [[UITextField alloc] init];
    self.portTextField.placeholder = @"输入端口号";
    self.portTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.portTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.portTextField.text = @"8888";
    
    // 创建搜索按钮
    self.searchButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.searchButton setTitle:@"查找" forState:UIControlStateNormal];
    [self.searchButton addTarget:self action:@selector(searchButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    // 创建水平stackView放置输入框和搜索按钮
    UIStackView *portStackView = [[UIStackView alloc] init];
    portStackView.axis = UILayoutConstraintAxisHorizontal;
    portStackView.spacing = 10;
    portStackView.alignment = UIStackViewAlignmentCenter;
    
    [portStackView addArrangedSubview:self.portTextField];
    [portStackView addArrangedSubview:self.searchButton];
    
    // 添加到主StackView (替换原来直接添加portTextField的代码)
    [self.mainStackView addArrangedSubview:self.connectionButton];
    [self.mainStackView addArrangedSubview:self.disconnectButton];
    [self.mainStackView addArrangedSubview:portStackView];
    
    // 调整按钮和输入框的尺寸
    [self.connectionButton.heightAnchor constraintEqualToConstant:44].active = YES;
    [self.disconnectButton.heightAnchor constraintEqualToConstant:44].active = YES;
    [self.portTextField.heightAnchor constraintEqualToConstant:44].active = YES;
    
    // 设置输入框宽度
    [self.portTextField.widthAnchor constraintEqualToConstant:200].active = YES;

    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        // StackView约束
        [self.mainStackView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [self.mainStackView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.mainStackView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        
        // TableView约束
        [self.tableView.topAnchor constraintEqualToAnchor:self.mainStackView.bottomAnchor constant:20],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

- (void)connectionButtonTapped:(UIButton *)sender {
    // 处理设置代理按钮点击
    NSLog(@"设置代理");

    if (self.selectedIndex >= 0 && self.selectedIndex < self.proxyServices.count) {
        NSString *selectedService = self.proxyServices[self.selectedIndex];
        NSLog(@"leotag. 选中的代理服务: %@", selectedService);
        // 在这里处理选中的代理服务

        NSString *ip = [selectedService componentsSeparatedByString:@":"].firstObject;
        NSInteger port = [selectedService componentsSeparatedByString:@":"].lastObject.integerValue;
        resetProxy(ip, @(port), nil, nil);
    } else {
        NSLog(@"未选择代理服务");
    }

    [self showAlertWithMessage:@"设置代理成功"];

}

- (void)disconnectButtonTapped:(UIButton *)sender {
    // 处理清除代理按钮点击
    NSLog(@"leotag 清除代理");
    resetProxy(nil, nil, nil, nil);

    [self showAlertWithMessage:@"清除代理成功"];
}

// 添加搜索按钮事件处理
- (void)searchButtonTapped:(UIButton *)sender {
    [self.view endEditing:YES];
    
    NSInteger port = [self.portTextField.text integerValue];
    if (port <= 0) {
        [self showAlertWithMessage:@"请输入有效的端口号"];
        return;
    }
    
    [ProxyServiceScanner scanProxyServicesOnPort:port completion:^(NSArray<NSString *> *services) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"leotag proxyservice: %@", services);
            self.proxyServices = services;
            self.selectedIndex = -1;
            [self.tableView reloadData];
            
            if (services.count == 0) {
                NSLog(@"未找到可用的代理服务");
            }
        });
    }];
}

- (void)showAlertWithMessage:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示"
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 实现UITextFieldDelegate方法处理键盘
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.proxyServices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.row < self.proxyServices.count) {
        NSString *service = self.proxyServices[indexPath.row];
        cell.textLabel.text = service;
        cell.accessoryType = (indexPath.row == self.selectedIndex) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 更新选中索引
    self.selectedIndex = indexPath.row;
    
    // 刷新所有可见单元格以更新选中状态
    [tableView reloadData];
}

@end