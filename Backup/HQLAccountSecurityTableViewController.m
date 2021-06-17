//
//  HQLAccountSecurityTableViewController.m
//  SeaTao
//
//  Created by Qilin Hu on 2020/7/29.
//  Copyright © 2020 Shanghai Haidian Information Technology Co.Ltd. All rights reserved.
//

#import "HQLAccountSecurityTableViewController.h"

// Controller
#import "HQLBandMobileFormViewController.h"
#import "HQLChangePasswordViewController.h"                // 修改密码 - 通过原密码修改密码
#import "HQLSendDefaultPhoneNumberCaptchaViewController.h" // 修改密码 - 通过短信验证码修改密码

static NSString * const cellReuseIdentifier = @"UITableViewCellStyleValue1";

@implementation HQLAccountSecurityTableViewController

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"账号与安全";
    [self setupTableView];
}

- (void)setupTableView {
    if (@available(iOS 11,*)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        self.automaticallyAdjustsScrollViewInsets = NO;
#pragma clang diagnostic pop
    }
    
    self.tableView.backgroundColor = COLOR_BACKGROUND;
    self.tableView.rowHeight = 60.0f;
    self.tableView.tableFooterView = [UIView new];
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellReuseIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    HQLUserManager *sharedManager = [HQLUserManager sharedManager];
    switch (indexPath.row) {
        case 0: {
            cell.textLabel.text = @"手机号";
            
            if ([sharedManager.user.mobile hql_isValidPhoneNumber]) {
                NSString *formattedString = [sharedManager.user.mobile stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
                cell.detailTextLabel.text = formattedString;
            }
            break;
        }
        case 1: {
            cell.textLabel.text = @"修改密码";
            break;
        }
//        case 2: {
//            cell.textLabel.text = @"微信账号";
//
//            if ([sharedManager.user.openId isNotBlank]) {
//                cell.detailTextLabel.text = sharedManager.user.openId;
//            }
//            break;
//        }
        default:
            break;
    }
    
    return cell;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0: {
            HQLUserManager *sharedManager = [HQLUserManager sharedManager];
            // 没有绑定手机号，则点击绑定手机号
            if (![sharedManager.user.mobile hql_isValidPhoneNumber]) {
                HQLBandMobileFormViewController *form = [[HQLBandMobileFormViewController alloc] init];
                [self.navigationController pushViewController:form animated:YES];
            }
            
            break;
        }
        case 1: {
            // 修改密码
            [self showActionSheetToChangePassword];
            break;
        }
//        case 2: {
//            // TODO: 绑定微信账号
//            
//            break;
//        }
        default:
            break;
    }
}

// 修改密码
- (void)showActionSheetToChangePassword {
    HQLUserManager *sharedManager = [HQLUserManager sharedManager];
    if (!sharedManager.isLogin) {
        [MBProgressHUD hql_showTextHUD:@"请先登录"];
        return;
    }

    // 1.实例化UIAlertController对象
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"身份验证"
                                                                   message:@"为确保您的账户安全，请先选择身份验证"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];

    // 2.1实例化UIAlertAction按钮:取消按钮
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alert addAction:cancelAction];

    // 2.3实例化UIAlertAction按钮:确定按钮
    __weak __typeof(self)weakSelf = self;
    UIAlertAction *phoneNumberAction = [UIAlertAction actionWithTitle:@"手机号验证"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
        // MARK: 手机号验证
        [weakSelf showSendCaptchaViewController];
                                                          }];
    [alert addAction:phoneNumberAction];
    
    UIAlertAction *passwordAction = [UIAlertAction actionWithTitle:@"原密码验证"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
        // MARK: 原密码验证
        [weakSelf showChangePasswordViewController];
                                                          }];
    [alert addAction:passwordAction];

    //  3.显示alertController
    [self presentViewController:alert animated:YES completion:nil];
}

// 手机号验证
- (void)showSendCaptchaViewController {
    // 检测用户是否绑定手机号码
    HQLUserManager *sharedManager = [HQLUserManager sharedManager];
    BOOL isValidatePhoneNumber = [sharedManager.user.mobile hql_isValidPhoneNumber];
    if (!isValidatePhoneNumber) {
        [MBProgressHUD hql_showFailureHUD:@"请先绑定手机号码" toView:self.view];
        return;
    }
    
    // 跳转到短信验证码发送页面
    HQLSendDefaultPhoneNumberCaptchaViewController *sendCaptchaVC = [[HQLSendDefaultPhoneNumberCaptchaViewController alloc] init];
    [self.navigationController pushViewController:sendCaptchaVC animated:YES];
}

// 原密码验证
- (void)showChangePasswordViewController {
    HQLChangePasswordViewController *changePasswordVC = [[HQLChangePasswordViewController alloc] init];
    [self.navigationController pushViewController:changePasswordVC animated:YES];
}

@end
