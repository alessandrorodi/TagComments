//
//  SmallUserTableCell.m
//  gymEver
//
//  Created by Alessandro Rodi on 2013-11-25.
//  Copyright (c) 2013 GymEver. All rights reserved.
//

#import "SmallUserTableCell.h"
#import "AppDelegate.h"


@implementation SmallUserTableCell

-(void)prepareForReuse
{
    [super prepareForReuse];
    self.smallUserCellView.fullname = @"";
    self.smallUserCellView.image = nil;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
}



@end
