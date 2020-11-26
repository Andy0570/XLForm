//
//  HQLProvince.h
//  XLForm
//
//  Created by Qilin Hu on 2020/11/26.
//  Copyright © 2020 Xmartlabs. All rights reserved.
//

#import <Mantle.h>

NS_ASSUME_NONNULL_BEGIN

/// 城市模型
@interface HQLCity : MTLModel <MTLJSONSerializing>
@property (nonatomic, readonly, copy) NSString *code;
@property (nonatomic, readonly, copy) NSString *name;
@end

/// 省份模型
@interface HQLProvince : MTLModel <MTLJSONSerializing>
@property (nonatomic, readonly, copy) NSString *code;
@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly, copy) NSArray<HQLCity *> *children;
@end

NS_ASSUME_NONNULL_END
