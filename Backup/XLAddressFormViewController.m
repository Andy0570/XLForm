//
//  XLAddressFormViewController.m
//  SeaTao
//
//  Created by Qilin Hu on 2021/4/26.
//  Copyright © 2021 Shanghai Haidian Information Technology Co.Ltd. All rights reserved.
//

#import "XLAddressFormViewController.h"

// View
#import "HQLPCAInlinePickerCell.h"

// Model
#import "HQLProvinceManager.h"
#import "HQLAddress.h"

// Service
#import "HQLAddAddressRequest.h"

static NSString *const kNameCell = @"NameCell";
static NSString *const KPhoneNumberCell = @"PhoneNumberCell";
static NSString *const KCityCell = @"CityCell";
static NSString *const kDetailAddressCell = @"DetailAddressCell";
static NSString *const kDefaultStateCell = @"DefaultStateCell";
static NSString *const KSaveButtonCell = @"SaveButtonCell";

static const CGFloat KRowHeight = 50.0f;

@implementation XLAddressFormViewController

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
    XLFormDescriptor *form = [XLFormDescriptor formDescriptorWithTitle:@"新增收货地址"];
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
    [section addFormRow:row];
    
    // 选择地区
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KCityCell
                                                rowType:HQLFormRowDescriptorTypePCAInlinePickerCell
                                                  title:@"选择地区"];
    row.height = KRowHeight;    
    row.noValueDisplayText = @"请选择所在城市";
    // 根据用户信息初始化当前城市
    HQLProvinceManager *provinceManager = [HQLProvinceManager sharedManager];
//    HQLUser *user = [HQLUserManager sharedManager].user;
//    if (user.cityCode) {
//        [provinceManager setCurrentCityCode:user.cityCode.stringValue];
//    } else if ([user.cityName isNotBlank]) {
//        [provinceManager setCurrentCityName:user.cityName];
//    }
    row.value = provinceManager;
    row.required = YES;
    [section addFormRow:row];
        
    // 详细地址
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDetailAddressCell
                                                rowType:XLFormRowDescriptorTypeTextView
                                                  title:@"详细地址"];
    row.height = KRowHeight;
    [row.cellConfigAtConfigure setObject:[NSNumber numberWithFloat:0.66]
                                  forKey:XLFormTextViewLengthPercentage];
    // 设置最大输入字符数
    //[row.cellConfigAtConfigure setObject:@(64) forKey:@"textViewMaxNumberOfCharacters"];
    [row.cellConfigAtConfigure setObject:@"小区楼栋门牌号" forKey:@"textView.placeholder"];
    row.required = YES;
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    // 设为默认地址
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDefaultStateCell
                                                rowType:XLFormRowDescriptorTypeBooleanSwitch
                                                  title:@"设为默认地址"];
    row.height = KRowHeight;
    [row.cellConfigAtConfigure setObject:COLOR_THEME forKey:@"switchControl.onTintColor"];
    row.value = @NO;
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
    HQLAddAddressRequest *request = [[HQLAddAddressRequest alloc] initWithAddress:address];
    [request startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        DDLogVerbose(@"新增收货地址，返回数据:\n%@",request.responseJSONObject);
        [hud hideAnimated:YES];
        
        NSNumber *code =request.responseJSONObject[@"code"];
        if (code.intValue != 200) {
            DDLogError(@"%@ Response Code Error:\n%@",@(__PRETTY_FUNCTION__), request.responseJSONObject);
            [self.view makeToast:@"请求数据失败(错误码:1002)"];
            return;
        }
        
        [self.view makeToast:@"新增收货地址成功"];
        [self.navigationController popViewControllerAnimated:YES];
        
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        DDLogError(@"%@, Request Error:\n%@", @(__PRETTY_FUNCTION__), request.error);
        [hud hideAnimated:YES];
        [self.view makeToast:@"请求数据失败(错误码:1001)"];
    }];
}

- (void)animateBackgroundColorCell:(UITableViewCell *)cell {
    cell.backgroundColor = [UIColor orangeColor];
    [UIView animateWithDuration:0.3 animations:^{
        cell.backgroundColor = [UIColor whiteColor];
    }];
}

@end
