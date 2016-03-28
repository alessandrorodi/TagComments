//
//  FollowerTableViewController.m
//  gymEver
//
//  Created by Alessandro Rodi on 2013-11-25.
//  Copyright (c) 2013 alegiallo. All rights reserved.
//

#import "CommentsTableViewController.h"
#import "CommentCell.h"
#import <QuartzCore/QuartzCore.h>
#import "NSDate+PrettyDate.h"

#import "TagTableView.h"
#import "SmallUserTableCell.h"

@interface CommentsTableViewController ()
{
    //The array to search in for when writing a string with @ or #
    NSArray *cachedFollowingArray;
    
    //Formatting the date
    NSDateFormatter *_dbDateFormatter;
    
    //Array for displaying users(tag)
    NSArray *_filtered;
    
    //The table view that displays the users that match with the current string following '@' or '#'
    TagTableView *tagTableView;
    
    //Most recent string changed by the text view
    NSString *_lastTextChanged;
    
    //Showing 'add a comment..' in UITEXTVIEW (No default placeholder attribute :( )
    UILabel *_placeholderLabel;

    //Used to cache cell heights
    NSMutableDictionary *offscreenCells;

    //Keyboard size in screen.
    CGRect keyboardBounds;
}
@end

@implementation CommentsTableViewController


/**
 * Toggling keyboard if we begin to scroll through the comments
 */
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if([scrollView isEqual:self.tableView])
    [self.commentTextView resignFirstResponder];

}

/**
 * Setting timezone of your database
 * (Eg. An example back-end here with a server with Chicago's timezone.
 */
-(void)initializeDbDateFormatter
{
    _dbDateFormatter = [[NSDateFormatter alloc] init];
    [_dbDateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"America/Chicago"]];
    [_dbDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
}

/**
 * Initialize the table view
 */
-(void)initializeTableView{
    self.tableView.delegate = self;
    self.tableView.dataSource =self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}


/**
 * Initialize various stuff for the screen to load properly
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Loading table view
    [self initializeTableView];
    
    //Initializing date formatter
    [self initializeDbDateFormatter];
    
    if(!self.commentsArray){
        self.commentsArray = [[NSMutableArray alloc]init];
         //Do anything here to load your current comments
    }
    
    //Loading cells array for autolayout cell height adjustment
    offscreenCells = [[NSMutableDictionary alloc]init];

    
    //Manually setting the frame of the comment text view ontainer
    [self.commentTextViewContainerView setFrame:CGRectMake(self.commentTextViewContainerView.frame.origin.x, ([[UIScreen mainScreen] preferredMode].size.height/[[UIScreen mainScreen] scale])-self.commentTextViewContainerView.frame.size.height, self.commentTextViewContainerView.frame.size.width, self.commentTextViewContainerView.frame.size.height)];
    
    
    //Initialize our comment text view
    [self initializeNormalTextview];
    
    //Getting cached array (from followingArray.json)
    cachedFollowingArray = [self getSortedFollowingArray];


    //Disabling auto correct to explicitly show the function of this project
    [self.commentTextView setAutocorrectionType:UITextAutocorrectionTypeNo];
    

}


/**
 * Parsing JSON from a file.
 */
-(NSArray*)dictionaryWithContentsOfJSONString:(NSString*)path{
    NSData* data = [NSData dataWithContentsOfFile:path];
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data
                                                options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}


/**
 * Gets the array to display when we type a string follow '@' or '#'
 * (Normally you would load this from your back-end; notice here how it's loaded from followingArray.json)
 * /return The array of all the users you're following
 */
-(NSMutableArray*)getSortedFollowingArray{
    //Parsing JSON from local file
    NSMutableArray *sortedFollowingArray;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"followingArray" ofType:@"json"];
    sortedFollowingArray = [[self dictionaryWithContentsOfJSONString:path] mutableCopy];
    return sortedFollowingArray;
}


/** 
 * Initializing the text view in the comment container
 */
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
    

    
    [self.commentTextView setDelegate:self];
    [self.commentTextView setFont:[UIFont systemFontOfSize:14]];
    [self.commentTextViewContainerView addSubview:self.commentTextView];
    
    //Initializing placeholder label
    _placeholderLabel = [[UILabel alloc]init];
    [_placeholderLabel setFrame:CGRectMake(4, 0, self.commentTextView.frame.size.width, self.commentTextView.frame.size.height)];
    [_placeholderLabel setText:NSLocalizedString(@"Add a comment", nil)];
    [_placeholderLabel setTextColor:[UIColor lightGrayColor]];
    [_placeholderLabel setBackgroundColor:[UIColor clearColor]];
    [_placeholderLabel setFont:[UIFont systemFontOfSize:14]];
    
    //Adding placeholder label in the text view
    [self.commentTextView addSubview:_placeholderLabel];
    [self.commentTextView sendSubviewToBack:_placeholderLabel];
    [self.commentTextView setBackgroundColor:[UIColor whiteColor]];
    

}

