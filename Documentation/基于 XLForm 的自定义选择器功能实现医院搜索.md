# 基于 XLForm 的自定义选择器功能实现医院搜索

![IMG_0845](https://blog-andy0570-1256077835.cos.ap-shanghai.myqcloud.com/site_Images/035542.png)



## 请求数据模型

### HQLOffSiteQueryHospitalRequestModel.h

```objective-c
#import <Foundation/Foundation.h>

// 医院级别
typedef NS_ENUM(NSUInteger, HQLOffSiteQueryHospitalRequestModelHospitalLevel) {
    HQLOffSiteQueryHospitalRequestModelHospitalLevel1 = 1,
    HQLOffSiteQueryHospitalRequestModelHospitalLevel2 = 2,
    HQLOffSiteQueryHospitalRequestModelHospitalLevel3 = 3,
};

/**
 「异地就医备案」- 查询医院，请求数据模型
 */
@interface HQLOffSiteQueryHospitalRequestModel : NSObject

@property (nonatomic, assign) HQLOffSiteQueryHospitalRequestModelHospitalLevel hospitalLevel;
@property (nonatomic, assign) NSUInteger pageNum; // 页码
@property (nonatomic, copy) NSString *queryString;

- (instancetype)initWithHospitalLevel:(HQLOffSiteQueryHospitalRequestModelHospitalLevel)hospitalLevel
                          queryString:(NSString *)queryString;

@end
```

### HQLOffSiteQueryHospitalRequestModel.m

```objective-c
#import "HQLOffSiteQueryHospitalRequestModel.h"

@implementation HQLOffSiteQueryHospitalRequestModel

#pragma mark - Init

// 指定初始化方法
- (instancetype)initWithHospitalLevel:(HQLOffSiteQueryHospitalRequestModelHospitalLevel)hospitalLevel
                          queryString:(NSString *)queryString {
    self = [super init];
    if (self) {
        _hospitalLevel = hospitalLevel;
        _queryString = [queryString copy];
        _pageNum = 1;
    }
    return self;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"Method Undefined"
                                   reason:@"Use Designated Initializer Method"
                                 userInfo:nil];
    return nil;
}

#pragma mark - Override

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"hospitalLevel" : @"yyjb",
             @"pageNum"       : @"page",
             @"queryString"   : @"yy",
             };
}

#pragma mark - NSObject

- (NSString *)description {
    return [self modelDescription];
}

@end
```



## 响应数据模型

### HQLOffSiteQueryHospitalResultModel.h

```objective-c
#import <Foundation/Foundation.h>
#import <XLFormRowDescriptor.h>

/**
 「异地就医备案」- 查询医院，返回数据模型
 */
@interface HQLOffSiteQueryHospitalResultModel : NSObject <XLFormOptionObject>

@property (nonatomic, copy, readonly) NSString *hospitalCode;
@property (nonatomic, copy, readonly) NSString *hospitalName;

- (instancetype)initWithHospitalCode:(NSString *)hospitalCode
                        hospitalName:(NSString *)hospitalName;

@end
```



### HQLOffSiteQueryHospitalResultModel.m

```objective-c
#import "HQLOffSiteQueryHospitalResultModel.h"

@interface HQLOffSiteQueryHospitalResultModel ()

@property (nonatomic, copy, readwrite) NSString *hospitalCode;
@property (nonatomic, copy, readwrite) NSString *hospitalName;

@end

@implementation HQLOffSiteQueryHospitalResultModel

#pragma mark - Init

- (instancetype)initWithHospitalCode:(NSString *)hospitalCode
                        hospitalName:(NSString *)hospitalName {
    self = [super init];
    if (self) {
        _hospitalCode = hospitalCode;
        _hospitalName = hospitalName;
    }
    return self;
}

#pragma mark - Override

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"hospitalCode" : @"akb020",
             @"hospitalName" : @"akb021",
             };
}

#pragma mark - XLFormOptionObject

// UI界面显示医院名称
-(nonnull NSString *)formDisplayText {
    return self.hospitalName;
}

// API接口上传医院代码？？？并没有
-(nonnull id)formValue {
    return self;
}

#pragma mark - NSObject

- (NSString *)description {
    return [self modelDescription];
}

@end
```



## 搜索页面

### HQLOffSiteHospitalSearchViewController.h

```objective-c
#import <UIKit/UIKit.h>
#import <XLFormRowDescriptor.h>

/**
 *「医疗保险」- 「异地就医备案」- 选择备案医院
 */
@interface HQLOffSiteHospitalSearchViewController : UITableViewController <XLFormRowDescriptorViewController>

@end
```

### HQLOffSiteHospitalSearchViewController.m

```objective-c
#import "HQLOffSiteHospitalSearchViewController.h"

// Framework
#import <MJRefresh.h>
#import <UITableView+FDTemplateLayoutCell.h>

// Model
#import "HQLOffSiteQueryHospitalRequestModel.h"
#import "HQLOffSiteQueryHospitalResultModel.h"

// Utils
#import "HQLURL_20_4.h"
#import "XLFormRowDescriptor+HQLAddExtraAttributes.h"

static NSString * const cellReusreIdentifier = @"UITableViewCellStyleDefault";

@interface HQLOffSiteHospitalSearchViewController () <UISearchResultsUpdating>

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray *searchList;
@property (nonatomic, strong) HQLOffSiteQueryHospitalRequestModel *requestModel;

@end

@implementation HQLOffSiteHospitalSearchViewController

@synthesize rowDescriptor = _rowDescriptor;

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 根据医院等级设置页面标题
    NSInteger hospitalLevel = [self.rowDescriptor.hospitalLevel integerValue];
    if (hospitalLevel == 1) {
        self.title = @"一级医院";
    } else if (hospitalLevel == 2) {
        self.title = @"二级医院";
    } else {
        self.title = @"三级医院";
    }
    
    [self setupTableView];
}

- (void)setupTableView {
    // 设置搜索框
    self.tableView.tableHeaderView = self.searchController.searchBar;
    // 解决退出时搜索框依然存在的问题
    self.definesPresentationContext = YES;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellReusreIdentifier];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(requestHospitalData)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Accessors

- (UISearchController *)searchController {
    if (!_searchController) {
        _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        _searchController.searchResultsUpdater = self;
        _searchController.searchBar.placeholder = @"请输入医院名称";
        _searchController.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_searchController.searchBar sizeToFit];
    }
    return _searchController;
}

- (HQLOffSiteQueryHospitalRequestModel *)requestModel {
    if (!_requestModel) {
        _requestModel = [[HQLOffSiteQueryHospitalRequestModel alloc] initWithHospitalLevel:[self.rowDescriptor.hospitalLevel integerValue] queryString:@""];
    }
    return _requestModel;
}

- (NSMutableArray *)searchList {
    if (!_searchList) {
        _searchList = [[NSMutableArray alloc] init];
    }
    return _searchList;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReusreIdentifier forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

// 配置cell
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    HQLOffSiteQueryHospitalResultModel *hospitalModel = self.searchList[indexPath.row];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = hospitalModel.hospitalName;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:cellReusreIdentifier cacheByIndexPath:indexPath configuration:^(id cell) {
        [self configureCell:(UITableViewCell *)cell atIndexPath:indexPath];
    }];
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 66)];
    label.text = @"请选择驻外城市医院，非驻外城市医疗机构，备案将会判定无效。";
    label.textColor = HexColor(@"#F4333C");
    label.numberOfLines = 2;
    return label;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HQLOffSiteQueryHospitalResultModel *hospitalModel = self.searchList[indexPath.row];
    self.rowDescriptor.value = hospitalModel;
    
    if ([self.parentViewController isKindOfClass:[UINavigationController class]]) {
        [self.navigationController popViewControllerAnimated:YES];
    }else if ([self.presentingViewController isKindOfClass:[HQLOffSiteHospitalSearchViewController class]]) {
        [[self.presentingViewController navigationController] popViewControllerAnimated:YES];
    }
}

#pragma mark - UISearchResultsUpdating

// Called when the search bar's text or scope has changed or when the search bar becomes first responder.
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    // 获取搜索框里的字符串
    NSString *searchString = searchController.searchBar.text;
    if (![searchString isNotBlank] || [searchString isEqual:[NSNull null]]) {
        return;
    }
    self.requestModel.pageNum = 1;
    self.requestModel.queryString = searchString;
    [self.searchList removeAllObjects]; // 清空列表数据
    [self.tableView reloadData];        // 刷新列表
    [self requestHospitalData];
}

// 模糊搜索医院名称，并更新UI
- (void)requestHospitalData {
    HQLURL_20_4 *api = [[HQLURL_20_4 alloc] initWithRequestModel:self.requestModel];
    [api startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        [self.tableView.mj_footer endRefreshing];
        
        // AES解密
        NSString *resultString = request.responseJSONObject[@"resultData"];
        NSDictionary *dictionary = [AESCipher decryptAES:resultString key:KEY];
        BLYLogDebug(@"[URL_20_4] Result Model:\n%@",dictionary);
        
        BOOL isMsgflagTrue = [dictionary[@"msgflag"] isEqualToString:@"0"];
        if (isMsgflagTrue) {
            self.requestModel.pageNum ++;
            NSArray *array = [NSArray modelArrayWithClass:[HQLOffSiteQueryHospitalResultModel class]
                                                     json:dictionary[@"msg"]];
            [self.searchList addObjectsFromArray:array];
            [self.tableView reloadData];
        }else {
            // 获取当前上拉刷新控件，变为没有更多数据的状态
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        [self.tableView.mj_footer endRefreshing];
        [MBProgressHUD hql_showErrorHUD:request.error.localizedDescription];
    }];
}

@end
```



## 查询请求类

### HQLURL_20_4.h

```objective-c
#import <YTKNetwork/YTKNetwork.h>

@class HQLOffSiteQueryHospitalRequestModel;

/**
 「异地就医备案」- 查询医院
 */
@interface HQLURL_20_4 : YTKRequest

- (instancetype)initWithRequestModel:(HQLOffSiteQueryHospitalRequestModel *)requestModel;

@end
```



### HQLURL_20_4.m

```objective-c
#import "HQLURL_20_4.h"
#import "HQLOffSiteQueryHospitalRequestModel.h"

@interface HQLURL_20_4 ()

@property (nonatomic, strong) HQLOffSiteQueryHospitalRequestModel *requestModel;

@end

@implementation HQLURL_20_4

#pragma mark - Lifecycle

- (instancetype)initWithRequestModel:(HQLOffSiteQueryHospitalRequestModel *)requestModel {
    self = [super init];
    if (self) {
        _requestModel = requestModel;
    }
    return self;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"Method Undefined"
                                   reason:@"Use Designated Initializer Method"
                                 userInfo:nil];
    return nil;
}

#pragma mark - Override

- (NSString *)requestUrl {
    return URL_20_4;
}

- (NSTimeInterval)requestTimeoutInterval {
    return 10.0f;
}

- (id)requestArgument {
    NSDictionary *dictionary = [_requestModel modelToJSONObject];
    
    BLYLogDebug(@"dictionary = %@",dictionary);
    NSString *cipherString = [AESCipher encryptAES:dictionary key:KEY];
    return @{@"postData":cipherString};
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodPOST;
}

- (id)jsonValidator {
    return @{@"resultData":[NSString class]};
}

@end
```



## 表单页面



### HQLOffSiteMedicalTreatmentAppRecord1ViewController.h

```objective-c
#import <XLForm/XLForm.h>

@class HQLOffSiteMedicalTreatmentAppRecord1Model;

/**
 「异地就医APP备案」
 1.备案记录查询表单页
 */
@interface HQLOffSiteMedicalTreatmentAppRecord1ViewController : XLFormViewController

@end
```

### HQLOffSiteMedicalTreatmentAppRecord1ViewController.m

```objective-c
#import "HQLOffSiteMedicalTreatmentAppRecord1ViewController.h"

// Framework
#import <SHSPhoneComponent/SHSPhoneLibrary.h>
#import <DateTools.h>

// Controller
#import "HQLOffSiteMedicalTreatmentAppRecord2ViewController.h"
#import "HQLOffSiteHospitalSearchViewController.h"

// View
#import "HQProvinceAndCityCell.h"

// Models
#import "HQLOffSiteMedicalTreatmentAppRecord1Model.h"
#import "HQLOffSiteMedicalTreatmentAppRecord2Model.h"
#import "HQProvinceAndCityModel.h"
#import "HQLOffSiteQueryHospitalRequestModel.h"

// Utils
#import "HQLURL_20_1.h"
#import "HQLURL_20_2.h"
#import "XLFormRowDescriptor+HQLAddExtraAttributes.h"

static NSString *const KName = @"name";
static NSString *const KIDNumber = @"idNumber";
static NSString *const KPersonalCode = @"personalCode";
static NSString *const KRecordState = @"recordState";
static NSString *const KCheckDescription = @"checkDescription";

static NSString *const KProvinceAndCity = @"provinceAndCity";
static NSString *const KStartDate = @"startDate";
static NSString *const KEndDate = @"endDate";
static NSString *const KContactName = @"contactName";
static NSString *const KPhoneNumber = @"phoneNumber";
static NSString *const KAddress = @"address";
static NSString *const KAbordType = @"abordType";
static NSString *const KCityType = @"cityType";
static NSString *const KHospital1 = @"hospital1"; // 一级医院
static NSString *const KHospital2 = @"hospital2"; // 二级医院
static NSString *const KHospital3 = @"hospital3"; // 三级医院
static NSString *const KRecodeNote = @"recodeNote";
static NSString *const KButton   = @"button";

@interface HQLOffSiteMedicalTreatmentAppRecord1ViewController ()

@property (nonatomic, strong) HQLOffSiteMedicalTreatmentAppRecord1Model *model; // 数据模型
@property (nonatomic, strong) NSDate *minimumDate; // 年月选择器最小值
@property (nonatomic, strong) NSDate *endDateMaximumDate;   // 结束时间最大值
@property (nonatomic, strong) NSDate *startDateMaximumDate; // 开始时间最大值
@property (nonatomic, assign) BOOL isDetailHidden;

@end

@implementation HQLOffSiteMedicalTreatmentAppRecord1ViewController {
    XLFormSectionDescriptor *section2; // 审核信息 section
    XLFormSectionDescriptor *section3; // 备注信息 section
    XLFormSectionDescriptor *section4; // 提交按钮 section
}

#pragma mark - Init

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeForm];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"异地就医备案";
    }
    return self;
}

- (void)initializeForm {
    XLFormDescriptor *form = [XLFormDescriptor formDescriptorWithTitle:@"异地就医备案"];
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    // ---------- 基本信息 ----------
    section = [XLFormSectionDescriptor formSectionWithTitle:@"基本信息"];
    [form addFormSection:section];
    
    // 姓名
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KName rowType:XLFormRowDescriptorTypeInfo title:@"姓名"];
    row.value = _model.name;
    [section addFormRow:row];
    
    // 身份证号码
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KIDNumber rowType:XLFormRowDescriptorTypeInfo title:@"身份证号码"];
    row.value = [_model.idNumber stringByReplacingCharactersInRange:NSMakeRange(6, 8) withString:@"********"];
    [section addFormRow:row];
    
    // 社保卡号码
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KPersonalCode rowType:XLFormRowDescriptorTypeInfo title:@"社保卡号码"];
    row.value = [_model.personalCode stringByReplacingCharactersInRange:NSMakeRange(3, 5) withString:@"*****"];
    [section addFormRow:row];
    
    // 审核状态
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KRecordState rowType:XLFormRowDescriptorTypeInfo title:@"审核状态"];
    switch (_model.recordState) {
        case HQLOffSiteMedicalTreatmentRecordStateDefault:
            row.value = @"材料不完善或未提交"; 
            break;
        case HQLOffSiteMedicalTreatmentRecordStateUploadSucceed:
            row.value = @"提交成功";
            break;
        case HQLOffSiteMedicalTreatmentRecordStateCheckFailure:
            row.value = @"审核未通过";
            break;
        case HQLOffSiteMedicalTreatmentRecordStateCheckSucceed:
            row.value = @"审核通过";
            break;
    }
    [section addFormRow:row];
    
    // 审核信息
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KCheckDescription rowType:XLFormRowDescriptorTypeInfo title:@"审核信息"];
    row.value = _model.checkDescription;
    row.hidden = [NSNumber numberWithBool:self.isDetailHidden];
    [section addFormRow:row];
    
    // ---------- 审核信息 ----------
    section = [XLFormSectionDescriptor formSectionWithTitle:@"审核信息"];
    section2 = section;
    section.hidden = [NSNumber numberWithBool:self.isDetailHidden];
    [form addFormSection:section];
    
    // 转往省份城市
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KProvinceAndCity rowType:HQFormRowDescriptorTypeProvinceAndCity title:@"转往省份城市"];
    row.value = [[HQProvinceAndCityModel alloc] initWithProvinceId:_model.province CityId:_model.city];
    row.required = YES;
    [section addFormRow:row];
    
    // 一级医院
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KHospital1 rowType:XLFormRowDescriptorTypeSelectorPush title:@"一级医院"];
    row.action.viewControllerClass = [HQLOffSiteHospitalSearchViewController class];
    row.hospitalLevel = @"1";
    row.value = _model.hospital1;
    row.required = NO;
    [section addFormRow:row];
    
    // 二级医院
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KHospital2 rowType:XLFormRowDescriptorTypeSelectorPush title:@"二级医院"];
    row.action.viewControllerClass = [HQLOffSiteHospitalSearchViewController class];
    row.hospitalLevel = @"2";
    row.value = _model.hospital2;
    row.required = NO;
    [section addFormRow:row];
    
    // 三级医院
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KHospital3 rowType:XLFormRowDescriptorTypeSelectorPush title:@"三级医院"];
    row.action.viewControllerClass = [HQLOffSiteHospitalSearchViewController class];
    row.hospitalLevel = @"3";
    row.value = _model.hospital3;
    row.required = NO;
    [section addFormRow:row];
    
    // 开始时间 （需要判断 开始时间 < 结束时间）
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KStartDate rowType:XLFormRowDescriptorTypeDateInline title:@"开始时间"];
    [row.cellConfigAtConfigure setObject:[NSLocale localeWithLocaleIdentifier:@"zh-CN"] forKey:@"locale"];
    [row.cellConfigAtConfigure setObject:self.minimumDate forKey:@"minimumDate"];
    [row.cellConfigAtConfigure setObject:self.startDateMaximumDate forKey:@"maximumDate"];
    row.value = _model.startDate ? : self.minimumDate;
    [section addFormRow:row];
    
    // 结束时间
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KEndDate rowType:XLFormRowDescriptorTypeDateInline title:@"结束时间"];
    [row.cellConfigAtConfigure setObject:[NSLocale localeWithLocaleIdentifier:@"zh-CN"] forKey:@"locale"];
    [row.cellConfigAtConfigure setObject:self.minimumDate forKey:@"minimumDate"];
    [row.cellConfigAtConfigure setObject:self.endDateMaximumDate forKey:@"maximumDate"];
    row.value = _model.endDate ? : [self.minimumDate dateByAddingMonths:6];
    [section addFormRow:row];
    
    // 联系人姓名
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KContactName rowType:XLFormRowDescriptorTypeText title:@"联系人姓名"];
    row.value = _model.contactName;
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row.cellConfig setObject:@"请输入联系人姓名" forKey:@"textField.placeholder"];
    row.required = YES;
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"姓名格式错误"
                                                                regex:@"^[\\u4e00-\\u9fa5]{2,}$"]];
    [section addFormRow:row];
    
    // 联系电话
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KPhoneNumber rowType:XLFormRowDescriptorTypePhone title:@"联系电话"];
    row.value = _model.phoneNumber;
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row.cellConfig setObject:@"请输入联系人手机号码" forKey:@"textField.placeholder"];
    row.required = YES;
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"手机号码格式错误"
                                                                regex:@"^1(3|4|5|6|7|8|9)\\d{9}$"]];
    // 格式化显示
    SHSPhoneNumberFormatter *formatter = [[SHSPhoneNumberFormatter alloc] init];
    [formatter setDefaultOutputPattern:@"### #### ####"];
    row.valueFormatter = formatter;
    row.useValueFormatterDuringInput = YES;
    [section addFormRow:row];
    
    // 联系地址
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KAddress rowType:XLFormRowDescriptorTypeTextView title:@"联系地址"];
    row.value = _model.address;
    [row.cellConfigAtConfigure setObject:@"200" forKey:@"textViewMaxNumberOfCharacters"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textView.textAlignment"];
    [row.cellConfig setObject:@"请输入联系人地址" forKey:@"textView.placeholder"];
    row.required = YES;
    [section addFormRow:row];
    
    // 驻外类别
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KAbordType rowType:XLFormRowDescriptorTypeSelectorPickerViewInline title:@"驻外类别"];
    row.height = 50;
    row.selectorOptions = @[@"异地安置",@"长期驻外",@"异地居住"];
    row.value = _model.abordType ? : @"异地安置";
    [section addFormRow:row];
    
    // 城市类型
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KCityType rowType:XLFormRowDescriptorTypeSelectorPickerViewInline title:@"城市类型"];
    row.height = 50;
    row.selectorOptions = @[@"直辖市",@"省会城市",@"地级市",@"县级市",@"城镇",@"农村"];
    row.value = _model.cityType ? : @"直辖市";
    [section addFormRow:row];
    
    
    // ---------- 备注信息 ----------
    section = [XLFormSectionDescriptor formSection];
    section3 = section;
    section.hidden = [NSNumber numberWithBool:self.isDetailHidden];
    [form addFormSection:section];
    
    // 备注
    row = [XLFormRowDescriptor formRowDescriptorWithTag:KRecodeNote rowType:XLFormRowDescriptorTypeTextView title:@"备注："];
    [row.cellConfigAtConfigure setObject:@"40" forKey:@"textViewMaxNumberOfCharacters"];
    row.value = _model.recodeNote;
    [section addFormRow:row];
    
    // ---------- 提交按钮 ----------
    section = [XLFormSectionDescriptor formSection];
    section4 = section;
    section.footerTitle = @"异地就医备案业务说明：\n参保人员登录「****」APP后，可在应用内上传相关材料交由相关业务部门审核，审核通过后，即可完成异地就医备案手续。\n需要提交的材料：\n1.身份证原件正反面照片；\n2.社保卡原件正面照片；\n3.异地房产证照片、异地户口本照片、异地居住证照片（以上材料为原件，提供其中之一）；\n4.在职人员派出单位和异地接受单位证明单位盖章原件；\n5.如有个人账户提现需求，需提供邮政储蓄银行卡照片或邮政储蓄存折照片。\n";
    [form addFormSection:section];
    
    // 新建备案/修改备案
    XLFormRowDescriptor *buttonRow = [XLFormRowDescriptor formRowDescriptorWithTag:KButton rowType:XLFormRowDescriptorTypeButton title:@"新建备案"];
    buttonRow.action.formSelector = @selector(editRecordButtonDidClicked:);
    // 未提交过备案才需要新建备案，其他一律修改备案
    switch (_model.recordState) {
        case HQLOffSiteMedicalTreatmentRecordStateDefault: {
            buttonRow.hidden = @NO;
            break;
        }
        case HQLOffSiteMedicalTreatmentRecordStateUploadSucceed:
        case HQLOffSiteMedicalTreatmentRecordStateCheckFailure:
        case HQLOffSiteMedicalTreatmentRecordStateCheckSucceed: {
            buttonRow.hidden = @YES;
            break;
        }
    }
    [section addFormRow:buttonRow];
    
    self.form = form;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self requestServer];
}

#pragma mark - Custom Accessors

- (NSDate *)minimumDate {
    if (!_minimumDate) {
        _minimumDate = [NSDate new];
    }
    return _minimumDate;
}

// 结束日期最大值 = 10年后
- (NSDate *)endDateMaximumDate {
    if (!_endDateMaximumDate) {
        _endDateMaximumDate = [NSDate dateWithTimeIntervalSinceNow:315360000];
    }
    return _endDateMaximumDate;
}

// 开始日期最大值 = 结束日期最大值 - 6个月
- (NSDate *)startDateMaximumDate {
    if (!_startDateMaximumDate) {
        _startDateMaximumDate = [self.endDateMaximumDate dateBySubtractingMonths:6];
    }
    return _startDateMaximumDate;
}

// 根据审核状态判断是否隐藏审核信息
- (BOOL)isDetailHidden {
    if (!_isDetailHidden) {
        switch (_model.recordState) {
            case HQLOffSiteMedicalTreatmentRecordStateDefault: {
                self.isDetailHidden = YES;
                break;
            }
            case HQLOffSiteMedicalTreatmentRecordStateUploadSucceed:
            case HQLOffSiteMedicalTreatmentRecordStateCheckFailure:
            case HQLOffSiteMedicalTreatmentRecordStateCheckSucceed: {
                self.isDetailHidden = NO;
                break;
            }
        }
    }
    return _isDetailHidden;
}

#pragma mark - IBActions

// 1.未提交-新建备案-显示隐藏栏、隐藏「新建备案」、显示导航栏按钮
- (void)editRecordButtonDidClicked:(id)sender {

    // 显示审核信息和备注信息 section
    section2.hidden = @NO;
    section3.hidden = @NO;
    section4.hidden = @YES;
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [self.tableView reloadData];
}

// 完成按钮
- (void)navigationBarDoneButtonDidClicked:(id)sender {
    // 1.放弃第一响应者
    [self.view endEditing:YES];
    
    // 2.验证输入项
    __block BOOL shouldReturn = NO;
    NSArray *array = [self formValidationErrors];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        XLFormValidationStatus *validationStatus = [[obj userInfo] objectForKey: XLValidationStatusErrorKey];
        // 转往省份、城市
        if ([validationStatus.rowDescriptor.tag isEqualToString:KProvinceAndCity]) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:validationStatus.rowDescriptor]];
            [self animateCell:cell];
            [MBProgressHUD hql_showTextHUD:validationStatus.msg];
            *stop = YES;
        }
        // 联系人姓名
        if ([validationStatus.rowDescriptor.tag isEqualToString:KContactName]) {
            shouldReturn = YES;
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:validationStatus.rowDescriptor]];
            [self animateCell:cell];
            [MBProgressHUD hql_showTextHUD:validationStatus.msg];
            *stop = YES;
        }
        // 联系人电话
        if ([validationStatus.rowDescriptor.tag isEqualToString:KPhoneNumber]) {
            shouldReturn = YES;
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:validationStatus.rowDescriptor]];
            [self animateCell:cell];
            [MBProgressHUD hql_showTextHUD:validationStatus.msg];
            *stop = YES;
        }
        // 联系人地址
        if ([validationStatus.rowDescriptor.tag isEqualToString:KAddress]) {
            shouldReturn = YES;
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:validationStatus.rowDescriptor]];
            [self animateCell:cell];
            [MBProgressHUD hql_showTextHUD:validationStatus.msg];
            *stop = YES;
        }
        // 一级医院
        if ([validationStatus.rowDescriptor.tag isEqualToString:KHospital1]) {
            shouldReturn = YES;
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:validationStatus.rowDescriptor]];
            [self animateCell:cell];
            [MBProgressHUD hql_showTextHUD:validationStatus.msg];
            *stop = YES;
        }
        // 一级医院
        if ([validationStatus.rowDescriptor.tag isEqualToString:KHospital1]) {
            shouldReturn = YES;
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:validationStatus.rowDescriptor]];
            [self animateCell:cell];
            [MBProgressHUD hql_showTextHUD:validationStatus.msg];
            *stop = YES;
        }
        // 二级级医院
        if ([validationStatus.rowDescriptor.tag isEqualToString:KHospital2]) {
            shouldReturn = YES;
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:validationStatus.rowDescriptor]];
            [self animateCell:cell];
            [MBProgressHUD hql_showTextHUD:validationStatus.msg];
            *stop = YES;
        }
        // 三级医院
        if ([validationStatus.rowDescriptor.tag isEqualToString:KHospital3]) {
            shouldReturn = YES;
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:validationStatus.rowDescriptor]];
            [self animateCell:cell];
            [MBProgressHUD hql_showTextHUD:validationStatus.msg];
            *stop = YES;
        }
    }];
    if (shouldReturn) {
        return;
    }
    
    // 更新请求数据模型
    NSDictionary *procinceAndCityDictioanry = self.httpParameters[KProvinceAndCity];

    HQLOffSiteMedicalTreatmentAppRecord1Model *model =
        [[HQLOffSiteMedicalTreatmentAppRecord1Model alloc] initWithIdNumber:_model.idNumber
                                                                   province:procinceAndCityDictioanry[@"province"]
                                                                       city:procinceAndCityDictioanry[@"city"]
                                                                  hospital1:self.httpParameters[KHospital1]
                                                                  hospital2:self.httpParameters[KHospital2]
                                                                  hospital3:self.httpParameters[KHospital3]
                                                                  startDate:self.httpParameters[KStartDate]
                                                                    endDate:self.httpParameters[KEndDate]
                                                                 recodeNote:self.httpParameters[KRecodeNote]
                                                                contactName:self.httpParameters[KContactName]
                                                                    address:self.httpParameters[KAddress]
                                                                phoneNumber:self.httpParameters[KPhoneNumber]
                                                                  abordType:self.httpParameters[KAbordType]
                                                                   cityType:self.httpParameters[KCityType]];
    
    // 发起请求
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"请稍候...";
    
    HQLURL_20_2 *api = [[HQLURL_20_2 alloc] initWithRecordModel:model];
    [api startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        [hud hideAnimated:YES];
        
        // AES解密
        NSString *resultString = request.responseJSONObject[@"resultData"];
        NSDictionary *dictionary = [AESCipher decryptAES:resultString key:KEY];
        BLYLogDebug(@"[URL_20_2] Result Model:\n%@",dictionary);
        
        BOOL isMsgflagTrue = [dictionary[@"msgflag"] isEqualToString:@"0"];
        if (isMsgflagTrue) {
            // 打开照片上传页面
            HQLOffSiteMedicalTreatmentAppRecord2Model *model = [HQLOffSiteMedicalTreatmentAppRecord2Model modelWithJSON:dictionary[@"msg"]];
            HQLOffSiteMedicalTreatmentAppRecord2ViewController *viewController = [[HQLOffSiteMedicalTreatmentAppRecord2ViewController alloc] initWithIDNumber:self->_model.idNumber AppRecord2Model:model];
            [self.navigationController pushViewController:viewController animated:YES];
        }else {
            BOOL isMsgNull = [dictionary[@"msg"] isEqual:[NSNull null]];
            [MBProgressHUD hql_showTextHUD:isMsgNull ? @"错误提示：返回数据为空" : dictionary[@"msg"]];
        }
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        [hud hideAnimated:YES];
        [MBProgressHUD hql_showErrorHUD:request.error.localizedDescription];
    }];
}

#pragma mark - Private

// 初始化页面，请求数据
- (void)requestServer {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"请稍候...";
    
    HQLURL_20_1 *api = [[HQLURL_20_1 alloc] init];
    [api startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        [hud hideAnimated:YES];
        
        // AES解密
        NSString *resultString = request.responseJSONObject[@"resultData"];
        NSDictionary *dictionary = [AESCipher decryptAES:resultString key:KEY];
        BLYLogDebug(@"[URL_20_1] Result Model:\n%@",dictionary);
        
        BOOL isMsgflagTrue = [dictionary[@"msgflag"] isEqualToString:@"0"];
        if (isMsgflagTrue) {
             HQLOffSiteMedicalTreatmentAppRecord1Model *model = [HQLOffSiteMedicalTreatmentAppRecord1Model modelWithJSON:dictionary[@"msg"]];
            self.model = model;
            [self initializeForm];
            [self setupNavigationRightButton];
        }else {
            [MBProgressHUD hql_showTextHUD:dictionary[@"msg"]];
        }
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        [hud hideAnimated:YES];
        [MBProgressHUD hql_showErrorHUD:request.error.localizedDescription];
    }];
}

- (void)setupNavigationRightButton {
    // 导航栏「提交备案」按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"提交备案" style:UIBarButtonItemStyleDone target:self action:@selector(navigationBarDoneButtonDidClicked:)];
    switch (_model.recordState) {
        case HQLOffSiteMedicalTreatmentRecordStateCheckFailure:
            self.navigationItem.rightBarButtonItem.enabled = YES;
            break;
        case HQLOffSiteMedicalTreatmentRecordStateDefault:
        case HQLOffSiteMedicalTreatmentRecordStateUploadSucceed:
        case HQLOffSiteMedicalTreatmentRecordStateCheckSucceed:
            self.navigationItem.rightBarButtonItem.enabled = NO;
            break;
    }
}

// 正则表达式验证某一行失败后，使用动画抖动该行进行提示。
-(void)animateCell:(UITableViewCell *)cell {
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

/**
 表单项中的值被修改后调用
 1. 判断开始时间 < 结束时间;
 */
- (void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue {
    [super formRowDescriptorValueHasChanged:formRow oldValue:oldValue newValue:newValue];
    
    // 「开始时间」被修改
    if ([formRow.tag isEqualToString:KStartDate]) {
        // 修改结束时间，结束时间为6个月之后的时间
        XLFormRowDescriptor *endDateRow = [self.form formRowWithTag:KEndDate];
        NSDate *endDate = [(NSDate *)newValue dateByAddingMonths:6];
        // 更新「结束时间」日期选择器
        [endDateRow.cellConfig setObject:endDate forKey:@"minimumDate"];
        endDateRow.value = endDate;
        [self reloadFormRow:endDateRow];
    }
}

@end
```

