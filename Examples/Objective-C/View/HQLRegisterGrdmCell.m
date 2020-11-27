//
//  HQLRegisterGrdmCell.m
//  XuZhouSS
//
//  Created by Qilin Hu on 2017/11/6.
//  Copyright © 2017年 ToninTech. All rights reserved.
//

#import "HQLRegisterGrdmCell.h"

// Framework
#import <Masonry.h>

NSString * const XLFormRowDescriptorTypeRegisterGrdmCell = @"XLFormRowDescriptorTypeRegisterGrdmCell";

@interface HQLRegisterGrdmCell () <UITextFieldDelegate>

// 标记位：描述是否已经添加了按钮的 Target
// 因为每次 update 都会执行 addTarget... 操作，会存在向视图控制器添加两遍 Target 的 bug！
@property (nonatomic, getter=hadAddButtonTarget) BOOL addButtonTarget;

@end

@implementation HQLRegisterGrdmCell

@synthesize textLabel = _textLabel;
@synthesize textField = _textField;
@synthesize returnKeyType = _returnKeyType;
@synthesize nextReturnKeyType = _nextReturnKeyType;

#pragma mark - Lifecycle

- (void)dealloc {
    [self.textLabel removeObserver:self forKeyPath:@"text"];
}

+ (void)load {
    // 添加行定义信息到 cellClassesForRowDescriptorTypes 字典中让 XLForm 知道。
    // key = 自定义的常量字符串, value = 类名
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[HQLRegisterGrdmCell class] forKey:XLFormRowDescriptorTypeRegisterGrdmCell];
}

#pragma mark - XLFormDescriptorCell

// 初始化所有对象，例如数组、UIControls 等等
- (void)configure {
    [super configure];
    
    self.returnKeyType = UIReturnKeyDone;
    self.nextReturnKeyType = UIReturnKeyNext;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // 设置输入人员识别号最大字符数，默认 20 个字符
    self.textFieldMaxNumberOfCharacters = @20;
    
    // 初始化时，默认还没有添加按钮点击事件
    self.addButtonTarget = NO;
    
    [self.contentView addSubview:self.textLabel];
    [self.contentView addSubview:self.textField];
    [self.contentView addSubview:self.button];
    [self autoLayout];
    [self.textLabel addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:0];
    [self.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

// 当cell将要显示时，更新cell
- (void)update {
    [super update];
    
    if (self.rowDescriptor.title) {
        self.textLabel.text = self.rowDescriptor.title;
    }
    
    // button Target-Action
    // 💡 设置按钮点击事件，通过 self.rowDescriptor.action.formSelector 触发
    if (self.rowDescriptor.action.formSelector && !self.hadAddButtonTarget) {
        [self.button addTarget:self.formViewController
                        action:self.rowDescriptor.action.formSelector
              forControlEvents:UIControlEventTouchUpInside];
        
        // 标记已添加按钮点击事件
        self.addButtonTarget = YES;
    }
    
    [self.textField setEnabled:!self.rowDescriptor.isDisabled];
    self.textField.textColor = self.rowDescriptor.isDisabled ? [UIColor grayColor] : [UIColor blackColor];
    self.textField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

// 是否能成为第一响应者
-(BOOL)formDescriptorCellCanBecomeFirstResponder {
    return (!self.rowDescriptor.isDisabled);
}

// 将相应的 UIView 指派为第一响应者
-(BOOL)formDescriptorCellBecomeFirstResponder {
    return [self.textField becomeFirstResponder];
}

// 当 cell 成为第一响应者时被调用，可以用于改变cell成为第一响应者时的呈现样式。
-(void)highlight {
    [super highlight];
    
    // 改变标题的颜色，默认黑色，当用户正在输入时，当前标题颜色变为绿色
    self.textLabel.textColor = self.tintColor;
}

// 当 cell 放弃第一响应者时被调用
-(void)unhighlight {
    [super unhighlight];
    [self.formViewController updateFormRow:self.rowDescriptor];
}

#pragma mark - Custom Accessors

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [UILabel autolayoutView];
        _textLabel.text = @"人员识别号";
    }
    return _textLabel;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [UITextField autolayoutView];
        _textField.placeholder = @"社会保障卡人员识别号";
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.keyboardType = UIKeyboardTypeDefault;
        _textField.autocorrectionType = UITextAutocorrectionTypeNo;
        _textField.delegate = self;
    }
    return _textField;
}