/**
 * Hides placeholder when text is typed in the text view.
 */
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    _placeholderLabel.hidden = YES;
}

/**
 * Hides placeholder when text is typed in the text view.
 */
- (void)textViewDidEndEditing:(UITextView *)textView
{
    _placeholderLabel.hidden = ([textView.text length] > 0);
}


/**
 * Auto-layout issues
 */
-(void)viewDidLayoutSubviews{
    [self.tableView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [self.commentTextViewContainerView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [self.view setTranslatesAutoresizingMaskIntoConstraints:YES];
    

}

#pragma mark - Keyboard functions

/**
 * Gets the right size of TagTableview depending on keyboard's size.
 * //some code from Brett Schumann on StackOverflow
 */
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

/**
 * Gets the right size of TagTableview depending on keyboard's size.
 * //some code from Brett Schumann on StackOverflow
 */
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



#pragma mark - UITEXTVIEW delegate methods

/**
 * UITEXTVIEW delegate method
 * Method handling the text view size and showing the tag table view when typing string after '@'
 
 The first part of textViewDidChange fixes the comment box's height depending on the text.  
 
 -tagTableView is a custom UITableView class where it displays the users currently matching with what the user is typing in the commentBox.  
 
 _filtered is the array displayed in tagTableView matching the current string in the commentBox.
 
 */
-(void)textViewDidChange:(UITextView *)textView{
    _placeholderLabel.hidden = ([textView.text length] > 0);

    NSString *textViewText = textView.text;
    //[self colorWord];
   CGSize size = [textView sizeThatFits:CGSizeMake(self.commentTextView.frame.size.width, 300)];
    
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

    }
    
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



/*
 UITABLEVIEW delegate method
 * some code taken from stack overflow to build the cell height with auto-layour
 */
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
        //Building comment cell to get the right cell height.
        [self setCommentCell:ccell withIndexPath:indexPath];
    
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

/*
 * Building comment cell from the array values.
 */
-(void)setCommentCell:(CommentCell*)cell withIndexPath:(NSIndexPath*)indexPath{
    //Username
    cell.usernameLabel.text = [[self.commentsArray objectAtIndex:indexPath.row]objectForKey:@"username"];
    [cell.usernameLabel addLinkForUsername:cell.usernameLabel.text];
    [cell.usernameLabel setNeedsDisplay];
    
    
    //Setting the text of the comment.
    NSString* commentString = [[self.commentsArray objectAtIndex:indexPath.row]objectForKey:@"comment"];
    cell.commentLabel.text = commentString;
    
    //Setting the id of comment.
    cell.idComment = [[self.commentsArray objectAtIndex:indexPath.row] objectForKey:@"idComment"];
    
    //Formatting the date from the comment record. (In our case, the date field is called 'created')
    NSString *createdString = [[self.commentsArray objectAtIndex:indexPath.row] objectForKey:@"created"];
    cell.timeLabel.text =   [[_dbDateFormatter dateFromString:createdString] prettyDate];
    
    //Setting default no profile pic image
    [cell.profileImageButton setImage:[UIImage imageNamed:@"noPpic.png"] forState:UIControlStateNormal];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentCell *cell = (CommentCell*)[tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    
    //Building comment cell.
    [self setCommentCell:cell withIndexPath:indexPath];
    
    //If we want to push a view from the cell directly.
    cell.commentTableViewController = self;
    
    //Setting the delegates and navigation controller for CustomColoredLabel
    cell.commentLabel.delegate = cell.commentLabel;
    cell.usernameLabel.delegate = cell.usernameLabel;
    cell.commentLabel.navigationController = self.navigationController;
    cell.usernameLabel.navigationController = self.navigationController;
    
    
    
    return cell;
    
  
}







#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentCell *cell = (CommentCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    DebugLog(@"Open profile that commented this comment !");

}



/**
 Method when clicking on 'Send' Button
 */
- (IBAction)commentButtonTapped:(id)sender {
 
    //Checking if string has characters other than space and new lines so we can post a valid comment
    NSString* result = [self.commentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if(self.commentTextView && [result length]>0)
    {
        //Setting appropriate number of comments
        NSInteger nbComments = [self.nbOfComments integerValue];
        nbComments++;
        self.nbOfComments = [[NSString alloc]initWithFormat:@"%ld",(long)nbComments ];
        
        //Set your own comment here
        NSMutableDictionary *comment = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.commentTextView.text,@"comment",@"yourusername",@"username",@"0",@"profilePicId",[_dbDateFormatter stringFromDate:[NSDate date]],@"created", nil];

        [self.commentsArray addObject:comment];
        [self.tableView reloadData];
       
        
        
        //Back-end method
        NSIndexPath *lastRowIndexPath =[NSIndexPath indexPathForRow:nbComments-1 inSection:0];
        CommentCell *cell = (CommentCell*)[self.tableView cellForRowAtIndexPath:lastRowIndexPath];
        [self commentMediaRequest:cell withCommentString:self.commentTextView.text];
    
    
        //Scrolling to bottom if there is more than one comment
        if(nbComments!=-1)
        {
            [self scrollToBottom];
        }
    
    }
    
   }
/**
 * Method to request your back-end and add the relevant information to commentsArray when you get your response from posting a comment in the database.
 */
-(void)commentMediaRequest:(CommentCell*)cell withCommentString:(NSString*)commentString
{
    //Request your back-end here to post a comment in the databse. Add the following lines when you get your back-end response.
    
    self.commentTextView.text = @"";
    [self textViewDidChange:self.commentTextView];
    [[self.commentsArray lastObject] setValue:@"0" forKey:@"idComment"];
    [[self.commentsArray lastObject] setValue:@"0" forKey:@"idUser"];

}

/**
 * Method to delete this comment from the database
 */
-(void)deleteCommentWithIdComment:(NSString*)idComment atRow:(NSUInteger)row
{
    DebugLog(@"Comment deleting");
}

/**
 * UITABLEVIEW delegate method;
 * Delete comments when editing the table view.
 */
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        DebugLog(@"Delete comment");
        
        NSInteger nbComments = [self.nbOfComments integerValue];
        nbComments--;
        self.nbOfComments = [[NSString alloc]initWithFormat:@"%ld",(long)nbComments ];

        [self.tableView beginUpdates];
        [self deleteCommentWithIdComment:[[self.commentsArray objectAtIndex:indexPath.row]objectForKey:@"idComment" ] atRow:indexPath.row];
        [self.commentsArray removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [self.tableView endUpdates];
        [self.tableView setEditing:NO];
        
    }
    
}

/**
 * UITABLEVIEW delegate method;
 * Only allow to delete comments if you're the one who wrote it.
 */
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentCell *cell = (CommentCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    
    if([cell.usernameLabel.text isEqualToString:@"yourusername"])
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

/**
 * Method stub to load more comments from database
 */
- (IBAction)loadMoreCommentsButtonTapped:(id)sender {
    //When loading more comments
}



#pragma - mark Table view delegate methods for selecting (tag table view ) 


/**
 * When a name is selected from TagTableView
 */
-(void)selectedRowWithUserDetails:(SmallUserTableCell *)cell{
    [tagTableView removeFromSuperview];
    [self addNameToTextViewWithString:cell.smallUserCellView.username];
}


/**
 * Adds tagged name into the textview
 */
-(void)addNameToTextViewWithString:(NSString*)string{
    NSString *text = self.commentTextView.text;
    NSUInteger cursorLocation = [self.commentTextView selectedRange].location;
    NSString *cursorLocationWord = [self wordAtIndex:cursorLocation withString:text];
    DebugLog(@"Word %@ at index %d",cursorLocationWord,cursorLocation);
    NSString* firstStringPart = [text substringWithRange:NSMakeRange(0,cursorLocation-cursorLocationWord.length)];
    NSString* secondStringPart;

    secondStringPart = [text substringFromIndex:cursorLocation];
        
    DebugLog(@"FirstPart %@ and Secondpart %@",firstStringPart,secondStringPart);

 
    NSArray *words=[self.commentTextView.text componentsSeparatedByString:@" "];
    NSString *lastword = [words lastObject];
    
    NSUInteger index= [self.commentTextView.text length]-[lastword length];
    text = [text substringToIndex:index]; //-1 because of the prefix that is removed
    
    //Adding a space
    string = [NSString stringWithFormat:@"%@ ",string];
    
    self.commentTextView.text = [[NSString alloc]initWithFormat:@"%@%@%@",firstStringPart,string,secondStringPart];

    [self textViewDidChange:self.commentTextView];
    [self.commentTextView setSelectedRange:NSMakeRange(cursorLocation-cursorLocationWord.length+string.length, 0)];
    [tagTableView removeFromSuperview];

}

/**
 * Returns word at a wanted index.
 */
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






@end
