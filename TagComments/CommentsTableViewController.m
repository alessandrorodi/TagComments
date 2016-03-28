//
//  FollowerTableViewController.m
//  gymEver
//
//  Created by Alessandro Rodi on 2013-11-25.
//  Copyright (c) 2013 alegiallo. All rights reserved.
//

#import "CommentsTableViewController.h"
#import "GymEverAPI.h"
#import "UIAlertView+error.h"
#import "CommentCell.h"
#import "ProfileViewController.h"
#import "GymEverAPI.h"
#import "AppDelegate.h"
#import <Crashlytics/Crashlytics.h>
#import "Haneke.h"
#import <QuartzCore/QuartzCore.h>
#import "NSDate+PrettyDate.h"

#import "EGOCache.h"
#import "UIButton+Extensions.h"

#import "TYMActivityIndicatorView.h"

#import "TagTableView.h"
#import "SmallUserTableCell.h"

@interface CommentsTableViewController ()
{

    TYMActivityIndicatorView *navBarActivityIndicator;
    
    NSMutableArray *userProfilePictureURLS;
    NSMutableArray *usernames;
    

    NSMutableArray *heightForRowArray;
    
    NSMutableDictionary *cachedProfilePicImages;
    
    NSOperationQueue *operationQueue;
    
    NSDateFormatter *_cellFormatter;
    NSDateFormatter *_dbDateFormatter;
    
    HPGrowingTextView *_cellTextView;
        
    int _commentOffset;
    
    NSString *_currentTime;

    NSArray *cachedFollowingArray;
    
    UILabel *_modelLabel;
    NSString * _followingCachedKey;
    NSString *_cacheStoredKey;
    UIFont *_mainFont;
    
    //Array for displaying users(tag)
    NSArray *_filtered;
    NSArray *_selectedFiltered;
    
    TagTableView *tagTableView;
    
    NSMutableArray *selectedUsers;

    NSString *_lastTextChanged;
    
    UILabel *_placeholderLabel;

    
    NSMutableArray *taggedUsersArrays;
    
    //Attributes for username label
    NSMutableDictionary *mutableLinkAttributes;
    NSMutableDictionary *mutableActiveLinkAttributes;
    
    //Used to cache cell heights
    NSMutableDictionary *offscreenCells;
    
    bool didbecomefirstresponder;
    
    
    //To get the good width for comment text view
    AppDelegate *appDelegate;
    
    CGRect keyboardBounds;
}
@end

@implementation CommentsTableViewController

//- (id)initWithStyle:(UITableViewStyle)style
//{
//    //self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if([scrollView isEqual:self.tableView])
    [self.commentTextView resignFirstResponder];

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.screenName = @"Comments Table View Controller";
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    /*if(!didbecomefirstresponder){
        didbecomefirstresponder = YES;
        [self.commentTextView becomeFirstResponder];
    }*/

}


//Sets the current device timezone with the dates
-(void)initializeCellFormatter
{
    _cellFormatter = [[NSDateFormatter alloc]init];
    NSInteger seconds = [[NSTimeZone localTimeZone]secondsFromGMT]/3600;
    DebugLog(@"TIMEZONE OF THIS IPHONE : %ld",(long)seconds);
    [_cellFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [_cellFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
}

//Since the server's timezone is chicago, we have to set the timezone of the database value.
-(void)initializeDbDateFormatter
{
    _dbDateFormatter = [[NSDateFormatter alloc] init];
    [_dbDateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"America/Chicago"]];
    [_dbDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    offscreenCells = [[NSMutableDictionary alloc]init];
    [self setCommentButtonShadow];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self setBoxViewShadow:self.navigationView];
    [self.backButton setHitTestEdgeInsets:UIEdgeInsetsMake(-30, -30, -30, -30)];

    [self initializeCellFormatter];
    [self initializeDbDateFormatter];
    [self initializeModelLabel];
    _currentTime = [_dbDateFormatter stringFromDate:[NSDate date]];
   self.nbOfComments = @"0";
    
    DebugLog(@"%@ nb of comments",self.nbOfComments);
    
    operationQueue = [NSOperationQueue new];
    self.tableView.delegate = self;
    self.tableView.dataSource =self;
    
    
    
    //[self initializeHPGrowingTextView];
    _mainFont = self.commentTextView.font;
    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [self loadMediaCommentCount];

    if(!self.commentsArray){
                self.commentsArray = [[NSMutableArray alloc]init];
                _commentOffset = 0;
                [self loadCommentsWithOffset:[[NSString alloc]initWithFormat:@"%d",_commentOffset] loadMoreComments:NO];
                
    }else{
        self.commentsArray = [self.commentsArray mutableCopy];
        _commentOffset = (int)[self.commentsArray count];
        [self.tableView reloadData];
    }
    
    [self.commentTextViewContainerView setFrame:CGRectMake(self.commentTextViewContainerView.frame.origin.x, ([[UIScreen mainScreen] preferredMode].size.height/[[UIScreen mainScreen] scale])-self.commentTextViewContainerView.frame.size.height, self.commentTextViewContainerView.frame.size.width, self.commentTextViewContainerView.frame.size.height)];
    
    
    [self initializeNormalTextview];
    cachedFollowingArray = [self getSortedFollowingArray];





}

-(void)initializeNormalTextview{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    

    
    //self.testCommentTextView = [[UITextView alloc] initWithFrame:CGRectMake(8, 8, 248, 32)];
    [self.commentTextView setDelegate:self];
 //   [self.testCommentTextView setScrollEnabled:NO];
    [self.commentTextView setFont:[UIFont systemFontOfSize:14]];
        [self.commentTextViewContainerView addSubview:self.commentTextView];
    _placeholderLabel = [[UILabel alloc]init];
    [_placeholderLabel setFrame:CGRectMake(4, 0, self.commentTextView.frame.size.width, self.commentTextView.frame.size.height)];
    [_placeholderLabel setText:NSLocalizedString(@"Add a comment", nil)];
    [_placeholderLabel setTextColor:[UIColor lightGrayColor]];
    [_placeholderLabel setBackgroundColor:[UIColor clearColor]];
    [_placeholderLabel setFont:[UIFont systemFontOfSize:14]];
    [self.commentTextView addSubview:_placeholderLabel];
    [self.commentTextView sendSubviewToBack:_placeholderLabel];
    [self.commentTextView setBackgroundColor:[UIColor whiteColor]];
    

}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    _placeholderLabel.hidden = YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    _placeholderLabel.hidden = ([textView.text length] > 0);
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    [self resignTextView];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

 /*   if (self.isMovingFromParentViewController) {
         [self.tableView setDelegate:nil];
         [self.tableView setDataSource:nil];
    }*/
}



