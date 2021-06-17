//
//  XLMessageSettingFormViewController.m
//  SeaTao
//
//  Created by Qilin Hu on 2020/7/30.
//  Copyright © 2020 Shanghai Haidian Information Technology Co.Ltd. All rights reserved.
//

#import "XLMessageSettingFormViewController.h"

// Manager
#import "IMPushManager.h"

static NSString *const KConsumerMessage = @"ConsumerMessage";
static NSString *const KInteractiveMessage = @"InteractiveMessage";
static NSString *const KPrivateMessage = @"PrivateMessage";
static NSString *const KSystemNotification = @"SystemNotification";

static const CGFloat KRowHeight = 55.0f;

@interface XLMessageSettingFormViewController () <XLFormDescriptorDelegate>
@end

@implementation XLMessageSettingFormViewController

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
    if (self) {
        [self initializeForm];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeForm];
    }
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
    row.value = [NSNumber numberWithBool:[NSUserDefaults jk_boolForKey:KConsumerMessage]];
    [section addFormRow:row];
    
    // 互动消息提醒
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KInteractiveMessage rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"互动消息提醒"];
    row.value = [NSNumber numberWithBool:[NSUserDefaults jk_boolForKey:KInteractiveMessage]];
    [section addFormRow:row];
    
    // 私信消息
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KPrivateMessage rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"私信消息"];
    row.value = [NSNumber numberWithBool:[NSUserDefaults jk_boolForKey:KPrivateMessage]];
    [section addFormRow:row];
    
    // 系统通知
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KSystemNotification rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"系统通知"];
    row.value = [NSNumber numberWithBool:[NSUserDefaults jk_boolForKey:KSystemNotification]];
    [section addFormRow:row];

    self.form = form;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return KRowHeight;
}

#pragma mark - <XLFormDescriptorDelegate>

-(void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue {
    [super formRowDescriptorValueHasChanged:formRow oldValue:oldValue newValue:newValue];
    
    NSNumber *boolValue = [NSNumber numberWithBool:[[newValue valueData] boolValue]];
    
    if ([formRow.tag isEqualToString:KConsumerMessage]) {
        [NSUserDefaults jk_setObject:boolValue forKey:KConsumerMessage];
    } else if ([formRow.tag isEqualToString:KInteractiveMessage]) {
        [NSUserDefaults jk_setObject:boolValue forKey:KInteractiveMessage];
    } else if ([formRow.tag isEqualToString:KPrivateMessage]) {
        [NSUserDefaults jk_setObject:boolValue forKey:KPrivateMessage];
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
    IMPushManager *pushManager = [[IMPushManager alloc] init];
    [pushManager enableOfflinePushWithCompletion:^(IMError * _Nonnull aError) {
        if (aError) {
            DDLogDebug(@"开启 APNs 推送:%@",aError);
        }
        [NSUserDefaults jk_setObject:@YES forKey:KSystemNotification];
    }];
}

// 关闭服务器 APNs IM 推送通知
- (void)sendCloseAPNsRequest {
    IMPushManager *pushManager = [[IMPushManager alloc] init];
    [pushManager disableOfflinePushWithCompletion:^(IMError * _Nonnull aError) {
        if (aError) {
            DDLogDebug(@"关闭 APNs 推送:%@",aError);
        }
        [NSUserDefaults jk_setObject:@NO forKey:KSystemNotification];
    }];
}

@end
