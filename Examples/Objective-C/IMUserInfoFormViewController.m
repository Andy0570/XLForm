//
//  IMUserInfoFormViewController.m
//  SeaTao
//
//  Created by Qilin Hu on 2021/1/8.
//  Copyright © 2021 Shanghai Haidian Information Technology Co.Ltd. All rights reserved.
//

#import "IMUserInfoFormViewController.h"

// Model
//#import "IMUser.h"

// Service
//#import "IMAddBlacklistRequest.h"

static NSString *const kAvatorImage = @"avatorImage";
static NSString *const kUserId = @"userId";
static NSString *const kName = @"name";
static NSString *const KGender = @"gender";
static NSString *const KTelephone = @"telephone";
static NSString *const kEmail = @"email";
static NSString *const kAddBlacklist = @"addBlacklist";

static const CGFloat KRowHeight = 60.0f;

@interface IMUserInfoFormViewController ()
//@property (nonatomic, strong) IMUser *user;
@end

@implementation IMUserInfoFormViewController

#pragma mark - Initialize

//- (instancetype)initWithUser:(IMUser *)user {
//    self = [super init];
//    if (!self) { return nil; }
//
//    self.user = user;
//    [self initializeForm];
//    return self;
//}

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self initializeForm];
}

- (void)initializeForm {
    XLFormDescriptor *form = [XLFormDescriptor formDescriptorWithTitle:@"个人信息"];
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    // 头像
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAvatorImage rowType:XLFormRowDescriptorTypeImage title:@"头像"];
    row.height = KRowHeight;
    row.value = [UIImage imageNamed:@"default_avatar"];
    [section addFormRow:row];
    
    // 账号
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kUserId rowType:XLFormRowDescriptorTypeText title:@"账号"];
    row.height = KRowHeight;
    row.value = [NSString stringWithFormat:@"100000"];
    [section addFormRow:row];
    
    // 名称
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName rowType:XLFormRowDescriptorTypeText title:@"名称"];
    row.height = KRowHeight;
    // row.value = ([self.user.name isNotBlank] ? self.user.name : @"未定义用户名");
    row.value = @"未定义用户名";
    [section addFormRow:row];
    
    // 性别
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KGender rowType:XLFormRowDescriptorTypeText title:@"性别"];
    row.height = KRowHeight;
    // row.value = (self.user.gender == 0) ? @"男" : @"女";
    row.value = @"男";
    [section addFormRow:row];
    
    // 电话
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KTelephone rowType:XLFormRowDescriptorTypeText title:@"电话"];
    row.height = KRowHeight;
    // row.value = self.user.telephone;
    row.value = @"135 1234 5678";
    [section addFormRow:row];
    
    // 邮箱
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEmail rowType:XLFormRowDescriptorTypeText title:@"邮箱"];
    row.height = KRowHeight;
    // row.value = self.user.email;
    row.value = @"andywhm@163.com";
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    // 拉入黑名单
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddBlacklist rowType:XLFormRowDescriptorTypeButton title:@"拉入黑名单"];
    [row.cellConfigAtConfigure setObject:[UIColor redColor] forKey:@"textLabel.color"];
    row.action.formSelector = @selector(addUserToBlacklistAction:);
    [section addFormRow:row];
    
    self.form = form;
}

#pragma mark - Actions

- (void)addUserToBlacklistAction:(XLFormRowDescriptor *)sender {
    [self deselectFormRow:sender];
    
    //  1.实例化UIAlertController对象
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定将该用户拉入黑名单？" message:nil preferredStyle:UIAlertControllerStyleAlert];

    //  2.1实例化UIAlertAction按钮:取消按钮
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];

    //  2.2实例化UIAlertAction按钮:确定按钮
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 点击按钮，调用此block
        //[self requestAddUserToBlacklist];
    }];
    [alert addAction:defaultAction];

    //  3.显示alertController
    [self presentViewController:alert animated:YES completion:nil];
}

//- (void)requestAddUserToBlacklist {
//
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    IMAddBlacklistRequest *request = [[IMAddBlacklistRequest alloc] initWithUserId:self.user.userId];
//    [request startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
//        [hud hideAnimated:YES];
//
//        DDLogInfo(@"拉入黑名单返回数据:%@",request.responseJSONObject);
//        NSNumber *code = request.responseJSONObject[@"code"];
//        if (code.intValue != 0) {
//            [self.view makeToast:@"操作失败~"];
//        } else {
//            [self.view makeToast:@"操作成功～"];
//
//            // TODO: 更新通讯录列表
//
//
//            // 返回上一页面
//            [self.navigationController popViewControllerAnimated:YES];
//        }
//    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
//        DDLogError(@"%@, Request Error:\n%@", @(__PRETTY_FUNCTION__), request.error);
//        [hud hideAnimated:YES];
//        [self.view makeToast:@"操作失败~"];
//    }];
//}

@end
