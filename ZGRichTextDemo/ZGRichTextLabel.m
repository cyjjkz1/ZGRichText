//
//  ZGRichTextLabel.m
//  ZGRichTextDemo
//
//  Created by mac on 14-7-16.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import "ZGRichTextLabel.h"

#import "ZGGetRichTextInfo.h"



@implementation ZGRichTextLabel

@synthesize emotionAndBoundsInLabel;
@synthesize targetRunCGRectInLabel;
@synthesize theStringCTFrameInLabel;
@synthesize isUsingconversation;
@synthesize tapGesture;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //        self.backgroundColor = [UIColor redColor];
        
        self.backgroundColor = [UIColor clearColor];
        
        self.userInteractionEnabled = YES;
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnTargetString:)];
        tapGesture.numberOfTouchesRequired = 1;
        
        
    }
    return self;
}

- (void)setIsUsingconversation:(BOOL)isUsing
{
    isUsingconversation = isUsing;
    if (isUsing != YES) {
        if (tapGesture != nil) {
            [self removeGestureRecognizer:tapGesture];
        }else{
            tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnTargetString:)];
            tapGesture.numberOfTouchesRequired = 1;
        }
        
        [self addGestureRecognizer:tapGesture];
    }
}


- (void)tapOnTargetString:(UITapGestureRecognizer *)theTapGesture
{
    CGPoint point = [theTapGesture locationInView:self];
    NSArray *runRectValueArray = [targetRunCGRectInLabel allKeys];
    for (NSValue *rectValue in runRectValueArray) {
        CGRect rect = [rectValue CGRectValue];
        if (CGRectContainsPoint(rect, point)) {
            NSArray *targetArray = [targetRunCGRectInLabel objectForKey:rectValue];
            int type = [[targetArray firstObject] intValue];
            NSString *targetString = [targetArray lastObject];
            if (targetString == nil) {
                continue;
            }
            
            UIPasteboard *pboard = [UIPasteboard generalPasteboard];
            if (targetString != nil && [targetString length] > 0) {
                pboard.string = targetString;
            }
            
            targetString = [targetString lowercaseString];
            
            
            switch (type) {
                case kTargetStringNumber:
                {
                  phoneNumber = targetString;
                  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phoneNumber]]];
                }
                    break;
                    
                case kTargetStringLink:
                {
                    
                    
                    if ([targetString hasPrefix:@"http://"] == YES) {
                        NSURL *url = [NSURL URLWithString:targetString];
                        if (url == nil) {
                            targetString = [targetString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                            url = [NSURL URLWithString:targetString];
                        }
                        url = [url standardizedURL];
                        BOOL ret = [[UIApplication sharedApplication] openURL:url];
                        if (ret == NO) {
                          
                        }
                    }else if([targetString hasPrefix:@"https://"] == YES)
                    {
                        NSURL *url = [NSURL URLWithString:targetString];
                        if (url == nil) {
                            targetString = [targetString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                            url = [NSURL URLWithString:targetString];
                        }
                        
                        url = [url standardizedURL];
                        BOOL ret = [[UIApplication sharedApplication] openURL:url];
                        if (ret == NO) {
                           
                        }
                        
                    }else{
                        targetString = [NSString stringWithFormat:@"http://%@", targetString];
                        
                        NSURL *url = [NSURL URLWithString:targetString];
                        if (url == nil) {
                            targetString = [targetString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                            url = [NSURL URLWithString:targetString];
                        }
                        
                        url = [url standardizedURL];
                        BOOL ret = [[UIApplication sharedApplication] openURL:url];
                        if (ret == NO) {
                           
                        }
                    }
                }
                    break;
                case kTargetStringEmail:
                {
                    
                    
                    
                    
                    
                    
                    //send email
                    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
                    
                    if (mailClass != nil)
                    {
                        if ([mailClass canSendMail])
                        {
                            mailVC = [[MFMailComposeViewController alloc] init];
                            
                            mailVC.mailComposeDelegate = self;
                            mailVC.title = @"Tell a Friend";
                            //设置主题
                            [mailVC setSubject: @"hi, ZG"];
                            
                            // 添加发送者
                            NSArray *toRecipients = [NSArray arrayWithObject: targetString];
                           
                            [mailVC setToRecipients: toRecipients];
                            
                            [shareAppDelegateInstance.window.rootViewController presentViewController:mailVC animated:YES completion:nil];
                        }
                        else
                        {
                            //                        [self launchMailAppOnDevice];
                        }
                    }
                    else
                    {
                        //                    [self launchMailAppOnDevice];
                    }
                    
                }
                    break;
                default:
                    break;
            }
            
        }
        
    }
}
-  (void)mailComposeController:(MFMailComposeViewController*)controller
           didFinishWithResult:(MFMailComposeResult)result
                         error:(NSError*)error
{
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
        {
            
        }
            break;
        case MFMailComposeResultSaved:
        {
            
        }
            break;
        case MFMailComposeResultSent:
        {
            
        }
            break;
        default:
        {
            //            [UIUtils AlertBoxSureTitle:nil body:_TT(@"EmailNotSend","alert box say that email failed for log&crash") delegate:self];
        }
            break;
    }
    [mailVC dismissViewControllerAnimated:YES completion:nil];
}

-(void)drawRect:(CGRect)rect{
    //    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextConcatCTM(ctx, CGAffineTransformScale(CGAffineTransformMakeTranslation(0, rect.size.height), 1.f, -1.f));
    
    CTFrameDraw(theStringCTFrameInLabel, ctx);
    
    for (int i = 0; i < [emotionAndBoundsInLabel count]; i++)
    {
        NSArray *imageData = [emotionAndBoundsInLabel objectAtIndex:i];
        if (imageData != nil && [imageData count] >0) {
            NSString* imgKey = [imageData objectAtIndex:0];
            CGRect imgBounds = CGRectFromString([imageData objectAtIndex:1]);
            
            CGContextDrawImage(ctx, imgBounds, ((UIImage *)[shareAppDelegateInstance.emotionDictionary objectForKey:imgKey]).CGImage);
        }
    }
}

- (void)dealloc
{
    phoneNumber = nil;
    self.emotionAndBoundsInLabel = nil;
    self.targetRunCGRectInLabel = nil;
    if (isUsingconversation == YES && self.theStringCTFrameInLabel != nil) {
        CFRelease(self.theStringCTFrameInLabel);
        self.theStringCTFrameInLabel = nil;
    }
    self.attributedString = nil;
    self.tapGesture = nil;
    
}
@end