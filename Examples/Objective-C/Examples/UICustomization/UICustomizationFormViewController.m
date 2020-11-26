//
//  UICustomizationFormViewController.m
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
#import "UICustomizationFormViewController.h"
#import <JKCategories/UIView+JKToast.h>

@implementation UICustomizationFormViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        XLFormDescriptor * form = [XLFormDescriptor formDescriptorWithTitle:@"UI Customization"];
        XLFormSectionDescriptor * section;
        XLFormRowDescriptor * row;
        
        
        // Section
        section = [XLFormSectionDescriptor formSection];
        [form addFormSection:section];
        
        // 姓名
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"Name" rowType:XLFormRowDescriptorTypeText title:@"姓名"];
        // textLabel 背景色
        [row.cellConfigAtConfigure setObject:[UIColor greenColor] forKey:@"backgroundColor"];
        // textLabel 字体
        [row.cellConfig setObject:[UIFont fontWithName:@"Helvetica" size:30] forKey:@"textLabel.font"];
        // textField 背景色
        [row.cellConfig setObject:[UIColor grayColor] forKey:@"textField.backgroundColor"];
        // textField 字体
        [row.cellConfig setObject:[UIFont fontWithName:@"Helvetica" size:25] forKey:@"textField.font"];
        // textField 对齐方式：右对齐
        [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
        [section addFormRow:row];
        
        
        // Section
        section = [XLFormSectionDescriptor formSection];
        [form addFormSection:section];
        
        // 按钮
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"Button" rowType:XLFormRowDescriptorTypeButton title:@"按钮"];
        // 按钮背景色
        [row.cellConfigAtConfigure setObject:[UIColor purpleColor] forKey:@"backgroundColor"];
        // 按钮文字颜色
        [row.cellConfig setObject:[UIColor whiteColor] forKey:@"textLabel.color"];
        // 按钮字体
        [row.cellConfig setObject:[UIFont fontWithName:@"Helvetica" size:40] forKey:@"textLabel.font"];
        [section addFormRow:row];
        
        
        // Section
        section = [XLFormSectionDescriptor formSection];
        [form addFormSection:section];
        
        // 确定按钮
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"Button2" rowType:XLFormRowDescriptorTypeButton title:@"提交"];
        // 蓝色背景
        UIColor *backgroundColor = [UIColor colorWithRed:16/255.0 green:142/255.0 blue:233/255.0 alpha:1.0];
        [row.cellConfigAtConfigure setObject:backgroundColor forKey:@"backgroundColor"];
        // 按钮文字颜色：白色
        [row.cellConfig setObject:UIColor.whiteColor forKey:@"textLabel.color"];
        [row.cellConfig setObject:[UIFont fontWithName:@"Helvetica" size:18] forKey:@"textLabel.font"];
        row.action.formSelector = @selector(didTouchButton:);
        [section addFormRow:row];
        
        
        // Section
        section = [XLFormSectionDescriptor formSection];
        [form addFormSection:section];
        
        // 退出登录
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"lagoutButtono" rowType:XLFormRowDescriptorTypeButton title:@"退出登录"];
        [row.cellConfigAtConfigure setObject:UIColor.systemRedColor forKey:@"textLabel.color"];
        row.action.formSelector = @selector(didTouchButton:);
        [section addFormRow:row];
        
        self.form = form;
    }
    return self;
}


// 修改cell高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // change cell height of a particular cell
    if ([[self.form formRowAtIndex:indexPath].tag isEqualToString:@"Name"]) {
        return 60.0;
    } else if ([[self.form formRowAtIndex:indexPath].tag isEqualToString:@"Button"]) {
        return 100.0;
    } else if ([[self.form formRowAtIndex:indexPath].tag isEqualToString:@"Button2"]) {
        return 55.0f;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

#pragma mark - IBActions

-(void)didTouchButton:(XLFormRowDescriptor *)sender {
    [self deselectFormRow:sender];
    
    [self.navigationController.view jk_makeToast:@"Tapped Button"];
}

@end
