//
//  XLSettingFormViewController.m
//  SeaTao
//
//  Created by Qilin Hu on 2021/1/21.
//  Copyright © 2021 Shanghai Haidian Information Technology Co.Ltd. All rights reserved.
//

#import "XLSettingFormViewController.h"

// Controller
#import "HQLAccountSecurityTableViewController.h"
#import "XLMessageSettingFormViewController.h"
#import "XLGeneralSettingFormViewController.h"
#import "HQLFAQTableViewController.h"
#import "HQLFeedbackViewController.h"
#import "HQLAboutViewController.h"

static NSString *const kAccountSecurityCell = @"AccountSecurityCell";
static NSString *const kMessageSettingCell  = @"MessageSettingCell";
static NSString *const kGeneralSettingCell  = @"GeneralSettingCell";
static NSString *const kFAQCell             = @"FAQCell";
static NSString *const kFeedbackCell        = @"FeedbackCell";
static NSString *const kAboutCell           = @"AboutCell";
static NSString *const kLogoutCell          = @"LogoutCell";

static const CGFloat KRowHeight = 55.0f;

@implementation XLSettingFormViewController

#pragma mark - Initialize

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        [self initializeForm];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self){
        [self initializeForm];
    }
    return self;
}

- (void)initializeForm {
    XLFormDescriptor *form = [XLFormDescriptor formDescriptorWithTitle:@"设置"];
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    // 账号与安全
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAccountSecurityCell rowType:XLFormRowDescriptorTypeButton title:@"账号与安全"];
    row.action.viewControllerClass = [HQLAccountSecurityTableViewController class];
    [section addFormRow:row];
    
    // 消息设置
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMessageSettingCell rowType:XLFormRowDescriptorTypeButton title:@"消息设置"];
    row.action.viewControllerClass = [XLMessageSettingFormViewController class];
    [section addFormRow:row];
    
    // 通用设置
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kGeneralSettingCell rowType:XLFormRowDescriptorTypeButton title:@"通用设置"];
    row.action.viewControllerClass = [XLGeneralSettingFormViewController class];
    [section addFormRow:row];
    
    // 常见问题
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFAQCell rowType:XLFormRowDescriptorTypeButton title:@"常见问题"];
    row.action.viewControllerClass = [HQLFAQTableViewController class];
    [section addFormRow:row];
    
    // 意见反馈
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFeedbackCell rowType:XLFormRowDescriptorTypeButton title:@"意见反馈"];
    row.action.viewControllerClass = [HQLFeedbackViewController class];
    [section addFormRow:row];
    
    // 关于我们
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAboutCell rowType:XLFormRowDescriptorTypeButton title:@"关于我们"];
    row.action.viewControllerClass = [HQLAboutViewController class];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    // 退出登录
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAboutCell rowType:XLFormRowDescriptorTypeButton title:@"退出登录"];
    row.action.formSelector = @selector(showLogoutAlertController);
    [section addFormRow:row];

    self.form = form;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return KRowHeight;
}

#pragma mark - Actions

- (void)showLogoutAlertController {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定要退出登录吗?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self removeAccessToken];
    }];
    [alert addAction:cancelAction];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

// 修改用户登录状态，删除 Access Token
- (void)removeAccessToken {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.bezelView.blurEffectStyle = UIBlurEffectStyleDark;
    hud.contentColor = [UIColor whiteColor];
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{

        [[HQLUserManager sharedManager] logout];

        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds *NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:LoginStateChangedNotification object:nil];
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
    });
}

@end
