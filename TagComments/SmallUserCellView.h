//
//  SmallUserCellView.h
//  gymEver
//
//  Created by Alessandro on 2014-11-22.
//  Copyright (c) 2014 alegiallo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmallUserCellView : UIView

@property (strong,nonatomic) NSString* username;
@property (strong,nonatomic) NSString* fullname;
@property (nonatomic) BOOL isFollowing;
@property (strong,nonatomic) UIImage *image;

-(void)erase;

@end