//The comment text view ( to add a comment )
-(void)initializeHPGrowingTextView
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    self.commentGrowingTextView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(8, 8, 264, 40)];

    
    self.commentGrowingTextView.isScrollable = NO;
    self.commentGrowingTextView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
	self.commentGrowingTextView.minNumberOfLines = 1;
	self.commentGrowingTextView.maxNumberOfLines = 6;
    // you can also set the maximum height in points with maxHeight
    self.commentGrowingTextView.maxHeight = 200.0f;
	self.commentGrowingTextView.returnKeyType = UIReturnKeySend; //just as an example
	self.commentGrowingTextView.font = [UIFont systemFontOfSize:14];
    self.commentGrowingTextView.delegate = self;
    
    //Setting delegate to access the internal textview myself
	self.commentGrowingTextView.internalTextView.delegate = self;
    self.commentGrowingTextView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    self.commentGrowingTextView.internalTextView.keyboardType = UIKeyboardTypeTwitter;
    self.commentGrowingTextView.backgroundColor = [UIColor whiteColor];
    self.commentGrowingTextView.textColor = [UIColor blackColor];
    self.commentGrowingTextView.placeholder = @"Add a comment...";
   // [self setBoxViewShadow:self.commentGrowingTextView];
    self.commentGrowingTextView.layer.cornerRadius = 2.0f;
    self.commentGrowingTextView.layer.borderColor = [UIColor blackColor].CGColor;
    self.commentGrowingTextView.layer.borderWidth = 0.3f;
    
    UIImageView *backgroundImgView = [[UIImageView alloc]init];
    backgroundImgView.frame = self.commentTextViewContainerView.frame;
    backgroundImgView.image = [UIImage imageNamed:@"tabbar_background_bottom.png"];
    
    // self.commentTableViewTextView.text = @"asdascearsdasdasasdascearsdasdasasdascearsdasdasasdascearsdasdasasdascearsdasdasasdascearsdasdasasdascearsdasdasasdascearsdasdas\n";
   // DebugLog(@"Static text text view height :%f",self.commentTableViewTextView.frame.size.height);
   // [self.commentTextViewContainerView setBackgroundColor:[UIColor colorWithRed:223 green:223 blue:223 alpha:1.0]];
    [self.commentTextViewContainerView addSubview:self.commentGrowingTextView];
 //   [self.commentTextViewContainerView addSubview:backgroundImgView];
  //  [self.commentTextViewContainerView sendSubviewToBack:backgroundImgView];
   // self.commentTextViewContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;

}
-(void)viewDidLayoutSubviews{
    [self.tableView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [self.commentTextViewContainerView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [self.view setTranslatesAutoresizingMaskIntoConstraints:YES];
    

}

-(void)resignTextView
{
//	[self.commentTextView resignFirstResponder];
}
-(void)setBoxViewShadow:(UIView*)boxView{
    //Adds a shadow to boxView
    boxView.layer.shadowOffset = CGSizeMake(0, 1.25);
    boxView.layer.shadowColor = [[UIColor blackColor] CGColor];
    boxView.layer.shadowRadius = 2.0f;
    boxView.layer.shadowOpacity = 0.40f;
    boxView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:boxView.layer.bounds] CGPath];
}
//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
	// get a rect for the textView frame
	CGRect containerFrame = self.commentTextViewContainerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    
    CGRect tableviewframe = self.tableView.frame;
    tableviewframe.size.height = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height+64);
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    [self.tableView setFrame:tableviewframe];

	// set views with new info
	self.commentTextViewContainerView.frame = containerFrame;
        [UIView commitAnimations];
	    [tagTableView setFrame:CGRectMake(0,64 ,[UIScreen mainScreen].bounds.size.width ,self.commentTextViewContainerView.frame.origin.y-64)];

    [self scrollToBottom];
}
- (void)scrollToBottom
{
    CGFloat yOffset = 0;
    
    if (self.tableView.contentSize.height > self.tableView.bounds.size.height) {
        yOffset = self.tableView.contentSize.height - self.tableView.bounds.size.height;
    }
    
    [self.tableView setContentOffset:CGPointMake(0, yOffset) animated:NO];
}
-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	
	// get a rect for the textView frame
	CGRect containerFrame = self.commentTextViewContainerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
	
    CGRect tableviewframe = self.tableView.frame;
       tableviewframe.size.height = self.view.bounds.size.height - (containerFrame.size.height+64);
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    [self.tableView setFrame:tableviewframe];

	// set views with new info
	self.commentTextViewContainerView.frame = containerFrame;
	
	// commit animations
	[UIView commitAnimations];
}



