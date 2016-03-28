//
//  FollowerTableViewController.h
//  gymEver
//
//  Created by Alessandro Rodi on 2013-11-25.
//  Copyright (c) 2013 alegiallo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"
#import "GAITrackedViewController.h"
#import "MediaFeed.h"
#import "SmallUserTableCell.h"
#import "TopBottomBorderView.h"

#define COMMENTSOFFSET 20;

@interface CommentsTableViewController : GAITrackedViewController <HPGrowingTextViewDelegate,UITextViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (strong,nonatomic) NSString *currentIdUser;
@property (strong,nonatomic) NSString *idMedia;

@property (strong, nonatomic) IBOutlet UILabel *commentNumberLabel;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UITextView *commentTextView;

@property (strong, nonatomic) HPGrowingTextView *commentGrowingTextView;
@property (strong, nonatomic) IBOutlet TopBottomBorderView *commentTextViewContainerView;

//TO notify the table view of comments modified
@property (strong,nonatomic) MediaFeed *gymEverTableVideoController;

@property (strong,nonatomic) NSMutableArray *commentsArray;


@property (nonatomic,assign) bool showLoadCommentsButton;

@property (strong,nonatomic) NSString *IdUser;

@property (nonatomic) bool isIphoneUserMedia;

@property (strong,nonatomic) NSString *totalNbOfComments;

@property (strong,nonatomic) NSString *nbOfComments;

@property (weak, nonatomic) IBOutlet UIButton *commentButton;

@property (weak, nonatomic) IBOutlet UIView *navigationView;

@property (weak, nonatomic) IBOutlet UIView *loadMoreCommentsView;
@property (strong, nonatomic) IBOutlet UIButton *loadMoreCommentsButton;
- (IBAction)loadMoreCommentsButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *commentsNavLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
- (IBAction)backButtonTapped:(id)sender;

//tagtableview calls this function.
-(void)selectedRowWithUserDetails:(SmallUserTableCell*)cell;


@end
