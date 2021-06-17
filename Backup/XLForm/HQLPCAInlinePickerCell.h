//
//  HQLPCAInlinePickerCell.h
//  SeaTao
//
//  Created by Qilin Hu on 2021/4/26.
//  Copyright © 2021 Shanghai Haidian Information Technology Co.Ltd. All rights reserved.
//

#import <XLForm/XLForm.h>

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSString *const HQLFormRowDescriptorTypePCAInlinePickerCell;
UIKIT_EXTERN NSString *const HQLFormRowDescriptorTypePCAInlinePickerControl;

@interface HQLPCAInlinePickerCell : XLFormBaseCell

@end

/// 省份城市区域选择器 Pick View
@interface HQLPCAInlinePickerControl : XLFormBaseCell <XLFormInlineRowDescriptorCell>

@end

NS_ASSUME_NONNULL_END
