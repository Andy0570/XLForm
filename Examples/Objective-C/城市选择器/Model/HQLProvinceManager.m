//
//  HQLProvinceManager.m
//  XLForm
//
//  Created by Qilin Hu on 2020/11/26.
//  Copyright © 2020 Xmartlabs. All rights reserved.
//

#import "HQLProvinceManager.h"
#import "HQLPropertyListStore.h"
#import "HQLProvince.h"

static NSString * const kJSONFileName = @"ProvinceCity.json";
static HQLProvinceManager *_sharedManager = nil;

@interface HQLProvinceManager ()
@property (nonatomic, readwrite, copy) NSArray<HQLProvince *> *provinces;
@end

@implementation HQLProvinceManager

#pragma mark - Initialize

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
        [_sharedManager loadProvinceData];
    });
    return _sharedManager;
}

#pragma mark - Public

- (void)setCurrentCityName:(NSString *)name {
    if (!name || [name isEqualToString:@""]) { return; }
    
    // 根据当前城市名称，找到所属省份
    [self.provinces enumerateObjectsUsingBlock:^(HQLProvince *currentProvince, NSUInteger idx, BOOL * _Nonnull stop) {
        [currentProvince.children enumerateObjectsUsingBlock:^(HQLCity *currentCity, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([currentCity.name isEqualToString:name]) {
                self.currentCity = currentCity;
                self.currentProvince = currentProvince;
                *stop = YES;
            }
        }];
    }];
}

- (void)setCurrentCityCode:(NSString *)code {
    if (!code || [code isEqualToString:@""]) { return; }
    
    // 根据当前城市代码找到所属省份
    [self.provinces enumerateObjectsUsingBlock:^(HQLProvince *currentProvince, NSUInteger idx, BOOL * _Nonnull stop) {
        [currentProvince.children enumerateObjectsUsingBlock:^(HQLCity *currentCity, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([currentCity.code isEqualToString:code]) {
                self.currentCity = currentCity;
                self.currentProvince = currentProvince;
                *stop = YES;
            }
        }];
    }];
}

#pragma mark - Private

- (void)loadProvinceData {
    HQLPropertyListStore *store = [[HQLPropertyListStore alloc] initWithJSONFileName:kJSONFileName modelsOfClass:HQLProvince.class];
    self.provinces = store.dataSourceArray;
    
    // 初始化并设置默认省份城市
    self.currentProvince = _provinces.firstObject;
    self.currentCity = _currentProvince.children.firstObject;
}

#pragma mark - XLFormOptionObject

// 显示在页面上的是城市中文名
// 如果对象遵守 XLFormOptionObject 协议，XLForm 从 formDisplayText 方法中得到要显示的值。
-(nonnull NSString *)formDisplayText {
    return [NSString stringWithFormat:@"%@，%@",_currentProvince.name, _currentCity.name];
}

// 提交时传的参数是城市代码
-(nonnull id)formValue {
    return @{
        @"citycode":_currentCity.code,
        @"cityname":_currentCity.name
    };
}

@end
