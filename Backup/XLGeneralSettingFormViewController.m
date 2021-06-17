//
//  XLGeneralSettingFormViewController.m
//  SeaTao
//
//  Created by Qilin Hu on 2020/7/30.
//  Copyright © 2020 Shanghai Haidian Information Technology Co.Ltd. All rights reserved.
//

#import "XLGeneralSettingFormViewController.h"

static NSString *const KVideoSetting = @"VideoSetting";
static NSString *const KCleanCache = @"CleanCache";

static const CGFloat KRowHeight = 55.0f;

@interface XLGeneralSettingFormViewController () <XLFormDescriptorDelegate>
@end

@implementation XLGeneralSettingFormViewController

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
    }
}

#pragma mark - Initialize

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        [self initializeForm];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self){
        [self initializeForm];
    }
    return self;
}

- (void)initializeForm {
    XLFormDescriptor *form = [XLFormDescriptor formDescriptorWithTitle:@"通用设置"];
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"视频设置"];
    [form addFormSection:section];
    
    // 视频设置
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KVideoSetting rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"只在Wi-Fi下自动播放视频"];
    row.value = [NSNumber numberWithBool:[NSUserDefaults jk_boolForKey:KVideoSetting]];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    // 清除缓存
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KCleanCache rowType:XLFormRowDescriptorTypeButton title:@"清除缓存"];
    // 设置了文本对齐方式和辅助箭头
    [row.cellConfig setObject:@(NSTextAlignmentNatural) forKey:@"textLabel.textAlignment"];
    [row.cellConfig setObject:[UIColor blackColor] forKey:@"textLabel.textColor"];
    [row.cellConfig setObject:@(UITableViewCellAccessoryDisclosureIndicator) forKey:@"accessoryType"];
    __weak __typeof(self)weakSelf = self;
    row.action.formBlock = ^(XLFormRowDescriptor * _Nonnull sender) {
        [weakSelf showCleanCacheAlertController];
    };
    [section addFormRow:row];
    
    self.form = form;
}

#pragma mark - Private

// 清除缓存弹窗
- (void)showCleanCacheAlertController {
    //  1.实例化UIAlertController对象
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认清除缓存"
                                                                   message:[NSString stringWithFormat:@"当前缓存大小：%@", [self getCacheSize]]
                                                            preferredStyle:UIAlertControllerStyleAlert];

    //  2.1实例化UIAlertAction按钮:取消按钮
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alert addAction:cancelAction];

    //  2.2实例化UIAlertAction按钮:确定按钮
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"确定"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
        [self cleanCache];
        [self.view makeToast:@"清除缓存成功" duration:0.5 position:CSToastPositionCenter];
                                                          }];
    [alert addAction:defaultAction];

    //  3.显示alertController
    [self presentViewController:alert animated:YES completion:nil];
}

// 获取并计算缓存大小
- (NSString *)getCacheSize {
    CGFloat size = 0;
    // 确定缓存文件夹是否存在
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cachesPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    BOOL fileExists = [fileManager fileExistsAtPath:cachesPath];
    if (fileExists) {
        // 遍历文件夹中的文件，并计算指定文件占用内存大小
        NSArray *childFile = [fileManager subpathsAtPath:cachesPath];
        for (NSString *subPath in childFile) {
            NSString *filePath = [cachesPath stringByAppendingPathComponent:subPath];
            //获得文件的属性字典
            NSDictionary *fileAttribute = [fileManager attributesOfItemAtPath:filePath error:nil];
            size += fileAttribute.fileSize;
        }
        
        // 添加 SDWebImage 的缓存
        float diskCacheSize = [[SDImageCache sharedImageCache] totalDiskSize];
        size += diskCacheSize;
    }
    return [NSString stringWithFormat:@"%.2fM", size / 1024 / 1024];
}

// 清除缓存
- (void)cleanCache {
    // 确定缓存文件夹是否存在
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cachesPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    BOOL fileExists = [fileManager fileExistsAtPath:cachesPath];
    if (fileExists) {
        // 遍历文件夹中的文件，逐个删除缓存文件
        NSArray *childFile = [fileManager subpathsAtPath:cachesPath];
        for (NSString *subPath in childFile) {
            NSString *filePath = [cachesPath stringByAppendingPathComponent:subPath];
            NSError *error = nil;
            BOOL isRemoveItemSucceed = [fileManager removeItemAtPath:filePath error:&error];
            if (!isRemoveItemSucceed) {
                DDLogDebug(@"Remove cache file failure.\n%@",error);
            }
            // 删除 SDWebImage 的缓存
            [[SDImageCache sharedImageCache] clearMemory];
        }
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return KRowHeight;
}

#pragma mark - <XLFormDescriptorDelegate>

-(void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue {
    [super formRowDescriptorValueHasChanged:formRow oldValue:oldValue newValue:newValue];
    
    if ([formRow.tag isEqualToString:KVideoSetting]) {
        NSNumber *boolValue = [NSNumber numberWithBool:[[newValue valueData] boolValue]];
        [NSUserDefaults jk_setObject:boolValue forKey:KVideoSetting];
    }
}

@end
