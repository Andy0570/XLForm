//
//  HQLPersonalQRCodeViewController.m
//  XLForm
//
//  Created by Qilin Hu on 2020/4/30.
//  Copyright © 2020 Qilin Hu. All rights reserved.
//

#import "HQLPersonalQRCodeViewController.h"

// Framework
#import <LBXScanNative.h>

@interface HQLPersonalQRCodeViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *avatorImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UIView *qrCodeContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImageView;

@end

@implementation HQLPersonalQRCodeViewController

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupQRCodeContainerView];
    [self setupUI];
}

#pragma mark - Private

- (void)setupQRCodeContainerView {
    self.qrCodeContainerView.backgroundColor = [UIColor whiteColor];
    self.qrCodeContainerView.layer.shadowOffset = CGSizeMake(0, 2);
    self.qrCodeContainerView.layer.shadowRadius = 2;
    self.qrCodeContainerView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.qrCodeContainerView.layer.shadowOpacity = 0.5;
}

- (void)setupUI {
    self.title = @"我的二维码";
    
    // 用户头像
    self.avatorImageView.image = [UIImage imageNamed:@"default_avatar"];
    
    // 用户昵称
    self.nickNameLabel.text = @"我的用户昵称";
    
    // 我的二维码
    NSString *code = @"cT3eAKvYq3k68CChSbB9jdPpEsenwsZ3a2KgAkdaNuWAKu";
    self.qrCodeImageView.image = [LBXScanNative createQRWithString:code QRSize:self.qrCodeImageView.bounds.size];
}

@end
