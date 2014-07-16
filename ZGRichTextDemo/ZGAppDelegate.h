//
//  ZGAppDelegate.h
//  ZGRichTextDemo
//
//  Created by mac on 14-7-16.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZGAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSDictionary *emotionDictionary;
@end

extern ZGAppDelegate *shareAppDelegateInstance;