//
//  HQLRegisterGrdmCell.h
//  XuZhouSS
//
//  Created by Qilin Hu on 2017/11/6.
//  Copyright © 2017年 ToninTech. All rights reserved.
//

#import <XLForm/XLForm.h>
#import <UIKit/UIKit.h>

extern NSString * const XLFormRowDescriptorTypeRegisterGrdmCell;

/**
 自定义 XLForm Cell，输入人员识别号cell，添加查看示例Button
 */
@interface HQLRegisterGrdmCell : XLFormBaseCell <XLFormReturnKeyProtocol>

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *button; // 查看示例按钮

@property (nonatomic) NSNumber *textFieldMaxNumberOfCharacters; // 标准12位，设置为最大20位

@end