#pragma mark - Keyboard functions
//////////////
//Functions that monitor that showing of keyboard. Changing the parent table view frame.
/*-(void) keyboardWillShow:(NSNotification *)note{
        // get keyboard size and loctaion
        CGRect keyboardBounds;
        [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
        NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
        
        // Need to translate the bounds to account for rotation.
        keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
        // get a rect for the textView frame
        CGRect containerFrame = self.tableView.frame;
        containerFrame.origin.y = 64;
        containerFrame.size.height = self.view.bounds.size.height - (keyboardBounds.size.height) -  containerFrame.origin.y;
        // animations settings
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:[duration doubleValue]];
        [UIView setAnimationCurve:[curve intValue]];
        
        // set views with new info
        self.tableView.frame = containerFrame;
        [UIView commitAnimations];
    
    
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    self.tableView.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, self.view.bounds.size.height-64);
    
    // commit animations
    [UIView commitAnimations];
}
*/


-(void)textViewDidChange:(UITextView *)textView{
    _placeholderLabel.hidden = ([textView.text length] > 0);

    NSString *textViewText = textView.text;
    //[self colorWord];
   CGSize size = [textView sizeThatFits:CGSizeMake(self.commentTextView.frame.size.width, 300)];
    
    DebugLog(@"Height of textview: %f",size.height);
    if(size.height < 150)
    {
        [self.commentTextView setScrollEnabled:NO];
        CGRect frame = textView.frame;
        CGRect containerFrame = self.commentTextViewContainerView.frame;
        CGRect buttonFrame = self.commentButton.frame;

           // frame.origin.y += (frame.size.height-size.height);
        containerFrame.origin.y += (frame.size.height-size.height);
        containerFrame.size.height += -(frame.size.height-size.height);
        buttonFrame.origin.y += -(frame.size.height-size.height);

        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.1];
        [UIView setAnimationCurve:0.2];
        
        frame.size.height = size.height;
        [textView setFrame:frame];
        [self.commentTextViewContainerView setFrame:containerFrame];
        [self.commentButton setFrame:buttonFrame];
        
        
        
        
        [UIView commitAnimations];
        
        [self.commentTextViewContainerView setNeedsDisplay];

    }else{
        [self.commentTextView setScrollEnabled:YES];
        [self.commentTextView setContentSize:size];
        CGPoint bottomOffset = CGPointMake(0, self.commentTextView.contentSize.height - self.commentTextView.bounds.size.height);
        [self.commentTextView setContentOffset:bottomOffset animated:YES];
    }

    
    //If there is no characters in the textview, remove the tableview if it there.
    if([textViewText length]==0) {[tagTableView removeFromSuperview];
        
    }else{
        
        
        //This is the last character typed. If it is a space, do not bother with searching.
        if([_lastTextChanged isEqualToString:@" "]) //Handling when the user presses the space bar
        {
            //Removing the table view
            [tagTableView removeFromSuperview];
            _filtered = nil;
            tagTableView = nil;
            
        }
        else{
            //Getting the cursorLocation
            NSInteger cursorLocation = [textView selectedRange].location;
            
            //This variable is the word to search
            NSString *stringToSearch = [self wordAtIndex:cursorLocation withString:textViewText];
            
            //We will modify this variable so we can see if there is a tag sign and a space as a prefix
            NSString *cursorLocationWord  = [self wordAtIndex:cursorLocation withString:textViewText];
            
            //The prefix. Changes if it is the first word in the textview (space is trimmed from prefix)
            NSString *prefix;
     
            //if the character is the first character typed, do not bother with searching.
            if(cursorLocation != 1 &&   (cursorLocationWord.length < cursorLocation))
            {
                NSInteger check = cursorLocation-cursorLocationWord.length-2;
                //THIS PREVENTS FROM INCEPTION TAGGING SUCH AS @al@felixflrodi
                //If the cursor is not in the first word, keep the space in the word.
                if((check)> 0){
                   
                    cursorLocationWord = [textViewText substringWithRange:NSMakeRange(cursorLocation-cursorLocationWord.length-2, cursorLocationWord.length+2)];
                    prefix = @" @";
                }else {
                    //If the cursor is in the first word, trim the space from the prefix and the word.
                    cursorLocationWord = [textViewText substringWithRange:NSMakeRange(cursorLocation-cursorLocationWord.length-1, cursorLocationWord.length+1)];
                    prefix = @"@";
                }
                
                if ([cursorLocationWord hasPrefix:prefix]) {
                    
                    //Searching the cached following array with a predicate
                    
                    //Selected filtered is the array to send to the server when we comment.
                    _selectedFiltered = [cachedFollowingArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"username BEGINSWITH[c] %@ ",stringToSearch]];
                    
                    //Filtered is the array that is displayed in the tableview. (clears when the word is exactly like the one in the table view. Not necessary to show it.)
                    _filtered = [cachedFollowingArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"username BEGINSWITH[c] %@ AND username != %@",stringToSearch,stringToSearch]];
                    
                    //Do not show tableview if empty search results
                    if([_filtered count]>0)
                    {
                        
                        //Generating the thumburlarray
                        NSMutableArray *thumbUrlArray = [[NSMutableArray alloc]init];
                        for(NSString* picId in [_filtered valueForKeyPath:@"profilePicId"]){
                            NSString *imgUrl = [[NSString alloc]initWithFormat:@"%@%@%@",@"https://www.gymever.com/manageLogin/upload/",picId,@"-thumb.jpg"];
                            
                            [thumbUrlArray addObject:imgUrl];
                        }
                        
                        
                        //Initializing the table view
                        [tagTableView removeFromSuperview];
                        tagTableView = nil;
                        
                        tagTableView = [[TagTableView alloc] init];
                        [tagTableView setFrame:CGRectMake(0,64 ,[UIScreen mainScreen].bounds.size.width,self.commentTextViewContainerView.frame.origin.y-64)];
                        
                        tagTableView.idUserArray = [_filtered valueForKeyPath:@"followedUserID"];
                        tagTableView.fullnameArray = [_filtered valueForKeyPath:@"fullname"];
                        tagTableView.usernameArray = [_filtered valueForKeyPath:@"username"];
                        tagTableView.userProfileImageThumbURLArray = thumbUrlArray;
                        tagTableView.nbOfRows = [_filtered count];
                        tagTableView.viewController = self;
                        [self.view addSubview:tagTableView];
                        
                    } else [tagTableView removeFromSuperview];
                }else [tagTableView removeFromSuperview];
            }else [tagTableView removeFromSuperview];
        }
        
        
        //uncomment this to select all tags
        
         
         NSArray *words=[textView.text componentsSeparatedByString:@" "];
         
         for (NSString *word in words) {
         if ([word hasPrefix:@"@"]) {
         //Removing the @ prefix
         
         //Searching the cached following array with a predicate
         NSString *stringToSearch = [word substringFromIndex:1];
         _selectedFiltered = [cachedFollowingArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"username == %@ ",stringToSearch]];
         if([_selectedFiltered count]>0)
         {
         
             DebugLog(@"%@",[_selectedFiltered description]);

       
         
         }
         
         //else [tagTableView removeFromSuperview];
         
         
         
         }
         }
    }
    
}


- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
    
    
    // Create the CABasicAnimation for the shadow
   // CABasicAnimation *shadowAnimation = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
  //  shadowAnimation.duration = 0;
   // shadowAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]; // Match the easing of the UIView block animation
  //  shadowAnimation.fromValue = (id)self.commentGrowingTextView.layer.shadowPath;
    
    
   /* [UIView animateWithDuration:0 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{*/
      
      
        CGRect r = self.commentGrowingTextView.frame;
        r.size.height -= diff;
        self.commentGrowingTextView.frame = r;
        //If difference height is decreasing, insert the shadow right away
       /* if(diff>0)
            self.commentGrowingTextView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.commentGrowingTextView.bounds].CGPath;*/
        
        CGRect c = self.commentTextViewContainerView.frame;
        c.size.height -= diff;
        c.origin.y += diff;
        self.commentTextViewContainerView.frame = c;
    
        CGRect btnFrame = self.commentButton.frame;
        btnFrame.origin.y -= diff;
        self.commentButton.frame = btnFrame;
       

   /* }
    completion:^(BOOL finished) {
        //If difference height is increasing, insert the shadow after
                         if(diff<0)
                         self.commentGrowingTextView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.commentGrowingTextView.bounds].CGPath;

         }
        ];*/
    
    
    
    
    
    // Set the toValue for the animation to the new frame of the view
   // shadowAnimation.toValue = (id)[UIBezierPath bezierPathWithRect:self.commentGrowingTextView.bounds].CGPath;
    
    // Add the shadow path animation
   // [self.commentGrowingTextView.layer addAnimation:shadowAnimation forKey:@"shadowPath"];
    
    // Set the new shadow path
	
    


}



-(void)loadMediaCommentCount
{
    NSString* command = @"showMediaCommentCount";
    NSMutableDictionary* params =[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  command, @"command",
                                  self.idMedia, @"idMedia",
                                  nil];
    
    
    //make the call to the web API
    [[GymEverAPI sharedInstance] commandWithParams:params
                                      onCompletion:^(NSArray *json) {
                                          //handle the response
                                           //DebugLog(@"Currently checking the response");
                                          //result returned
                                          
                      
                                          for(NSDictionary* res in json)
                                          {
                                              
      
                                                  if([res objectForKey:@"commentCount"]!= nil)
                                                  {
                                                      self.totalNbOfComments = [res objectForKey:@"commentCount"];
                                                      
                                                      if([self.totalNbOfComments integerValue]>8){
                                                          [self showLoadMediaCommentsButton];
                                                      }
                                                     
                                                  }
                                              
                                          }
                                      }];
}

