//
//  HQLProvincePickViewViewController.m
//  XLForm
//
//  Created by Qilin Hu on 2020/11/26.
//  Copyright © 2020 Xmartlabs. All rights reserved.
//

#import "HQLProvincePickViewViewController.h"
#import "HQLProvince.h"
#import "HQLProvinceManager.h"

@interface HQLProvincePickViewViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (nonatomic, strong) HQLProvinceManager *provinceManager;

@end

@implementation HQLProvincePickViewViewController

// 遵守 <XLFormRowDescriptorViewController> 协议需要实现的属性
@synthesize rowDescriptor = _rowDescriptor;

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"选择省份城市";
    self.provinceManager = [HQLProvinceManager sharedManager];
}

#pragma mark - UIPickerViewDataSource

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (component) {
        case 0: {
            // 返回省份个数
            return _provinceManager.provinces.count;
            break;
        }
        case 1: {
            // 返回当前省份的城市数
            return _provinceManager.currentProvince.children.count;
            break;
        }
        default:
            return 0;
            break;
    }
}

#pragma mark - UIPickerViewDelegate

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (component) {
        case 0: {
            // 第一列返回省份名字
            HQLProvince *province = (HQLProvince *)_provinceManager.provinces[row];
            return province.name;
            break;
        }
        case 1: {
            // 第二列返回城市名字
            HQLCity *city = (HQLCity *)_provinceManager.currentProvince.children[row];
            return city.name;
            break;
        }
        default:
            return nil;
            break;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    switch (component) {
        case 0: {
            _provinceManager.currentProvince = (HQLProvince *)_provinceManager.provinces[row];
            _provinceManager.currentCity = (HQLCity *)_provinceManager.currentProvince.children.firstObject;
            [pickerView reloadComponent:1];
            break;
        }
        case 1: {
            _provinceManager.currentCity = (HQLCity *)_provinceManager.currentProvince.children[row];
            break;
        }
        default:
            break;
    }
    
    // !!!: 回传数据
    self.rowDescriptor.value = [NSString stringWithFormat:@"%@，%@",_provinceManager.currentProvince.name, _provinceManager.currentCity.name];
}

@end
