//
//  HQLVerificationCodeCell.h
//  XuZhouSS
//
//  Created by Qilin Hu on 2017/10/30.
//  Copyright © 2017年 ToninTech. All rights reserved.
//

#import <XLForm/XLForm.h>
#include <UIKit/UIKit.h>

extern NSString * const XLFormRowDescriptorTypeVerificationCodeCell;

/**
 自定义 XLForm Cell，获取并输入短信验证码
 */
@interface HQLVerificationCodeCell : XLFormBaseCell <XLFormReturnKeyProtocol>

@property (nonatomic, readonly) UILabel *textLabel;
@property (nonatomic, readonly) UITextField *textField;
@property (nonatomic, strong) UIButton *button; // 获取验证码按钮

// 最大输入的字符数，默认设置为 6 个。
@property (nonatomic) NSNumber *textFieldMaxNumberOfCharacters;

@end