-(void)showLoadMediaCommentsButton{
    [self.loadMoreCommentsView setHidden:NO];
    [self.tableView scrollRectToVisible:CGRectMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height) animated:NO];

}
-(void)hideLoadMediaCommentButton{
    [self.loadMoreCommentsView setHidden:YES];

}
-(void)loadCommentsWithOffset:(NSString*)offset loadMoreComments:(bool)isMoreComments{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    
    
    DebugLog(@"loading comments WITH offset %@",offset);
    NSString* command = @"showMediaComments";
    NSMutableDictionary* params =[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  command, @"command",
                                  self.idMedia, @"idMedia",
                                  offset,@"offset",
                                  _currentTime,@"firstViewCommentTime",
                                  nil];
    
    
    //make the call to the web API
    [[GymEverAPI sharedInstance] commandWithParams:params
                                      onCompletion:^(NSArray *json) {
                                          //handle the response
                                          NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:
                                                                 NSMakeRange(0,[json count])];
                                          [self.commentsArray insertObjects:json atIndexes:indexes];
                                          _commentOffset += [json count];

                                          int i = 0;
                                          for(NSDictionary* res in json)
                                          {
                                              
                                              
                                              
                                             
                                                      //Dynamic label size
                                                      _modelLabel.text =[res objectForKey:@"comment"];
                                                        CGSize maximumLabelSize = CGSizeMake(228, 1000);
                                                        CGSize expectedSize = [_modelLabel sizeThatFits:maximumLabelSize];
                                                        [heightForRowArray insertObject:[NSNumber numberWithFloat:expectedSize.height]atIndex:i];
                                                      
                                              
                                            
                                          }
                                          
                                          
                                          
                                          [self enableLoadCommentsButton];
                                          [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                          if(_commentOffset == [self.totalNbOfComments integerValue]) [self hideLoadMediaCommentButton];
                                          [self.tableView reloadData];
                                      } onFailure:^(AFHTTPRequestOperation *operation) {
                                          [self enableLoadCommentsButton];
                                          [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

                                      }];
    
}

-(void)enableLoadCommentsButton
{
    [_loadMoreCommentsButton setEnabled:YES];

}

-(void)disableLoadCommentsButton
{
    [_loadMoreCommentsButton setEnabled:NO];
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [self.commentsArray count];
}
-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentCell *ccell = (CommentCell*)cell;
    
    
    
    [ccell.loadImageOperation cancel];
    
    //scell.userProfilePictureView.image = [UIImage imageNamed:@"noPpic.jpg"];
}




-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    // Determine which reuse identifier should be used for the cell at this index path.
    NSString *reuseIdentifier = @"CommentCell";
  
   
    // Use a dictionary of offscreen cells to get a cell for the reuse identifier, creating a cell and storing
    // it in the dictionary if one hasn't already been added for the reuse identifier.
    // WARNING: Don't call the table view's dequeueReusableCellWithIdentifier: method here because this will result
    // in a memory leak as the cell is created but never returned from the tableView:cellForRowAtIndexPath: method!
    CommentCell *ccell = [offscreenCells objectForKey:reuseIdentifier];
    if (!ccell) {
        ccell = (CommentCell*)[tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
        //ccell = [[CommentCell alloc] init];
        [offscreenCells setObject:ccell forKey:reuseIdentifier];
    }
    

if([self.commentsArray count]>0){
    
                ccell.usernameLabel.text = [[self.commentsArray objectAtIndex:indexPath.row]objectForKey:@"username"];
                
                [ccell.usernameLabel addLinkForUsername:ccell.usernameLabel.text];
                
                [ccell.usernameLabel setNeedsDisplay];
                NSString* commentString = [[self.commentsArray objectAtIndex:indexPath.row]objectForKey:@"comment"];
                
                ccell.commentLabel.text = commentString;
    
                
   
                    ccell.idComment = [[self.commentsArray objectAtIndex:indexPath.row] objectForKey:@"idComment"];
    
            NSString *createdString = [[self.commentsArray objectAtIndex:indexPath.row] objectForKey:@"created"];
                ccell.timeLabel.text =   [[_dbDateFormatter dateFromString:createdString] prettyDate];
    
 }

    [ccell setNeedsDisplay];

    // Make sure the constraints have been set up for this cell, since it may have just been created from scratch.
    // Use the following lines, assuming you are setting up constraints from within the cell's updateConstraints method:
    [ccell setNeedsUpdateConstraints];
    [ccell updateConstraintsIfNeeded];
    
    // Set the width of the cell to match the width of the table view. This is important so that we'll get the
    // correct cell height for different table view widths if the cell's height depends on its width (due to
    // multi-line UILabels word wrapping, etc). We don't need to do this above in -[tableView:cellForRowAtIndexPath]
    // because it happens automatically when the cell is used in the table view.
    // Also note, the final width of the cell may not be the width of the table view in some cases, for example when a
    // section index is displayed along the right side of the table view. You must account for the reduced cell width.
    ccell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.bounds), 64);
    // Do the layout pass on the cell, which will calculate the frames for all the views based on the constraints.
    // (Note that you must set the preferredMaxLayoutWidth on multi-line UILabels inside the -[layoutSubviews] method
    // of the UITableViewCell subclass, or do it manually at this point before the below 2 lines!)
    [ccell setNeedsLayout];
    [ccell layoutIfNeeded];
    
    // Get the actual height required for the cell's contentView
    CGFloat height = [ccell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    // Add an extra point to the height to account for the cell separator, which is added between the bottom
    // of the cell's contentView and the bottom of the table view cell.
    height += 1.0f;
    
    return height;

    
}





- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentCell *cell = (CommentCell*)[tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    cell.commentLabel.navigationController = self.navigationController;
    cell.usernameLabel.navigationController = self.navigationController;
    cell.commentLabel.delegate = cell.commentLabel;
    cell.usernameLabel.delegate = cell.usernameLabel;
    
    cell.idMedia = self.idMedia;
    
    //TO refresh the comments after having commented
    cell.commentTableViewController = self;
   // __block NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        //if(![operation isCancelled]){
            
            cell.usernameLabel.text = [[self.commentsArray objectAtIndex:indexPath.row]objectForKey:@"username"];
            
            [cell.usernameLabel addLinkForUsername:cell.usernameLabel.text];
            
            [cell.usernameLabel setNeedsDisplay];
            NSString* commentString = [[self.commentsArray objectAtIndex:indexPath.row]objectForKey:@"comment"];
            
            cell.commentLabel.text = commentString;
           
            
            CGFloat labelHeight = [[heightForRowArray objectAtIndex:indexPath.row] floatValue];
            
            
            cell.idComment = [[self.commentsArray objectAtIndex:indexPath.row] objectForKey:@"idComment"];
            
            NSString *createdString = [[self.commentsArray objectAtIndex:indexPath.row] objectForKey:@"created"];
            cell.timeLabel.text =   [[_dbDateFormatter dateFromString:createdString] prettyDate];
            NSString *urlString = [[NSString alloc]initWithFormat:@"%@%@%@",@"https://www.gymever.com/manageLogin/upload/",[[self.commentsArray objectAtIndex:indexPath.row] objectForKey:@"profilePicId"],@"-thumb.jpg"];
            
            NSURL *url =[NSURL URLWithString:urlString];
            if(url)
            {
                UIImageView *modelImageView = [[UIImageView alloc]init];
                [modelImageView setFrame:cell.profileImageButton.frame];
                HNKCacheFormat *format = [HNKCache sharedCache].formats[@"smallUserPicFormat"];
                modelImageView.hnk_cacheFormat = format;
                [modelImageView hnk_setImageFromURL:url placeholderImage:nil success:^(UIImage *image) {
                    [cell.profileImageButton setImage:image forState:UIControlStateNormal];
                } failure:^(NSError *error) {
                    [cell.profileImageButton setImage:[UIImage imageNamed:@"noPpic.png"] forState:UIControlStateNormal];
                }];
            }else{
                [cell.profileImageButton setImage:[UIImage imageNamed:@"noPpic.png"]forState:UIControlStateNormal];
            }
            
            
      //  }
    //}];
    
   // cell.loadImageOperation = operation;
   // [operationQueue addOperation:operation];
    
    return cell;
    
}


