//
//  TLTextField.m
//  TLGaodeMap
//
//  Created by TAN on 2017/6/7.
//  Copyright © 2017年 zfsoft.com. All rights reserved.
//

#import "TLTextField.h"

@interface TLTextField ()<UITextFieldDelegate>
@end

@implementation TLTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setUpTextField];
    }
    return self;
}
// 设置
- (void)setUpTextField
{
   // 光标颜色
    self.tintColor=[UIColor lightGrayColor];
    self.backgroundColor=[UIColor whiteColor];
    self.placeholder=@"请输入关键词";
    self.font=[UIFont systemFontOfSize:14];
    self.leftViewMode=UITextFieldViewModeAlways;
    self.clearButtonMode=UITextFieldViewModeWhileEditing;
    //self.returnKeyType = UIReturnKeySearch;
}
// 设置leftView的位置
- (CGRect)leftViewRectForBounds:(CGRect)bounds
{
    CGRect leftRect = [super leftViewRectForBounds:bounds];
    leftRect.origin.x += 10; //右边偏10
    return leftRect;
}
// 设置rightView的位置
- (CGRect)rightViewRectForBounds:(CGRect)bounds
{
    CGRect rightRect = [super rightViewRectForBounds:bounds];
    rightRect.origin.x -= 10; //左边偏10
    return rightRect;
}
// 占位文字与输入框的距离
- (CGRect)textRectForBounds:(CGRect)bounds
{
    if (self.leftView) {
        return CGRectInset(bounds, 30, 0);
    }
    return CGRectInset(bounds, 10, 0);
}
//控制编辑文本的位置
- (CGRect)editingRectForBounds:(CGRect)bounds{
    if (self.leftView) {
        return CGRectInset(bounds, 30, 0);
    }
    return CGRectInset(bounds, 10, 0);
}

@end
