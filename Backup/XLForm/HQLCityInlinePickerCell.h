//
//  HQLCityInlinePickerCell.h
//  XLForm
//
//  Created by Qilin Hu on 2020/11/26.
//  Copyright © 2020 Xmartlabs. All rights reserved.
//

#import <XLForm/XLForm.h>

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSString *const HQLFormRowDescriptorTypeCityInlinePickerCell;
UIKIT_EXTERN NSString *const HQLFormRowDescriptorTypeCityInlinePickerControl;

/**
 城市选择器，内嵌样式
 
 技术栈：
 1. 通过 Mantle 框架创建城市模型（HQLCity）和省份模型（HQLProvince）：
 2. 通过 HQLProvinceManager 对象管理城市模型数据；
 3. 通过 HQLPropertyListStore 类加载 json 数据，该 json 数据中包含所有省份城市；
 */
@interface HQLCityInlinePickerCell : XLFormBaseCell

@end

/// 城市选择器 Pick View
@interface HQLCityInlinePickerControl : XLFormBaseCell <XLFormInlineRowDescriptorCell>

@end

NS_ASSUME_NONNULL_END
