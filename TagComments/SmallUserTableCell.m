//
//  SmallUserTableCell.m
//  gymEver
//
//  Created by Alessandro Rodi on 2013-11-25.
//  Copyright (c) 2013 alegiallo. All rights reserved.
//

#import "SmallUserTableCell.h"
#import "GymEverAPI.h"
#import "AppDelegate.h"
#import "EGOCache.h"
#import "Haneke.h"

@interface SmallUserTableCell()
{
    bool _isInFollowingOperation;
    bool _isInUnfollowingOperation;
    
    
    NSString *_cacheStoredKey;
    NSString *_followingCachedKey;
}
@end

@implementation SmallUserTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
   // self.userProfilePictureView.image = [UIImage imageNamed:@"noPpic.png"];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    [self.requestLabel setHidden:YES];
    [self.clientRequestButton setHidden:YES];
    [self.hasATrainerLabel setHidden:YES];
   //self.usernameLabel.text = @"";
    //self.usernameTopLabel.text = @"";
   // self.fullnameLabel.text = @"";

   // [self.userProfilePictureView setImage:nil];
   
    [self.modelImageView hnk_cancelImageRequest];
    //[self.smallUserCellView erase];
    self.smallUserCellView.fullname = @"";
    self.smallUserCellView.image = nil;
    //[self setNeedsDisplay];

   // [self.followButton setHidden:NO];

   // [self.followButton setSelected:NO];
    [self.followButton setHidden:YES];
    
    

}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(void)awakeFromNib{
  //  AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    //[appDelegate fixXOriginForLargerScreen:self.followButton];
//self.userProfilePictureView.contentMode = UIViewContentModeScaleAspectFit;
  /*  self.usernameTopLabel.lineBreakMode = NSLineBreakByClipping;
    self.usernameTopLabel.adjustsFontSizeToFitWidth = YES;*/

   // [self.followButton setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:255.0/255.0 green:120/255.0 blue:0/255.0 alpha:1.0]] forState:UIControlStateSelected];
   // [self.followButton setImage:[UIImage imageNamed:@"ic_following.png"] forState:UIControlStateSelected];
    //UIImage* imageForRendering = [[UIImage imageNamed:@"ic_follow_person.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
 //   [self.followButton setImage:imageForRendering forState:UIControlStateNormal];
  //  self.followButton.imageView.tintColor = [UIColor colorWithRed:255.0/255.0 green:120/255.0 blue:0/255.0 alpha:1.0]; // or any color you want to tint it with
  /*  CALayer *profileImageLayer = self.userProfilePictureView.layer;
    [profileImageLayer setCornerRadius:2];
    [profileImageLayer setMasksToBounds:YES];
    */
    
    
  /*  CALayer *followButtonLayer = self.followButton.layer;
    [followButtonLayer setCornerRadius:2];
    [followButtonLayer setMasksToBounds:YES];
    [followButtonLayer setBorderWidth:1];
    [followButtonLayer setBorderColor:[UIColor colorWithRed:255.0/255.0 green:120/255.0 blue:0/255.0 alpha:1.0].CGColor];*/
    [self.followButton setHidden:YES];

}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setFollowing{
    [self.followButton setSelected:YES];
  
}

-(void)setFollow{
    [self.followButton setSelected:NO];
}

- (IBAction)requestButtonTapped:(id)sender {
    [self.clientRequestButton setEnabled:NO];
    NSString* command = @"becomeTrainerRequest";
    NSMutableDictionary* params =[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  command, @"command",
                                  [[GymEverAPI sharedInstance].user objectForKey:@"idUser"], @"trainerIdUser",
                                  self.idUser,@"clientIdUser",
                                  nil];
    
    //make the call to the web API
    [[GymEverAPI sharedInstance] commandWithParams:params
                                      onCompletion:^(NSArray *json) {
                                          //handle the response
                                          [self.clientRequestButton setEnabled:YES];
                                          [self showRequestedAlert];
                                          DebugLog(@"%@ succesfully requested client, iduser %@",[[GymEverAPI sharedInstance].user objectForKey:@"idUser"],self.idUser);
                                      } onFailure:^(AFHTTPRequestOperation *operation) {
                                          [self.clientRequestButton setEnabled:YES];
                                      }];
}

-(void)showRequestedAlert{
    NSString *message = [NSString stringWithFormat:@"%@%@",self.smallUserCellView.username,NSLocalizedString(@" succesfully received your request to be his/her personal trainer.", nil)];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Client Requested", nil)
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * action) {
                                                          }];
    
    [alert addAction:defaultAction];
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate.topMostController presentViewController:alert animated:YES completion:nil];
}

