//
//  RichPushView.h
//  TestPopupWebView
//
//  Created by NIFTY Corporation on 2014/01/09.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NCMBRichPushView : UIWebView

- (void) appearWebView:(UIInterfaceOrientation)interfaceOrientation url:(NSString*)richUrl;
- (void) sizingWebView:(UIInterfaceOrientation)interfaceOrientation;
- (void) closeWebView:(id)sender;

@end
