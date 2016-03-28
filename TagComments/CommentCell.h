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

@interface CommentCell : UITableViewCell <HPGrowingTextViewDelegate,TTTAttributedLabelDelegate>
@property (strong, nonatomic) IBOutlet CustomColoredLabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *userProfilePictureView;
@property (strong,nonatomic) NSOperation *loadImageOperation;

@property (strong,nonatomic) CommentsTableViewController *commentTableViewController;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *commentActivityIndicator;
@property (strong, nonatomic) IBOutlet UIButton *retryCommentButton;

- (IBAction)retryCommentButtonTapped:(id)sender;

-(void)initializeTextView;

@property (weak, nonatomic) IBOutlet UIView *boxView;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;

@property (strong,nonatomic) NSString *idMedia;

@property (strong,nonatomic) NSString *idComment;

@property (weak, nonatomic) IBOutlet UIView *commentBoxView;
@property (weak, nonatomic) IBOutlet CustomColoredLabel *commentLabel;
@property (weak, nonatomic) IBOutlet UIButton *profileImageButton;

//setting shadow after changing the height
-(void)setCommentBoxViewShadow;
@end
