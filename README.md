<h1> TAG COMMENTS </h1>

Here is the code for the mechanism used in the app [GymEver](https://itunes.apple.com/ca/app/gymever/id827253499?mt=8) ; when users comment and tag other users. It searches and displays only the users that you are following when you type some characters after *#* or *@*. 

--

In **CommentsTableViewController.m** : 

The first part of *textViewDidChange* method fixes the comment box's height depending on the text.  

**TagTableView** is a custom *UITableView* class where it displays the users currently matching with what the user is typing in the commentBox.  

*_filtered* is the array displayed in **TagTableView** matching the current string in the Comment Box.


*Your back-end should scan and checks the comment itself for any tags with '@' and notifies the relevant users.*

--

*SmallUserCellView* is a custom view class that draws manually the strings and the image in a custom UITableView cell.

*CustomColoredLabel* is a customized [TTTAttributedLabel](https://github.com/TTTAttributedLabel/TTTAttributedLabel) class. It is coded in the goal of recognizing strings starting with *@* or *#*. It colors them with a defined color and also provides a mechanism to push a view controller when clicking on them.

--

Any questions ? E-mail me at *alrodi@gymever.com*
