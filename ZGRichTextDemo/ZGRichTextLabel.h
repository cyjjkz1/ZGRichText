//
//  ZGRichTextLabel.h
//  ZGRichTextDemo
//
//  Created by mac on 14-7-16.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreText/CoreText.h>

#import <MessageUI/MFMailComposeViewController.h>

@class ZGGetRichTextInfo;

@interface ZGRichTextLabel : UIView<UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
{
    NSString *phoneNumber;
    MFMailComposeViewController *mailVC;
}
@property(strong, nonatomic) NSMutableArray *emotionAndBoundsInLabel;

@property (strong, nonatomic) NSMutableDictionary *targetRunCGRectInLabel;

@property (assign, nonatomic) CTFrameRef theStringCTFrameInLabel;

@property (assign, nonatomic) int lineLimit;

@property (strong, nonatomic) NSMutableAttributedString *attributedString;

@property (assign, nonatomic) BOOL isUsingconversation;

@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;

- (id)initWithFrame:(CGRect)frame wiTextInformation:(ZGGetRichTextInfo *)getInfo;

@end
