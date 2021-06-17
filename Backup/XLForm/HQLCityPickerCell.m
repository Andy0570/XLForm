//
//  HQLCityPickerCell.m
//  XLForm
//
//  Created by Qilin Hu on 2020/11/26.
//  Copyright © 2020 Xmartlabs. All rights reserved.
//

#import "HQLCityPickerCell.h"
#import "HQLProvinceManager.h"
#import "HQLProvince.h"

NSString *const HQLFormRowDescriptorTypeCityPickerView = @"HQLCityPickerCell";

@interface HQLCityPickerCell () <UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) HQLProvinceManager *provinceManager;
@end

@implementation HQLCityPickerCell {
    UIColor *_beforeChangeColor;
}

+ (void)load {
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:HQLCityPickerCell.class
                                                              forKey:HQLFormRowDescriptorTypeCityPickerView];
}

- (BOOL)canBecomeFirstResponder {
    if ([self.rowDescriptor.rowType isEqualToString:HQLFormRowDescriptorTypeCityPickerView]) {
        return YES;
    }
    return [super canBecomeFirstResponder];
}

// 成为第一响应者，显示 pickerView
- (BOOL)becomeFirstResponder {
    if (self.isFirstResponder) {
        return [super becomeFirstResponder];
    }
    _beforeChangeColor = self.detailTextLabel.textColor;
    BOOL result = [super becomeFirstResponder];
    if (result && self.rowDescriptor.value) {
        // 如果有默认值，反向选中选择器
        [self selectedProvinceRowIndex];
        [self selectCityRowIndex];
    }
    return result;
}

// 放弃第一响应者，移除 pickerView
- (BOOL)resignFirstResponder {
    if (![self isFirstResponder]) {
        return [super resignFirstResponder];
    }
    BOOL result = [super resignFirstResponder];
    if (result) {
        
    }
    return result;
}

#pragma mark - Custom Accessors

- (UIPickerView *)pickerView {
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc] init];
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

#pragma mark - <XLFormDescriptorCell>

// 初始化所有对象，例如数组、UIControls 等等
- (void)configure {
    [super configure];
}

// 当 cell 将要显示时，更新 cell
- (void)update {
    [super update];
    
    self.accessoryType = UITableViewCellAccessoryNone;
    self.editingAccessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = self.rowDescriptor.isDisabled ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleDefault;
    
    self.textLabel.text = self.rowDescriptor.title;
    self.detailTextLabel.text = [self valueDisplayText];
}

// 是否能成为第一响应者
-(BOOL)formDescriptorCellCanBecomeFirstResponder {
    return (!self.rowDescriptor.isDisabled && ([self.rowDescriptor.rowType isEqualToString:HQLFormRowDescriptorTypeCityPickerView]));
}

// 将相应的 UIView 指派为第一响应者
-(BOOL)formDescriptorCellBecomeFirstResponder {
    if ([self isFirstResponder]) {
        [self resignFirstResponder];
        return NO;
    }
    return [self becomeFirstResponder];
}

// 当 cell 被选中时被调用
-(void)formDescriptorCellDidSelectedWithFormController:(XLFormViewController *)controller {
    [controller.tableView deselectRowAtIndexPath:[controller.form indexPathOfFormRow:self.rowDescriptor] animated:YES];
}

// 当 cell 成为第一响应者时被调用，可以用于改变cell成为第一响应者时的呈现样式。
-(void)highlight {
    [super highlight];
    _beforeChangeColor = self.detailTextLabel.textColor;
    self.detailTextLabel.textColor = self.tintColor;
}

// 当 cell 放弃第一响应者时被调用
-(void)unhighlight {
    [super unhighlight];
    self.detailTextLabel.textColor = _beforeChangeColor;
}

#pragma mark - <UIPickerViewDataSource>

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (component) {
        case 0:
            // 返回省份个数
            return self.provinceManager.provinces.count;
            break;
        case 1:
            // 返回当前省份的城市数
            return self.provinceManager.currentProvince.children.count;
            break;
        default:
            return 0;
            break;
    }
}

#pragma mark - <UIPickerViewDelegate>

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (component) {
        case 0: {
            // 第一列返回省份名字
            HQLProvince *province = (HQLProvince *)self.provinceManager.provinces[row];
            return province.name;
            break;
        }
        case 1: {
            // 第二列返回城市名字
            HQLCity *city = (HQLCity *)self.provinceManager.currentProvince.children[row];
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
            HQLProvince *currentProvince = (HQLProvince *)self.provinceManager.provinces[row];
            self.provinceManager.currentProvince = currentProvince;
            [pickerView reloadComponent:1];
            break;
        }
        case 1: {
            HQLCity *currentCity = (HQLCity *)self.provinceManager.currentProvince.children[row];
            self.provinceManager.currentCity = currentCity;
            break;
        }
        default:
            break;
    }
    
    self.rowDescriptor.value = self.provinceManager;
    self.detailTextLabel.text = [self valueDisplayText];
    [self setNeedsLayout];
}


#pragma mark - Helpers

- (NSString *)valueDisplayText {
    if (!self.rowDescriptor.value) {
        return self.rowDescriptor.noValueDisplayText;
    }
    if (self.rowDescriptor.valueTransformer) {
        NSAssert([self.rowDescriptor.valueTransformer isSubclassOfClass:[NSValueTransformer class]], @"valueTransformer is not a subclass of NSValueTransformer");
        NSValueTransformer *valueTransformer = [self.rowDescriptor.valueTransformer new];
        NSString *tranformedValue = [valueTransformer transformedValue:self.rowDescriptor.value];
        if (tranformedValue) {
            return tranformedValue;
        } else {
            return self.rowDescriptor.noValueDisplayText;
        }
    }
    return [self.rowDescriptor.value displayText];
}

// 当 control 成为第一响应者时的输入视图
- (UIView *)inputView {
    if ([self.rowDescriptor.rowType isEqualToString:HQLFormRowDescriptorTypeCityPickerView]) {
        return self.pickerView;
    }
    return [super inputView];
}

// 根据表单 value 值，反向选中选择器
- (void)selectedProvinceRowIndex {
    XLFormRowDescriptor *formRow = self.rowDescriptor;
    if (formRow.value && self.provinceManager.currentProvince) {
        NSInteger currentProvinceIndex = [self.provinceManager.provinces indexOfObject:self.provinceManager.currentProvince];
        [self.pickerView selectRow:currentProvinceIndex inComponent:0 animated:NO];
    }
}

- (void)selectCityRowIndex {
    XLFormRowDescriptor *formRow = self.rowDescriptor;
    if (formRow.value && self.provinceManager.currentCity) {
        NSInteger currentCityIndex = [self.provinceManager.currentProvince.children indexOfObject:self.provinceManager.currentCity];
        [self.pickerView selectRow:currentCityIndex inComponent:1 animated:NO];
    }
}

@end
