//
//  SmallUserTableCell.h
//  gymEver
//
//  Created by Alessandro Rodi on 2013-11-25.
//  Copyright (c) 2013 GymEver. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmallUserCellView.h"


@interface SmallUserTableCell : UITableViewCell
@property (strong, nonatomic) NSString *idUser;
@property (weak, nonatomic) IBOutlet SmallUserCellView *smallUserCellView;

@property (strong,nonatomic) NSOperation *loadImageOperation;

@end
