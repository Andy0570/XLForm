//
//  HQLPersonalInfoFormViewController.m
//  XLForm
//
//  Created by Qilin Hu on 2020/11/27.
//  Copyright © 2020 Xmartlabs. All rights reserved.
//

#import "HQLPersonalInfoFormViewController.h"
#import <JKCategories.h>

// View
#import "HQLCityPickerCell.h"
#import "HQLProvinceManager.h"

static NSString *const KHeadImage = @"headImage";
static NSString *const KNickname = @"nickname";
static NSString *const KGender = @"gender";
static NSString *const KBirthday = @"birthday";
static NSString *const KCityName = @"cityName";
static NSString *const KSignature = @"signature";
static NSString *const KPersonalQRCode = @"personalQRCode";

static const CGFloat KRowHeight = 60.0f;

@interface HQLPersonalInfoFormViewController () <XLFormDescriptorDelegate>

@end

@implementation HQLPersonalInfoFormViewController

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

#pragma mark - Initialize

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        [self initializeForm];
        [self addNavigationBarCompleteButton];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self){
        [self initializeForm];
        [self addNavigationBarCompleteButton];
    }
    return self;
}

- (void)initializeForm {
    XLFormDescriptor *form = [XLFormDescriptor formDescriptorWithTitle:@"个人信息"];
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
        
    // 头像
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KHeadImage rowType:XLFormRowDescriptorTypeImage title:@"头像"];
    row.height = KRowHeight;
    
    row.value = [UIImage imageNamed:@"default_avatar"];
    [section addFormRow:row];
    
    // 昵称
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KNickname rowType:XLFormRowDescriptorTypeText title:@"昵称"];
    row.height = KRowHeight;
    row.value = @"独木舟的木";
    [row.cellConfig setObject:@"请输入昵称，20字以内~" forKey:@"textField.placeholder"];
    // 默认左对齐，可以设置右对齐
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"姓名格式错误" regex:@"^[\\u4e00-\\u9fa5|.|·]{0,20}$"]];
    [section addFormRow:row];
    
    // 性别
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KGender rowType:XLFormRowDescriptorTypeSelectorPickerViewInline title:@"性别"];
    row.height = KRowHeight;
    row.selectorOptions = @[
        [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"男"],
        [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"女"]];
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"男"];
    [section addFormRow:row];
    
    // 生日
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KBirthday rowType:XLFormRowDescriptorTypeDateInline title:@"生日"];
    row.height = KRowHeight;
    [row.cellConfigAtConfigure setObject:[NSLocale localeWithLocaleIdentifier:@"zh-Hans"]
    forKey:@"locale"];
    // 设置最小日期和最大日期
    NSDate *now = [NSDate new];
    [row.cellConfigAtConfigure setObject:[now jk_dateBySubtractingYears:100] forKey:@"minimumDate"];
    [row.cellConfigAtConfigure setObject:now forKey:@"maximumDate"];
    row.value = now;
    row.noValueDisplayText = @"请选择日期";
    [section addFormRow:row];
    
    // 城市
    // !!!: 自定义城市选择器，pick view
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KCityName rowType:HQLFormRowDescriptorTypeCityPickerView title:@"城市"];
    row.required = YES;
    // 根据用户信息初始化当前城市
    HQLProvinceManager *provinceManager = [HQLProvinceManager sharedManager];
    [provinceManager setCurrentCityCode:@"320200"];
    row.value = provinceManager;
    row.noValueDisplayText = @"请选择当前城市";
    [section addFormRow:row];
    
    // 签名
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KSignature rowType:XLFormRowDescriptorTypeTextView title:@"签名"];
    row.height = 80.0f;
    // 设置最大输入字符数
    [row.cellConfigAtConfigure setObject:@(64) forKey:@"textViewMaxNumberOfCharacters"];
    [row.cellConfigAtConfigure setObject:@"请输入文字" forKey:@"textView.placeholder"];
    // 默认左对齐，可以设置右对齐
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textView.textAlignment"];
    row.value = @"如果你给我的和别人一样，那我就不要了。";
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    // 个人二维码
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KPersonalQRCode rowType:XLFormRowDescriptorTypeButton title:@"个人二维码"];
    row.height = KRowHeight;
    row.action.viewControllerNibName = @"HQLPersonalQRCodeViewController";
    [section addFormRow:row];
    
    self.form = form;
}

#pragma mark - Actions

- (void)navigationBarCompleteButtonAction:(id)sender {
    NSLog(@"表单数据：\n%@",self.formValues);
}

#pragma mark - <XLFormDescriptorDelegate>

-(void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue {
    [super formRowDescriptorValueHasChanged:formRow oldValue:oldValue newValue:newValue];
    
    // 更改头像
    if ([formRow.tag isEqual:KHeadImage]) {
        
        // TODO: 上传头像图片到服务器
        
    }
}

#pragma mark - Private

- (void)addNavigationBarCompleteButton {
    UIBarButtonItem *completeBarButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(navigationBarCompleteButtonAction:)];
    self.navigationItem.rightBarButtonItem = completeBarButton;
}

@end
