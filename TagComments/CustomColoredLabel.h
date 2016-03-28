//
//  customColoredLabel.h
//  gymEver
//
//  Created by Alessandro on 2015-01-04.
//  Copyright (c) 2015 alegiallo. All rights reserved.
//

#import "TTTAttributedLabel.h"


@interface CustomColoredLabel : TTTAttributedLabel <TTTAttributedLabelDelegate>

@property (strong,nonatomic) NSMutableArray *taggedUserArray;


@property (strong,nonatomic) NSMutableDictionary *mutableUsernameLabelLinkAttributes;
@property (strong,nonatomic) NSMutableDictionary *mutableUsernameLabelActiveLinkAttributes;


//For delegate
@property (strong,nonatomic) UINavigationController *navigationController;


-(void)addLinkForUsername:(NSString*)username;

@property (nonatomic) BOOL isComment;


- (void)colorUsernamesWithATag;
@end
