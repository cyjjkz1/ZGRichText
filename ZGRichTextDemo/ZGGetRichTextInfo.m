//
//  ZGGetRichTextInfo.m
//  ZGRichTextDemo
//
//  Created by mac on 14-7-16.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import "ZGGetRichTextInfo.h"

static ZGGetRichTextInfo *sharedGetTextInformation = nil;

CGFloat imageSize = 30.0;

@implementation ZGGetRichTextInfo

@synthesize theEmotionImagesArray;//Store the  image and  location  of emotion in recreate attribute string

@synthesize emotionAndBounds;//store the image of emotion and CGRect

@synthesize drawEmotionFont;

@synthesize drawTextWithFont;

@synthesize theStringCTFrame;

@synthesize textColor;

@synthesize imageCount;

@synthesize suggestTextSize;

@synthesize ctFrame;

@synthesize targetRunCGRect;

@synthesize isSendByMyself;

@synthesize isUsingInConversation;

@synthesize theLastCTLinePoint;

@synthesize theLastCTLineWidth;

@synthesize theLastCTLineHeight;

@synthesize richTextLines;

@synthesize lastMessageWidth;


+ (ZGGetRichTextInfo*) sharedInstance  //第二步：实例构造检查静态实例是否为nil
{
    @synchronized (self)
    {
        if (sharedGetTextInformation == nil)
        {
            sharedGetTextInformation = [[self alloc] init];
        }
    }
    return sharedGetTextInformation;
}

+ (id) allocWithZone:(NSZone *)zone //第三步：重写allocWithZone方法
{
    @synchronized (self) {
        if (sharedGetTextInformation == nil) {
            sharedGetTextInformation = [super allocWithZone:zone];
            return sharedGetTextInformation;
        }
    }
    return nil;
}

- (id) copyWithZone:(NSZone *)zone //第四步
{
    return self;
}

