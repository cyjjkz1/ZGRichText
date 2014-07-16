//
//  ZGGetRichTextInfo.h
//  ZGRichTextDemo
//
//  Created by mac on 14-7-16.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreText/CoreText.h>

#define IMG_DIC_KEY_FILENAME @"0" //the file name of emotion image

#define IMG_DIC_KEY_LOCATION @"1" //the location of emotion in the text

#define NUMBER_ATTRIBUTE     @"3" //number for example telephone number "02883655315", "13541134278"

#define HYPER_LINK_ATTRIBUTE @"4" //link

#define EMAIL_ATTRIBUTE      @"5" //email

enum kTargetStringType
{
    kTargetStringNone,   //the normal text
    kTargetStringEmotion,//emotion
    kTargetStringNumber, //number
    kTargetStringLink,   //link
    kTargetStringEmail   //email
};

typedef enum kTargetStringType TargetStringType;

@interface ZGGetRichTextInfo : NSObject
{
    NSDictionary *emotionENtext;//the 
    
    NSMutableDictionary *lineBreakDictionary;
    
    NSMutableDictionary *lineBreakDictionaryChar;
    
    CTFontRef fontRef;
    
    NSRegularExpression *useChatListRegular;
    
    NSRegularExpression *useChatRegular;
    
    NSRegularExpression *emailRegular;
    NSRegularExpression *numberRegular;
    NSRegularExpression *linkRegular;
    
    UIFont *useInChatFont;
    UIFont *useInConversationFont;
    UIColor *linkColor;
}

@property (strong, nonatomic) NSMutableDictionary *targetRunCGRect;//目标字符串得位子可以保存下来()

@property (strong, nonatomic) NSMutableArray *theEmotionImagesArray;

@property (strong, nonatomic) NSMutableArray *emotionAndBounds;//表情和位子信息可以保存

@property (strong, nonatomic) UIFont *drawTextWithFont;

@property (strong, nonatomic) UIFont *drawEmotionFont;

@property (strong, nonatomic) UIColor *textColor;

@property (assign, nonatomic) CTFrameRef theStringCTFrame;

@property (assign, nonatomic) NSInteger imageCount;

@property (assign, nonatomic) CGSize suggestTextSize;

@property (assign, nonatomic) CTFrameRef ctFrame;

@property (assign, nonatomic) BOOL isSendByMyself;

@property (assign, nonatomic) BOOL isUsingInConversation;

@property (assign, nonatomic) CGFloat theLastCTLineWidth;

@property (assign, nonatomic) CGPoint theLastCTLinePoint;

@property (assign, nonatomic) CGFloat theLastCTLineHeight;

@property (assign, nonatomic) int richTextLines;

@property (assign, nonatomic) CGFloat lastMessageWidth;


+ (ZGGetRichTextInfo*) sharedInstance;

- (void)clearCanshStringInfo;

- (NSMutableAttributedString *)attributeStringFromMarkup:(NSString *) markup;

- (void)attachEmotionImageWithText:(NSString *)markup maxSize:(CGSize)maxSize;

@end
