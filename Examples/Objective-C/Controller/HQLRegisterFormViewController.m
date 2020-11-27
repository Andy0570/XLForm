//
//  HQLRegisterFormViewController.m
//  XLForm
//
//  Created by Qilin Hu on 2019/11/8.
//  Copyright © 2019 Xmartlabs. All rights reserved.
//

#import "HQLRegisterFormViewController.h"

// Frameworks
#import <SHSPhoneLibrary.h>
#import <CustomIOSAlertView.h>
#import <Chameleon.h>
#import <Toast.h>

// Views
#import "HQLVerificationCodeCell.h" // 自定义短信验证码 cell
#import "HQLRegisterGrdmCell.h"     // 自定义人员识别号 cell
#import "HQLGrdmVew.h"

static NSString *const KIDNumber = @"idNumber";
static NSString *const KName     = @"name";
static NSString *const KGrdm     = @"grdm";
static NSString *const KPhoneNumber      = @"phoneNumber";
static NSString *const KVerificationCode = @"verificationCode";
static NSString *const KNextStepButton   = @"nextStepButton";

@interface HQLRegisterFormViewController ()

@end

@implementation HQLRegisterFormViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initializeForm];
    }
    return self;
}

- (void)initializeForm {
    XLFormDescriptor *form = [XLFormDescriptor formDescriptorWithTitle:@"注册"];
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    section = [XLFormSectionDescriptor formSection];
    section.footerTitle = @"说明:\n1. 手机号码：请务必填写社会保障卡采集时录入的本人手机号码，如未登记或手机号码已更换，请至业务经办点办理。";
    [form addFormSection:section];
    
    // 身份证号码
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KIDNumber rowType:XLFormRowDescriptorTypeAccount title:@"身份证号"];
    [row.cellConfigAtConfigure setObject:[NSNumber numberWithFloat:0.66]
                                  forKey:XLFormTextFieldLengthPercentage];
    [row.cellConfig setObject:@"请输入居民二代身份证号" forKey:@"textField.placeholder"];
    row.required = YES;
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"身份证号码格式错误"
                                                                regex:@"^\\d{17}(\\d|X|x)$"]];
    [section addFormRow:row];
    
    // 姓名
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KName rowType:XLFormRowDescriptorTypeName title:@"姓名"];
    [row.cellConfigAtConfigure setObject:[NSNumber numberWithFloat:0.66]
                                  forKey:XLFormTextFieldLengthPercentage];
    [row.cellConfig setObject:@"请输入姓名" forKey:@"textField.placeholder"];
    row.required = YES;
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"姓名格式错误"
                                                                regex:@"^[\\u4e00-\\u9fa5|.|·]{2,}$"]];
    [section addFormRow:row];
    
    // 人员识别号
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KGrdm rowType:XLFormRowDescriptorTypeRegisterGrdmCell title:@"人员识别号"];
    row.required = YES;
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"人员识别号格式错误"
                                                                regex:@"^[Jj][Ss].(\\d+)(\\d|X|x)$"]];
    row.action.formSelector = @selector(helpButtonDidClicked:);
    [section addFormRow:row];
    
    // 手机号码
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KPhoneNumber rowType:XLFormRowDescriptorTypePhone title:@"手机号码"];
    [row.cellConfigAtConfigure setObject:[NSNumber numberWithFloat:0.66]
                                  forKey:XLFormTextFieldLengthPercentage];
    [row.cellConfig setObject:@"请输入手机号码" forKey:@"textField.placeholder"];
    row.required = YES;
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"手机号码格式错误"
                                                                regex:@"^1(3|4|5|6|7|8|9)\\d{9}$"]];
    // 格式化显示
    SHSPhoneNumberFormatter *formatter = [[SHSPhoneNumberFormatter alloc] init];
    [formatter setDefaultOutputPattern:@"### #### ####"];
    row.valueFormatter = formatter;
    row.useValueFormatterDuringInput = YES;
    [section addFormRow:row];
    
    // 验证码
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KVerificationCode rowType:XLFormRowDescriptorTypeVerificationCodeCell];
    row.title = @"验证码";
    row.required = YES;
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"输入验证码格式错误"
                                                                regex:@"^\\d{4,6}$"]];
    row.action.formSelector = @selector(getVerificationCodeButtonDidClicked:);
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    // 下一步按钮
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KNextStepButton rowType:XLFormRowDescriptorTypeButton title:@"下一步"];
    [row.cellConfig setObject:[UIColor whiteColor] forKey:@"textLabel.color"];
    [row.cellConfig setObject:HexColor(@"#108EE9") forKey:@"backgroundColor"];
    row.action.formSelector= @selector(nextStepButtonDidClicked:);
    [section addFormRow:row];
    
    self.form = form;
}

#pragma mark - IBActions