-(HNKCacheFormat*)initializeHNKFormat{
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






#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentCell *cell = (CommentCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        ProfileViewController *vc = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
        vc.username = cell.usernameLabel.text;
        vc.profileIdUser = [[self.commentsArray objectAtIndex:indexPath.row] objectForKey:@"idUser"];
        vc.isIphoneUser = NO;
        [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView{
    [self commentButtonTapped:nil];
    return NO;
}

-(CGFloat)addHeightForRow:(NSString*)comment{
    _modelLabel.text = comment;
      CGSize maximumLabelSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 1000);
     CGSize expectedSize = [_modelLabel sizeThatFits:maximumLabelSize];
    return expectedSize.height;
}



- (IBAction)commentButtonTapped:(id)sender {
 
    //Checking if string has characters other than space and new lines so we can post a valid comment
    NSString* result = [self.commentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if(self.commentTextView && [result length]>0)
    {
        
        
    NSInteger nbComments = [self.nbOfComments integerValue];

        nbComments++;
        self.nbOfComments = [[NSString alloc]initWithFormat:@"%ld",(long)nbComments ];
        
        
    NSInteger totalNbComments = [self.totalNbOfComments integerValue];
        totalNbComments++;
        self.totalNbOfComments = [[NSString alloc]initWithFormat:@"%ld",(long)totalNbComments ];
        
        
        NSMutableDictionary *comment = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.commentTextView.text,@"comment",[[GymEverAPI sharedInstance].user objectForKey:@"username"],@"username",[[GymEverAPI sharedInstance].user objectForKey:@"profilePicId"],@"profilePicId",[_dbDateFormatter stringFromDate:[NSDate date]],@"created", nil];


        [heightForRowArray addObject:[NSNumber numberWithFloat:[self addHeightForRow:self.commentTextView.text]]];
        
        
        [self.commentsArray addObject:comment];
        [self.tableView reloadData];
       
        
        NSIndexPath *lastRowIndexPath =[NSIndexPath indexPathForRow:nbComments-1 inSection:0];
         CommentCell *cell = (CommentCell*)[self.tableView cellForRowAtIndexPath:lastRowIndexPath];

        [self commentMediaRequest:cell withCommentString:self.commentTextView.text];
    
    
    
        if(nbComments!=-1)
        {

            [self scrollToBottom];
            
        }
    
   
    }
    
   }

-(void)commentMediaRequest:(CommentCell*)cell withCommentString:(NSString*)commentString
{
    NSString* command = @"commentMedia";
    NSMutableDictionary* params =[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  command, @"command",
                                  [[GymEverAPI sharedInstance].user objectForKey:@"idUser"],@"idUser",
                                  commentString,@"comment",
                                  self.idMedia, @"idMedia",
                                  self.IdUser,@"notifiedIdUser",
                                  nil];
    
    self.commentTextView.text = @"";
    [self textViewDidChange:self.commentTextView];
    [self resignTextView];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    DebugLog(@"Comment posting");
    //make the call to the web API
    [[GymEverAPI sharedInstance] commandWithParams:params
                                      onCompletion:^(NSArray *json) {
                                          DebugLog(@"in comment posting");
                                          
                                          
                                              //   dispatch_sync(dispatch_get_main_queue(), ^{
                                              DebugLog(@"Comment posted");
                                              
                                             // [cell.commentActivityIndicator stopAnimating];
                                              //  });

                                              dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

                                              [self.gymEverTableVideoController refreshCommentsAndLikes];
                                              });
                                                  NSDictionary* res = json[0];
                                          
                                          [[self.commentsArray lastObject] setValue:[res objectForKey:@"idComment"] forKey:@"idComment"];
                                          [[self.commentsArray lastObject] setValue:[[GymEverAPI sharedInstance].user objectForKey:@"idUser"] forKey:@"idUser"];
                                          
                                          

                                              DebugLog(@"id comment:%@",[res objectForKey:@"idComment"]);
                                              
                                              DebugLog(@" user id : %@",self.IdUser);
                                          
                                          [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

                                      } onFailure:^(AFHTTPRequestOperation *operation) {
                                          if(operation.responseString) DebugLog(@"Comment failed : %@", operation.responseString);
                                          //[cell.commentActivityIndicator stopAnimating];
                                          [cell.retryCommentButton setEnabled:true];
                                          [cell.retryCommentButton setHidden:NO];
                                          [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

                                      }];
}

-(void)deleteCommentWithIdComment:(NSString*)idComment atRow:(NSUInteger)row
{
    NSString* command = @"deleteComment";
    NSMutableDictionary* params =[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  command, @"command",
                                  idComment,@"idComment",
                                 [[self.commentsArray objectAtIndex:row] objectForKey:@"idUser" ],@"idUser",
                                  self.idMedia, @"idMedia",
                                  self.IdUser,@"notifiedIdUser",
                                  nil];
    
    
    DebugLog(@"Comment deleting");
    //make the call to the web API
    [[GymEverAPI sharedInstance] commandWithParams:params
                                      onCompletion:^(NSArray *json) {
                                          
                                          

                                              dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                  
                                                  [self.gymEverTableVideoController refreshCommentsAndLikes];
                                              });
                                              DebugLog(@"Successfully deleted comment");
                                       
                                          
                                          
                                          
                                          
                                          
                                      }];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        DebugLog(@"Delete comment");
        //[tableView reloadData];
        
        NSInteger nbComments = [self.nbOfComments integerValue];
        nbComments--;
        self.nbOfComments = [[NSString alloc]initWithFormat:@"%ld",(long)nbComments ];
        
        NSInteger totalNbComments = [self.totalNbOfComments integerValue];
        totalNbComments--;
        self.totalNbOfComments = [[NSString alloc]initWithFormat:@"%ld",(long)totalNbComments ];
        
        [self.tableView beginUpdates];
        [self deleteCommentWithIdComment:[[self.commentsArray objectAtIndex:indexPath.row]objectForKey:@"idComment" ] atRow:indexPath.row];
        [self.commentsArray removeObjectAtIndex:indexPath.row];
        [heightForRowArray removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [operationQueue cancelAllOperations];
        
        [self.tableView endUpdates];
        [self.tableView setEditing:NO];
        
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentCell *cell = (CommentCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    
    if(self.isIphoneUserMedia || [cell.usernameLabel.text isEqualToString:[[GymEverAPI sharedInstance].user  objectForKey:@"username"]])
    return YES;
    else return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCellEditingStyle result = UITableViewCellEditingStyleDelete;
    return result;
}



- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0f;
}

//Attempted method to refresh the comments
-(void)reloadComments{
    self.nbOfComments = @"0";

}

- (IBAction)loadMoreCommentsButtonTapped:(id)sender {
    
    [self disableLoadCommentsButton];

        [self loadCommentsWithOffset:[[NSString alloc]initWithFormat:@"%d",_commentOffset] loadMoreComments:YES];
        

    
}

- (IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)initializeModelLabel
{
    _modelLabel = [[CustomColoredLabel alloc]init];
    _modelLabel.numberOfLines = 0;
    //MAKE SURE TO MATCH THE STORYBOARD's FONT
    _modelLabel.font = [UIFont systemFontOfSize:14.0];
    _modelLabel.lineBreakMode = NSLineBreakByClipping;
}

#pragma Cache methods for following array ( tag implementation )
#pragma mark - Caching idUser following array (sorted)
-(void)initializeCacheKeys
{
    NSString *idUser = [[GymEverAPI sharedInstance].user objectForKey:@"idUser"];
    _followingCachedKey = [[NSString alloc]initWithFormat:@"%@followingArray",idUser];
    _cacheStoredKey = [[NSString alloc]initWithFormat:@"%@followingIsStored",idUser];
}

