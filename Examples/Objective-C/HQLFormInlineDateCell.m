//
//  HQLFormInlineDateCell.m
//  XLForm
//
//  Created by Qilin Hu on 2020/11/27.
//  Copyright © 2020 Xmartlabs. All rights reserved.
//

#import "HQLFormInlineDateCell.h"
#import <JKCategories/NSDate+JKExtension.h>
#import <JKCategories/NSDate+JKFormatter.h>

NSString *const HQLFormRowDescriptorTypeInlineDateCell = @"HQLFormInlineDateCell";
NSString *const HQLFormRowDescriptorTypeInlineDatePicker = @"HQLFormDatePickerControl";

@implementation HQLFormInlineDateCell {
    UIColor *_beforeChangeColor;
}

+ (void)load {
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:HQLFormInlineDateCell.class forKey:HQLFormRowDescriptorTypeInlineDateCell];
    [XLFormViewController.inlineRowDescriptorTypesForRowDescriptorTypes setObject:HQLFormRowDescriptorTypeInlineDatePicker forKey:HQLFormRowDescriptorTypeInlineDateCell];
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
        // 创建并添加年月选择器行
        XLFormRowDescriptor *inlineRowDescriptor = [XLFormRowDescriptor formRowDescriptorWithTag:nil rowType:[XLFormViewController inlineRowDescriptorTypesForRowDescriptorTypes] [self.rowDescriptor.rowType]];
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

// 初始化所有对象，例如数组、UIControls 等等
- (void)configure {
    [super configure];
}

// 当cell将要显示时，更新cell
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
    return !(self.rowDescriptor.isDisabled);
}

// 将相应的 UIView 指派为第一响应者
-(BOOL)formDescriptorCellBecomeFirstResponder {
    if ([self isFirstResponder]){
        [self resignFirstResponder];
        return NO;
    }
    return [self becomeFirstResponder];
}

// 当cell被选中时调用
-(void)formDescriptorCellDidSelectedWithFormController:(XLFormViewController *)controller {
    [controller.tableView deselectRowAtIndexPath:[controller.form indexPathOfFormRow:self.rowDescriptor] animated:YES];
}

// 当cell成为第一响应者时被调用，可以用于改变cell成为第一响应者时的呈现样式。
-(void)highlight {
    [super highlight];
    self.detailTextLabel.textColor = self.tintColor; // detail 高亮为蓝色，默认灰色
}

// 当cell放弃第一响应者时被调用
-(void)unhighlight {
    [super unhighlight];
    self.detailTextLabel.textColor = _beforeChangeColor; // detail 设置为灰色
}

#pragma mark - Helpers

-(NSString *)valueDisplayText {
    return (self.rowDescriptor.value ? [self.rowDescriptor.value displayText] : self.rowDescriptor.noValueDisplayText);
}

@end


@interface HQLFormDatePickerControl () <UIPickerViewDataSource, UIPickerViewDelegate> {
    NSInteger _yearIndex;
    NSInteger _monthIndex;
}

@property (nonatomic, strong, readwrite) NSArray *years;
@property (nonatomic, strong, readwrite) NSArray *months;
@property (nonatomic, strong, readwrite) NSDate *minimumDate;
@property (nonatomic, strong, readwrite) NSDate *maximumDate;

@end

@implementation HQLFormDatePickerControl

@synthesize pickerView = _pickerView;
@synthesize inlineRowDescriptor = _inlineRowDescriptor;

+ (void)load {
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:HQLFormDatePickerControl.class forKey:HQLFormRowDescriptorTypeInlineDatePicker];
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
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
    }
    return _pickerView;
}

- (NSArray *)years {
    if (!_years) {
        NSMutableArray *mutableYears = [NSMutableArray array];
        NSInteger minYear = self.minimumDate.jk_year;
        NSInteger maxYear = self.maximumDate.jk_year;
        for (NSInteger i = minYear; i <= maxYear; i++) {
            NSNumber *num = [NSNumber numberWithInteger:i];
            [mutableYears addObject:num];
        }
        _years = [mutableYears copy];
    }
    return _years;
}

