//
//  InputsFormViewController.m
//  XLForm ( https://github.com/xmartlabs/XLForm )
//
//  Copyright (c) 2015 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "XLForm.h"
#import "InputsFormViewController.h"
#import <SHSPhoneLibrary.h>


NSString *const kName = @"name";
NSString *const kEmail = @"email";
NSString *const kTwitter = @"twitter";
NSString *const kZipCode = @"zipCode";
NSString *const kNumber = @"number";
NSString *const kInteger = @"integer";
NSString *const kDecimal = @"decimal";
NSString *const kPassword = @"password";
NSString *const kPhone = @"phone";
NSString *const kUrl = @"url";
NSString *const kTextView = @"textView";
NSString *const kNotes = @"notes";


@implementation InputsFormViewController

-(id)init
{
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Text Fields"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    // Basic Information - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"TextField 类型"];
    section.footerTitle = @"这是一段可以显示在section底部的长文本";
    [formDescriptor addFormSection:section];
    
    // Name
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName rowType:XLFormRowDescriptorTypeText title:@"姓名"];
    // MARK: 设置文本输入框的宽度在整行中的百分比为 60%
    [row.cellConfigAtConfigure setObject:[NSNumber numberWithFloat:0.6] forKey:XLFormTextFieldLengthPercentage];
    row.required = YES;
    [section addFormRow:row];
    
    // Email
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEmail rowType:XLFormRowDescriptorTypeEmail title:@"Email"];
    // validate the email
    [row addValidator:[XLFormValidator emailValidator]];
    [section addFormRow:row];
    
    // Twitter
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kTwitter rowType:XLFormRowDescriptorTypeTwitter title:@"Twitter"];
    row.disabled = @YES;
    row.value = @"row.disabled = @YES";
    [section addFormRow:row];
    
    // Zip Code
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kZipCode rowType:XLFormRowDescriptorTypeZipCode title:@"邮编"];
    [section addFormRow:row];

    // Number
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNumber rowType:XLFormRowDescriptorTypeNumber title:@"Number"];
    [section addFormRow:row];
    
    // Integer，整数
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kInteger rowType:XLFormRowDescriptorTypeInteger title:@"Integer"];
    [section addFormRow:row];
	
    // Decimal，十进制，带小数点
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDecimal rowType:XLFormRowDescriptorTypeDecimal title:@"Decimal"];
    [section addFormRow:row];
    
    // Password
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPassword rowType:XLFormRowDescriptorTypePassword title:@"Password"];
    [section addFormRow:row];
    
    // Phone
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPhone rowType:XLFormRowDescriptorTypePhone title:@"Phone"];
    // MARK: 默认左对齐，你可以设置为右对齐
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    // MARK: 设置占位符文本
    [row.cellConfig setObject:@"请输入手机号码" forKey:@"textField.placeholder"];
    // MARK: 正则表达式验证
    row.required = YES;
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"手机号码格式错误" regex:@"^1(3|4|5|7|8)\\d{9}$"]];
    // MARK: 格式化显示电话号码 (135 1673 0641)
    // 通过 SHSPhoneComponent 框架实现
    SHSPhoneNumberFormatter *formatter = [[SHSPhoneNumberFormatter alloc] init];
    [formatter setDefaultOutputPattern:@"### #### ####"];
    row.valueFormatter = formatter;
    [section addFormRow:row];
    
    // Url
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kUrl rowType:XLFormRowDescriptorTypeURL title:@"Url"];
    [section addFormRow:row];
    
    
    section = [XLFormSectionDescriptor formSection];
    [formDescriptor addFormSection:section];
    
    // TextView 示例一
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kTextView rowType:XLFormRowDescriptorTypeTextView];
    [row.cellConfigAtConfigure setObject:@"Text View 占位符文本" forKey:@"textView.placeholder"];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"带 label 的 Text View 示例"];
    [formDescriptor addFormSection:section];
    
    // TextView 示例二
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNotes rowType:XLFormRowDescriptorTypeTextView title:@"Notes"];
    // MARK: 设置限制最大输入字符数
    [row.cellConfigAtConfigure setObject:@(20) forKey:@"textViewMaxNumberOfCharacters"];
    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
    
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(savePressed:)];
    
    // MARK: 初始化显示表单时放弃第一响应者，即不显示键盘
    self.form.assignFirstResponderOnShow = NO;
}


-(void)savePressed:(UIBarButtonItem * __unused)button
{
    // 表单验证
    NSArray * validationErrors = [self formValidationErrors];
    if (validationErrors.count > 0){
        [self showFormValidationError:[validationErrors firstObject]];
        return;
    }
    [self.tableView endEditing:YES];
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Valid Form", nil) message:@"No errors found" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
