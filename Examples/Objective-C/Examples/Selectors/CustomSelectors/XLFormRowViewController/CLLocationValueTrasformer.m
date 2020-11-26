//
//  CLLocationValueTrasformer.h
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

#import <MapKit/MapKit.h>
#import "CLLocationValueTrasformer.h"

@implementation CLLocationValueTrasformer

// 被转换成的类型
+ (Class)transformedValueClass
{
    return [NSString class];
}

// 是否允许反向转换
+ (BOOL)allowsReverseTransformation
{
    return NO;
}

// 被转换成的类型值格式
// MapViewController 给代理协议传的值是 CLLocation 对象，需要将其转换为字符串对象
- (id)transformedValue:(id)value
{
    if (!value) return nil;
    CLLocation * location = (CLLocation *)value;
    return [NSString stringWithFormat:@"%0.4f, %0.4f", location.coordinate.latitude, location.coordinate.longitude];
}

@end
