//
//  HQLProvinceManager.h
//  XLForm
//
//  Created by Qilin Hu on 2020/11/26.
//  Copyright © 2020 Xmartlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XLForm/XLFormRowDescriptor.h>

NS_ASSUME_NONNULL_BEGIN

@class HQLCity;
@class HQLProvince;


@interface HQLProvinceManager : NSObject <XLFormOptionObject>

@property (nonatomic, readonly, copy) NSArray<HQLProvince *> *provinces;
@property (nonatomic, readwrite, strong) HQLProvince *currentProvince;
@property (nonatomic, readwrite, strong) HQLCity *currentCity;

+ (instancetype)sharedManager;

- (void)setCurrentCityName:(NSString *)name;
- (void)setCurrentCityCode:(NSString *)code;

@end

NS_ASSUME_NONNULL_END
