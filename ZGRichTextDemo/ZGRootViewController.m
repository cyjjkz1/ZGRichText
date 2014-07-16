//
//  ZGRootViewController.m
//  ZGRichTextDemo
//
//  Created by mac on 14-7-16.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import "ZGRootViewController.h"

#import "ZGGetRichTextInfo.h"

#import "ZGRichTextLabel.h"

@interface ZGRootViewController ()

@end

@implementation ZGRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *theContent = @"Find the location [B)] set go way [B)] [B)] you [/:-)][/:-)] have [B)] box [B)][B)]have http://www.cnblogs.com/zcw-ios/articles/2607985.html [:\"-)][:\"-)]Www.baidu.com google kite ok cyjjkz1@gmail.com HHS fcjcjcjc church's whir ugh fight Dutch finding HFCs gggg 477456899 jfcjjc chjckvkv www.sina.com jfcjjc gggg juddujf.";
    ZGGetRichTextInfo *getStringInformation = [ZGGetRichTextInfo sharedInstance];
    
    getStringInformation.isSendByMyself = YES;
    getStringInformation.isUsingInConversation = NO;
    
    [getStringInformation attachEmotionImageWithText:theContent maxSize:CGSizeMake(255, 10000)];
    
    ZGRichTextLabel *displayTxtMsgView = [[ZGRichTextLabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    displayTxtMsgView.emotionAndBoundsInLabel = getStringInformation.emotionAndBounds;
    displayTxtMsgView.targetRunCGRectInLabel = getStringInformation.targetRunCGRect;
    displayTxtMsgView.theStringCTFrameInLabel = getStringInformation.ctFrame;
    displayTxtMsgView.isUsingconversation = NO;
    displayTxtMsgView.frame = CGRectMake(10, 100, getStringInformation.suggestTextSize.width + 5.0, getStringInformation.suggestTextSize.height);

    [self.view addSubview:displayTxtMsgView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
