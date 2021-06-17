//
//  HQLCityInlinePickerCell.m
//  XLForm
//
//  Created by Qilin Hu on 2020/11/26.
//  Copyright © 2020 Xmartlabs. All rights reserved.
//

#import "HQLCityInlinePickerCell.h"
#import "HQLProvinceManager.h"
#import "HQLProvince.h"

NSString *const HQLFormRowDescriptorTypeCityInlinePickerCell = @"HQLCityInlinePickerCell";
NSString *const HQLFormRowDescriptorTypeCityInlinePickerControl = @"HQLCityInlinePickerControl";

@implementation HQLCityInlinePickerCell {
    UIColor *_beforeChangeColor;
}

+ (void)load {
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:HQLCityInlinePickerCell.class forKey:HQLFormRowDescriptorTypeCityInlinePickerCell];
    [XLFormViewController.inlineRowDescriptorTypesForRowDescriptorTypes setObject:HQLFormRowDescriptorTypeCityInlinePickerControl forKey:HQLFormRowDescriptorTypeCityInlinePickerCell];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

// 成为第一响应者，在下方添加选择器行
- (BOOL)becomeFirstResponder {
    if (self.isFirstResponder) {
        return [super becomeFirstResponder];
    }
    _beforeChangeColor = self.detailTextLabel.textColor;
    BOOL result = [super becomeFirstResponder];
    if (result) {
        // 创建并添加城市选择器行
        XLFormRowDescriptor *inlineRowDescriptor = [XLFormRowDescriptor formRowDescriptorWithTag:nil rowType:[XLFormViewController inlineRowDescriptorTypesForRowDescriptorTypes] [self.rowDescriptor.rowType]];
        inlineRowDescriptor.value = self.rowDescriptor.value;
        UITableViewCell<XLFormDescriptorCell> *cell = [inlineRowDescriptor cellForFormController:self.formViewController];
        NSAssert([cell conformsToProtocol:@protocol(XLFormInlineRowDescriptorCell)], @"inline cell must conform to XLFormInlineRowDescriptorCell");
        UITableViewCell<XLFormInlineRowDescriptorCell> * inlineCell = (UITableViewCell<XLFormInlineRowDescriptorCell> *)cell;
        inlineCell.inlineRowDescriptor = self.rowDescriptor;
        [self.rowDescriptor.sectionDescriptor addFormRow:inlineRowDescriptor afterRow:self.rowDescriptor];
        [self.formViewController ensureRowIsVisible:inlineRowDescriptor];
    }
    return result;
}

// 放弃第一响应者，在下方移出选择器行
- (BOOL)resignFirstResponder {
    if (![self isFirstResponder]) {
        return [super resignFirstResponder];
    }
    NSIndexPath * selectedRowPath = [self.formViewController.form indexPathOfFormRow:self.rowDescriptor];
    NSIndexPath * nextRowPath = [NSIndexPath indexPathForRow:selectedRowPath.row + 1 inSection:selectedRowPath.section];
    XLFormRowDescriptor * nextFormRow = [self.formViewController.form formRowAtIndex:nextRowPath];
    XLFormSectionDescriptor * formSection = [self.formViewController.form.formSections objectAtIndex:nextRowPath.section];
    BOOL result = [super resignFirstResponder];
    if (result) {
        [formSection removeFormRow:nextFormRow];
    }
    return result;
}

#pragma mark - XLFormDescriptorCell

- (void)configure {
    [super configure];
}

- (void)update {
    [super update];
    
    self.accessoryType = UITableViewCellAccessoryNone;
    self.editingAccessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = self.rowDescriptor.isDisabled ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleDefault;
    
    self.textLabel.text = self.rowDescriptor.title;
    self.detailTextLabel.text = [self valueDisplayText];
}

- (BOOL)formDescriptorCellCanBecomeFirstResponder {
    return !self.rowDescriptor.isDisabled;
}

- (BOOL)formDescriptorCellBecomeFirstResponder {
    if ([self isFirstResponder]) {
        [self resignFirstResponder];
        return NO;
    }
    return [self becomeFirstResponder];
}

- (void)formDescriptorCellDidSelectedWithFormController:(XLFormViewController *)controller {
    [controller.tableView deselectRowAtIndexPath:[controller.form indexPathOfFormRow:self.rowDescriptor] animated:YES];
}

-(void)highlight {
    [super highlight];
    self.detailTextLabel.textColor = self.tintColor;
}

-(void)unhighlight {
    [super unhighlight];
    self.detailTextLabel.textColor = _beforeChangeColor;
}

#pragma mark - Helpers

