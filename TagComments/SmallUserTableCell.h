//
//  SmallUserTableCell.h
//  gymEver
//
//  Created by Alessandro Rodi on 2013-11-25.
//  Copyright (c) 2013 alegiallo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmallUserCellView.h"
#import "SmallUserFollowButton.h"
#import "SmallUserTableViewController.h"


@interface SmallUserTableCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *usernameTopLabel;
@property (strong, nonatomic) IBOutlet UIImageView *userProfilePictureView;
@property (strong,nonatomic) NSOperation *loadImageOperation;
@property (strong,nonatomic) NSOperation *getProfileDataOperation;


@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadProfileActivityIndicator;
@property (strong, nonatomic) IBOutlet UILabel *arrowLabel;
@property (strong, nonatomic) IBOutlet SmallUserFollowButton *followButton;
@property (strong, nonatomic) IBOutlet SmallUserFollowButton *testFollowButton;

@property (strong, nonatomic) UIImageView *modelImageView;

@property (strong, nonatomic) NSString *idUser;

@property (strong, nonatomic) UIImage *profilePicImage;

@property (weak, nonatomic) IBOutlet UILabel *fullnameLabel;

-(void)getProfileData;

//Array used when unfollowing or following a user
@property (strong, nonatomic) SmallUserTableViewController *sutvc;


@property (weak, nonatomic) IBOutlet SmallUserCellView *smallUserCellView;

@property (strong, nonatomic) IBOutlet UIButton *clientRequestButton;
@property (strong, nonatomic) IBOutlet UILabel *requestLabel;
@property (weak, nonatomic) IBOutlet UILabel *hasATrainerLabel;
- (IBAction)requestButtonTapped:(id)sender;

- (IBAction)followButtonTapped:(id)sender;
@end
