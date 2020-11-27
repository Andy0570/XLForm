//
//  ExamplesFormViewController.m
//  XLForm ( https://github.com/xmartlabs/XLForm )
//
//  Copyright (c) 2015 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "InputsFormViewController.h"
#import "SelectorsFormViewController.h"
#import "OthersFormViewController.h"
#import "DatesFormViewController.h"
#import "MultiValuedFormViewController.h"
#import "ExamplesFormViewController.h"
#import "NativeEventFormViewController.h"
#import "UICustomizationFormViewController.h"
#import "CustomRowsViewController.h"
#import "AccessoryViewFormViewController.h"
#import "PredicateFormViewController.h"
#import "FormattersViewController.h"

// 自定义示例
#import "HQLFeeViewController.h"
#import "HQLInsuredPaymentDetailQueryFormViewController.h"
#import "HQLPersonalInfoFormViewController.h"
#import "HQLRegisterFormViewController.h"

NSString * const kTextFieldAndTextView = @"TextFieldAndTextView";
NSString * const kSelectors = @"Selectors";
NSString * const kOthes = @"Others";
NSString * const kDates = @"Dates";
NSString * const kPredicates = @"BasicPredicates";
NSString * const kBlogExample = @"BlogPredicates";
NSString * const kMultivalued = @"Multivalued";
NSString * const kMultivaluedOnlyReorder = @"MultivaluedOnlyReorder";
NSString * const kMultivaluedOnlyInsert = @"MultivaluedOnlyInsert";
NSString * const kMultivaluedOnlyDelete = @"MultivaluedOnlyDelete";
NSString * const kValidations= @"Validations";
NSString * const kFormatters = @"Formatters";

NSString * const kFeeCell = @"HQLFeeViewController";
NSString * const kHQLCBJF = @"HQLCBJF";
NSString * const kPersonalInfo = @"HQLPersonalInfoFormViewController";
NSString * const KRegisterForm = @"HQLRegisterFormViewController";


@interface ExamplesFormViewController ()

@end

@implementation ExamplesFormViewController


-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        [self initializeForm];
    }
    return self;
}


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self){
        [self initializeForm];
    }
    return self;
}


#pragma mark - Helper

