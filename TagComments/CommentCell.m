
//  CommentCell.m
//  gymEver
//
//  Created by Alessandro Rodi on 2013-12-20.
//  Copyright (c) 2013 GymEver. All rights reserved.
//

#import "CommentCell.h"

@implementation CommentCell


/**
 Setting a method when clicking the profile picture to be able to push a view.
 */
-(void)awakeFromNib{
   
    //Setting a little corner radius on image
    CALayer *profileImageButtonLayer = self.profileImageButton.layer;
    [profileImageButtonLayer setCornerRadius:2];
    [profileImageButtonLayer setMasksToBounds:YES];
    
    //Adding target to image button
    [self.profileImageButton addTarget:self action:@selector(profileImageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    //to set the comment at the right position in the label
    self.commentLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
}

/**
 Clearing profile image when cell is reused.
 */
-(void)prepareForReuse
{
    [super prepareForReuse];
    [self.profileImageButton setImage:nil forState:UIControlStateNormal];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.commentLabel.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width - 76;
}

- (void)profileImageButtonTapped:(id)sender {
    DebugLog(@"Will open profile!");
}




@end
