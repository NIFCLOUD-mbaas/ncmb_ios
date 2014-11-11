//
//  NCMBTwitterLoginView.h
//  NIFTY Cloud mobile backend
//
//  Created by NIFTY Corporation on 2014/10/31.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NCMBTwitterLoginView : UIWebView

@property (retain, nonatomic) UIButton* closeButton;
@property (retain, nonatomic) UIWebView *webView;

- (void) appearWebView:(UIInterfaceOrientation)interfaceOrientation;
- (void) closeWebView;
- (void) webviewDidFailLoad;
- (void) startWebViewLoading;
- (void) endWebViewLoading;

@end