-(void)cacheFollowingArray:(NSArray* )followingArray{
    [self initializeCacheKeys];
    if(followingArray) [[EGOCache globalCache]setObject:followingArray forKey:_followingCachedKey withTimeoutInterval:604800];
    [[EGOCache globalCache]setObject:[NSNumber numberWithBool:YES] forKey:_cacheStoredKey withTimeoutInterval:604800];
}

-(NSArray*)getSortedFollowingArray{
    if([self checkIfCacheStored])
    {
        return (NSMutableArray*)[[EGOCache globalCache]objectForKey:_followingCachedKey];
    }
    return nil;
}

-(BOOL)checkIfCacheStored{
    [self initializeCacheKeys];
    if([[EGOCache globalCache]objectForKey:_cacheStoredKey]==[NSNumber numberWithBool:YES])
        return YES;
    else return NO;
}


#pragma - mark Table view delegate methods for selecting (tag table view ) 


-(void)selectedRowWithUserDetails:(SmallUserTableCell *)cell{
    [tagTableView removeFromSuperview];
    [self addNameToTextViewWithString:cell.smallUserCellView.username];
}

-(void)addNameToTextViewWithString:(NSString*)string{
    NSString *text = self.commentTextView.text;
    NSUInteger cursorLocation = [self.commentTextView selectedRange].location;
    NSString *cursorLocationWord = [self wordAtIndex:cursorLocation withString:text];
    DebugLog(@"Word %@ at index %d",cursorLocationWord,cursorLocation);
    NSString* firstStringPart = [text substringWithRange:NSMakeRange(0,cursorLocation-cursorLocationWord.length)];
    NSString* secondStringPart;
   /* if(cursorLocation > text.length){
    tringPart = @"";
    }else{*/
        secondStringPart = [text substringFromIndex:cursorLocation];
        
   /* }*/
    DebugLog(@"FirstPart %@ and Secondpart %@",firstStringPart,secondStringPart);

    //Trim the space (happens after we explicitly select the row after the user presses a spacebar with only one user in table view
  /*  if([[text substringFromIndex:[text length]-1] isEqualToString:@" "])
    {
        self.commentGrowingTextView.internalTextView.text = [self.commentGrowingTextView.internalTextView.text substringToIndex:text.length-1];
    }*/
    NSArray *words=[self.commentTextView.text componentsSeparatedByString:@" "];
    NSString *lastword = [words lastObject];
    
    NSUInteger index= [self.commentTextView.text length]-[lastword length];
    text = [text substringToIndex:index]; //-1 because of the prefix that is removed
    
    //Adding a space
    string = [NSString stringWithFormat:@"%@ ",string];

   // self.commentGrowingTextView.internalTextView.text = [[NSString alloc]initWithFormat:@"%@@%@ ",text,string];
    
    self.commentTextView.text = [[NSString alloc]initWithFormat:@"%@%@%@",firstStringPart,string,secondStringPart];

    [self textViewDidChange:self.commentTextView];
    [self.commentTextView setSelectedRange:NSMakeRange(cursorLocation-cursorLocationWord.length+string.length, 0)];
    [tagTableView removeFromSuperview];

}

- (NSString *) wordAtIndex:(NSInteger) index withString:(NSString*)string{
    __block NSString *result = nil;
    [string enumerateSubstringsInRange:NSMakeRange(0, string.length)
                             options:NSStringEnumerationByWords
                          usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                              if (NSLocationInRange(index-1, enclosingRange)) {
                                  result = substring;
                                  *stop = YES;
                              }
                          }];
    return result;
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)atext {
    _lastTextChanged = atext;
    //weird 1 pixel bug when clicking backspace when textView is empty
    if(![textView hasText] && [atext isEqualToString:@""]) return NO;
    
    //Added by bretdabaker: sometimes we want to handle this ourselves
    if ([self respondsToSelector:@selector(growingTextView:shouldChangeTextInRange:replacementText:)])
        return [self growingTextView:self.commentGrowingTextView shouldChangeTextInRange:range replacementText:atext];
    
    if ([atext isEqualToString:@"\n"]) {
        if ([self respondsToSelector:@selector(growingTextViewShouldReturn:)]) {
            if (![self performSelector:@selector(growingTextViewShouldReturn:) withObject:self]) {
                return YES;
                
            } else {
                [textView resignFirstResponder];
                return NO;
            }
        }
    }
    
    return YES;

}
/*
///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
        return [self growingTextViewShouldBeginEditing:self.commentGrowingTextView];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
        return [self growingTextViewShouldEndEditing:self.commentGrowingTextView];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDidBeginEditing:(UITextView *)textView {
        [self growingTextViewDidBeginEditing:self.commentGrowingTextView];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDidEndEditing:(UITextView *)textView {
        [self growingTextViewDidEndEditing:self.commentGrowingTextView];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDidChangeSelection:(UITextView *)textView {
        [self growingTextViewDidChangeSelection:self.commentGrowingTextView];
}*/

-(void)setCommentButtonShadow{
    //Adds a shadow to boxView
   /* self.commentButton.layer.shadowOffset = CGSizeMake(0, 1.25);
    self.commentButton.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.commentButton.layer.shadowRadius = 2.0f;
    self.commentButton.layer.shadowOpacity = 0.40f;
    self.commentButton.layer.shadowPath = [[UIBezierPath bezierPathWithRect:self.commentButton.layer.bounds] CGPath];*/
    self.commentButton.layer.cornerRadius = 2;
    
}
@end
