//
//  HQLFormInlineDateCell.h
//  XLForm
//
//  Created by Qilin Hu on 2020/11/27.
//  Copyright © 2020 Xmartlabs. All rights reserved.
//

#import <XLForm/XLForm.h>

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSString *const HQLFormRowDescriptorTypeInlineDateCell;
UIKIT_EXTERN NSString *const HQLFormRowDescriptorTypeInlineDatePicker;

/// 内嵌年月选择器，只能选择年月，不能选择日
@interface HQLFormInlineDateCell : XLFormBaseCell
@end

@interface HQLFormDatePickerControl : XLFormBaseCell <XLFormInlineRowDescriptorCell>
@property (nonatomic, strong, readonly) UIPickerView *pickerView;
@end

NS_ASSUME_NONNULL_END
