//
//  CommentCell.h
//  gymEver
//
//  Created by Alessandro Rodi on 2013-12-20.
//  Copyright (c) 2013 alegiallo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentsTableViewController.h"
#import "CustomColoredLabel.h"

@interface CommentCell : UITableViewCell <TTTAttributedLabelDelegate>

@property (strong, nonatomic) IBOutlet CustomColoredLabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet CustomColoredLabel *commentLabel;
@property (weak, nonatomic) IBOutlet UIButton *profileImageButton;

@property (strong,nonatomic) NSString *idComment;

//To push a view controller
@property (strong,nonatomic) CommentsTableViewController *commentTableViewController;


@end
