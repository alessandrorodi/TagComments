//
//  TagTableView.m
//  gymEver
//
//  Created by Alessandro on 2015-01-03.
//  Copyright (c) 2015 alegiallo. All rights reserved.
//

#import "TagTableView.h"
#import "SmallUserTableCell.h"
#import "Haneke.h"
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
            NSURL *url = [NSURL URLWithString:[self.userProfileImageThumbURLArray objectAtIndex:indexPath.row]];
            
            if(url)
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if(![operation isCancelled])
                    {
                        scell.modelImageView = [[UIImageView alloc]initWithFrame:CGRectMake(8, 8, 36, 36)];
                        scell.modelImageView.hnk_cacheFormat = [self initializeFormat];
                        [scell.modelImageView hnk_setImageFromURL:url placeholderImage:nil success:^(UIImage *image) {
                            if(![operation isCancelled]){
                                scell.smallUserCellView.image = image;
                                [scell.smallUserCellView setNeedsDisplay];
                            }
                        } failure:^(NSError *error) {
                            if(![operation isCancelled]){
                                scell.smallUserCellView.image = [UIImage imageNamed:@"noPpic36.png"];
                                [scell.smallUserCellView setNeedsDisplay];
                            }
                        }];
                    }
                });
            }
            else{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if(![operation isCancelled]){
                        scell.smallUserCellView.image = [UIImage imageNamed:@"noPpic36.png"];
                        [scell.smallUserCellView setNeedsDisplay];
                    }
                });
            }
            
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


-(HNKCacheFormat*)initializeFormat{
    HNKCacheFormat *format = [HNKCache sharedCache].formats[@"smallUserPicFormat"];
    if (!format)
    {
        format = [[HNKCacheFormat alloc] initWithName:@"smallUserPicFormat"];
        format.size = CGSizeMake(36, 36);
        format.scaleMode = HNKScaleModeAspectFill;
        format.compressionQuality = 1;
        format.diskCapacity = 50 * 1024 * 1024; // 1MB
        format.preloadPolicy = HNKPreloadPolicyAll;
    }
    
    return format;
}



 // In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     SmallUserTableCell *cell = (SmallUserTableCell*)[self cellForRowAtIndexPath:indexPath];
     if([self.viewController respondsToSelector:@selector(selectedRowWithUserDetails:)])
       [self.viewController performSelector:@selector(selectedRowWithUserDetails:) withObject:cell];
 }
 
 

 



/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