- (id)init
{
    @synchronized(self)
    {
        self = [super init];
        if (self) {
            NSDictionary *emotionDicNew = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"emotion_en_new" ofType:@"plist"]];
            
            NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
            
            for (NSString * key in emotionDicNew) {
        
                NSString *emotionFileName = [emotionDicNew objectForKey:key];
                
                UIImage *image = [UIImage imageNamed:emotionFileName];
                
                [tempDic setObject:image forKey:key];
                
                emotionFileName = nil;
                
                image           = nil;
            }
            
            emotionENtext = tempDic;
            
            emotionDicNew = nil;
            
            tempDic       = nil;
            
            theEmotionImagesArray  = [[NSMutableArray alloc] init];
            
            emotionAndBounds       = [[NSMutableArray alloc] init];
            
            
            //there has two line break mode
            CTParagraphStyleSetting lineBreakMode;
            CTLineBreakMode lineBreak = kCTLineBreakByWordWrapping;//kCTLineBreakByWordWrapping;
            lineBreakMode.spec = kCTParagraphStyleSpecifierLineBreakMode;
            lineBreakMode.value = &lineBreak;
            lineBreakMode.valueSize = sizeof(CTLineBreakMode);
            
            CTParagraphStyleSetting settings[] = {lineBreakMode};
            CTParagraphStyleRef style = CTParagraphStyleCreate(settings, 1);
            
            lineBreakDictionary = [NSMutableDictionary dictionaryWithObject:(__bridge id)style forKey:(id)kCTParagraphStyleAttributeName];
            
            CTParagraphStyleSetting lineBreakModeChar;
            CTLineBreakMode lineBreakChar = kCTLineBreakByCharWrapping;//kCTLineBreakByWordWrapping;
            lineBreakModeChar.spec = kCTParagraphStyleSpecifierLineBreakMode;
            lineBreakModeChar.value = &lineBreakChar;
            lineBreakModeChar.valueSize = sizeof(CTLineBreakMode);
        
            CTParagraphStyleSetting settingsChar[] = {lineBreakModeChar};
            CTParagraphStyleRef styleChar = CTParagraphStyleCreate(settingsChar, 1);
            
            lineBreakDictionaryChar = [NSMutableDictionary dictionaryWithObject:(__bridge id)styleChar forKey:(id)kCTParagraphStyleAttributeName];
            
            
            useChatListRegular = [[NSRegularExpression alloc] initWithPattern:@"\\[{1}[^\\[\\]]{2,6}(\\]{1})" options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators error:nil];
            
            NSString *webString = [self webURL];
            
            //the string of number regular expressions
            NSString *customString = @"(\\+65\\d{8}|\\+86\\d{11}|\\d{3}-\\d{8}|\\d{4}-\\d{7})|((\\d){5,24})|\\[{1}[^\\[\\]]{2,6}(\\]{1})";
            
            //the string of email regular expressions
            NSString *emailString = @"[a-zA-Z0-9\\+\\.\\_\\%\\-\\+]{1,256}\\@[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}(\\.[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25})+";
            
             //the regular can find the target string, for example email, number, link.
            useChatRegular =   [[NSRegularExpression alloc] initWithPattern:[NSString stringWithFormat:@"%@|%@|%@", emailString, customString, webString] options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators error:nil];
            
             //the regular can find email
            emailRegular = [[NSRegularExpression alloc] initWithPattern:@"[a-zA-Z0-9\\+\\.\\_\\%\\-\\+]{1,256}\\@[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}(\\.[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25})+" options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators error:nil];
            
             //the regular can find number
            numberRegular = [[NSRegularExpression alloc] initWithPattern:@"(^\\+65\\d{8}|\\+86\\d{11}|\\d{3}-\\d{8}|\\d{4}-\\d{7})|((\\d){5,24})" options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators error:nil];
            
             //the regular can find link
            linkRegular = [[NSRegularExpression alloc] initWithPattern:webString options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators error:nil];
            
            targetRunCGRect = [[NSMutableDictionary alloc] init];
            imageCount = 0;
            
            useInChatFont = [UIFont fontWithName:@"HelveticaNeue" size:17];
            
            useInConversationFont = [UIFont fontWithName:@"HelveticaNeue" size:16];
            
            linkColor = [UIColor colorWithRed:36.0/255.0 green:154.0/255.0 blue:196.0/255.0 alpha:1];
        }
        return self;
    }
}