- (UIButton *)button {
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    return _button;
}

#pragma mark - Private

- (void)autoLayout {
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).with.offset(15);
        make.centerY.equalTo(self.contentView);
        make.width.mas_equalTo(90);
    }];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.textLabel.mas_right).with.offset(8);
        make.centerY.equalTo(self.contentView);
    }];
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.textField.mas_right).with.offset(6);
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).with.offset(-20);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
}

- (void)textFieldDidChange:(UITextField *)textField{
    if([self.textField.text length] > 0) {
        BOOL didUseFormatter = NO;
        
        if (self.rowDescriptor.valueFormatter && self.rowDescriptor.useValueFormatterDuringInput)
        {
            // use generic getObjectValue:forString:errorDescription and stringForObjectValue
            NSString *errorDescription = nil;
            NSString *objectValue = nil;
            
            if ([ self.rowDescriptor.valueFormatter getObjectValue:&objectValue forString:textField.text errorDescription:&errorDescription]) {
                NSString *formattedValue = [self.rowDescriptor.valueFormatter stringForObjectValue:objectValue];
                
                self.rowDescriptor.value = objectValue;
                textField.text = formattedValue;
                didUseFormatter = YES;
            }
        }
        
        // only do this conversion if we didn't use the formatter
        if (!didUseFormatter)
        {
            if ([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeNumber] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDecimal]){
                self.rowDescriptor.value =  [NSDecimalNumber decimalNumberWithString:self.textField.text locale:NSLocale.currentLocale];
            } else if ([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeInteger]){
                self.rowDescriptor.value = @([self.textField.text integerValue]);
            } else {
                self.rowDescriptor.value = self.textField.text;
            }
        }
    } else {
        self.rowDescriptor.value = nil;
    }
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.textLabel && [keyPath isEqualToString:@"text"]){
        if ([[change objectForKey:NSKeyValueChangeKindKey] isEqualToNumber:@(NSKeyValueChangeSetting)]){
            [self.contentView setNeedsUpdateConstraints];
        }
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return [self.formViewController textFieldShouldClear:textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [self.formViewController textFieldShouldReturn:textField];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return [self.formViewController textFieldShouldBeginEditing:textField];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return [self.formViewController textFieldShouldEndEditing:textField];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (self.textFieldMaxNumberOfCharacters) {
        // Check maximum length requirement
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if (newString.length > self.textFieldMaxNumberOfCharacters.integerValue) {
            return NO;
        }
    }
    
    // Otherwise, leave response to view controller
    return [self.formViewController textField:textField shouldChangeCharactersInRange:range replacementString:string];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.formViewController beginEditing:self.rowDescriptor];
    [self.formViewController textFieldDidBeginEditing:textField];
    // set the input to the raw value if we have a formatter and it shouldn't be used during input
    if (self.rowDescriptor.valueFormatter) {
        self.textField.text = [self.rowDescriptor editTextValue];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // process text change before we stick a formatted value in the UITextField
    [self textFieldDidChange:textField];
    
    // losing input, replace the text field with the formatted value
    if (self.rowDescriptor.valueFormatter) {
        self.textField.text = [self.rowDescriptor.value displayText];
    }
    
    [self.formViewController endEditing:self.rowDescriptor];
    [self.formViewController textFieldDidEndEditing:textField];
}

#pragma mark - XLFormReturnKeyProtocol

-(void)setReturnKeyType:(UIReturnKeyType)returnKeyType
{
    _returnKeyType = returnKeyType;
    self.textField.returnKeyType = returnKeyType;
}

-(UIReturnKeyType)returnKeyType
{
    return _returnKeyType;
}

@end
