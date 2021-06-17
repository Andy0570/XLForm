//
//  XLEditAddressFormViewController.h
//  SeaTao
//
//  Created by Qilin Hu on 2021/5/12.
//  Copyright © 2021 Shanghai Haidian Information Technology Co.Ltd. All rights reserved.
//

#import "XLFormViewController.h"
@class HQLAddress;

NS_ASSUME_NONNULL_BEGIN

/// 编辑收货地址
@interface XLEditAddressFormViewController : XLFormViewController

- (instancetype)initWithAddress:(HQLAddress *)address;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
