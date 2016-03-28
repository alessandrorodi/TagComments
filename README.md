Here is the code for the mechanism used the app GymEver; when users comment and tag other users. It searches and displays only the users that you are following when you type after '#' or '@' . 

In CommentsTableViewController.m : 

The first part of textViewDidChange fixes the comment box's height depending on the text.  -tagTableView is a custom UITableView class where it displays the users currently matching with what the user is typing in the commentBox.  

_selectedFiltered is the array regrouping the users we tagged in the current comment. _filtered is the array displayed in tagTableView matching the current string in the commentBox; to create the _selectedFiltered array.  


The back-end scans and checks the comment itself for any tags with '@' and notifies the relevant users.

--

SmallUserCellView is a custom view class that draws manually the strings and the image in a custom UITableView cell.

CustomColoredLabel is a customized TTTAttributedLabel class. It is coded in the goal of recognizing strings starting with '@' or '#'. It colors them with a defined color and also provides a mechanism to push a view controller when clicking on them.
https://github.com/TTTAttributedLabel/TTTAttributedLabel