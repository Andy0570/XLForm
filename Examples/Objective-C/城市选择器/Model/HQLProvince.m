//
//  HQLProvince.m
//  XLForm
//
//  Created by Qilin Hu on 2020/11/26.
//  Copyright © 2020 Xmartlabs. All rights reserved.
//

#import "HQLProvince.h"

@implementation HQLCity

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @"code" : @"code",
        @"name" : @"name"
    };
}

@end

@implementation HQLProvince

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @"code"     : @"code",
        @"name"     : @"name",
        @"children" : @"children"
    };
}

// children
// MARK: JSON Array <——> NSArray<Model>
+ (NSValueTransformer *)childrenJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:HQLCity.class];
}

@end
