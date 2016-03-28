//
//  SmallUserCellView.m
//  gymEver
//
//  Created by Alessandro on 2014-11-22.
//  Copyright (c) 2014 alegiallo. All rights reserved.
//

#import "SmallUserCellView.h"

@implementation SmallUserCellView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
#define LEFT_COLUMN_OFFSET 52
#define MIDDLE_COLUMN_OFFSET 220
#define RIGHT_COLUMN_OFFSET 270
    
#define UPPER_ROW_TOP 5
#define MIDDLE_ROW_TOP 14
#define LOW_ROW_TOP 25
#define LOWER_ROW_TOP 44
        //CGContextRef context = UIGraphicsGetCurrentContext();
       // CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);

    
 
    // In this example we will never be editing, but this illustrates the appropriate pattern.
        CGPoint point;
    
 
    if([self.username length]>0)
    {
        
        // Color for the main text items (time zone name, time).
        UIColor *mainTextColor;
        
        // Color for the secondary text items (GMT offset, day).
        UIColor *secondaryTextColor;
        
        // Choose font color based on highlighted state.
        
        mainTextColor = [UIColor blackColor];
        secondaryTextColor = [UIColor lightGrayColor];
        
        
        /*
         Font attributes for the main text items (time zone name, time).
         For iOS 7 and later, use text styles instead of system fonts.
         */
        UIFont *mainFont;
        
        mainFont = [UIFont systemFontOfSize:14.0 weight:UIFontWeightMedium];
        
        NSDictionary *mainTextAttributes = @{ NSFontAttributeName : mainFont, NSForegroundColorAttributeName : mainTextColor };
        
        // Font attributes for the secondary text items (GMT offset, day).
        UIFont *secondaryFont;
        
        secondaryFont = [UIFont systemFontOfSize:14.0f];
        
        NSDictionary *secondaryTextAttributes = @{ NSFontAttributeName : secondaryFont, NSForegroundColorAttributeName : secondaryTextColor };
        
            NSAttributedString *localeNameAttributedString = [[NSAttributedString alloc] initWithString:self.username attributes:mainTextAttributes];
        if([self.fullname length]>0)
        {
        NSAttributedString *fullnameAttributedString = [[NSAttributedString alloc] initWithString:self.fullname attributes:secondaryTextAttributes];
        point = CGPointMake(LEFT_COLUMN_OFFSET, LOW_ROW_TOP);
        [fullnameAttributedString drawAtPoint:point];
            
        point = CGPointMake(LEFT_COLUMN_OFFSET, UPPER_ROW_TOP);
        [localeNameAttributedString drawAtPoint:point];

        }else{
           
            point = CGPointMake(LEFT_COLUMN_OFFSET, MIDDLE_ROW_TOP);
            [localeNameAttributedString drawAtPoint:point];
            
        }
       
        
    }
    
    CGFloat imageY = (self.bounds.size.height - 36) / 2;
    point = CGPointMake(8, imageY);
    CGRect imageRect = CGRectMake(8, imageY, 36, 36);
    
    [[UIBezierPath bezierPathWithRoundedRect:imageRect cornerRadius:2] addClip];
    [[UIColor colorWithRed:223.0/255.0 green:223.0/255.0 blue:223.0/255.0 alpha:1] setFill];
    UIRectFill( imageRect );
    

        if(self.image)
        {
       [self.image drawInRect:imageRect];
        }



}

-(void)erase{
    self.image = nil;
    [self setNeedsDisplay];
}

@end
