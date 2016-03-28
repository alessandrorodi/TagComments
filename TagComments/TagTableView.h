//
//  TagTableView.h
//  gymEver
//
//  Created by Alessandro on 2015-01-03.
//  Copyright (c) 2015 alegiallo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TagTableView : UITableView <UITableViewDataSource,UITableViewDelegate>
@property (strong,nonatomic) NSMutableArray *usernameArray;
@property (strong,nonatomic) NSMutableArray *fullnameArray;
@property (strong,nonatomic) NSMutableArray *idUserArray;
@property (strong,nonatomic) NSMutableArray *userProfileImageThumbURLArray;

@property (nonatomic) NSUInteger nbOfRows;

@property (strong,nonatomic) UIViewController *viewController;

@end