- (NSArray *)months {
    if (!_months) {
        NSMutableArray *mutableMouths = [NSMutableArray arrayWithCapacity:12];
        for (NSInteger i = 1; i <= 12; i++) {
            NSNumber *num = [NSNumber numberWithInteger:i];
            [mutableMouths addObject:num];
        }
        _months = [mutableMouths copy];
    }
    return _months;
}

#pragma mark - XLFormDescriptorCell

- (void)configure {
    [super configure];
    
    [self.contentView addSubview:self.pickerView];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.pickerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[pickerView]-0-|" options:0 metrics:0 views:@{@"pickerView" : self.pickerView}]];
    
    if (!self.minimumDate) {
        self.minimumDate = [NSDate jk_dateWithString:@"199601" format:@"yyyyMM"];
    }
    if (!self.maximumDate) {
        self.maximumDate = [NSDate date];
    }
}

- (void)update {
    [super update];
    
    BOOL isDisable = self.rowDescriptor.isDisabled;
    self.userInteractionEnabled = !isDisable;
    self.contentView.alpha = isDisable ? 0.5 : 1.0;
    
    // 根据cell上的value值反向选中年月选择器
    _yearIndex = [self selectedYearIndex];
    _monthIndex = [self selectedMonthIndex];
    [self.pickerView selectRow:_yearIndex inComponent:0 animated:NO];
    [self.pickerView selectRow:_monthIndex inComponent:1 animated:NO];
    [self.pickerView reloadAllComponents];
}

+ (CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {
    return 216.0f;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return self.years.count;
    } else {
        return self.months.count;
    }
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        return [NSString stringWithFormat:@"%@年",self.years[row]];
    } else {
        return [NSString stringWithFormat:@"%@月",self.months[row]];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {

    if (component == 0) {
        _yearIndex = row;
    } else {
        _monthIndex = row;
    }
    
    // 格式化年月，并返回
    NSUInteger selectedYear = [(NSNumber *)self.years[_yearIndex] unsignedIntegerValue];
    NSUInteger selectedMonth = [(NSNumber *)self.months[_monthIndex] unsignedIntegerValue];
    NSString *resultString = [NSString stringWithFormat:@"%ld%02ld",selectedYear,selectedMonth];
    
    if (self.inlineRowDescriptor) {
        self.inlineRowDescriptor.value = resultString;
        [self.formViewController updateFormRow:self.inlineRowDescriptor];
    }
}

#pragma mark - helpers

// 根据表单value值，反向选中选择器
- (NSInteger)selectedYearIndex {
    XLFormRowDescriptor *formRow = (self.inlineRowDescriptor ? : self.rowDescriptor);
    if (formRow.value) {
        NSDate *selectedDate = [NSDate jk_dateWithString:formRow.value format:@"yyyyMM"];
        NSNumber *selectedYear = [NSNumber numberWithUnsignedInteger:selectedDate.jk_year];
        for (NSNumber *indexYear in self.years) {
            if ([indexYear isEqualToNumber:selectedYear]) {
                return [self.years indexOfObject:indexYear];
            }
        }
    }
    return 0;
}

- (NSInteger)selectedMonthIndex {
    XLFormRowDescriptor *formRow = (self.inlineRowDescriptor ? : self.rowDescriptor);
    if (formRow.value) {
        NSDate *selectedDate = [NSDate jk_dateWithString:formRow.value format:@"yyyyMM"];
        NSNumber *selectedMouth = [NSNumber numberWithUnsignedInteger:selectedDate.jk_month];
        for (NSNumber *indexMouth in self.months){
            if ([indexMouth isEqualToNumber:selectedMouth]) {
                return [self.months indexOfObject:indexMouth];
            }
        }
    }
    return 0;
}

@end
