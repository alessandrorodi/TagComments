//
//  FollowerTableViewController.h
//  gymEver
//
//  Created by Alessandro Rodi on 2013-11-25.
//  Copyright (c) 2013 alegiallo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmallUserTableCell.h"
#import "TopBottomBorderView.h"


@interface CommentsTableViewController : UIViewController <UITextViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (strong,nonatomic) NSString *nbOfComments;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITextView *commentTextView;
@property (strong, nonatomic) IBOutlet TopBottomBorderView *commentTextViewContainerView;

@property (strong,nonatomic) NSMutableArray *commentsArray;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIView *navigationView;

//View to load more comments from the back-end
@property (weak, nonatomic) IBOutlet UIView *loadMoreCommentsView;
@property (strong, nonatomic) IBOutlet UIButton *loadMoreCommentsButton;

- (IBAction)loadMoreCommentsButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *commentsNavLabel;


//tagtableview calls this function.
-(void)selectedRowWithUserDetails:(SmallUserTableCell*)cell;


@end