-(void)initializeForm
{
    XLFormDescriptor * form;
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    form = [XLFormDescriptor formDescriptor];
    
    // ---------------------------------------------------------------
    // 第一组
    section = [XLFormSectionDescriptor formSectionWithTitle:@"真实示例"];
    [form addFormSection:section];
    
    // NativeEventFormViewController
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"realExamples" rowType:XLFormRowDescriptorTypeButton title:@"iOS 日历表单"];
    row.action.formSegueIdentifier = @"NativeEventNavigationViewControllerSegue";
    [section addFormRow:row];
    
    // MARK: 支付费用明细
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFeeCell rowType:XLFormRowDescriptorTypeButton title:@"支付费用明细"];
    row.action.viewControllerClass = HQLFeeViewController.class;
    [section addFormRow:row];
    
    // MARK: 参保缴费明细查询
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHQLCBJF rowType:XLFormRowDescriptorTypeButton title:@"参保缴费明细查询"];
    row.action.viewControllerClass = HQLInsuredPaymentDetailQueryFormViewController.class;
    [section addFormRow:row];
    
    // MARK: 编辑个人资料
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPersonalInfo rowType:XLFormRowDescriptorTypeButton title:@"编辑个人资料"];
    row.action.viewControllerClass = HQLPersonalInfoFormViewController.class;
    [section addFormRow:row];
    
    // MARK: 注册表单
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KRegisterForm rowType:XLFormRowDescriptorTypeButton title:@"注册表单"];
    row.action.viewControllerClass = HQLRegisterFormViewController.class;
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"This form is actually an example"];
    section.footerTitle = @"ExamplesFormViewController.h, Select an option to view another example";
    [form addFormSection:section];
    
    
    // TextFieldAndTextView
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kTextFieldAndTextView rowType:XLFormRowDescriptorTypeButton title:@"Text Fields"];
    row.action.viewControllerClass = [InputsFormViewController class];
    [section addFormRow:row];
    
    // Selectors
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSelectors rowType:XLFormRowDescriptorTypeButton title:@"Selectors"];
    row.action.formSegueIdentifier = @"SelectorsFormViewControllerSegue";
    [section addFormRow:row];
    
    // Dates
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDates rowType:XLFormRowDescriptorTypeButton title:@"Date & Time"];
    row.action.viewControllerClass = [DatesFormViewController class];
    [section addFormRow:row];
    
    // NSFormatters
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFormatters rowType:XLFormRowDescriptorTypeButton title:@"NSFormatter Support"];
    row.action.viewControllerClass = [FormattersViewController class];
    [section addFormRow:row];
    
    // Others
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kOthes rowType:XLFormRowDescriptorTypeButton title:@"Other Rows"];
    row.action.formSegueIdentifier = @"OthersFormViewControllerSegue";
    [section addFormRow:row];
    
    // ---------------------------------------------------------------
    // 第三组
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Multivalued example"];
    [form addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMultivalued rowType:XLFormRowDescriptorTypeButton title:@"Multivalued Sections"];
    row.action.viewControllerClass = [MultivaluedFormViewController class];
    [section addFormRow:row];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMultivaluedOnlyReorder rowType:XLFormRowDescriptorTypeButton title:@"Multivalued Only Reorder"];
    row.action.viewControllerClass = [MultivaluedOnlyReorderViewController class];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMultivaluedOnlyInsert rowType:XLFormRowDescriptorTypeButton title:@"Multivalued Only Insert"];
    row.action.viewControllerClass = [MultivaluedOnlyInserViewController class];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMultivaluedOnlyDelete rowType:XLFormRowDescriptorTypeButton title:@"Multivalued Only Delete"];
    row.action.viewControllerClass = [MultivaluedOnlyDeleteViewController class];
    [section addFormRow:row];
    

    // ---------------------------------------------------------------
    // 第四组
    section = [XLFormSectionDescriptor formSectionWithTitle:@"定制UI样式"];
    [form addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMultivalued rowType:XLFormRowDescriptorTypeButton title:@"UI Customization"];
    row.action.viewControllerClass = [UICustomizationFormViewController class];
    [section addFormRow:row];
    
    
    // ---------------------------------------------------------------
    // 第五组
    section = [XLFormSectionDescriptor formSectionWithTitle:@"自定义 Rows"];
    [form addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMultivalued rowType:XLFormRowDescriptorTypeButton title:@"Custom Rows"];
    row.action.viewControllerClass = [CustomRowsViewController class];
    [section addFormRow:row];
    
    // ---------------------------------------------------------------
    // 第六组
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Accessory View"];
    [form addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMultivalued rowType:XLFormRowDescriptorTypeButton title:@"Accessory Views"];
    row.action.viewControllerClass = [AccessoryViewFormViewController class];
    [section addFormRow:row];

    // ---------------------------------------------------------------
    // 第七组
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Validation Examples"];
    [form addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kValidations rowType:XLFormRowDescriptorTypeButton title:@"Validation Examples"];
    row.action.formSegueIdentifier = @"ValidationExamplesFormViewControllerSegue";
    [section addFormRow:row];
    
    // ---------------------------------------------------------------
    // 第七组
    section = [XLFormSectionDescriptor formSectionWithTitle:@"使用谓词"];
    [form addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPredicates rowType:XLFormRowDescriptorTypeButton title:@"Very basic predicates"];
    row.action.formSegueIdentifier = @"BasicPredicateViewControllerSegue";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPredicates rowType:XLFormRowDescriptorTypeButton title:@"Blog Example Hide predicates"];
    row.action.formSegueIdentifier = @"BlogExampleViewSegue";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPredicates rowType:XLFormRowDescriptorTypeButton title:@"Another example"];
    row.action.formSegueIdentifier = @"PredicateFormViewControllerSegue";
    [section addFormRow:row];
    
    self.form = form;

}



@end