- (NSString *)webURL {//the string of the link Regular expressions
    
    NSString *TOP_LEVEL_DOMAIN_STR_FOR_WEB_URL = @"(?:\
(?:aero|arpa|asia|a[cdefgilmnoqrstuwxz])\
|(?:biz|b[abdefghijmnorstvwyz])\
|(?:cat|com|coop|c[acdfghiklmnoruvxyz])\
|d[ejkmoz]\
|(?:edu|e[cegrstu])\
|f[ijkmor]\
|(?:gov|g[abdefghilmnpqrstuwy])\
|h[kmnrtu]\
|(?:info|int|i[delmnoqrst])\
|(?:jobs|j[emop])\
|k[eghimnprwyz]\
|l[abcikrstuvy]\
|(?:mil|mobi|museum|m[acdeghklmnopqrstuvwxyz])\
|(?:name|net|n[acefgilopruz])\
|(?:org|om)\
|(?:pro|p[aefghklmnrstwy])\
|qa\
|r[eosuw]\
|s[abcdeghijklmnortuvyz]\
|(?:tel|travel|t[cdfghjklmnoprtvwz])\
|u[agksyz]\
|v[aceginu]\
|w[fs]\
|(?:\u03b4\u03bf\u03ba\u03b9\u03bc\u03ae|\u0438\u0441\u043f\u044b\u0442\u0430\u043d\u0438\u0435|\u0440\u0444|\u0441\u0440\u0431|\u05d8\u05e2\u05e1\u05d8|\u0622\u0632\u0645\u0627\u06cc\u0634\u06cc|\u0625\u062e\u062a\u0628\u0627\u0631|\u0627\u0644\u0627\u0631\u062f\u0646|\u0627\u0644\u062c\u0632\u0627\u0626\u0631|\u0627\u0644\u0633\u0639\u0648\u062f\u064a\u0629|\u0627\u0644\u0645\u063a\u0631\u0628|\u0627\u0645\u0627\u0631\u0627\u062a|\u0628\u06be\u0627\u0631\u062a|\u062a\u0648\u0646\u0633|\u0633\u0648\u0631\u064a\u0629|\u0641\u0644\u0633\u0637\u064a\u0646|\u0642\u0637\u0631|\u0645\u0635\u0631|\u092a\u0930\u0940\u0915\u094d\u0937\u093e|\u092d\u093e\u0930\u0924|\u09ad\u09be\u09b0\u09a4|\u0a2d\u0a3e\u0a30\u0a24|\u0aad\u0abe\u0ab0\u0aa4|\u0b87\u0ba8\u0bcd\u0ba4\u0bbf\u0baf\u0bbe|\u0b87\u0bb2\u0b99\u0bcd\u0b95\u0bc8|\u0b9a\u0bbf\u0b99\u0bcd\u0b95\u0baa\u0bcd\u0baa\u0bc2\u0bb0\u0bcd|\u0baa\u0bb0\u0bbf\u0b9f\u0bcd\u0b9a\u0bc8|\u0c2d\u0c3e\u0c30\u0c24\u0c4d|\u0dbd\u0d82\u0d9a\u0dcf|\u0e44\u0e17\u0e22|\u30c6\u30b9\u30c8|\u4e2d\u56fd|\u4e2d\u570b|\u53f0\u6e7e|\u53f0\u7063|\u65b0\u52a0\u5761|\u6d4b\u8bd5|\u6e2c\u8a66|\u9999\u6e2f|\ud14c\uc2a4\ud2b8|\ud55c\uad6d|xn\\-\\-0zwm56d|xn\\-\\-11b5bs3a9aj6g|xn\\-\\-3e0b707e|xn\\-\\-45brj9c|xn\\-\\-80akhbyknj4f|xn\\-\\-90a3ac|xn\\-\\-9t4b11yi5a|xn\\-\\-clchc0ea0b2g2a9gcd|xn\\-\\-deba0ad|xn\\-\\-fiqs8s|xn\\-\\-fiqz9s|xn\\-\\-fpcrj9c3d|xn\\-\\-fzc2c9e2c|xn\\-\\-g6w251d|xn\\-\\-gecrj9c|xn\\-\\-h2brj9c|xn\\-\\-hgbk6aj7f53bba|xn\\-\\-hlcj6aya9esc7a|xn\\-\\-j6w193g|xn\\-\\-jxalpdlp|xn\\-\\-kgbechtv|xn\\-\\-kprw13d|xn\\-\\-kpry57d|xn\\-\\-lgbbat1ad8j|xn\\-\\-mgbaam7a8h|xn\\-\\-mgbayh7gpa|xn\\-\\-mgbbh1a71e|xn\\-\\-mgbc0a9azcg|xn\\-\\-mgberp4a5d4ar|xn\\-\\-o3cw4h|xn\\-\\-ogbpf8fl|xn\\-\\-p1ai|xn\\-\\-pgbs0dh|xn\\-\\-s9brj9c|xn\\-\\-wgbh1c|xn\\-\\-wgbl6a|xn\\-\\-xkc2al3hye2a|xn\\-\\-xkc2dl3a5ee0h|xn\\-\\-yfro4i67o|xn\\-\\-ygbi2ammx|xn\\-\\-zckzah|xxx)\
|y[et]\
|z[amw]))";
    NSString *GOOD_IRI_CHAR = @"a-zA-Z0-9\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF";
    NSString *pattern = [NSString stringWithFormat:@"((?:(http|https|Http|Https|rtsp|Rtsp|irc|ircs):\\/\\/(?:(?:[a-zA-Z0-9\\$\\-\\_\\.\\+\\!\\*\\'\\(\\)\
\\,\\;\\?\\&\\=]|(?:\\%%[a-fA-F0-9]{2})){1,64}(?:\\:(?:[a-zA-Z0-9\\$\\-\\_\
\\.\\+\\!\\*\\'\\(\\)\\,\\;\\?\\&\\=]|(?:\\%%[a-fA-F0-9]{2})){1,25})?\\@)?)?\
((?:(?:[%@][%@\\-]{0,64}\\.)+%@\
|(?:(?:25[0-5]|2[0-4]\
[0-9]|[0-1][0-9]{2}|[1-9][0-9]|[1-9])\\.(?:25[0-5]|2[0-4][0-9]\
|[0-1][0-9]{2}|[1-9][0-9]|[1-9]|0)\\.(?:25[0-5]|2[0-4][0-9]|[0-1]\
[0-9]{2}|[1-9][0-9]|[1-9]|0)\\.(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}\
|[1-9][0-9]|[0-9])))\
(?:\\:\\d{1,5})?)\
(\\/(?:(?:[%@\\;\\/\\?\\:\\@\\&\\=\\#\\~\\$\
\\-\\.\\+\\!\\*\\'\\(\\)\\,\\_])|(?:\\%%[a-fA-F0-9]{2}))*)?\
(?:\\b|$)", GOOD_IRI_CHAR, GOOD_IRI_CHAR, TOP_LEVEL_DOMAIN_STR_FOR_WEB_URL, GOOD_IRI_CHAR];
    
    
    return pattern;
}

