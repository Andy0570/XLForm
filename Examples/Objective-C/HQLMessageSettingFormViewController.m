//
//  HQLMessageSettingFormViewController.m
//  XLForm
//
//  Created by Qilin Hu on 2021/1/20.
//  Copyright © 2021 Xmartlabs. All rights reserved.
//

#import "HQLMessageSettingFormViewController.h"

// Framework
#import <XLForm/XLForm.h>

// Controller

// Service


static NSString *const KConsumerMessage = @"ConsumerMessage";
static NSString *const KInteractiveMessage = @"InteractiveMessage";
static NSString *const KPrivateMessage = @"PrivateMessage";
static NSString *const KSystemNotification = @"SystemNotification";
static NSString *const KBlacklistManage = @"KBlacklistManage";

static const CGFloat KRowHeight = 60.0f;

@interface HQLMessageSettingFormViewController () <XLFormDescriptorDelegate>

@end

@implementation HQLMessageSettingFormViewController

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
    }
}

#pragma mark - Initialize

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) { return nil; }
    
    [self initializeForm];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self) { return nil; }
    
    [self initializeForm];
    return self;
}

- (void)initializeForm {
    
    XLFormDescriptor *form = [XLFormDescriptor formDescriptorWithTitle:@"消息设置"];
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    // 消费消息提醒
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KConsumerMessage rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"消费消息提醒"];
    BOOL isConsumerMessageSelected = [self readUserPreferencesForKey:KConsumerMessage];
    row.value = isConsumerMessageSelected ? @YES : @NO;
    [section addFormRow:row];
    
    // 互动消息提醒
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KInteractiveMessage rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"互动消息提醒"];
    BOOL isInteractiveMessageSelected = [self readUserPreferencesForKey:KInteractiveMessage];
    row.value = isInteractiveMessageSelected ? @YES : @NO;
    [section addFormRow:row];
    
    // 私信消息
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KPrivateMessage rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"私信消息"];
    BOOL isPrivateMessageSelected = [self readUserPreferencesForKey:KPrivateMessage];
    row.value = isPrivateMessageSelected ? @YES : @NO;
    [section addFormRow:row];
    
    // 系统通知
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KSystemNotification rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"系统通知"];
    BOOL isSystemNotification = [self readUserPreferencesForKey:KSystemNotification];
    row.value = isSystemNotification ? @YES : @NO;
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    // 黑名单管理
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KBlacklistManage rowType:XLFormRowDescriptorTypeButton title:@"黑名单管理"];
    row.action.viewControllerClass = [UIViewController class]; // 模拟黑名单列表
    [section addFormRow:row];
    
    self.form = form;
}

#pragma mark - Private

- (void)saveUserPreferencesForKey:(NSString *)key boolValue:(BOOL)value {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:value forKey:key];
    [userDefaults synchronize];
}

- (BOOL)readUserPreferencesForKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return KRowHeight;
}

#pragma mark - <XLFormDescriptorDelegate>

-(void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue {
    [super formRowDescriptorValueHasChanged:formRow oldValue:oldValue newValue:newValue];
    
    if ([formRow.tag isEqualToString:KConsumerMessage]) {
        [self saveUserPreferencesForKey:KConsumerMessage boolValue:[[newValue valueData] boolValue]];
    } else if ([formRow.tag isEqualToString:KInteractiveMessage]) {
        [self saveUserPreferencesForKey:KInteractiveMessage boolValue:[[newValue valueData] boolValue]];
    } else if ([formRow.tag isEqualToString:KPrivateMessage]) {
        [self saveUserPreferencesForKey:KPrivateMessage boolValue:[[newValue valueData] boolValue]];
    } else if ([formRow.tag isEqualToString:KSystemNotification]) {
        if ([[newValue valueData] boolValue]) {
            [self sendOpenAPNsRequest];
        } else {
            [self sendCloseAPNsRequest];
        }
    }
}

// 开启服务器 APNs IM 推送通知
- (void)sendOpenAPNsRequest {
//    IMOpenAPNsRequest *request = [[IMOpenAPNsRequest alloc] init];
//    [request startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
//        DDLogDebug(@"开启 APNs 推送，响应数据：\n%@",request.responseJSONObject);
//        [self saveUserPreferencesForKey:KSystemNotification boolValue:YES];
//    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
//        DDLogError(@"%@, Request Error:\n%@", @(__PRETTY_FUNCTION__), request.error);
//    }];
}

// 关闭服务器 APNs IM 推送通知
- (void)sendCloseAPNsRequest {
//    IMCloseAPNsRequest *request = [[IMCloseAPNsRequest alloc] init];
//    [request startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
//        DDLogDebug(@"关闭 APNs 推送，响应数据：\n%@",request.responseJSONObject);
//        [self saveUserPreferencesForKey:KSystemNotification boolValue:NO];
//    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
//        DDLogError(@"%@, Request Error:\n%@", @(__PRETTY_FUNCTION__), request.error);
//    }];
}

@end
