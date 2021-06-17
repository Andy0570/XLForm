//
//  XLEditAddressFormViewController.m
//  SeaTao
//
//  Created by Qilin Hu on 2021/5/12.
//  Copyright © 2021 Shanghai Haidian Information Technology Co.Ltd. All rights reserved.
//

#import "XLEditAddressFormViewController.h"

// View
#import "HQLPCAInlinePickerCell.h"

// Model
#import "HQLProvinceManager.h"
#import "HQLAddress.h"

// Service
#import "HQLUpdateAddressRequest.h"
#import "HQLDeleteAddressRequest.h"

static NSString *const kNameCell = @"NameCell";
static NSString *const KPhoneNumberCell = @"PhoneNumberCell";
static NSString *const KCityCell = @"CityCell";
static NSString *const kDetailAddressCell = @"DetailAddressCell";
static NSString *const kDefaultStateCell = @"DefaultStateCell";
static NSString *const KSaveButtonCell = @"SaveButtonCell";

static const CGFloat KRowHeight = 50.0f;

@interface XLEditAddressFormViewController ()
@property (nonatomic, strong) HQLAddress *address;
@end

@implementation XLEditAddressFormViewController

#pragma mark - Initialize

- (instancetype)initWithAddress:(HQLAddress *)address {
    self = [super init];
    if (!self) { return nil; }
    
    self.address = address;
    [self initializeForm];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(showDeleteAddressAlert)];
}

- (void)initializeForm {
    XLFormDescriptor *form = [XLFormDescriptor formDescriptorWithTitle:@"编辑收货地址"];
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    // 收货人
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNameCell
                                                rowType:XLFormRowDescriptorTypeName
                                                  title:@"收货人"];
    row.height = KRowHeight;
    [row.cellConfigAtConfigure setObject:[NSNumber numberWithFloat:0.66]
                                  forKey:XLFormTextFieldLengthPercentage];
    [row.cellConfig setObject:@"姓名" forKey:@"textField.placeholder"];
    row.required = YES;
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"姓名格式错误"
                                                                regex:@"^[\\u4e00-\\u9fa5|.|·]{2,}$"]];
    row.value = self.address.name;
    [section addFormRow:row];
    
    // 手机号
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KPhoneNumberCell
                                                rowType:XLFormRowDescriptorTypePhone
                                                  title:@"手机号"];
    row.height = KRowHeight;
    [row.cellConfigAtConfigure setObject:[NSNumber numberWithFloat:0.66]
                                  forKey:XLFormTextFieldLengthPercentage];
    [row.cellConfig setObject:@"手机号码" forKey:@"textField.placeholder"];
    row.required = YES;
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"手机号码格式错误"
                                                                regex:@"^1(3|4|5|6|7|8|9)\\d{9}$"]];
    row.value = self.address.phoneNumber;
    [section addFormRow:row];
    
    // 选择地区
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KCityCell
                                                rowType:HQLFormRowDescriptorTypePCAInlinePickerCell
                                                  title:@"选择地区"];
    row.height = KRowHeight;
    row.noValueDisplayText = @"请选择所在城市";
    // 根据用户信息初始化当前城市
    HQLProvinceManager *provinceManager = [HQLProvinceManager sharedManager];
    [provinceManager setCurrentCityCode:self.address.postCode];
    
    row.value = provinceManager;
    row.required = YES;
    [section addFormRow:row];
    
    // 详细地址
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDetailAddressCell
                                                rowType:XLFormRowDescriptorTypeTextView
                                                  title:@"详细地址"];
    row.height = KRowHeight * 2;
    [row.cellConfigAtConfigure setObject:[NSNumber numberWithFloat:0.66]
                                  forKey:XLFormTextViewLengthPercentage];
    // 设置最大输入字符数
    //[row.cellConfigAtConfigure setObject:@(64) forKey:@"textViewMaxNumberOfCharacters"];
    [row.cellConfigAtConfigure setObject:@"小区楼栋门牌号" forKey:@"textView.placeholder"];
    row.required = YES;
    row.value = self.address.detailAddress;
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    // 设为默认地址
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDefaultStateCell
                                                rowType:XLFormRowDescriptorTypeBooleanSwitch
                                                  title:@"设为默认地址"];
    row.height = KRowHeight;
    [row.cellConfigAtConfigure setObject:COLOR_THEME forKey:@"switchControl.onTintColor"];
    row.value = self.address.defaultStatus;
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    // 保存并使用
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KSaveButtonCell
                                                rowType:XLFormRowDescriptorTypeButton
                                                  title:@"保存并使用"];
    row.height = KRowHeight;
    [row.cellConfigAtConfigure setObject:COLOR_THEME forKey:@"backgroundColor"];
    // 按钮文字颜色：白色
    [row.cellConfig setObject:UIColor.whiteColor forKey:@"textLabel.color"];
    [row.cellConfig setObject:[UIFont systemFontOfSize:18.0f] forKey:@"textLabel.font"];
    row.action.formSelector = @selector(saveButtonDidClicked:);
    [section addFormRow:row];
    
    self.form = form;
}

#pragma mark - Actions