- (void)attachEmotionImageWithText:(NSString *)markup maxSize:(CGSize)maxSize
{
    @autoreleasepool {
        [self clearCashAStringInfo];
        
        
        if (isUsingInConversation == YES) {
            drawTextWithFont = useInConversationFont;
            drawEmotionFont = useInConversationFont;
        }else{
            drawTextWithFont = useInChatFont;
            drawEmotionFont = useInChatFont;
        }
        imageSize = drawEmotionFont.pointSize * 1.5;
        
        
        if (markup == nil || [markup isEqualToString:@""]) {
            return;
        }
        
        NSMutableAttributedString *theAttributedString = [self attributeStringFromMarkup:markup];
        
        [theAttributedString appendAttributedString: [[NSAttributedString alloc] initWithString:@" " attributes:nil]];
        if (isUsingInConversation == NO) {
            [theAttributedString addAttributes:lineBreakDictionary range:NSMakeRange(0, [theAttributedString length]-1)];
        }else{
            [theAttributedString addAttributes:lineBreakDictionaryChar range:NSMakeRange(0, [theAttributedString length]-1)];
        }
        
        
        CGSize suggestMaxSize = CGSizeMake(([theEmotionImagesArray count] >= 1)? maxSize.width+6:maxSize.width, maxSize.height);
        
        CTFramesetterRef ctFramesetter = CTFramesetterCreateWithAttributedString((CFMutableAttributedStringRef)theAttributedString);
        CGSize suggestFrame = CTFramesetterSuggestFrameSizeWithConstraints(ctFramesetter, CFRangeMake(0, 0), NULL, suggestMaxSize, NULL);
        CGSize theAttributedSize = CGSizeMake( floorf(suggestFrame.width+1) , floorf(suggestFrame.height+1));
        suggestTextSize = CGSizeMake(suggestFrame.width, suggestFrame.height);
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGRect bounds = CGRectMake(0.0, 0.0, theAttributedSize.width, theAttributedSize.height);
        CGPathAddRect(path, NULL, bounds);
        
        self.ctFrame = CTFramesetterCreateFrame(ctFramesetter,CFRangeMake(0, 0), path, NULL);
        CFRelease(path);
        CFRelease(ctFramesetter);
        
        CGPoint *lineOrigins;
        CFArrayRef ctLines = (CFArrayRef)CTFrameGetLines(ctFrame);
        CGPoint lineOriginsArray[CFArrayGetCount(ctLines)];
        lineOrigins = lineOriginsArray;
        CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), lineOrigins);
        
        int emotionIndex = 0;
        
        NSDictionary *nextEmotion;
        NSString *theEmotionName;
        if ([theEmotionImagesArray count] != 0) {
            nextEmotion = [theEmotionImagesArray objectAtIndex:emotionIndex];
            theEmotionName = [nextEmotion objectForKey:IMG_DIC_KEY_FILENAME];
        }
        
        int emotionCount = [theEmotionImagesArray count];
        richTextLines = CFArrayGetCount(ctLines);
        for (int i = 0; i < richTextLines; i++) {
            CTLineRef line = (CTLineRef)CFArrayGetValueAtIndex(ctLines, i);
            CGFloat lineAscent;
            CGFloat lineDescent;
            CGFloat lineLeading;
            
            double width = CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
            
            CFArrayRef runs = (CFArrayRef)CTLineGetGlyphRuns(line);
            CGPoint lineOrigin = lineOrigins[i];//the CGPoint of the CTLine
            
            if (i == (richTextLines - 1) ) {
                theLastCTLineWidth = width;
                theLastCTLinePoint = CGPointMake(lineOrigin.x, suggestTextSize.height - lineOrigin.y - lineDescent);
                theLastCTLineHeight = floorf(lineAscent + lineDescent + 1);
            }
            for (int j = 0; j < CFArrayGetCount(runs); j++) {
                
                CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runs, j);//get the CTRun
                CFRange runRange = CTRunGetStringRange(run);
                
                
                NSDictionary* attributes = (NSDictionary*)CTRunGetAttributes(run);
                NSString *emotionName = [attributes objectForKey:IMG_DIC_KEY_FILENAME];
                //            int location = [[attributes objectForKey:IMG_DIC_KEY_LOCATION] intValue];
                
                if (emotionName != nil && [theEmotionName isEqualToString:emotionName] == YES) {//ctRun
                    
                    CGRect runBounds;
                    
                    runBounds = CGRectMake(lineOrigin.x + CTLineGetOffsetForStringIndex(line, runRange.location, NULL), lineOrigin.y - imageSize*0.2, imageSize, imageSize);
                    
                    //                UIImage *theEmotionImg = [UIImage imageNamed:[nextEmotion objectForKey:IMG_DIC_KEY_FILENAME]];
                    //                UIImage *theEmotionImg = [[UIImage alloc] initWithContentsOfFile:[nextEmotion objectForKey:IMG_DIC_KEY_FILENAME]];
                    //                    NSString *path = [[NSBundle mainBundle] pathForResource:[nextEmotion objectForKey:IMG_DIC_KEY_FILENAME] ofType:@"png"];
                    //                    UIImage *theEmotionImg = [UIImage imageWithContentsOfFile:path];
                    CGPathRef pathRef = CTFrameGetPath(ctFrame); //10
                    CGRect colRect = CGPathGetBoundingBox(pathRef);
                    CGRect imgBounds = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y);
                    
                    [emotionAndBounds addObject:[NSArray arrayWithObjects:emotionName, NSStringFromCGRect(imgBounds), nil]];
                    
                    emotionIndex++;//访问下一个表情
                    if (emotionIndex < emotionCount) {
                        nextEmotion = [theEmotionImagesArray objectAtIndex:emotionIndex];
                        theEmotionName = [nextEmotion objectForKey:IMG_DIC_KEY_FILENAME];
                    }
                }
                
                NSString *number = [attributes objectForKey:NUMBER_ATTRIBUTE];
                NSString *link = [attributes objectForKey:HYPER_LINK_ATTRIBUTE];
                NSString *email = [attributes objectForKey:EMAIL_ATTRIBUTE];
                if ((number != nil && [number length] > 0) || (link != nil && [link length] > 0) || (email != nil && [email length] > 0)) {
                    CGFloat runAscent,runDescent;
                    CGFloat runWidth  = CTRunGetTypographicBounds(run, CFRangeMake(0,0), &runAscent, &runDescent, NULL);
                    CGFloat runHeight = runAscent + runDescent;
                    CGFloat runPointX = lineOrigin.x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
                    CGFloat runPointY =  suggestTextSize.height - lineOrigin.y - runHeight;
                    
                    CGRect runRect = CGRectMake(runPointX, runPointY, runWidth, runHeight);
                    
                    if (number != nil && [number length] > 0) {
                        NSArray *targetArray = [NSArray arrayWithObjects:[NSNumber numberWithInt:2], number, nil];
                        [targetRunCGRect setObject:targetArray forKey:[NSValue valueWithCGRect:runRect]];
                        
                    }
                    
                    if (link != nil && [link length] > 0) {
                        NSArray *targetArray = [NSArray arrayWithObjects:[NSNumber numberWithInt:3], link, nil];
                        [targetRunCGRect setObject:targetArray forKey:[NSValue valueWithCGRect:runRect]];
                    }
                    
                    
                    if (email != nil && [email length] > 0) {
                        NSArray *targetArray = [NSArray arrayWithObjects:[NSNumber numberWithInt:4], email, nil];
                        [targetRunCGRect setObject:targetArray forKey:[NSValue valueWithCGRect:runRect]];
                    }
                    
                }
                
            }
        }
    }
}

