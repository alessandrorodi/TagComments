
//  CommentCell.m
//  gymEver
//
//  Created by Alessandro Rodi on 2013-12-20.
//  Copyright (c) 2013 alegiallo. All rights reserved.
//

#import "CommentCell.h"
#import "GymEverAPI.h"
#import "UIAlertView+error.h"

@implementation CommentCell



-(void)awakeFromNib{
   
    CALayer *profileImageButtonLayer = self.profileImageButton.layer;
    [profileImageButtonLayer setCornerRadius:2];
    [profileImageButtonLayer setMasksToBounds:YES];
    
    [self.profileImageButton addTarget:self action:@selector(profileImageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.commentLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;

}

-(void)prepareForReuse
{
    [super prepareForReuse];
    [self.profileImageButton.imageView hnk_cancelImageRequest];
    [self.profileImageButton setImage:nil forState:UIControlStateNormal];
}

-(void)layoutSubviews{
     [super layoutSubviews];
    //116 is the leading and trailing spaces of label
    self.commentLabel.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width - 76;
}

- (IBAction)retryCommentButtonTapped:(id)sender {
    
    
    NSString* command = @"commentMedia";
    NSMutableDictionary* params =[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  command, @"command",
                                  [[GymEverAPI sharedInstance].user objectForKey:@"idUser"],@"idUser",
                                  self.commentLabel.text,@"comment",
                                  self.idMedia, @"idMedia",
                                  nil];
    
    self.commentLabel.text = @"";
    
    
    
    DebugLog(@"Comment posting");
    //make the call to the web API
    [[GymEverAPI sharedInstance] commandWithParams:params
                                      onCompletion:^(NSArray *json) {
                                     
                                          
                                              //   dispatch_sync(dispatch_get_main_queue(), ^{
                                              DebugLog(@"Comment posted");

                                              
                                            //  [idCommentArray addObject:[res objectForKey:@"idComment"]];
                                              //DebugLog(@"id comment:%@",[res objectForKey:@"idComment"]);
                                              
                                              [self.commentActivityIndicator stopAnimating];
                                              [self.retryCommentButton setEnabled:NO];
                                              [self.retryCommentButton setHidden:YES];
                                              //  });
                                              
                                    
                                          
                                          
                                      }onFailure:^(AFHTTPRequestOperation *operation) {
                                          if(operation.responseString) DebugLog(@"Comment failed : %@", operation.responseString);
                                          [self.commentActivityIndicator stopAnimating];
                                          [self.retryCommentButton setEnabled:true];
                                          [self.retryCommentButton setHidden:NO];
                                      }];
}

-(void)setCommentBoxViewShadow{
    //Adds a shadow to boxView
    self.boxView.layer.shadowOffset = CGSizeMake(0, 1.25);
    self.boxView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.boxView.layer.shadowRadius = 2.0f;
    self.boxView.layer.shadowOpacity = 0.40f;
    self.boxView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:self.boxView.layer.bounds] CGPath];
    self.boxView.layer.cornerRadius = 2;
    
}

- (IBAction)profileImageButtonTapped:(id)sender {
   
        ProfileViewController *vc = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
    NSString* goodUsername = self.usernameLabel.text;
    
    vc.username = goodUsername;
    vc.taggedUsername = goodUsername;
    
    [self.commentTableViewController.navigationController pushViewController:vc animated:YES];
    
    
}




@end