- (NSString *)valueDisplayText {
    return (self.rowDescriptor.value ? [self.rowDescriptor.value displayText] : self.rowDescriptor.noValueDisplayText);
}

@end


@interface HQLCityInlinePickerControl () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) HQLProvinceManager *provinceManager;
@end

@implementation HQLCityInlinePickerControl

@synthesize pickerView = _pickerView;
@synthesize inlineRowDescriptor = _inlineRowDescriptor;

+ (void)load {
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:HQLCityInlinePickerControl.class forKey:HQLFormRowDescriptorTypeCityInlinePickerControl];
}

- (BOOL)formDescriptorCellCanBecomeFirstResponder {
    return (!self.rowDescriptor.isDisabled && (self.inlineRowDescriptor == nil));
}

- (BOOL)formDescriptorCellBecomeFirstResponder {
    return [self becomeFirstResponder];
}

- (BOOL)canResignFirstResponder {
    return YES;
}

- (BOOL)canBecomeFirstResponder {
    return [self formDescriptorCellCanBecomeFirstResponder];
}

#pragma mark - Custom Accessors

- (UIPickerView *)pickerView {
    if (!_pickerView) {
        _pickerView = [UIPickerView autolayoutView];
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
    }
    return _pickerView;
}

- (HQLProvinceManager *)provinceManager {
    if (!_provinceManager) {
        _provinceManager = [HQLProvinceManager sharedManager];
    }
    return _provinceManager;
}

#pragma mark - XLFormDescriptorCell

- (void)configure {
    [super configure];
    
    [self.contentView addSubview:self.pickerView];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.pickerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[pickerView]-0-|" options:0 metrics:0 views:@{@"pickerView" : self.pickerView}]];
}

- (void)update {
    [super update];
    
    BOOL isDisable = self.rowDescriptor.isDisabled;
    self.userInteractionEnabled = !isDisable;
    self.contentView.alpha = isDisable ? 0.5 : 1.0;
    
    if (self.rowDescriptor.value) {
        // 如果有默认值，反向选中选择器
        [self selectedProvinceRowIndex];
        [self selectCityRowIndex];
    }
}

+ (CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor
{
    return 216.0f;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (component) {
        case 0: {
            // 返回省份个数
            return self.provinceManager.provinces.count;
            break;
        }
        case 1: {
            // 返回当前省份的城市数
            return self.provinceManager.currentProvince.children.count;
            break;
        }
        default: {
            return 0;
            break;
        }
    }
}

#pragma mark - UIPickerViewDelegate

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (component) {
        case 0: {
            // 第一列返回省份名字
            HQLProvince *province = [self.provinceManager.provinces jk_objectAtIndex:row];
            return province.name;
            break;
        }
        case 1: {
            // 第二列返回城市名字
            HQLCity *city = [self.provinceManager.currentProvince.children jk_objectAtIndex:row];
            return city.name;
            break;
        }
        default: {
            return NULL;
            break;
        }
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    switch (component) {
        case 0: {
            HQLProvince *currentProvince = [self.provinceManager.provinces jk_objectAtIndex:row];
            self.provinceManager.currentProvince = currentProvince;
            
            // 选择省份后，更新城市信息
            [pickerView reloadComponent:1];
            [pickerView selectRow:0 inComponent:1 animated:YES];
            break;
        }
        case 1: {
            HQLCity *currentCity = [self.provinceManager.currentProvince.children jk_objectAtIndex:row];
            self.provinceManager.currentCity = currentCity;
            break;
        }
        default:
            break;
    }
    
    if (self.inlineRowDescriptor) {
        self.inlineRowDescriptor.value = self.provinceManager;
        [self.formViewController updateFormRow:self.inlineRowDescriptor];
    }
}

#pragma mark - Helpers

// 根据表单值value值，反向选中选择器
- (void)selectedProvinceRowIndex {
    XLFormRowDescriptor *formRow = self.inlineRowDescriptor ? : self.rowDescriptor;
    if (formRow.value && self.provinceManager.currentProvince) {
        NSInteger currentProvinceIndex = [self.provinceManager.provinces indexOfObject:self.provinceManager.currentProvince];
        [self.pickerView selectRow:currentProvinceIndex inComponent:0 animated:NO];
    }
}

- (void)selectCityRowIndex {
    XLFormRowDescriptor *formRow = self.inlineRowDescriptor ? : self.rowDescriptor;
    if (formRow.value && self.provinceManager.currentCity) {
        NSInteger currentCityIndex = [self.provinceManager.currentProvince.children indexOfObject:self.provinceManager.currentCity];
        [self.pickerView selectRow:currentCityIndex inComponent:1 animated:NO];
    }
}

@end
