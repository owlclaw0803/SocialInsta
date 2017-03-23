//
//  CommntViewController.m
//  SocialMedia
//
//  Created by PARMARTH MORI on 07/07/14.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import "CommntViewController.h"
#import "AsyncImageView.h"

@interface CommntViewController ()

@end

@implementation CommntViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
	// Do any additional setup after loading the view.
    tblView.tableFooterView = [[UIView alloc] init];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:YES];
    BOOL isPost = [[NSUserDefaults standardUserDefaults] boolForKey:@"Post"];
    if (isPost==YES) {
        [self.tabBarController setSelectedIndex:0];
    }
    if ([mutCommentArry count]!=0) {
        int lastRowNumber = [tblView numberOfRowsInSection:0]-1;
        NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
        [tblView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:NO];
        [tblView visibleCells];
    }
    else{
        mutCommentArry=[[NSMutableArray alloc]init];
    }

    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/get_comments.php"]];
    __unsafe_unretained ASIFormDataRequest *request = _request;
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setPostValue:self.strimageid forKey:@"image_id"];
    
    [request startAsynchronous];
    [request setCompletionBlock:^{
        NSMutableArray *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        NSLog(@"News Root %@",root);
        if(root != NULL)
        {
            mutCommentArry = [[NSMutableArray alloc] initWithArray:[[root reverseObjectEnumerator] allObjects]];
//            int lastRowNumber = [tblView numberOfRowsInSection:0]-1;
//            NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
//            [tblView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:NO];
//            [tblView visibleCells];
            [tblView reloadData];
        }
    }];

    [request setFailedBlock:^{
        NSError *error = [request error];
        [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                        type:AJNotificationTypeRed
                                       title:error.localizedDescription
                             linedBackground:AJLinedBackgroundTypeDisabled
                                   hideAfter:5.0];
    }];
}

