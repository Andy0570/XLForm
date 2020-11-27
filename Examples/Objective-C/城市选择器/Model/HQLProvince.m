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
        @"area"       : @"area",
        @"code"       : @"code",
        @"first_char" : @"first_char",
        @"ID"         : @"id",
        @"listorder"  : @"listorder",
        @"name"       : @"name",
        @"parentid"   : @"parentid",
        @"pinyin"     : @"pinyin",
        @"region"     : @"region"
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
