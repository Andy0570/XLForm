//
//  XLFormInlineSegmentedCell.h
//  XLForm
//
//  Created by mathias Claassen on 16/12/15.
//  Copyright © 2015 Xmartlabs. All rights reserved.
//

#import <XLForm/XLForm.h>

extern NSString * const XLFormRowDescriptorTypeSegmentedInline;
extern NSString * const XLFormRowDescriptorTypeSegmentedControl;

/// 内嵌分段cell
@interface XLFormInlineSegmentedCell : XLFormBaseCell
@end

/// 分段cell选择控制器
@interface XLFormInlineSegmentedControl : XLFormBaseCell<XLFormInlineRowDescriptorCell>
@property (strong, nonatomic) UISegmentedControl* segmentedControl;
@end
