//
//  OthersFormViewController.m
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

#import "MapViewController.h"
#import "OthersFormViewController.h"

NSString *const kSwitchBool = @"switchBool";
NSString *const kSwitchCheck = @"switchCheck";
NSString *const kStepCounter = @"stepCounter";
NSString *const kSlider = @"slider";
NSString *const kSegmentedControl = @"segmentedControl";
NSString *const kCustom = @"custom";
NSString *const kInfo = @"info";
NSString *const kButton = @"button";
NSString *const kImage = @"image";
NSString *const kButtonLeftAligned = @"buttonLeftAligned";
NSString *const kButtonWithSegueId = @"buttonWithSegueId";
NSString *const kButtonWithSegueClass = @"buttonWithSegueClass";
NSString *const kButtonWithNibName = @"buttonWithNibName";
NSString *const kButtonWithStoryboardId = @"buttonWithStoryboardId";


@implementation OthersFormViewController


-(instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initializeForm];
    }
    return self;
}

-(instancetype)init
{
    self = [super init];
    if (self){
        [self initializeForm];
    }
    return self;
}

-(void)initializeForm
{
    XLFormDescriptor * form = [XLFormDescriptor formDescriptorWithTitle:@"Other Cells"];
    XLFormSectionDescriptor * section;
    
    // --------------------------------------------------------------
    // Basic Information
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Other Cells"];
    section.footerTitle = @"rowType:\n1.XLFormRowDescriptorTypeBooleanSwitch\n2.XLFormRowDescriptorTypeBooleanCheck\n3.XLFormRowDescriptorTypeStepCounter\n4.XLFormRowDescriptorTypeSelectorSegmentedControl\n5.XLFormRowDescriptorTypeSlider\n6.XLFormRowDescriptorTypeImage\n.7XLFormRowDescriptorTypeInfo";
    [form addFormSection:section];
    
    // Switch - 开关
    XLFormRowDescriptor * row = [XLFormRowDescriptor formRowDescriptorWithTag:kSwitchBool rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Switch"];
    // !!!: 设置开关打开的颜色为红色（默认绿色）
    [row.cellConfigAtConfigure setObject:UIColor.redColor forKey:@"switchControl.onTintColor"];
    // 设置开关状态
    // row.value = _model.isSelected ? @YES : @NO;
    [section addFormRow:row];
    
    // check
    [section addFormRow:[XLFormRowDescriptor formRowDescriptorWithTag:kSwitchCheck rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Check"]];
    
    // step counter - 步进器
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kStepCounter rowType:XLFormRowDescriptorTypeStepCounter title:@"Step counter"];
    row.value = @50;
    [row.cellConfigAtConfigure setObject:@YES forKey:@"stepControl.wraps"]; // 轮回：最大-最小
    [row.cellConfigAtConfigure setObject:@10 forKey:@"stepControl.stepValue"]; // // 步进值，默认为1
    [row.cellConfigAtConfigure setObject:@10 forKey:@"stepControl.minimumValue"];
    [row.cellConfigAtConfigure setObject:@100 forKey:@"stepControl.maximumValue"];
    [section addFormRow:row];
    
    // Segmented Control
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSegmentedControl rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Fruits"];
    row.selectorOptions = @[@"Apple", @"Orange", @"Pear"];
    row.value = @"Pear";
    [section addFormRow:row];
    
    
    // Slider
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSlider rowType:XLFormRowDescriptorTypeSlider title:@"Slider"];
    row.value = @(30);
    [row.cellConfigAtConfigure setObject:@(100) forKey:@"slider.maximumValue"];
    [row.cellConfigAtConfigure setObject:@(10) forKey:@"slider.minimumValue"];
    [row.cellConfigAtConfigure setObject:@(4) forKey:@"steps"];
    [section addFormRow:row];
    
    // Image
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kImage rowType:XLFormRowDescriptorTypeImage title:@"Image"];
    row.value = [UIImage imageNamed:@"default_avatar"];
    [section addFormRow:row];

    /**
     Info 类型
     
     XLFormRowDescriptorTypeInfo 类型的 cell 是用 XLFormSelectorCell 封装的，而该类并没有对 XLFormTextFieldLengthPercentage 属性作 KVC 编码，
     因此你不可以设置修改其文本长度或其他 KVC 设置：
     // !!!: 你不能设置文本显示的长度
     [infoRowDescriptor.cellConfigAtConfigure setObject:[NSNumber numberWithFloat:0.7]
                                                 forKey:XLFormTextFieldLengthPercentage];

     // !!!: 你也不能修改文本的颜色
     [row.cellConfig setObject:[UIColor flatMintColor] forKey:@"textField.color"];
     */
    XLFormRowDescriptor *infoRowDescriptor = [XLFormRowDescriptor formRowDescriptorWithTag:kInfo rowType:XLFormRowDescriptorTypeInfo];
    infoRowDescriptor.title = @"Version";
    infoRowDescriptor.value = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [section addFormRow:infoRowDescriptor];
    
    
    // --------------------------------------------------------------
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Buttons"];
    section.footerTitle = @"当 Switch 开关打开时，点击蓝色按钮可以弹出消息.";
    [form addFormSection:section];
    
    // Button - 按钮
    XLFormRowDescriptor * buttonRow = [XLFormRowDescriptor formRowDescriptorWithTag:kButton rowType:XLFormRowDescriptorTypeButton title:@"Button"];
    buttonRow.action.formSelector = @selector(didTouchButton:);
    [section addFormRow:buttonRow];
    
    
    // Left Button
    XLFormRowDescriptor * buttonLeftAlignedRow = [XLFormRowDescriptor formRowDescriptorWithTag:kButtonLeftAligned rowType:XLFormRowDescriptorTypeButton title:@"Button with Block"];
    // 设置了文本对齐方式、文本字体颜色和辅助箭头
    [buttonLeftAlignedRow.cellConfig setObject:@(NSTextAlignmentNatural) forKey:@"textLabel.textAlignment"];
    [buttonLeftAlignedRow.cellConfig setObject:UIColor.greenColor forKey:@"textLabel.textColor"];
    [buttonLeftAlignedRow.cellConfig setObject:@(UITableViewCellAccessoryDisclosureIndicator) forKey:@"accessoryType"];
    
    // Block 方式触发按钮点击方法
    __typeof(self) __weak weakSelf = self;
    buttonLeftAlignedRow.action.formBlock = ^(XLFormRowDescriptor * sender){
        if ([[sender.sectionDescriptor.formDescriptor formRowWithTag:kSwitchBool].value boolValue]){
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Switch is ON", nil)
                                                                                      message:@"Button has checked the switch value..."
                                                                               preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                                style:UIAlertActionStyleDefault
                                                              handler:nil]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        [weakSelf deselectFormRow:sender];
    };
    [section addFormRow:buttonLeftAlignedRow];
    
    // Another Left Button with segue
    XLFormRowDescriptor * buttonLeftAlignedWithSegueRow = [XLFormRowDescriptor formRowDescriptorWithTag:kButtonWithSegueClass rowType:XLFormRowDescriptorTypeButton title:@"Button with Segue Class"];
    buttonLeftAlignedWithSegueRow.action.formSegueClass = NSClassFromString(@"UIStoryboardPushSegue");
    buttonLeftAlignedWithSegueRow.action.viewControllerClass = [MapViewController class];
    [section addFormRow:buttonLeftAlignedWithSegueRow];
    
    
    // Button with SegueId
    XLFormRowDescriptor * buttonWithSegueId = [XLFormRowDescriptor formRowDescriptorWithTag:kButtonWithSegueClass rowType:XLFormRowDescriptorTypeButton title:@"Button with Segue Idenfifier"];
    buttonWithSegueId.action.formSegueIdentifier = @"MapViewControllerSegue";
    [section addFormRow:buttonWithSegueId];
    
    
    // Another Button using Segue
    XLFormRowDescriptor * buttonWithStoryboardId = [XLFormRowDescriptor formRowDescriptorWithTag:kButtonWithStoryboardId rowType:XLFormRowDescriptorTypeButton title:@"Button with StoryboardId"];
    buttonWithStoryboardId.action.viewControllerStoryboardId = @"MapViewController";
    [section addFormRow:buttonWithStoryboardId];
    
    // Another Left Button with segue
    XLFormRowDescriptor * buttonWithNibName = [XLFormRowDescriptor formRowDescriptorWithTag:kButtonWithNibName
                                                                                    rowType:XLFormRowDescriptorTypeButton
                                                                                      title:@"Button with NibName"];
    buttonWithNibName.action.viewControllerNibName = @"MapViewController";
    [section addFormRow:buttonWithNibName];
    
    self.form = form;
}

-(void)didTouchButton:(XLFormRowDescriptor *)sender
{
    if ([[sender.sectionDescriptor.formDescriptor formRowWithTag:kSwitchBool].value boolValue]){
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Switch is ON", nil)
                                                                                  message:@"Button has checked the switch value..."
                                                                           preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    [self deselectFormRow:sender];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithTitle:@"Disable" style:UIBarButtonItemStylePlain
                                                target:self
                                                action:@selector(disableEnable:)];
    barButton.possibleTitles = [NSSet setWithObjects:@"Disable", @"Enable", nil];
    self.navigationItem.rightBarButtonItem = barButton;
}

-(void)disableEnable:(UIBarButtonItem *)button
{
    self.form.disabled = !self.form.disabled;
    [button setTitle:(self.form.disabled ? @"Enable" : @"Disable")];
    [self.tableView endEditing:YES];
    [self.tableView reloadData];
}


@end
