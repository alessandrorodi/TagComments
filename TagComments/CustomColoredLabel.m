//
//  customColoredLabel.m
//  gymEver
//
//  Created by Alessandro on 2015-01-04.
//  Copyright (c) 2015 alegiallo. All rights reserved.
//

#import "CustomColoredLabel.h"


@implementation CustomColoredLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(id)initWithFrame:(CGRect)frame{
    [self initializeLinkAttributes];

    self = [super initWithFrame:frame];
    if(self) self.delegate = self;
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    [self initializeLinkAttributes];

    self = [super initWithCoder:aDecoder];
    if(self) self.delegate = self;
    return self;
}
-(void)setText:(id)text{
    
    [super setText:text];
    [self colorUsernamesWithATag];

}

-(CGSize)sizeThatFits:(CGSize)size{
    return [TTTAttributedLabel sizeThatFitsAttributedString:self.attributedText withConstraints:size limitedToNumberOfLines:0];
}
/*
-(CGSize)sizeThatFits:(CGSize)size{
    return [super sizeThatFits:size];
}
*/
- (void)colorUsernamesWithATag{
    NSArray *words=[self.text componentsSeparatedByString:@" "];
    //Special checking for same username occurences
    NSInteger start = 0;
    
    NSInteger newLineStart = 0;

    //Color first word(username) if label is comment
    if(self.isComment){
    for (NSString *word in words) {
        NSRange checkRange = NSMakeRange(0, [self.text length] - 0);
        NSRange range = [self.text  rangeOfString:word options:0 range:checkRange];
        // DebugLog(@"range is %@ for string %@", NSStringFromRange(range), word);
        start = range.location + range.length;
        [self addLinkWithTextCheckingResult:[NSTextCheckingResult linkCheckingResultWithRange:range URL:[NSURL URLWithString:word]] attributes:self.mutableUsernameLabelLinkAttributes];
        self.activeLinkAttributes = self.mutableUsernameLabelActiveLinkAttributes;
        break;
    }

        
        for (NSString *word in words) {
            if ([word hasPrefix:@"\n"] && [word length]>2) {
               NSString* username = [word substringFromIndex:1];
                if(username){
                NSRange checkRange = NSMakeRange(newLineStart, [self.text length] - newLineStart);
                NSRange range = [self.text  rangeOfString:word options:0 range:checkRange];
                // DebugLog(@"range is %@ for string %@", NSStringFromRange(range), word);
                newLineStart = range.location + range.length;
                [self addLinkWithTextCheckingResult:[NSTextCheckingResult linkCheckingResultWithRange:range URL:[NSURL URLWithString:username]] attributes:self.mutableUsernameLabelLinkAttributes];
                }
            }
        }
    }

    NSString *tag = @"@";
    [self scanForWordWithPrefix:tag AndWords:words];
    
     NSString *hashTag = @"#";
    [self scanForWordWithPrefix:hashTag AndWords:words];

    
}

-(void)scanForWordWithPrefix:(NSString*)prefix AndWords:(NSArray*)words{
   NSInteger start = 0;
    for (NSString *word in words) {
        if ([word hasPrefix:prefix]) {
            
            //Checking for inception of signs
            NSArray *tagsInTags=[[word substringFromIndex:1] componentsSeparatedByString:prefix];
            if([tagsInTags count]>1){ // If there is more than one sign in the word
                NSInteger tagStart = 0;
                for (NSString *username in tagsInTags) {

                    NSString *usernameWord =   [self removeSpecialCharactersFromTag:username];
                    usernameWord = [NSString stringWithFormat:@"%@%@",prefix,usernameWord];
                    
                    //Skip one iteration if is equal to sign
                    if([usernameWord isEqualToString:prefix]) continue;
                    
                    NSRange checkRange = NSMakeRange(start, [self.text length] - start);
                    NSRange range = [self.text  rangeOfString:usernameWord options:0 range:checkRange];
                    // DebugLog(@"range is %@ for string %@", NSStringFromRange(range), word);
                    tagStart = range.location + range.length;
                    [self addLinkWithTextCheckingResult:[NSTextCheckingResult linkCheckingResultWithRange:range URL:[NSURL URLWithString:usernameWord]]];
                }
                
            }else{
                NSString *string =   [self removeSpecialCharactersFromTag:word];
                string = [NSString stringWithFormat:@"%@%@",prefix,string];
                NSRange checkRange = NSMakeRange(start, [self.text length] - start);
                NSRange range = [self.text  rangeOfString:string options:0 range:checkRange];
                // DebugLog(@"range is %@ for string %@", NSStringFromRange(range), word);
                if(range.length>0){
                start = range.location + range.length;
                
                [self addLinkWithTextCheckingResult:[NSTextCheckingResult linkCheckingResultWithRange:range URL:[NSURL URLWithString:string]]];
                }
            }
        }
    }
}

-(NSString*)removeSpecialCharactersFromTag:(NSString*)word{
    //Removing dots
    NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789"] invertedSet];
    NSString *resultString = [[word componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
    return resultString;
    
}

-(NSString*)removeSpecialCharactersFromHashTag:(NSString*)word{
    //Removing dots
    NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"#abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789"] invertedSet];
    NSString *resultString = [[word componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
    return resultString;
    
}
-(void)addLinkForUsername:(NSString*)username{
    [self initializeLinkAttributes];
    [self addLinkWithTextCheckingResult:[NSTextCheckingResult linkCheckingResultWithRange:NSMakeRange(0, [username length]) URL:[NSURL URLWithString:username]] attributes:self.mutableUsernameLabelLinkAttributes];
    self.activeLinkAttributes = self.mutableUsernameLabelActiveLinkAttributes;
}



//Gets the username label attributes
-(void)initializeLinkAttributes{
    self.mutableUsernameLabelLinkAttributes = [NSMutableDictionary dictionary];
    [self.mutableUsernameLabelLinkAttributes setValue: [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0f]
                             forKey: (NSString *) kCTFontAttributeName];
    [self.mutableUsernameLabelLinkAttributes setObject:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    [self.mutableUsernameLabelLinkAttributes setObject:[UIColor colorWithRed:255.0/255.0 green:120/255.0 blue:0/255.0 alpha:1] forKey:(NSString *)kCTForegroundColorAttributeName];
    
    self.mutableUsernameLabelActiveLinkAttributes = [NSMutableDictionary dictionary];
    [self.mutableUsernameLabelActiveLinkAttributes setObject:[UIColor colorWithRed:255.0/255.0 green:90.0/255.0 blue:0/255.0 alpha:1] forKey:(NSString *)kCTForegroundColorAttributeName];
    
}


#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(CustomColoredLabel *)label didSelectLinkWithURL:(NSURL *)url {
    //Handling if clicked on hashtag or tag
    NSString *selectedString = [url absoluteString];
    
    
    if([selectedString hasPrefix:@"#"]){
        selectedString = [selectedString substringFromIndex:1];
        DebugLog(@"Will open hashtag page corresponding to : %@!",selectedString);

    }else{
        
        if([selectedString hasPrefix:@"@"]){
            selectedString = [selectedString substringFromIndex:1];
        }else{
            selectedString = [selectedString substringFromIndex:0];
        }
        
        DebugLog(@"Will open profile page corresponding to : %@!",selectedString);

    }
}

@end