- (IBAction)followButtonTapped:(id)sender {
    
    if(![self.followButton isSelected])
    {
        if(!_isInFollowingOperation && !_isInUnfollowingOperation)
        {
            [self setFollowing];
            
            DebugLog(@"%@ will follow user %@",[[GymEverAPI sharedInstance].user objectForKey:@"idUser"],self.idUser);
            _isInFollowingOperation=YES;
            
            
            NSString* command = @"followUser";
            NSMutableDictionary* params =[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          command, @"command",
                                          [[GymEverAPI sharedInstance].user objectForKey:@"idUser"], @"idUser",self.idUser,@"followedUserID",
                                          nil];
            
            //make the call to the web API
            [[GymEverAPI sharedInstance] commandWithParams:params
                                              onCompletion:^(NSArray *json) {
                                                  //handle the response
                                                      DebugLog(@"%@ succesfully followed user %@",[[GymEverAPI sharedInstance].user objectForKey:@"idUser"],self.idUser);
                                                      
                                                      __block AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                                      appDelegate.changedUserFeed = YES;
                                                      _isInFollowingOperation=NO;
                                                  
                                               
                                                      [[NSNotificationCenter defaultCenter]postNotificationName:@"followedUser" object:nil];
                                                      
                                                      if(![[NSUserDefaults standardUserDefaults] boolForKey:@"FollowedAUser"])
                                                      {
                                                          [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FollowedAUser"];
                                                      }
                                                  
                                                  //Posts a notificaiton handled by small user table views. Purpose of selecting the follow button when user scrolls back on it.
                                                  NSDictionary* userInfo = @{@"cell":self};
                                                  [[NSNotificationCenter defaultCenter]postNotificationName:@"addToIsFollowingArray" object:nil userInfo:userInfo];
                                                  

                                                  //Notify that load and cache following userarray needs to be ran
                                                  [[NSNotificationCenter defaultCenter]postNotificationName:@"modifyFollowingUserArray" object:nil];
                                                  
                                              } onFailure:^(AFHTTPRequestOperation *operation) {
                                                  _isInFollowingOperation=NO;
                                                  [self setFollow];
                                              }];
            
        }
    }else{
        
        if(!_isInFollowingOperation && !_isInUnfollowingOperation)
        {
            [self setFollow];
            
            DebugLog(@"%@ will UNfollow user %@",[[GymEverAPI sharedInstance].user objectForKey:@"idUser"],self.idUser);
            _isInUnfollowingOperation = YES;
            
            NSString* command = @"unfollowUser";
            NSMutableDictionary* params =[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          command, @"command",
                                          [[GymEverAPI sharedInstance].user objectForKey:@"idUser"], @"idUser",self.idUser,@"followedUserID",
                                          nil];
            
            
            
            //make the call to the web API
            [[GymEverAPI sharedInstance] commandWithParams:params
                                              onCompletion:^(NSArray *json) {
                                                  //handle the response
                                                  
                                                      DebugLog(@"%@ succesfully unfollowed user %@",[[GymEverAPI sharedInstance].user objectForKey:@"idUser"],self.idUser);
                                                      
                                                      __block AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                                      appDelegate.changedUserFeed = YES;
                                                      _isInUnfollowingOperation = NO;
                                                      [self setFollow];
                                                  
                                                  
                                                  //Posts a notificaiton handled by small user table views. Purpose of unselecting the follow button when user scrolls back on it.
                                                  NSDictionary* userInfo = @{@"cell":self};
                                                  [[NSNotificationCenter defaultCenter]postNotificationName:@"removeFromIsFollowingArray" object:nil userInfo:userInfo];
                                                  

                                                  //Notify that load and cache following userarray needs to be ran
                                                  [[NSNotificationCenter defaultCenter]postNotificationName:@"modifyFollowingUserArray" object:nil];
                                                  
                                              }onFailure:^(AFHTTPRequestOperation *operation) {
                                                  _isInUnfollowingOperation = NO;
                                                  [self setFollowing];
                                              }];
            
        }
        
        
    }
    

}
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
}

-(NSUInteger)searchArray:(NSArray*)sortedIdUserArray withIdUser:(NSString*)idUser{
    NSString* searchObject = idUser;
    NSRange searchRange = NSMakeRange(0, [sortedIdUserArray count]);
    NSUInteger findIndex = [sortedIdUserArray indexOfObject:searchObject
                                              inSortedRange:searchRange
                                                    options:NSBinarySearchingFirstEqual
                                            usingComparator:^(id obj1, id obj2)
                            {
                                return [obj1 compare:obj2];
                            }];
    return findIndex;
}


@end