- (void)clearCashAStringInfo
{
    
    [theEmotionImagesArray removeAllObjects];
    [emotionAndBounds removeAllObjects];
    [targetRunCGRect removeAllObjects];
}


- (NSMutableAttributedString *)attributeStringFromMarkup:(NSString *) markupText
{
    @autoreleasepool {
        
        NSMutableAttributedString *attributeString;
        
        UIColor *theNoTargetStringColor = [UIColor blackColor];// the normal text color
        
        if (isUsingInConversation == YES) {
            theNoTargetStringColor = [UIColor lightGrayColor];
        }
        
        NSArray* chunks = nil;
        
        if (isUsingInConversation == YES) {
            chunks = [useChatListRegular matchesInString:markupText options:0
                                                   range:NSMakeRange(0, [markupText length])];
        }else{
            chunks = [useChatRegular matchesInString:markupText options:0
                                               range:NSMakeRange(0, [markupText length])];
        }
        
        
        BOOL isAddAttribute = NO;
        
        
        if ([chunks count] == 0 || chunks == nil) {//the text hasn't target string
            //set the text font and color
            NSDictionary *attributeDictionaryDelegate = [NSDictionary dictionaryWithObjectsAndKeys:drawTextWithFont, (NSString*)kCTFontAttributeName, theNoTargetStringColor, (NSString *)kCTForegroundColorAttributeName, nil];
            
            attributeString = [[NSMutableAttributedString alloc] initWithString:markupText attributes:attributeDictionaryDelegate];
            
            attributeDictionaryDelegate = nil;
            
        }else//the text has some target string
        {
            attributeString = [[NSMutableAttributedString alloc] init];
            
            int targetArrayCount = [chunks count];
            
            for (int i = 0; i < targetArrayCount; i++)
            {
                NSTextCheckingResult *result = [chunks objectAtIndex:i];
                
                NSRange resultRange = result.range;
                
                if (i == 0) {//handle the string fornt of the frist string
                    NSString *previousString = [markupText substringWithRange:NSMakeRange(0, resultRange.location)];//the frist target string hasn't the general string
                    
                    if (previousString != nil && [previousString length] > 0) {
                        NSDictionary *attributeDictionaryDelegate = [NSDictionary dictionaryWithObjectsAndKeys:drawTextWithFont, (NSString*)kCTFontAttributeName, theNoTargetStringColor, (NSString *)kCTForegroundColorAttributeName, nil];
                        
                        [attributeString appendAttributedString:[[NSAttributedString alloc] initWithString:previousString attributes:attributeDictionaryDelegate]];
                    }
                }
                
                //handle the target string, the emtion, the number, the link, and so on
                
                NSString *theTargetString = [markupText substringWithRange:resultRange];//get the target string from text
                
                TargetStringType stringType = [self judgeTheTargetStringType:theTargetString];//judge the target string style
                
                if (stringType == kTargetStringEmotion) {//add the property with the target string
                    if (theTargetString != nil && [theTargetString length] > 0) {//handle the emotion target string
                        
                        CTRunDelegateCallbacks imageCallbacks;
                        imageCallbacks.version = kCTRunDelegateVersion1;
                        imageCallbacks.dealloc = RunDelegateDeallocCallback;
                        imageCallbacks.getAscent = RunDelegateGetAscentCallback;
                        imageCallbacks.getDescent = RunDelegateGetDescentCallback;
                        imageCallbacks.getWidth = RunDelegateGetWidthCallback;
                        
                        CTRunDelegateRef iamgeDelegate = CTRunDelegateCreate(&imageCallbacks, NULL);
                        
                        NSDictionary *attrDictionaryDelegate;
                        
                        //handle some emotion missed because the emtions has the same property.
                        if (isAddAttribute == YES) {
                            
                            attrDictionaryDelegate = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      (__bridge id)iamgeDelegate,  (NSString*)kCTRunDelegateAttributeName,
                                                      [UIColor clearColor].CGColor, (NSString*)kCTForegroundColorAttributeName,
                                                      drawEmotionFont, (NSString*)kCTFontAttributeName, theTargetString, IMG_DIC_KEY_FILENAME, nil];
                            isAddAttribute = NO;
                        }else{
                            
                            attrDictionaryDelegate = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      (__bridge id)iamgeDelegate,  (NSString*)kCTRunDelegateAttributeName,
                                                      [UIColor clearColor].CGColor, (NSString*)kCTForegroundColorAttributeName,
                                                      drawEmotionFont, (NSString*)kCTFontAttributeName, theTargetString, IMG_DIC_KEY_FILENAME,  @"aaa", @"111", nil];
                            isAddAttribute = YES;
                        }
                        
                        //change the emtion string to "-"
                        NSMutableAttributedString *theEmotionPoint = [[NSMutableAttributedString alloc] initWithString:@"-" attributes:attrDictionaryDelegate];
                        
                        [attributeString appendAttributedString:theEmotionPoint];
                        
                        imageCount++;
                        
                        [theEmotionImagesArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:theTargetString, IMG_DIC_KEY_FILENAME, [NSNumber numberWithInt:[attributeString length] - 1],IMG_DIC_KEY_LOCATION, nil]];//so we store the "-" location and file name
                        
                        CFRelease(iamgeDelegate);
                        
                    }else{//the taeget string isn't contain in the emotion dictionary, so we handle it the general string
                        NSDictionary *attributeDictionaryDelegate = [NSDictionary dictionaryWithObjectsAndKeys:drawTextWithFont, (NSString*)kCTFontAttributeName, theNoTargetStringColor, (NSString *)kCTForegroundColorAttributeName, nil];
                        
                        
                        [attributeString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[markupText substringWithRange:resultRange] attributes:attributeDictionaryDelegate]];
                    }
                    
                }else{//handle the target string
                    
                    NSMutableDictionary *attrDictionaryDelegate = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                   drawTextWithFont, (NSString*)kCTFontAttributeName,
                                                                   (id)linkColor, (NSString *)kCTForegroundColorAttributeName,
                                                                   (id)[NSNumber numberWithInt:kCTUnderlineStyleSingle], (NSString *)kCTUnderlineStyleAttributeName, nil];
                    
                    switch (stringType) {
                        case kTargetStringLink:
                            [attrDictionaryDelegate setObject:theTargetString forKey:HYPER_LINK_ATTRIBUTE];
                            break;
                        case kTargetStringNumber:
                            [attrDictionaryDelegate setObject:theTargetString forKey:NUMBER_ATTRIBUTE];
                            break;
                        case kTargetStringEmail:
                            [attrDictionaryDelegate setObject:theTargetString forKey:EMAIL_ATTRIBUTE];
                            break;
                        default:
                            break;
                    }
                    
                    
                    NSMutableAttributedString *theLink = [[NSMutableAttributedString alloc] initWithString:theTargetString attributes:attrDictionaryDelegate];
                    
                    [attributeString appendAttributedString:theLink];
                    
                }
                
                //handle the tail of the target string
                if ((i + 1) < targetArrayCount) {
                    NSTextCheckingResult *theNextResult = [chunks objectAtIndex:(i + 1)];
                    
                    NSRange theNextRange = theNextResult.range;
                    
                    NSRange theLastStringRange = NSMakeRange((resultRange.location + resultRange.length), (theNextRange.location - (resultRange.location + resultRange.length)));
                    
                    //设置字体的颜色
                    NSDictionary *attributeDictionaryDelegate = [NSDictionary dictionaryWithObjectsAndKeys:drawTextWithFont, (NSString*)kCTFontAttributeName, theNoTargetStringColor, (NSString *)kCTForegroundColorAttributeName, nil];
                    
                    [attributeString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[markupText substringWithRange:theLastStringRange] attributes:attributeDictionaryDelegate]];
                }else{//handle the tail of markupText
                    NSRange theLastStringRange = NSMakeRange((resultRange.location + resultRange.length), [markupText length] - (resultRange.location + resultRange.length));
                    
                    NSDictionary *attributeDictionaryDelegate = [NSDictionary dictionaryWithObjectsAndKeys:drawTextWithFont, (NSString*)kCTFontAttributeName, theNoTargetStringColor, (NSString *)kCTForegroundColorAttributeName, nil];
                    
                    [attributeString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[markupText substringWithRange:theLastStringRange] attributes:attributeDictionaryDelegate]];
                }
                
            }
        }
        
        chunks = nil;
        
        return attributeString;
    }
    
}


