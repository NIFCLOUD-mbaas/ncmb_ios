//
//  CloseImageView.m
//  TestPopupWebView
//
//  Created by NIFTY Corporation on 2014/01/09.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//

#import "NCMBCloseImageView.h"


@implementation NCMBCloseImageView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = UIColor.clearColor; //背景を透明に
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBStrokeColor(context, 1, 1, 1, 1.0);
    CGContextSetLineWidth(context, 2.0);
    CGContextSetLineCap(context, kCGLineCapButt);
    
    CGContextMoveToPoint(context, 1, 1);
    CGContextAddLineToPoint(context, IMAGE_SIZE, IMAGE_SIZE);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, 1, IMAGE_SIZE);
    CGContextAddLineToPoint(context, IMAGE_SIZE, 1);
    CGContextStrokePath(context);
    
}

@end
