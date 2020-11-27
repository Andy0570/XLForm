//
//  HQLInsuredPaymentDetailQueryFormViewController.m
//  XLForm
//
//  Created by Qilin Hu on 2020/11/27.
//  Copyright © 2020 Xmartlabs. All rights reserved.
//

#import "HQLInsuredPaymentDetailQueryFormViewController.h"

#import <JKCategories.h>
#import "HQLFormInlineDateCell.h"

static NSString * const KName = @"name";           // 姓名
static NSString * const KIDNumber = @"IDNumber";   // 身份证号码
static NSString * const KStartDate = @"startDate"; // 开始年月
static NSString * const KEndDate = @"endDate";     // 结束年月
static NSString * const KButton = @"button";       // 查询按钮

@interface HQLInsuredPaymentDetailQueryFormViewController ()
// 查询时间跨度是否在一年之内
@property (nonatomic, getter=isOneYearInterval) BOOL oneYearInterval;
@end

@implementation HQLInsuredPaymentDetailQueryFormViewController

#pragma mark - Initialize

- (instancetype)init {
    if (self = [super init]) {
        [self initializeForm];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self= [super initWithCoder:aDecoder]) {
        [self initializeForm];
    }
    return self;
}

- (void)initializeForm {
    XLFormDescriptor *form = [XLFormDescriptor formDescriptorWithTitle:@"参保缴费明细查询"];
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    section = [XLFormSectionDescriptor formSection];
    section.footerTitle = @"查询说明：\n1.个人缴费明细查询时间为养老保险建立个人账户（1996年元月）至今，1996年前缴费年限需依据职工档案及《职工养老保险手册》认定。\n2.首次参保日期结合职工档案认定为准。\n3.一次查询中开始日期和结束日期只能选择12个月之内，时间跨度超过12个月的请分次查询。";
    [form addFormSection:section];
    
    // 姓名
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KName rowType:XLFormRowDescriptorTypeInfo title:@"姓名"];
    row.value = @"张三";
    [section addFormRow:row];
    
    // 身份证号码
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KIDNumber rowType:XLFormRowDescriptorTypeAccount title:@"身份证号码"];
    // 右对齐
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    // 占位符
    [row.cellConfig setObject:@"请输入居民二代身份证号" forKey:@"textField.placeholder"];
    row.required = YES;
    // 正则表达式
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"身份证号码格式错误" regex:@"^\\d{17}(\\d|X|x)$"]];
    // 默认值
    row.value = @"32028***********10";
    // row.value = [_model.idNumber stringByReplacingCharactersInRange:NSMakeRange(6, 8) withString:@"********"]; // 身份证信息隐藏
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"请选择查询年月"];
    [form addFormSection:section];
    
    // 开始年月
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KStartDate rowType:HQLFormRowDescriptorTypeInlineDateCell title:@"开始年月"];
    row.required = YES;
    [section addFormRow:row];
    
    // 结束年月
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KEndDate rowType:HQLFormRowDescriptorTypeInlineDateCell title:@"结束年月"];
    row.required = YES;
    // 初始化时禁止设置设置「结束年月值」，只有当「开始年月值」被设置后，才可以设置「结束年月值」。
    row.disabled = @YES;
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    // 「查询」按钮
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KButton rowType:XLFormRowDescriptorTypeButton title:@"查询"];
    row.action.formSelector = @selector(queryButtonDidClicked:);
    [section addFormRow:row];
    
    self.form = form;
}

#pragma mark - Actions

// 参保缴费明细查询
- (void)queryButtonDidClicked:(XLFormRowDescriptor *)sender {
    [self deselectFormRow:sender];
    
    // 验证查询年月
    __block BOOL shouldReturn;
    NSArray *array = [self formValidationErrors];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        XLFormValidationStatus *validationStatus = [[obj userInfo] objectForKey:XLValidationStatusErrorKey];
        // 开始年月
        if ([validationStatus.rowDescriptor.tag isEqualToString:KStartDate]) {
            shouldReturn = YES;
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:validationStatus.rowDescriptor]];
            [self animateCell:cell];
        }
        // 结束年月
        else if ([validationStatus.rowDescriptor.tag isEqualToString:KEndDate]) {
            shouldReturn = YES;
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:validationStatus.rowDescriptor]];
            [self animateCell:cell];
        }
    }];
    if (shouldReturn) {
        return;
    }
    
    if (!self.isOneYearInterval) {
        [self.navigationController.view jk_makeToast:@"查询时间不得超过一年"];
        return;
    }
    
    [self.navigationController.view jk_makeToast:@"验证通过，发起网络请求！"];
    NSLog(@"打印表单值：\n%@",self.formValues);
}

// 正则表达式验证某一行失败后，使用动画抖动该行进行提示。
-(void)animateCell:(UITableViewCell *)cell
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"position.x";
    animation.values =  @[ @0, @20, @-20, @10, @0];
    animation.keyTimes = @[@0, @(1 / 6.0), @(3 / 6.0), @(5 / 6.0), @1];
    animation.duration = 0.3;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.additive = YES;
    
    [cell.layer addAnimation:animation forKey:@"shake"];
}

#pragma mark - XLFormDescriptorDelegate

/*
 表单项中的值被改变后调用
 
 功能：
 1. 必须先设置「开始年月」，才能再设置「结束年月」；
 2. 「结束年月」的日期不得早于「开始年月」；
 */
-(void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)rowDescriptor oldValue:(id)oldValue newValue:(id)newValue
{
    [super formRowDescriptorValueHasChanged:rowDescriptor oldValue:oldValue newValue:newValue];
    
    if ([rowDescriptor.tag isEqualToString:KStartDate]) {
        // 如果开始年月值被设置,修改结束年月，结束年月=开始年月
        XLFormRowDescriptor *endDateDescriptor = [self.form formRowWithTag:KEndDate];
        endDateDescriptor.disabled = @NO;
        endDateDescriptor.value = (NSString *)newValue;
        [self updateFormRow:endDateDescriptor];
    } else if ([rowDescriptor.tag isEqualToString:KEndDate]) {
        // 结束年月值被设置，验证
        // 条件一：开始年月 < 结束年月
        // 条件二：结束年月-开始年月 < 1年
        
        XLFormRowDescriptor *startDateDescriptor = [self.form formRowWithTag:KStartDate];
        XLFormRowDescriptor *endDateDescriptor = [self.form formRowWithTag:KEndDate];
        
        // 业务要求：一次只能查询一年之内的数据
        // 计算开始年月与结束年月时间区间是否在一年之内
        NSDate *startDate = [NSDate jk_dateWithString:startDateDescriptor.value format:@"yyyyMM"];
        NSDate *endDate   = [NSDate jk_dateWithString:endDateDescriptor.value format:@"yyyyMM"];
        NSInteger monthsInterval = [startDate jk_distanceMonthsToDate:endDate];
        self.oneYearInterval = (monthsInterval >= 0 && monthsInterval < 12);
    }
}

@end