- (TargetStringType)judgeTheTargetStringType:(NSString *)targetString
{
    TargetStringType type = kTargetStringNone;
    @autoreleasepool {
        
        if (targetString != nil) {
            if ([targetString hasPrefix:@"["] == YES && [targetString hasSuffix:@"]"] == YES && [targetString length] > 0 && [targetString length] <= 8) {
                type = kTargetStringEmotion;
            }else{
                NSArray* chunksEmail = [emailRegular matchesInString:targetString options:0
                                                               range:NSMakeRange(0, [targetString length])];
                
                if (chunksEmail != nil && [chunksEmail count] > 0) {
                    
                    type = kTargetStringEmail;
                    
                }else{
                    
                    NSArray* chunksLink = [linkRegular matchesInString:targetString options:0
                                                                 range:NSMakeRange(0, [targetString length])];
                    
                    
                    if (chunksLink != nil && [chunksLink count] > 0) {
                        type = kTargetStringLink;
                    }else{
                        NSArray* chunksNumber = [numberRegular matchesInString:targetString options:0
                                                                         range:NSMakeRange(0, [targetString length])];
                        if (chunksNumber != nil && [chunksNumber count] > 0) {
                            type = kTargetStringNumber;
                        }
                        chunksNumber = nil;
                    }
                    chunksLink = nil;
                }
                chunksEmail = nil;
                
                
            }
        }
    }
    return type;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - CTRunDelegateCallbacks

static void RunDelegateDeallocCallback( void* refCon ){
    
}

static CGFloat RunDelegateGetAscentCallback( void *refCon ){
    
    return imageSize;
}

static CGFloat RunDelegateGetDescentCallback(void *refCon){
    return 0;
}

static CGFloat RunDelegateGetWidthCallback(void *refCon){
    
    return imageSize;
}

@end
