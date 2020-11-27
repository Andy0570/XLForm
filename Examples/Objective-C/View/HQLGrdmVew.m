//
//  HQLGrdmVew.m
//  XuZhouSS
//
//  Created by Qilin Hu on 2018/7/6.
//  Copyright © 2018年 ToninTech. All rights reserved.
//

#import "HQLGrdmVew.h"

// Framework
#import <Masonry.h>
#import <Chameleon.h>

@interface HQLGrdmVew ()

@property (nonatomic, strong, readwrite) UILabel *titleLabel;
@property (nonatomic, strong, readwrite) UIImageView *imageView;

@end
@implementation HQLGrdmVew

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, 315, 265);
        self.backgroundColor = [UIColor whiteColor];
        [self addsubviews];
    }
    return self;
}

#pragma mark - Custom Accessors

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"社会保障卡";
        _titleLabel.font = [UIFont systemFontOfSize:16.0f];
        _titleLabel.textColor = HexColor(@"#1296db");
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"register_grdm"]];
    }
    return _imageView;
}

#pragma mark - Private

- (void)addsubviews {
    [self addSubview:self.titleLabel];
    [self addSubview:self.imageView];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).with.offset(15);
        make.centerX.equalTo(self.mas_centerX);
    }];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).with.offset(25);
        make.left.equalTo(self.mas_left).with.offset(20);
    }];
}

@end
