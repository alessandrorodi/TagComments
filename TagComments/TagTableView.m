//
//  TagTableView.m
//  gymEver
//
//  Created by Alessandro on 2015-01-03.
//  Copyright (c) 2015 GymEver. All rights reserved.
//

#import "TagTableView.h"
#import "SmallUserTableCell.h"
#import "CommentsTableViewController.h"

@interface TagTableView(){
    NSOperationQueue *operationQueue;
}
@end

@implementation TagTableView
- (id)init
{
    self = [super init];
    if (self) {
        self.dataSource = self;
        self.delegate = self;
        [self setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        UINib *nib = [UINib nibWithNibName:@"SmallUserTableCell" bundle:nil];
        [self registerNib:nib forCellReuseIdentifier:@"SmallUserTableCell"];
        operationQueue = [NSOperationQueue new];
    }
    return self;
}

- (id)initWithFrame:(CGRect)aRect{
    self = [super initWithFrame:aRect];
    if (self) {
        self.dataSource = self;
        self.delegate = self;
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _nbOfRows;
}
-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    SmallUserTableCell *scell = (SmallUserTableCell*)cell;
    [scell.loadImageOperation cancel];
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    SmallUserTableCell *scell = (SmallUserTableCell*)cell;
    
    scell.idUser = [self.idUserArray objectAtIndex:indexPath.row];
    // cell.userProfilePictureView.hnk_cacheFormat = [HNKCache sharedCache].formats[@"smallUserPicFormat"];
    
    __block NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        
        if(![operation isCancelled]){
            
            
            if([[self.fullnameArray objectAtIndex:indexPath.row] length]>0)
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    scell.smallUserCellView.fullname = [self.fullnameArray objectAtIndex:indexPath.row];
                });
            }
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                // cell.usernameTopLabel.text = [usernameArray objectAtIndex:indexPath.row];
                scell.smallUserCellView.username =[self.usernameArray objectAtIndex:indexPath.row];
                [scell.smallUserCellView setNeedsDisplay];
            });
            scell.smallUserCellView.image = [UIImage imageNamed:@"noPpic.png"];

            
        }else {
            DebugLog(@"CAncelled");
        }
    }];
    scell.loadImageOperation = operation;
    
    [operationQueue addOperation:operation];
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SmallUserTableCell *cell = (SmallUserTableCell*)[tableView dequeueReusableCellWithIdentifier:@"SmallUserTableCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

 // In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     SmallUserTableCell *cell = (SmallUserTableCell*)[self cellForRowAtIndexPath:indexPath];
     if([self.viewController respondsToSelector:@selector(selectedRowWithUserDetails:)])
       [self.viewController performSelector:@selector(selectedRowWithUserDetails:) withObject:cell];
 }
 

@end