-(void)CommentApicall:(NSString *)comment completionBlock:(void (^)(BOOL result)) return_block{
    
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/post_comment.php"]];
    _request.shouldAttemptPersistentConnection   = NO;
    __unsafe_unretained ASIFormDataRequest *request = _request;
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    
    [request setPostValue:[[NSUserDefaults standardUserDefaults]objectForKey:@"id"] forKey:@"user_id"];
    [request setPostValue:self.strimageid forKey:@"image_id"];
    [request setPostValue:comment forKey:@"comment"];
    [request startAsynchronous];
    [request setCompletionBlock:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSMutableArray *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        NSLog(@"Login Root %@",root);
        [mutCommentArry addObject:root];
        
        NSArray* reversedArray = [[mutCommentArry reverseObjectEnumerator] allObjects];
        mutCommentArry = [NSMutableArray arrayWithArray:reversedArray];
        
        NSArray* reversedArray2 = [[mutCommentArry reverseObjectEnumerator] allObjects];
        mutCommentArry = [NSMutableArray arrayWithArray:reversedArray2];
        
        NSLog(@"%@",mutCommentArry);
        return_block(TRUE);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [mutCommentArry count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    NotificationCustomCell *cell = (NotificationCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[NotificationCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSMutableDictionary *tempDic = (NSMutableDictionary *)[mutCommentArry objectAtIndex:indexPath.row];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@-profile.jpg",[tempDic valueForKey:@"user_id"]]]; //The image URL goes here.
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [cell.profileImageView setImageWithURLRequest:request
                                 placeholderImage:nil
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                              
                                              cell.profileImageView.image = image;
                                              [cell setNeedsLayout];
                                              
                                          } failure:nil];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@",[tempDic valueForKey:@"display_name"],[tempDic valueForKey:@"comment"]]];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14.0] range:NSMakeRange(0,[[tempDic valueForKey:@"display_name"] length])];
    cell.commentTextView.attributedText = attributedString;
    CGSize usernamesize = CGSizeMake(250,999);
    CGSize usernameRect =[attributedString.string boundingRectWithSize: usernamesize options:NSStringDrawingUsesLineFragmentOrigin attributes: @{NSFontAttributeName:[UIFont boldSystemFontOfSize:14.0]} context: nil].size;
    CGRect frame = cell.commentTextView.frame;
    if(frame.size.height < usernameRect.height){
        CGRect frame1 = cell.timeLabel.frame;
        frame1.origin.y = frame1.origin.y + usernameRect.height - frame.size.height;
        frame.size.height = usernameRect.height;
        cell.commentTextView.frame = frame;
        cell.timeLabel.frame = frame1;
    }
    
    MyTapGestureRecognizer *tap = [[MyTapGestureRecognizer alloc] initWithTarget:self action:@selector(commentTapped:)];
    tap.userid = [NSString stringWithFormat:@"%d",indexPath.row];
    [cell.commentTextView setTextColor:[UIColor whiteColor]];
    [cell.commentTextView addGestureRecognizer:tap];
    cell.timeLabel.text = [NSString stringWithFormat:@"%@ ago",[[mutCommentArry objectAtIndex:indexPath.row]objectForKey:@"comment_dt"] ];
    [cell.profileButton setTag:indexPath.row];
    [cell.profileButton addTarget:self action:@selector(handleTapFromactivityprofile:) forControlEvents:UIControlEventTouchUpInside];
    cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.size.width/2;
    cell.profileImageView.layer.masksToBounds = YES;
    
//    UITableViewCell *commentDataCell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
//    for (UIView *view in commentDataCell.contentView.subviews) {
//        // if (view.tag!=10 && view.tag!=1) {
//        [view removeFromSuperview];
//        //}
//    }
//    
//    NSString *aStrDisplyimage = [NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@-profile.jpg",[[mutCommentArry objectAtIndex:indexPath.row] objectForKey:@"user_id"]];
//    AsyncImageView *profileImage = [[AsyncImageView alloc] initWithFrame:CGRectMake(10, 10, 44, 44)];
//    profileImage.layer.cornerRadius = profileImage.frame.size.height/2;
//    profileImage.layer.masksToBounds = YES;
//    [profileImage setImageURL:[NSURL URLWithString:aStrDisplyimage]];
//    
//    [commentDataCell.contentView addSubview:profileImage];
//    UILabel *profileName = [[UILabel alloc] init];
//    profileName.lineBreakMode = NSLineBreakByWordWrapping;
//    profileName.numberOfLines = 0;
//    
//    NSString *stringName = [[mutCommentArry objectAtIndex:indexPath.row] objectForKey:@"display_name"];
//    int aUserCount = [stringName length];
//    NSString *stringComment = [[mutCommentArry objectAtIndex:indexPath.row] objectForKey:@"comment"];
//    int aActivity = [stringComment length];
//    
//    NSMutableString *aAllActivity = [NSMutableString stringWithFormat:@"%@ %@",stringName,stringComment];
//    NSMutableAttributedString *aAtributedStr = [[NSMutableAttributedString alloc]initWithString:aAllActivity];
//    [aAtributedStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:13.0] range:NSMakeRange(0, aUserCount)];
//    [aAtributedStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13.0] range:NSMakeRange(aUserCount+1, aActivity)];
//    [aAtributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]range:NSMakeRange(0, aUserCount)];
//    [aAtributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]range:NSMakeRange(aUserCount+1, aActivity)];
//    
//    [profileName setAttributedText:aAtributedStr];
//    
//    CGSize usernamesize = CGSizeMake(260,999);
//    CGSize usernameRect = [profileName.text boundingRectWithSize: usernamesize options: NSStringDrawingUsesLineFragmentOrigin
//                                                     attributes: @{NSFontAttributeName:profileName.font} context: nil].size ;
//    
//    [profileName setFrame:CGRectMake(60, 10, usernameRect.width+10, usernameRect.height+10)];
//    [commentDataCell.contentView addSubview:profileName];
//    
//    UILabel *aTime = [[UILabel alloc]initWithFrame:CGRectMake(60, 10+profileName.frame.size.height, 100, 23)];
//    aTime.text = [NSString stringWithFormat:@"%@ ago",[[mutCommentArry objectAtIndex:indexPath.row]objectForKey:@"comment_dt"] ];
//    [aTime setFont:[UIFont systemFontOfSize:13]];
//    [aTime setTextColor:[UIColor whiteColor]];
//    [commentDataCell.contentView addSubview:aTime];
    
    if (indexPath.row == [mutCommentArry count]-1) {
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width-15);
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//        UIStoryboard *storyboard = self.navigationController.storyboard;
//        ProfileViewController *fllowerPrfile = [storyboard instantiateViewControllerWithIdentifier:@"followerProfile"];
//        fllowerPrfile.userId=[[mutCommentArry objectAtIndex:indexPath.row] objectForKey:@"user_id"];
//        
//        //Push to detail View
//        [self.navigationController pushViewController:fllowerPrfile animated:YES];
    
    UIView* view = viewTextField;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionTransitionNone
                     animations:^
     {
         CGRect frame = view.frame;
         frame.origin.y = 465;
         view.frame = frame;
         
         CGRect tblViewFrame = tblView.frame;
         tblViewFrame.size.height = 390;
         tblView.frame = tblViewFrame;
     }
                     completion:^(BOOL finished)
     {
         NSLog(@"Completed");
         [txtfield resignFirstResponder];
         
     }];
    
}

- (void)commentTapped:(MyTapGestureRecognizer *)recognizer {
    
    UITextView *textView = (UITextView *)recognizer.view;
    
    // Location of the tap in text-container coordinates
    
    NSLayoutManager *layoutManager = textView.layoutManager;
    CGPoint location = [recognizer locationInView:textView];
    location.x -= textView.textContainerInset.left;
    location.y -= textView.textContainerInset.top;
    
    NSLog(@"location: %@", NSStringFromCGPoint(location));
    NSInteger tag = [[recognizer userid] integerValue];
    
    // Find the character that's been tapped on
    
    NSUInteger characterIndex;
    characterIndex = [layoutManager characterIndexForPoint:location
                                           inTextContainer:textView.textContainer
                  fractionOfDistanceBetweenInsertionPoints:NULL];
    
    if (characterIndex < textView.textStorage.length) {
        NSMutableDictionary *tempDic = (NSMutableDictionary *)[mutCommentArry objectAtIndex:tag];
        if (characterIndex<[[tempDic valueForKey:@"display_name"] length]) {
            [self handleProfileWithTag:tag];
        }
        else if (characterIndex>[[tempDic valueForKey:@"display_name"] length]+[[tempDic valueForKey:@"display_name"] length]+1) {
            
            UIView* view = viewTextField;
            [UIView animateWithDuration:0.5
                                  delay:0.0
                                options: UIViewAnimationOptionTransitionNone
                             animations:^
             {
                 CGRect frame = view.frame;
                 frame.origin.y = 465;
                 view.frame = frame;
                 
                 CGRect tblViewFrame = tblView.frame;
                 tblViewFrame.size.height = 390;
                 tblView.frame = tblViewFrame;
             }
                             completion:^(BOOL finished)
             {
                 NSLog(@"Completed");
                 [txtfield resignFirstResponder];
                 
             }];
        }
    }
}

-(void)handleTapFromactivityprofile:(UIButton *)sender {
    
    int tag = sender.tag;
    [self handleProfileWithTag:tag];
}

- (void)handleProfileWithTag:(NSInteger)tag {
    
    UIStoryboard *storyboard = self.navigationController.storyboard;
    ProfileViewController *fllowerPrfile = [storyboard instantiateViewControllerWithIdentifier:@"followerProfile"];
    fllowerPrfile.userId=[[mutCommentArry objectAtIndex:tag] objectForKey:@"user_id"];
    
    //Push to detail View
    [self.navigationController pushViewController:fllowerPrfile animated:YES];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
      UITableViewCell *commentDataCell = [tableView dequeueReusableCellWithIdentifier:@"commentedData"];
//    NSString *aStrDisplyimage=[NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@-profile.jpg",[[mutCommentArry objectAtIndex:indexPath.row] objectForKey:@"user_id"]];
//    AsyncImageView *profileImage = [[AsyncImageView alloc]initWithFrame:CGRectMake(10, 10, 44, 44)];
//    profileImage.layer.cornerRadius = profileImage.frame.size.height/2;
//    profileImage.layer.masksToBounds = YES;
//    [profileImage setImageURL:[NSURL URLWithString:aStrDisplyimage]];
//    
//    UILabel *profileName = [[UILabel alloc] init];
//    
//    profileName.lineBreakMode = NSLineBreakByWordWrapping;
//    profileName.numberOfLines = 0;
//    
//    NSString *stringName = [[mutCommentArry objectAtIndex:indexPath.row] objectForKey:@"display_name"];
//    int aUserCount=[stringName length];
//    NSString *stringComment = [[mutCommentArry objectAtIndex:indexPath.row]objectForKey:@"comment"];
//    int aActivity=[stringComment length];
//    
//    NSMutableString *aAllActivity=[NSMutableString stringWithFormat:@"%@ %@",stringName,stringComment];
//    NSMutableAttributedString *aAtributedStr=[[NSMutableAttributedString alloc]initWithString:aAllActivity];
//    [aAtributedStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:13.0] range:NSMakeRange(0, aUserCount)];
//    [aAtributedStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13.0] range:NSMakeRange(aUserCount+1, aActivity)];
//    [aAtributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:51.0/225.0f green:0/225.0f blue:102/225.0f alpha:1]range:NSMakeRange(0, aUserCount)];
//    [aAtributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:33/225.0f alpha:1 ]range:NSMakeRange(aUserCount+1, aActivity)];
//    
//    [profileName setAttributedText:aAtributedStr];
//    
//    CGSize usernamesize = CGSizeMake(260,999);
//    CGSize usernameRect =[profileName.text boundingRectWithSize: usernamesize options: NSStringDrawingUsesLineFragmentOrigin
//                                                     attributes: @{NSFontAttributeName:profileName.font} context: nil].size ;
//    
//    [profileName setFrame:CGRectMake(60, 10, usernameRect.width+10, usernameRect.height+10)];
//    [commentDataCell.contentView addSubview:profileName];
//
//    UILabel *aTime=[[UILabel alloc]initWithFrame:CGRectMake(60, 10+profileName.frame.size.height, 100, 23)];
//    aTime.text=[[mutCommentArry objectAtIndex:indexPath.row]objectForKey:@"comment_dt"];
//    
//    if (aTime.frame.origin.y+23>55 ){
//        return aTime.frame.origin.y+23;
//    }
//    else{
//        return 60;
//    }
    NSMutableDictionary *tempDic = (NSMutableDictionary *)[mutCommentArry objectAtIndex:indexPath.row];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@",[tempDic valueForKey:@"display_name"],[tempDic valueForKey:@"comment"]]];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14.0] range:NSMakeRange(0,[[tempDic valueForKey:@"display_name"] length])];
    CGSize usernamesize = CGSizeMake(250,999);
    CGSize usernameRect =[attributedString.string boundingRectWithSize: usernamesize options:NSStringDrawingUsesLineFragmentOrigin attributes: @{NSFontAttributeName:[UIFont boldSystemFontOfSize:14.0]} context: nil].size;
    if(52 < usernameRect.height){
        return 60 + usernameRect.height - 52;
    }
    return 60;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    UIView* view = viewTextField;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionTransitionNone
                     animations:^
     {
         CGRect frame = view.frame;
         frame.origin.y = 265;
         view.frame = frame;
         
         CGRect tblViewFrame = tblView.frame;
         tblViewFrame.size.height = 190;
         tblView.frame = tblViewFrame;
         
         int lastRowNumber = [tblView numberOfRowsInSection:0]-1;
         if (lastRowNumber>=0) {
             NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
             [tblView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:NO];
         }
         [tblView visibleCells];
         //[tblView reloadData];
         //[tblView scrollRectToVisible:CGRectMake(0, 0, [mutCommentArry count]-1, 1) animated:YES];
     }
                     completion:^(BOOL finished)
     {
         NSLog(@"Completed");
         
     }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    UIView* view = viewTextField;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionTransitionNone
                     animations:^
     {
         CGRect frame = view.frame;
         frame.origin.y = 465;
         view.frame = frame;
         
         CGRect tblViewFrame = tblView.frame;
         tblViewFrame.size.height = 390;
         tblView.frame = tblViewFrame;
     }
                     completion:^(BOOL finished)
     {
         NSLog(@"Completed");
         
     }];
}

- (IBAction)CommentSend:(id)sender {
     NSString *str=txtfield.text;
    
    [self CommentApicall:(NSString *)str completionBlock:^(BOOL result) {
        [tblView reloadData];
        int lastRowNumber = [tblView numberOfRowsInSection:0]-1;
        NSLog(@"lastRowNumber = %d",lastRowNumber);
        NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
        [tblView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }];
    txtfield.text = nil;
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)hideKeyboardOnReturnTap:(id)sender
{
    [sender resignFirstResponder];
}

@end