// 获取短信验证码
- (void)getVerificationCodeButtonDidClicked:(id)sender {
    // 收起键盘
    [self.view endEditing:YES];
    
    // 判断是否输入身份证号码、手机号码
    __block BOOL shouldReturn = NO;
    NSArray *array = [self formValidationErrors];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        XLFormValidationStatus *validationStatus = [[obj userInfo] objectForKey: XLValidationStatusErrorKey];
        // 身份证号码
        if ([validationStatus.rowDescriptor.tag isEqualToString:KIDNumber]) {
            shouldReturn = YES;
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:validationStatus.rowDescriptor]];
            [self animateBackgroundColorCell:cell];
            [self.view makeToast:validationStatus.msg];
            *stop = YES;
        }
        // 手机号码
        if ([validationStatus.rowDescriptor.tag isEqualToString:KPhoneNumber]) {
            shouldReturn = YES;
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:validationStatus.rowDescriptor]];
            [self animateBackgroundColorCell:cell];
            [self.view makeToast:validationStatus.msg];
            *stop = YES;
        }
    }];
    if (shouldReturn) {
        return;
    }
    
    // 获取验证码
    // 1.实例化alertController
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"短信验证码发送成功"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];

    // 2.实例化按钮
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
        // 点击按钮，调用此block
        // 开启“获取验证码”按钮倒计时
        [self buttonCountDown:(UIButton *)sender];
                                                       
                                                   }];
    [alert addAction:action];

    //  3.显示alertController
    [self presentViewController:alert animated:YES completion:nil];
    
}


// 下一步按钮
- (void)nextStepButtonDidClicked:(XLFormRowDescriptor *)sender {
    [self deselectFormRow:sender];
    
    // 表单项判断
    __block BOOL shouldReturn = NO;
    NSArray *array = [self formValidationErrors];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        XLFormValidationStatus *validationStatus = [[obj userInfo] objectForKey: XLValidationStatusErrorKey];
        // 身份证号
        if ([validationStatus.rowDescriptor.tag isEqualToString:KIDNumber]) {
            shouldReturn = YES;
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:validationStatus.rowDescriptor]];
            [self animateBackgroundColorCell:cell];
            [self.view makeToast:validationStatus.msg];
            *stop = YES;
        }
        // 姓名
        if ([validationStatus.rowDescriptor.tag isEqualToString:KName]) {
            shouldReturn = YES;
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:validationStatus.rowDescriptor]];
            [self animateBackgroundColorCell:cell];
            [self.view makeToast:validationStatus.msg];
            *stop = YES;
        }
        // 人员识别号
        if ([validationStatus.rowDescriptor.tag isEqualToString:KGrdm]) {
            shouldReturn = YES;
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:validationStatus.rowDescriptor]];
            [self animateBackgroundColorCell:cell];
            [self.view makeToast:validationStatus.msg];
            *stop = YES;
        }
        // 手机号
        if ([validationStatus.rowDescriptor.tag isEqualToString:KPhoneNumber]) {
            shouldReturn = YES;
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:validationStatus.rowDescriptor]];
            [self animateBackgroundColorCell:cell];
            [self.view makeToast:validationStatus.msg];
            *stop = YES;
        }
        // 验证码
        if ([validationStatus.rowDescriptor.tag isEqualToString:KVerificationCode]) {
            shouldReturn = YES;
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:validationStatus.rowDescriptor]];
            [self animateBackgroundColorCell:cell];
            [self.view makeToast:validationStatus.msg];
            *stop = YES;
        }
    }];
    if (shouldReturn) {
        return;
    }
    
    // 加载动画
    // 1.实例化alertController
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"标题"
                                                                   message:@"消息"
                                                            preferredStyle:UIAlertControllerStyleAlert];

    // 2.实例化按钮
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       // 点击按钮，调用此block
                                                       NSLog(@"Button Click");
                                                   }];
    [alert addAction:action];

    //  3.显示alertController
    [self presentViewController:alert animated:YES completion:nil];
}

// 显示人员识别号图片按钮
- (void)helpButtonDidClicked:(id)sender {
    [self.view endEditing:YES];
    
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    [alertView setContainerView:[[HQLGrdmVew alloc] init]];
    [alertView setButtonTitles:@[@"确定"]];
    alertView.closeOnTouchUpOutside = YES;
    [alertView show];
}

#pragma mark - Private

-(void)buttonCountDown:(UIButton *)button {
    button.enabled = NO;
    
    __block NSUInteger timeout = 60; // 倒计时时间
    NSTimeInterval intervalInSeconds = 1.0; // 执行时间间隔
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, intervalInSeconds * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        if (timeout <= 0) {
            dispatch_source_cancel(timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                button.enabled = YES;
                [button setTitle:@"获取验证码" forState:UIControlStateNormal];
            });
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                button.enabled = NO;
                NSString *buttonTitle = [NSString stringWithFormat:@"%lu s",(unsigned long)timeout];
                [button setTitle:buttonTitle forState:UIControlStateNormal];
            });
        }
        timeout --;
    });
    dispatch_resume(timer);
}

- (void)animateBackgroundColorCell:(UITableViewCell *)cell {
    cell.backgroundColor = [UIColor orangeColor];
    [UIView animateWithDuration:0.3 animations:^{
        cell.backgroundColor = [UIColor whiteColor];
    }];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}


@end
