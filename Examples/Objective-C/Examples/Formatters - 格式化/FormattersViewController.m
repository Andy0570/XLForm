//
//  FormattersViewController.m
//  XLForm
//
//  Created by Freddy Henin on 12/29/14.
//  Copyright (c) 2014 Xmartlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XLForm.h"
#import "FormattersViewController.h"

// GitHub地址：https://github.com/Serheo/SHSPhoneComponent
#import <SHSPhoneComponent/SHSPhoneNumberFormatter+UserConfig.h>


// 描述货币格式的简单类。 不幸的是，我们必须将 NSNumberFormatter 子类化，以解决一些长期以来知道的具有 NSNumberFormatter 的四舍五入的错误
// Simple little class to demonstraite currency formatting.   Unfortunally we have to subclass
// NSNumberFormatter to work aroundn some long known rounding bugs with NSNumberFormatter
// http://stackoverflow.com/questions/12580162/nsstring-to-nsdate-conversion-issue
@interface CurrencyFormatter : NSNumberFormatter

@property (readonly, strong) NSDecimalNumberHandler *roundingBehavior;

@end

@implementation CurrencyFormatter

- (id) init
{
    self = [super init];
    if (self) {
        [self setNumberStyle: NSNumberFormatterCurrencyStyle];
        [self setGeneratesDecimalNumbers:YES];
        
        NSUInteger currencyScale = [self maximumFractionDigits];
        
        _roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:currencyScale raiseOnExactness:FALSE raiseOnOverflow:TRUE raiseOnUnderflow:TRUE raiseOnDivideByZero:TRUE];
        
    }
    
    return self;
}

//- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error
//{
//    NSDecimalNumber *number;
//    BOOL success = [super getObjectValue:&number forString:string errorDescription:error];
//    
//    if (success) {
//        *anObject = [number decimalNumberByRoundingAccordingToBehavior:_roundingBehavior];
//    }
//    else {
//        *anObject = nil;
//    }
//    
//    return success;
//}

@end

@interface FormattersViewController ()
@end

@implementation FormattersViewController

-(id)init
{
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Text Fields"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    formDescriptor.assignFirstResponderOnShow = NO;
    
    section = [XLFormSectionDescriptor formSection];
    section.title = @"NSFormatter Support";
    section.footerTitle = @"可以在您键入时将 row 配置为支持格式化显示，或者在显示/编辑期间切换打开和关闭。 由于 NSNumberFormatter 在这方面是非常有限的，所以您很可能需要使用自定义的 NSFormatter 对象进行即时格式化。";
    [formDescriptor addFormSection:section];
    
    // 电话号码
    // SHSPhoneComponent 第三方框架
    SHSPhoneNumberFormatter *formatter = [[SHSPhoneNumberFormatter alloc] init];
    [formatter setDefaultOutputPattern:@"(###) ###-####" imagePath:nil];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"phone" rowType:XLFormRowDescriptorTypePhone title:@"US Phone"];
    row.valueFormatter = formatter;
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    
    row.useValueFormatterDuringInput = YES;
    [section addFormRow:row];
    
    // 货币
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"货币" rowType:XLFormRowDescriptorTypeDecimal title:@"USD"];
    CurrencyFormatter *numberFormatter = [[CurrencyFormatter alloc] init];
    row.valueFormatter = numberFormatter; // 设置格式化货币
    row.value = [NSDecimalNumber numberWithDouble:9.95];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    // 折扣
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"折扣" rowType:XLFormRowDescriptorTypeNumber title:@"Test Score"];
    NSNumberFormatter *acctFormatter = [[NSNumberFormatter alloc] init];
    [acctFormatter setNumberStyle:NSNumberFormatterPercentStyle];
    row.valueFormatter = acctFormatter;
    row.value = @(0.75);
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    // 兆字节
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"兆字节" rowType:XLFormRowDescriptorTypeInfo title:@"Megabytes"];
    row.valueFormatter = [NSByteCountFormatter new];
    row.value = @(1024);
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSection];
    [formDescriptor addFormSection:section];
    
    return [super initWithForm:formDescriptor];
    
}

@end