// 更新收货地址
- (void)saveButtonDidClicked:(XLFormRowDescriptor *)sender {
    [self deselectFormRow:sender];
    
    // Step 1.表单项判断
    __block BOOL shouldReturn = NO;
    NSArray *array = [self formValidationErrors];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        XLFormValidationStatus *validationStatus = [[obj userInfo] objectForKey: XLValidationStatusErrorKey];
        
        // 收货人
        if ([validationStatus.rowDescriptor.tag isEqualToString:kNameCell]) {
            shouldReturn = YES;
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:validationStatus.rowDescriptor]];
            [self animateBackgroundColorCell:cell];
            [self.view makeToast:validationStatus.msg];
            *stop = YES;
        }
        // 手机号
        if ([validationStatus.rowDescriptor.tag isEqualToString:KPhoneNumberCell]) {
            shouldReturn = YES;
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:validationStatus.rowDescriptor]];
            [self animateBackgroundColorCell:cell];
            [self.view makeToast:validationStatus.msg];
            *stop = YES;
        }
        // 选择地区
        if ([validationStatus.rowDescriptor.tag isEqualToString:KCityCell]) {
            shouldReturn = YES;
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:validationStatus.rowDescriptor]];
            [self animateBackgroundColorCell:cell];
            [self.view makeToast:validationStatus.msg];
            *stop = YES;
        }
        // 详细地址
        if ([validationStatus.rowDescriptor.tag isEqualToString:kDetailAddressCell]) {
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
    
    // Step 2.构建网络请求参数
    HQLAddress *address = [[HQLAddress alloc] init];
    address.addressId = self.address.addressId;
    address.name = self.httpParameters[kNameCell];
    address.phoneNumber = self.httpParameters[KPhoneNumberCell];
    
    // 是否设置为默认地址，将 Bool 类型转换为 int 类型上传
    NSNumber *defaultState = self.httpParameters[kDefaultStateCell];
    address.defaultStatus = [NSNumber numberWithInt:defaultState.intValue];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:self.httpParameters[KCityCell]];
    address.postCode = dict[@"areaid"];
    address.province = dict[@"province"];
    address.city = dict[@"cityname"];
    address.region = dict[@"areaname"];
    
    address.detailAddress = self.httpParameters[kDetailAddressCell];
    
    // Step 3.发起网络请求
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HQLUpdateAddressRequest *request = [[HQLUpdateAddressRequest alloc] initWithAddress:address];
    [request startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        DDLogVerbose(@"编辑收货地址，返回数据:\n%@",request.responseJSONObject);
        [hud hideAnimated:YES];
        
        NSNumber *code =request.responseJSONObject[@"code"];
        if (code.intValue != 200) {
            DDLogError(@"%@ Response Code Error:\n%@",@(__PRETTY_FUNCTION__), request.responseJSONObject);
            [self.view makeToast:@"修改失败(错误码:1002)"];
            return;
        }
        
        [self.view makeToast:@"修改成功"];
        [self.navigationController popViewControllerAnimated:YES];
        
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        DDLogError(@"%@, Request Error:\n%@", @(__PRETTY_FUNCTION__), request.error);
        [hud hideAnimated:YES];
        [self.view makeToast:@"修改失败(错误码:1001)"];
    }];
}

- (void)animateBackgroundColorCell:(UITableViewCell *)cell {
    cell.backgroundColor = [UIColor orangeColor];
    [UIView animateWithDuration:0.3 animations:^{
        cell.backgroundColor = [UIColor whiteColor];
    }];
}

// 删除地址之前，弹窗提示
- (void)showDeleteAddressAlert {
    //  1.实例化UIAlertController对象
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"删除收货地址？" message:nil preferredStyle:UIAlertControllerStyleAlert];

    //  2.1实例化UIAlertAction按钮:取消按钮
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];

    //  2.2实例化UIAlertAction按钮:确定按钮
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 点击按钮，调用此block
        [self sendDeleteAddressRequest];
    }];
    [alert addAction:defaultAction];

    //  3.显示alertController
    [self presentViewController:alert animated:YES completion:nil];
}

// 发起网络请求，删除收货地址
- (void)sendDeleteAddressRequest {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HQLDeleteAddressRequest *request = [[HQLDeleteAddressRequest alloc] initWithAddress:self.address];
    [request startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        DDLogVerbose(@"删除收货地址，返回数据:\n%@",request.responseJSONObject);
        [hud hideAnimated:YES];
        
        NSNumber *code =request.responseJSONObject[@"code"];
        if (code.intValue != 200) {
            DDLogError(@"%@ Response Code Error:\n%@",@(__PRETTY_FUNCTION__), request.responseJSONObject);
            [self.view makeToast:@"删除失败(错误码:1002)"];
            return;
        }
        
        [self.view makeToast:@"删除成功"];
        [self.navigationController popViewControllerAnimated:YES];
        
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        DDLogError(@"%@, Request Error:\n%@", @(__PRETTY_FUNCTION__), request.error);
        [hud hideAnimated:YES];
        [self.view makeToast:@"删除失败(错误码:1001)"];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

@end
