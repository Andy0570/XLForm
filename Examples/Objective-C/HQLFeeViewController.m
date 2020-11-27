//
//  HQLFeeViewController.m
//  XLForm
//
//  Created by Qilin Hu on 2020/11/26.
//  Copyright © 2020 Xmartlabs. All rights reserved.
//

#import "HQLFeeViewController.h"

static NSString * const KInfo1 = @"KInfo1";
static NSString * const KInfo2 = @"KInfo2";
static NSString * const KInfo3 = @"KInfo3";
static NSString * const KInfo4 = @"KInfo4";
static NSString * const KInfo5 = @"KInfo5";
static NSString * const KInfo6 = @"KInfo6";
static NSString * const KInfo7 = @"KInfo7";
static NSString * const KInfo8 = @"KInfo8";
static NSString * const KInfo9 = @"KInfo9";
static NSString * const KButton = @"KButton";

@implementation HQLFeeViewController

#pragma mark - Initialize

- (instancetype)init {
    if (self = [super init]) {
        [self initializeForm];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initializeForm];
    }
    return self;
}


- (void)initializeForm {
    XLFormDescriptor *form = [XLFormDescriptor formDescriptorWithTitle:@"挂号费用明细"];
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    // 门诊登记流水号
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KInfo1
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"门诊登记流水号"];
    row.value = @"2019091524962";
    [section addFormRow:row];
    
    // 订单提交时间
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KInfo2
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"订单提交时间"];
    row.value = @"2019-09-15 23:39:11";
    [section addFormRow:row];
    
    // 本次医疗费用
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KInfo3
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"本次医疗费用"];
    row.value = @"12.0元";
    [section addFormRow:row];
    
    // 本次统筹支出
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KInfo4
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"本次统筹支出"];
    row.value = @"0.0元";
    [section addFormRow:row];
    
    // 本次大病支出
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KInfo5
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"本次大病支出"];
    row.value = @"0.0元";
    [section addFormRow:row];
    
    // 本次账户支出
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KInfo6
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"本次账户支出"];
    row.value = @"12.0元";
    [section addFormRow:row];
    
    // 本次现金支出
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KInfo7
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"本次现金支出"];
    row.value = @"0.0元";
    [section addFormRow:row];
    
    // 本次公务员补助支出
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KInfo8
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"本次公务员补助支出"];
    row.value = @"0.0元";
    [section addFormRow:row];
    
    // 本次其他支出
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KInfo8
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"本次其他支出"];
    row.value = @"0.0元";
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    // 「确认支付」按钮
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KButton rowType:XLFormRowDescriptorTypeButton title:@"确认支付"];
    row.action.formSelector = @selector(payButtonDidClicked:);
    [section addFormRow:row];
    
    self.form = form;
    
}

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

#pragma mark - IBActions

// 确认支付按钮
- (void)payButtonDidClicked:(XLFormRowDescriptor *)sender {
    // 把个位数转换为 0x 的形式
    NSInteger index = 12;
    NSString *string = [NSString stringWithFormat:@"%02ld",(long)index];
    NSLog(@"%@",string);
}

@end
