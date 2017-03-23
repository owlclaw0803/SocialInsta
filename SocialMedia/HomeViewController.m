//
//  HomeViewController.m
//  SocialMedia
//
//  Created by PARMARTH MORI on 02/07/14.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import "HomeViewController.h"
#import "AsyncImageView.h"
#import "AppDelegate.h"
#import "TabbarControllerViewController.h"
#import "SVPullToRefresh.h"
#import "ExploreViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController
@synthesize mutTimeline,actionSheetCurrentUser,actionSheetOtherUser,actionSheetProfile, imagePickerConteroller;

BOOL bCommentExpand[10000];
int bBackViewExpand[10000];

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
    
    actionSheetCurrentUser = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Dismiss" destructiveButtonTitle:@"Report Inappropriate" otherButtonTitles:@"Tweet",@"instagram",@"Facebook", @"Delete Post", nil];
    actionSheetOtherUser = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Dismiss" destructiveButtonTitle:@"Report Inappropriate" otherButtonTitles:@"Tweet",@"instagram",@"Facebook", nil];
    actionSheetProfile = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Dismiss" destructiveButtonTitle:NULL otherButtonTitles:@"My Profile",@"Find People",@"Logout", nil];

    [self.view addSubview:actionSheetCurrentUser];
    [self.view addSubview:actionSheetOtherUser];
    heights = [[NSMutableArray alloc]init];
    
    landscapeView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 320, 548)];
    [landscapeView setBackgroundColor:[UIColor blackColor]];
    refreshcell = -1;
    [tblview addPullToRefreshWithActionHandler:^{
        [self gettingApiData];
        [tblview.pullToRefreshView stopAnimating];
    }];
    
    [self gettingApiData];
    isMoreHidden = YES;
    isComment = NO;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    BOOL isPost = [[NSUserDefaults standardUserDefaults] boolForKey:@"Post"];
    if (isComment==YES || isPost==YES) {
        [self gettingApiData];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"Post"];
        isComment = NO;
    }
    if(isPost == YES){
        NSIndexPath* ip = [NSIndexPath indexPathForRow:0 inSection:0];
        [tblview scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

- (void)gettingApiData {
    [hederview setHidden:NO];
    [UIView animateWithDuration:0.0 animations:^{
        [hederview setFrame:CGRectMake(0, 20, 320,50)];
    }completion:^(BOOL finished){
        [hederview setHidden:NO];
    }];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/get_timeline.php"]];
    __unsafe_unretained ASIFormDataRequest *request = _request;
    request.shouldAttemptPersistentConnection   = NO;
    [request setValidatesSecureCertificate:NO];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] forKey:@"user_id"];
    
    [request startAsynchronous];
    [request setCompletionBlock:^ {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSMutableArray *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        //NSLog(@"News Root %@",root);
        if(root!=NULL)
        {
            mutTimeline = Nil;
            mutTimeline=[[NSMutableArray alloc]init];
            for (int i=0; i<[root count]; i++) {
                [mutTimeline addObject:[root objectAtIndex:i]];
                bCommentExpand[i] = NO;
                bBackViewExpand[i] = 1;
            }
            
            NSArray* reversedArray = [[mutTimeline reverseObjectEnumerator] allObjects];
            
            
            //mutTimeline = [[NSMutableArray alloc] init];
            //[tblview reloadData];
            
            mutTimeline = [NSMutableArray arrayWithArray:reversedArray];
            [tblview reloadData];
        }
    }];
    
    [request setFailedBlock:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSError *error = [request error];
        [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                        type:AJNotificationTypeRed
                                       title:error.localizedDescription
                             linedBackground:AJLinedBackgroundTypeDisabled
                                   hideAfter:5.0];
    }];
}

#pragma mark-UITableview Datasource and Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [mutTimeline count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //tableView.sectionHeaderHeight=90;
    UIView *aViewSection=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320,60)];
    aViewSection.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"profilepicbackground.png"]];
    NSString *astr=[[mutTimeline objectAtIndex:section] objectForKey:@"user_id"];
    NSString *aStrDisplyimage=[NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/thumb/%@-profile.jpg", astr];
    NSURL *aimageurl = [NSURL URLWithString:aStrDisplyimage];
    
    UIImageView *aImageViewInSectionView=[[UIImageView alloc]initWithFrame:CGRectMake(10,10, 35 , 35)];
    aImageViewInSectionView.layer.cornerRadius = aImageViewInSectionView.frame.size.width/2;
    aImageViewInSectionView.layer.masksToBounds = YES;
    [aImageViewInSectionView setImageWithURL:aimageurl placeholderImage:NULL];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(53.0, 16, 200, 20)];
    [headerLabel setBackgroundColor:[UIColor clearColor]];
    headerLabel.font = [UIFont boldSystemFontOfSize:13];
    headerLabel.textColor=[UIColor blackColor];
    headerLabel.text=[[mutTimeline objectAtIndex:section] objectForKey:@"display_name"];
    
    UIButton *btn=[[UIButton alloc]initWithFrame:CGRectMake(0.0, 10, 80, 60)];
    [btn setBackgroundColor:[UIColor clearColor]];
    [btn addTarget:self action:@selector(pushImageDescription:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTag:section+1];
    [aViewSection addSubview:btn];
    
    UIImageView *aImageViewClock=[[UIImageView alloc]initWithFrame:CGRectMake(273,18, 15 , 15)];
    aImageViewClock.image=[UIImage imageNamed:@"clockicon"];
    UILabel *clockLabel = [[UILabel alloc] initWithFrame:CGRectMake(290, 18, 30, 15)];
    [clockLabel setBackgroundColor:[UIColor clearColor]];
    clockLabel.font = [UIFont systemFontOfSize:11];
    clockLabel.textColor=[UIColor whiteColor];
    clockLabel.text=[[mutTimeline objectAtIndex:section] objectForKey:@"upload_dt"];
    
    UIImageView *aImageViewPhoto;
    if ([[[mutTimeline objectAtIndex:section] objectForKey:@"post_type"]isEqualToString:@"p"]) {
        aImageViewPhoto=[[UIImageView alloc]initWithFrame:CGRectMake(234,19, 29 , 13)];
        aImageViewPhoto.image=[UIImage imageNamed:@"PanoramicIcon"];
    }
    else if ([[[mutTimeline objectAtIndex:section]objectForKey:@"post_type"]isEqualToString:@"v"]) {
        aImageViewPhoto=[[UIImageView alloc]initWithFrame:CGRectMake(242,19, 21 , 13)];
        aImageViewPhoto.image=[UIImage imageNamed:@"VideoIcon"];
    }
    else {
        aImageViewPhoto=[[UIImageView alloc]initWithFrame:CGRectMake(249,19, 14 , 13)];
        aImageViewPhoto.image=[UIImage imageNamed:@"PhotoIcon"];
    }
    
    [aViewSection addSubview:aImageViewClock];
    [aViewSection addSubview:aImageViewPhoto];
    [aViewSection addSubview:headerLabel];
    [aViewSection addSubview:aImageViewInSectionView];
    [aViewSection addSubview:clockLabel];
    
    return aViewSection;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItemCell"];
    if(cell)
    //if(cell.contentView.subviews.count > 2 && refreshcell != indexPath.row){
    //    if(indexPath.row == [mutTimeline count]-1){
    //        refreshcell = -1;
    //    }
    //    return cell;
    //}
    //if(indexPath.row == [mutTimeline count]-1 || refreshcell == indexPath.row){
    //    refreshcell = -1;
    //}
    for (UIView *view in cell.contentView.subviews) {
       // if (view.tag!=10 && view.tag!=1) {
            [view removeFromSuperview];
        //}
    }
    UIView *aViewSection=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320,50)];
    [aViewSection setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
    NSString *astr=[[mutTimeline objectAtIndex:indexPath.section] objectForKey:@"user_id"];
    NSString *aStrDisplyimage=[NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/thumb/%@-profile.jpg", astr];
    NSURL *aimageurl=[NSURL URLWithString:aStrDisplyimage];
    
    AsyncImageView *aImageViewInSectionView=[[AsyncImageView alloc]initWithFrame:CGRectMake(10,10, 35 , 35)];
    aImageViewInSectionView.layer.cornerRadius = aImageViewInSectionView.frame.size.width/2;
    aImageViewInSectionView.layer.masksToBounds = YES;
    [aImageViewInSectionView setImageURL:aimageurl];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(53.0, 16, 200, 20)];
    [headerLabel setBackgroundColor:[UIColor clearColor]];
    headerLabel.font = [UIFont boldSystemFontOfSize:13];
    headerLabel.textColor=[UIColor whiteColor];
    headerLabel.text=[[mutTimeline objectAtIndex:indexPath.section] objectForKey:@"display_name"];
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    [btn setBackgroundColor:[UIColor clearColor]];
    [btn addTarget:self action:@selector(pushImageDescription:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTag:indexPath.section+1];
    [aViewSection addSubview:btn];
    
    UIImageView *aImageViewClock=[[UIImageView alloc]initWithFrame:CGRectMake(273,18, 15 , 15)];
    aImageViewClock.image=[UIImage imageNamed:@"clockicon"];
    UILabel *clockLabel = [[UILabel alloc] initWithFrame:CGRectMake(290, 18, 30, 15)];
    [clockLabel setBackgroundColor:[UIColor clearColor]];
    clockLabel.font = [UIFont systemFontOfSize:11];
    clockLabel.textColor=[UIColor whiteColor];
    clockLabel.text=[[mutTimeline objectAtIndex:indexPath.section] objectForKey:@"upload_dt"];
    
    UIImageView *aImageViewPhoto;
    if ([[[mutTimeline objectAtIndex:indexPath.section] objectForKey:@"post_type"]isEqualToString:@"p"]) {
        aImageViewPhoto=[[UIImageView alloc]initWithFrame:CGRectMake(234,19, 29 , 13)];
        aImageViewPhoto.image=[UIImage imageNamed:@"PanoramicIcon"];
    }
    else if ([[[mutTimeline objectAtIndex:indexPath.section]objectForKey:@"post_type"]isEqualToString:@"v"]) {
        aImageViewPhoto=[[UIImageView alloc]initWithFrame:CGRectMake(242,19, 21 , 13)];
        aImageViewPhoto.image=[UIImage imageNamed:@"VideoIcon"];
    }
    else {
        aImageViewPhoto=[[UIImageView alloc]initWithFrame:CGRectMake(249,19, 14 , 13)];
        aImageViewPhoto.image=[UIImage imageNamed:@"PhotoIcon"];
    }
    
    [aViewSection addSubview:aImageViewClock];
    [aViewSection addSubview:aImageViewPhoto];
    [aViewSection addSubview:headerLabel];
    [aViewSection addSubview:aImageViewInSectionView];
    [aViewSection addSubview:clockLabel];
    
    float totalSize = 0.0;
    AsyncImageView *imageIcon = [[AsyncImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 450)];
    [imageIcon setBackgroundColor:[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0]];
    imageIcon.layer.cornerRadius = 0;
    imageIcon.layer.masksToBounds = YES;
    [cell.contentView addSubview:imageIcon];
    [imageIcon setTag:10];
    
    NSString *astrUserid = [[mutTimeline objectAtIndex:indexPath.section] objectForKey:@"user_id"];
    NSString *astrImageid = [[mutTimeline objectAtIndex:indexPath.section] objectForKey:@"image_id"];
    aStrDisplyimage = [NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@-%@.jpg",astrUserid, astrImageid];
    aimageurl=[NSURL URLWithString:aStrDisplyimage];

    if ([[[mutTimeline objectAtIndex:indexPath.section] objectForKey:@"post_type"]isEqualToString:@"p"]) {
        
        AsyncImageView *pano=[[AsyncImageView alloc]init];
        [pano setBackgroundColor:[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0]];//[UIColor clearColor]];
        pano.FeedType = 1;
        pano.bNormalShow = YES;
        
        UIScrollView *scroll=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0,320,450)];
        
        // Khalid Code Start
        
        UITapGestureRecognizer *panoGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(panoGestureClicked:)];
        panoGesture.numberOfTapsRequired=1;
        [scroll addGestureRecognizer:panoGesture];
        // Khalid Code End
        
        [pano setFrame:CGRectMake(0, 0, 0, scroll.frame.size.height)];
        [cell.contentView addSubview:scroll];
        [scroll setBounces:NO];
        [scroll setTag:indexPath.section];
        [scroll addSubview:pano];
        [scroll setBackgroundColor:[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0]];
        pano.tempscroll = scroll;
        [pano setImageURL:aimageurl];
        totalSize = totalSize+scroll.frame.size.height+3;
        [imageIcon setHidden:YES];
    }
    else if ([[[mutTimeline objectAtIndex:indexPath.section]objectForKey:@"post_type"]isEqualToString:@"v"])
    {
        imageIcon=Nil;
        
        [[cell viewWithTag:8]removeFromSuperview];
        
        AsyncImageView *aImage=[[AsyncImageView alloc]initWithFrame:CGRectMake(0 ,0,320,450)];
        [aImage setBackgroundColor:[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0]];
        aImage.FeedType = 2;
        aImage.bNormalShow = YES;
        [cell.contentView addSubview:aImage];
        [aImage setImageURL:aimageurl];
        
        UIImageView *videoImage=[[UIImageView alloc]initWithFrame:CGRectMake(110 , 80,100, 100)];
        videoImage.image=[UIImage imageNamed:@"video"];
        [cell.contentView addSubview:videoImage];
        totalSize=totalSize+aImage.frame.size.height+3;
    }
    else{
        imageIcon.FeedType = 3;
        imageIcon.bNormalShow = YES;
        [imageIcon setImageURL:aimageurl];
        totalSize=totalSize+imageIcon.frame.size.height+3;
        [imageIcon setHidden:NO];
    }

    totalSize -= 97;
    
    if(bBackViewExpand[indexPath.section] != 2){
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
    [backView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
    [cell.contentView addSubview:backView];
    
    int backViewheight = 5;
        
    UILabel *likes = [[UILabel alloc]init];
    [likes setTag:8];
    [backView addSubview:likes];
    [likes setTextColor:[UIColor whiteColor]];
    [likes setFont:[UIFont boldSystemFontOfSize:13.0]];
        
    NSMutableArray *likearry=[[NSMutableArray alloc]init];
    for (int i=0; i<[[[mutTimeline objectAtIndex:indexPath.section] objectForKey:@"likes"] count]; i++) {
        [likearry addObject:[[[mutTimeline objectAtIndex:indexPath.section] objectForKey:@"likes"] objectAtIndex:i]];
    }
        
    likearry = [[mutTimeline objectAtIndex:indexPath.section] objectForKey:@"likes"];
    
    NSLog(@"main likearry = %@",likearry);
//        
    [likearry lastObject];
    NSMutableString* mutString = [[NSMutableString alloc] init];
    NSMutableString* mutidString = [[NSMutableString alloc] init];
    int  k=0;
    for (int i = 1; i <= [likearry count]; i++)
    {
        if (i == [likearry count]) {
            NSLog(@"1234 if");
            [mutString appendString:[NSString stringWithFormat:@"%@",[[likearry objectAtIndex:k] objectForKey:@"display_name"]]];
            [mutidString appendString:[NSString stringWithFormat:@"%@",[[likearry objectAtIndex:k] objectForKey:@"user_id"]]];
        }
        else
        {
            NSLog(@"1234 else");
            [mutString appendString:[NSString stringWithFormat:@"%@, ",[[likearry objectAtIndex:k] objectForKey:@"display_name"]]];
            [mutidString appendString:[NSString stringWithFormat:@"%@, ",[[likearry objectAtIndex:k] objectForKey:@"user_id"]]];
        }
        k++;
    }
        NSLog(@"mutString = %@ , mutidString = %d",mutString,[mutidString intValue]);
        
        likes.text = mutString;
        CGSize Likesize = CGSizeMake(290,999);
        CGSize textRect =[likes.text boundingRectWithSize: Likesize options: NSStringDrawingUsesLineFragmentOrigin
                                               attributes: @{NSFontAttributeName:likes.font} context: nil].size ;
        
        [likes setFrame:CGRectMake(28,backViewheight,textRect.width, textRect.height)];
        likes.numberOfLines=0;
        likes.lineBreakMode = NSLineBreakByWordWrapping;
        
        UIButton *btnlikeStatic = [[UIButton alloc]init];
        [btnlikeStatic setFrame:CGRectMake(9 ,backViewheight, 13, 13)];
        [btnlikeStatic setImage:[UIImage imageNamed:@"likeicon.png"] forState:UIControlStateNormal];
        [btnlikeStatic setTag:5];
        
        [backView addSubview:btnlikeStatic];
        backViewheight = backViewheight+likes.frame.size.height;
        
        UIButton *btn1 = [[UIButton alloc] init];
        CGSize usernameRect12 = CGSizeMake(likes.frame.size.width, likes.frame.size.height) ;
        [btn1 setFrame:CGRectMake(likes.frame.origin.x, likes.frame.origin.y, usernameRect12.width, usernameRect12.height+10)];
        [btn1 setBackgroundColor:[UIColor clearColor]];
        MyTapGestureRecognizer *tapGestureRecognizer2 = [[MyTapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoProfilePage:)];
        tapGestureRecognizer2.userid = [[NSString alloc] initWithFormat:@"%d",[mutidString intValue]];
        [btn1 addGestureRecognizer:tapGestureRecognizer2];
        [backView addSubview:btn1];
        [backView addSubview:btnlikeStatic];

        [[cell viewWithTag:555] removeFromSuperview];
        
        UILabel *profilename = [[UILabel alloc]init];
        [profilename setTextColor:[UIColor whiteColor]];
        profilename.numberOfLines = 0;
        profilename.lineBreakMode = NSLineBreakByWordWrapping;
        profilename.userInteractionEnabled = YES;
        
        NSString *stringprofileName = [[mutTimeline objectAtIndex:indexPath.section] objectForKey:@"display_name"];
        int aprofileNametCount = [stringprofileName length];
        NSString *stringCaption = [[mutTimeline objectAtIndex:indexPath.section] objectForKey:@"caption"];
        int aCaptionCount = [stringCaption length];
        
        NSMutableString *aAllActivity = [NSMutableString stringWithFormat:@"%@ %@",stringprofileName,stringCaption];
        NSMutableAttributedString *aAtributedCaptionStr = [[NSMutableAttributedString alloc]initWithString:aAllActivity];
        [aAtributedCaptionStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:13.0] range:NSMakeRange(0, aprofileNametCount)];
        [aAtributedCaptionStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13.0] range:NSMakeRange(aprofileNametCount+1, aCaptionCount)];
        NSMutableArray *hashtags = [self getHashUsernameRange:aAllActivity];
        for(int l = 0 ; l < [hashtags count] ; l++){
            NSRange range = NSRangeFromString([hashtags objectAtIndex:l]);
            [aAtributedCaptionStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:39.0f/256.0f green:199.0f/256.0f blue:246.0f/256.0f alpha:1.0f] range:range];
        }
        [profilename setAttributedText:aAtributedCaptionStr];
        [profilename setTag:555];
        
        CGSize profilsize = CGSizeMake(290,999);
        CGSize profiletextRect = [profilename.text boundingRectWithSize: profilsize options: NSStringDrawingUsesLineFragmentOrigin
                                                             attributes: @{NSFontAttributeName:profilename.font} context: nil].size;
        [profilename setFrame:CGRectMake(28,backViewheight, profiletextRect.width+10, profiletextRect.height+11)];
        [backView addSubview:profilename];
        
        profilename.userInteractionEnabled = YES;
        MyTapGestureRecognizer *tapGesture = [[MyTapGestureRecognizer alloc] initWithTarget:self action:@selector(CommentLabelClicked:)];
        tapGesture.eventLabel = profilename;
        [profilename addGestureRecognizer:tapGesture];
        
        UIButton *btn = [[UIButton alloc] init];
        CGSize usernameRect1 =[stringprofileName boundingRectWithSize: profilsize options: NSStringDrawingUsesLineFragmentOrigin
                                                           attributes: @{NSFontAttributeName:profilename.font} context: nil].size ;
        [btn setFrame:CGRectMake(profilename.frame.origin.x, backViewheight, usernameRect1.width, usernameRect1.height+10)];
        [btn setBackgroundColor:[UIColor clearColor]];
        MyTapGestureRecognizer *tapGestureRecognizer1 = [[MyTapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoProfilePage:)];
        tapGestureRecognizer1.userid = [[mutTimeline objectAtIndex:indexPath.section] objectForKey:@"user_id"];
        [btn addGestureRecognizer:tapGestureRecognizer1];
        [backView addSubview:btn];
        
        backViewheight = backViewheight+profiletextRect.height+3;
        
        UIButton *btnCommentStatic=[[UIButton alloc]init];
        [btnCommentStatic setFrame:CGRectMake(9 ,profilename.frame.origin.y+8, 13, 13)];
        [btnCommentStatic setImage:[UIImage imageNamed:@"commenticon.png"] forState:UIControlStateNormal];
        [btnCommentStatic setTag:2];
        [btnCommentStatic setTitle:[NSString stringWithFormat:@"%d", indexPath.section] forState:UIControlStateNormal];
        [btnCommentStatic setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        
        [backView addSubview:btnCommentStatic];
        UIScrollView *scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
        int scrollheight = 0;
        backViewheight += 0;
        NSMutableArray *mutComment;//=[[NSMutableArray alloc]init];
        //NSArray* reversedArray = [[[[mutTimeline objectAtIndex:indexPath.section] objectForKey:@"comments"] reverseObjectEnumerator] allObjects];
        //mutComment = [NSMutableArray arrayWithArray:reversedArray];
        mutComment=[[mutTimeline objectAtIndex:indexPath.section] objectForKey:@"comments"];
        
        if([mutComment count] == 0) {
            for (int i = 0 ; i <= 20 ; i++) {
                [[cell viewWithTag:100+i] removeFromSuperview];
                [[cell viewWithTag:200+i] removeFromSuperview];
            }
        }
        int totalcount = [mutComment count];
        for (int i=1; i<=totalcount; i++)
        {
            [[cell viewWithTag:100+i] removeFromSuperview];
            [[cell viewWithTag:200+i] removeFromSuperview];
        }
        
        
        //if(bBackViewExpand[indexPath.section] == 3 && totalcount <= 5){
        //    bBackViewExpand[indexPath.section] = 1;
        //}
        NSLog(@"IndexPath.Section is %d,",bBackViewExpand[indexPath.section]);
        int j;
        j = totalcount-1;
        if(totalcount > 3 && bBackViewExpand[indexPath.section] == 1) {
            j = 3-1;
            totalcount = 3;
        }
        for (int i=1; i<=totalcount; i++) {
            UILabel *aUserNamecomment=[[UILabel alloc]init];
            aUserNamecomment.lineBreakMode = NSLineBreakByWordWrapping;
            aUserNamecomment.numberOfLines = 0;
            aUserNamecomment.textColor=[UIColor whiteColor];
            aUserNamecomment.userInteractionEnabled = YES;
            NSString *stringName = [[mutComment objectAtIndex:j] objectForKey:@"display_name"];
            int aUserCount=[stringName length];
            NSString *stringComment = [[mutComment objectAtIndex:j] objectForKey:@"comment"];
            int aActivity=[stringComment length];
            
            NSMutableString *aAllActivity;
            NSMutableAttributedString *aAtributedStr;
            
            aAllActivity=[NSMutableString stringWithFormat:@"%@ %@",stringName,stringComment];
            if(aAllActivity.length > 88){
                aAllActivity=[NSMutableString stringWithFormat:@"%@ ...",[aAllActivity substringToIndex:84]];
                aActivity = aAllActivity.length-aUserCount-1;
            }
            aAtributedStr=[[NSMutableAttributedString alloc]initWithString:aAllActivity];
            NSMutableParagraphStyle *paragrahstyle=[[NSMutableParagraphStyle alloc] init];
            //[paragrahstyle setLineSpacing:0.5f];
            [aAtributedStr addAttribute:NSParagraphStyleAttributeName value:paragrahstyle range:NSMakeRange(0, aAllActivity.length)];
            [aAtributedStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:13.0] range:NSMakeRange(0, aUserCount)];
            [aAtributedStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13.0] range:NSMakeRange(aUserCount+1, aActivity)];
            hashtags = [self getHashUsernameRange:aAllActivity];
            for(int l = 0 ; l < [hashtags count] ; l++){
                NSRange range = NSRangeFromString([hashtags objectAtIndex:l]);
                [aAtributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:39.0f/256.0f green:199.0f/256.0f blue:246.0f/256.0f alpha:1.0f] range:range];
            }
            if ((bBackViewExpand[indexPath.section] != 4 && i==3) && [mutComment count]>3) {
                [aAtributedStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n....."]];
            }
            
            [aUserNamecomment setAttributedText:aAtributedStr];
            //float twolineheight = aUserNamecomment.font.lineHeight*2.2;
            CGSize usernamesize = CGSizeMake(250,999);
            CGSize usernameRect =[aUserNamecomment.text boundingRectWithSize: usernamesize options:NSStringDrawingUsesLineFragmentOrigin attributes: @{NSFontAttributeName:aUserNamecomment.font} context: nil].size;
            [aUserNamecomment setFrame :CGRectMake(28, scrollheight,usernameRect.width+10 , usernameRect.height+10)];
            [aUserNamecomment setTag:100+i];
            [scrollview addSubview:aUserNamecomment];
            
            aUserNamecomment.userInteractionEnabled = YES;
            MyTapGestureRecognizer *tapGesture = [[MyTapGestureRecognizer alloc] initWithTarget:self action:@selector(CommentLabelClicked:)];
            tapGesture.eventLabel = aUserNamecomment;
            [aUserNamecomment addGestureRecognizer:tapGesture];
            
            scrollheight = scrollheight+usernameRect.height+1;
            
            //if (i<totalcount) {
            UIButton *btn1 = [[UIButton alloc] init];
            CGSize usernameRect1 =[stringName boundingRectWithSize: profilsize options: NSStringDrawingUsesLineFragmentOrigin
                                                            attributes: @{NSFontAttributeName:aUserNamecomment.font} context: nil].size ;
            [btn1 setFrame:CGRectMake(aUserNamecomment.frame.origin.x, aUserNamecomment.frame.origin.y, usernameRect1.width, usernameRect1.height+10)];
            [btn1 setBackgroundColor:[UIColor clearColor]];
            MyTapGestureRecognizer *tapGestureRecognizer2 = [[MyTapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoProfilePage:)];
            tapGestureRecognizer2.userid = [[mutComment objectAtIndex:j]objectForKey:@"user_id"];
            [btn1 addGestureRecognizer:tapGestureRecognizer2];
            [scrollview addSubview:btn1];
           // }
            j--;
        }
        [backView addSubview:scrollview];
        if(scrollheight > 0){
            scrollheight += 7;
            int offset = 0;
            if(backViewheight+scrollheight > 328){
                offset = backViewheight+scrollheight-328;
            }
            scrollview.frame = CGRectMake(0, backViewheight, 280, scrollheight-offset);
            scrollview.contentSize = CGSizeMake(0, scrollheight);
            backViewheight += scrollheight-offset;
            backViewheight -= 8;
        }else{
            backViewheight -= 5;
        }
        
        NSLog(@"totalSize = %f",totalSize);
    
        [[cell viewWithTag:19] removeFromSuperview];
        [[cell viewWithTag:600] removeFromSuperview];
        [[cell viewWithTag:300] removeFromSuperview];
    
        UIButton *btnlike=[[UIButton alloc]initWithFrame:CGRectMake(10, backViewheight+15, 55, 25)];
        [backView addSubview:btnlike];
        [btnlike setTag:19];
        if ([btnlike isSelected]) {
            [btnlike setBackgroundImage:[UIImage imageNamed:@"likeinwhite.png"] forState:UIControlStateNormal];
            [btnlike setSelected:NO];
        }else{
            [btnlike setBackgroundImage:[UIImage imageNamed:@"like.png"] forState:UIControlStateNormal];
            [btnlike setSelected:YES];
        }

        if ([[[[mutTimeline objectAtIndex:indexPath.section] objectForKey:@"user_liked"] description]isEqualToString:@"1"]) {
            [btnlike setBackgroundImage:[UIImage imageNamed:@"likeinwhite"] forState:UIControlStateSelected];
            [btnlike setSelected:YES];
        }
        [btnlike addTarget:self action:@selector(likebtn:) forControlEvents:UIControlEventTouchUpInside];
    
        UIButton *buzzButton = [[UIButton alloc]initWithFrame:CGRectMake(70, btnlike.frame.origin.y, 87, 25)];
        [buzzButton setTag:300];
        [buzzButton setImage:[UIImage imageNamed:@"comment" ] forState:UIControlStateNormal];
        [buzzButton addTarget:self action:@selector(buzzAction:) forControlEvents:UIControlEventTouchUpInside];
        [backView addSubview:buzzButton];
    
        UIButton *btnShare=[[UIButton alloc]initWithFrame:CGRectMake(240, btnlike.frame.origin.y, 55, 20)];
        [btnShare setTag:600];
        [btnShare setImage:[UIImage imageNamed:@"threedot"] forState:UIControlStateNormal];
        [btnShare addTarget:self action:@selector(shareImage:) forControlEvents:UIControlEventTouchUpInside];
        backViewheight=backViewheight+btnlike.frame.size.height;
        [backView addSubview:btnShare];
    
        [cell.contentView addSubview:aViewSection];
    
        UIButton *btnBackViewExpand = [[UIButton alloc]init];
        if([mutComment count] > 3 && bBackViewExpand[indexPath.section] == 1){
            [btnBackViewExpand setImage:[UIImage imageNamed:@"UpArrow"] forState:UIControlStateNormal];
        }
        else {
            [btnBackViewExpand setImage:[UIImage imageNamed:@"DownArrow"] forState:UIControlStateNormal];
            bBackViewExpand[indexPath.section] = 3;
        }
        [btnBackViewExpand setTitle:[NSString stringWithFormat:@"%d", indexPath.section] forState:UIControlStateNormal];
        [btnBackViewExpand setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [btnBackViewExpand addTarget:self action:@selector(BackViewExpand:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.contentView addSubview:btnBackViewExpand];
        
        backViewheight = backViewheight+25;
        if(backViewheight > 378)
            backViewheight = 378;
        backView.frame = CGRectMake(0, 450-backViewheight, 320,  backViewheight);
        aViewSection.frame = CGRectMake(0,450-backViewheight-50,320,50);
        btnBackViewExpand.frame = CGRectMake(0,450-backViewheight-50-22,320,22);
    }
    else
    {
        UIButton *btnBackViewExpand = [[UIButton alloc]init];
        [btnBackViewExpand setImage:[UIImage imageNamed:@"UpArrow.png"] forState:UIControlStateNormal];
        [btnBackViewExpand setTitle:[NSString stringWithFormat:@"%d", indexPath.section] forState:UIControlStateNormal];
        [btnBackViewExpand setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [btnBackViewExpand addTarget:self action:@selector(BackViewExpand:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btnBackViewExpand];
        btnBackViewExpand.frame = CGRectMake(0,428,320,22);
    }
    return cell;
}

- (IBAction)CommentExpand:(id)sender
{
    [self HidePhotoView];
    UIButton *btn = (UIButton*)sender;
    int index = [btn.titleLabel.text intValue];
    bCommentExpand[index] = !bCommentExpand[index];
    [tblview reloadData];
}

- (IBAction)BackViewExpand:(id)sender
{
    [self HidePhotoView];
    UIButton *btn = (UIButton*)sender;
    int index = [btn.titleLabel.text intValue];
    bBackViewExpand[index]--;
    if(bBackViewExpand[index] == 0)
        bBackViewExpand[index] = 4;
    [tblview reloadData];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==[mutTimeline count]-1) {
        [self LoadMore:[[mutTimeline objectAtIndex:indexPath.section] objectForKey:@"image_id"] completionBlock:^(BOOL result) {
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *tvCell = (UITableViewCell *)[tblview cellForRowAtIndexPath:indexPath];
    
    if ([[[mutTimeline objectAtIndex:indexPath.section]objectForKey:@"post_type"]isEqualToString:@"v"]) {
        NSString *astrUserid = [[mutTimeline objectAtIndex:indexPath.section] objectForKey:@"user_id"];
        NSString *astrImageid = [[mutTimeline objectAtIndex:indexPath.section] objectForKey:@"image_id"];
        NSString *astrExt = [[mutTimeline objectAtIndex:indexPath.section] objectForKey:@"ext"];
        NSString *aStrDisplyimage = [NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/vids/user/%@-%@.%@",astrUserid, astrImageid ,astrExt];
        NSURL *avideourl = [NSURL URLWithString:aStrDisplyimage];
        self.player = [[MPMoviePlayerController alloc] init];
        self.player.controlStyle = MPMovieControlStyleNone;
        [self.player setScalingMode:MPMovieScalingModeAspectFill];
        [self.player.view setFrame:CGRectMake(0, 0,320, 450)];
        self.player.movieSourceType = MPMovieSourceTypeStreaming;
        [self.player setContentURL:avideourl];
        [self.player.view setHidden:NO];
        [self.player prepareToPlay];
        [tvCell.contentView addSubview:self.player.view];
        [self.player play];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayerPlayState:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:self.player];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playbackEnded:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.player];
    }
    
    [self HidePhotoView];
}

- (void)playbackEnded:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:@"MPMoviePlayerPlaybackDidFinishNotification"
     object:nil];
    
    [self.player stop];
    //self.player=Nil;
    [self.player.view removeFromSuperview];
}

- (void)moviePlayerPlayState:(NSNotification *)noti {
    
    if (noti.object == self.player) {
        
        MPMoviePlaybackState reason = self.player.playbackState;
        
        if (reason == MPMoviePlaybackStatePlaying) {
            
            [[NSNotificationCenter defaultCenter] removeObserver:self name: MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                
                while (self.player.view.hidden)
                {
                    NSLog(@"not ready");
                    if (self.player.readyForDisplay) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            NSLog(@"show");
                            self.player.view.hidden=NO;
                        });
                    }
                    usleep(50);
                }
            });
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 450;//cellheight;
}

- (IBAction)pushImageDescription:(id)sender {
    [self HidePhotoView];
    //    CGPoint hitPoint = [sender convertPoint:CGPointZero toView:tableViewObj];
    //    NSIndexPath *hitIndex = [tableViewObj indexPathForRowAtPoint:hitPoint];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[sender tag] inSection:[[sender superview] tag]];
    NSLog(@"%ld",(long)indexPath.row);
    NSString *str=[[mutTimeline objectAtIndex:indexPath.row-1] objectForKey:@"user_id"];

    UIStoryboard *storyboard = self.navigationController.storyboard;
    
    ProfileViewController *fllowerPrfile = [storyboard instantiateViewControllerWithIdentifier:@"followerProfile"];
    
    fllowerPrfile.userId=str;
    
    //Push to detail View
    [self.navigationController pushViewController:fllowerPrfile animated:YES];
    [hederview setHidden:NO];
    [self showTabBar:self.tabBarController];
    [self HidePhotoView];
    hidden = NO;
}

-(IBAction)buzzAction:(id)sender{
    [self HidePhotoView];
    CGPoint hitPoint = [sender convertPoint:CGPointZero toView:tblview];
    NSIndexPath *hitIndex = [tblview indexPathForRowAtPoint:hitPoint];
    NSLog(@"%ld",(long)hitIndex.section);
    isComment = YES;
    refreshcell = hitIndex;
    //UIStoryboard *storyboard = self.navigationController.storyboard;
    CommntViewController *buzz = [self.storyboard instantiateViewControllerWithIdentifier:@"comment"];
    //uzz.mutCommentArray=[[mutTimeline objectAtIndex:hitIndex.section] objectForKey:@"comments"];
    //NSLog(@"%@",[[mutTimeline objectAtIndex:hitIndex.section] objectForKey:@"comments"]);
    buzz.strimageid = [[mutTimeline objectAtIndex:hitIndex.section]objectForKey:@"image_id"];
    buzz.strUserid = [[mutTimeline objectAtIndex:hitIndex.section]objectForKey:@"user_id"];
    
    [self.navigationController pushViewController:buzz animated:YES];
    [hederview setHidden:NO];
    [self showTabBar:self.tabBarController];
    hidden = NO;
}

- (void)panoGestureClicked:(UIGestureRecognizer*)sender {
    
    [self hideTabBar:self.tabBarController];
    
    UIScrollView *scroll = (UIScrollView *)[sender view];
    int sectionId = [scroll tag];
    
    NSString *astrUserid = [[mutTimeline objectAtIndex:sectionId] objectForKey:@"user_id"];
    NSString *astrImageid = [[mutTimeline objectAtIndex:sectionId] objectForKey:@"image_id"];
    NSString *aStrDisplyimage = [NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@-%@.jpg",astrUserid, astrImageid];
    NSURL *aimageurl=[NSURL URLWithString:aStrDisplyimage];
    
    __block UIImageView *pano=[[UIImageView alloc]init];
    [pano setBackgroundColor:[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0]];
    UIScrollView *landscapeScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0,320,548)];
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] init];
    activityView.center = CGPointMake(self.view.bounds.size.width / 2.0f, self.view.bounds.size.height / 2.0f);
    [activityView startAnimating];
    [pano addSubview:activityView];
    
    NSURLRequest *contentRequest = [NSURLRequest requestWithURL:aimageurl];
    [pano setImageWithURLRequest:contentRequest
                placeholderImage:nil
     
                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                             pano.transform = CGAffineTransformMakeRotation(M_PI_2);
                             [landscapeScroll setContentSize:CGSizeMake(320, image.size.width*320/image.size.height)];
                             [pano setFrame:CGRectMake(0, 0, 320,image.size.width*320/image.size.height)];
                             pano.image = image;
                             [activityView stopAnimating];
                             [activityView hidesWhenStopped];
                         } failure:nil];
    
    [landscapeScroll addSubview:pano];
    
    UITapGestureRecognizer *panoDismissGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(panoDismissGestureClicked:)];
    panoDismissGesture.numberOfTapsRequired=1;
    [landscapeScroll addGestureRecognizer:panoDismissGesture];
    
    [landscapeView addSubview:landscapeScroll];
    [landscapeScroll setBounces:NO];
    [landscapeScroll setScrollEnabled:YES];
    [landscapeScroll setBackgroundColor:[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0]];
    [self.view addSubview:landscapeView];
    NSLog(@"Pano Clicked");
}

- (void)panoDismissGestureClicked:(UIGestureRecognizer*)sender {
    [landscapeView removeFromSuperview];
    [self showTabBar:self.tabBarController];
}

#pragma mark: ShareimageAction

-(IBAction)shareImage:(id)sender{
    [self HidePhotoView];
    CGPoint hitPoint = [sender convertPoint:CGPointZero toView:tblview];
    NSIndexPath *hitIndex = [tblview indexPathForRowAtPoint:hitPoint];
    indexpath = hitIndex.section;
    NSLog(@"%ld",(long)hitIndex.section);
    
    if ([[[[mutTimeline objectAtIndex:hitIndex.section]objectForKey:@"user_id"] description]isEqual:[[NSUserDefaults standardUserDefaults] objectForKey:@"id"]]) {
        [actionSheetCurrentUser showInView:self.view];
    }
    else
    {
        [actionSheetOtherUser showInView:self.view];
    }
}

-(IBAction)likebtn:(id)sender{
    [self HidePhotoView];
    UIButton *btnTemp = (UIButton *)sender;
    if([btnTemp isSelected])
    {
        [btnTemp setBackgroundImage:[UIImage imageNamed:@"likeinwhite.png"] forState:UIControlStateNormal];
        [btnTemp setSelected:NO];
    }
    else
    {
        [btnTemp setBackgroundImage:[UIImage imageNamed:@"like.png"] forState:UIControlStateNormal];
        [btnTemp setSelected:YES];
    }

    CGPoint hitPoint = [sender convertPoint:CGPointZero toView:tblview];
    NSIndexPath *hitIndex = [tblview indexPathForRowAtPoint:hitPoint];
    NSLog(@"%ld",(long)hitIndex.section);
    NSString *aStrLike=[[mutTimeline objectAtIndex:hitIndex.section] objectForKey:@"image_id"];

//    NSArray *aryLike = [[NSArray alloc] initWithObjects:@"Test",nil];
//    [[[[mutTimeline objectAtIndex:hitIndex.section] valueForKey:@"likes"] addObject:dic];
  
    [self LikeApicall:(NSString *)aStrLike completionBlock:^(BOOL result) {
        [self gettingApiData];
        [self viewWillAppear:NO];
    }];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (actionSheet==actionSheetCurrentUser) {
        if (buttonIndex == 0) {
            
        }
        if (buttonIndex ==1){
            
            SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            
            //[mySLComposerSheet setInitialText:@"iOS 6 Social Framework test!"];
            NSString *astrUserid=[[mutTimeline objectAtIndex:indexpath] objectForKey:@"user_id"];
            NSString *astrImageid=[[mutTimeline objectAtIndex:indexpath] objectForKey:@"image_id"];
            NSString *aStrDisplyimage=[NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@-%@.jpg",astrUserid, astrImageid ];
            NSURL *aimageurl=[NSURL URLWithString:aStrDisplyimage];
            
            [mySLComposerSheet addImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:aimageurl]]];
            indexpath=0;
            [self presentViewController:mySLComposerSheet animated:YES completion:nil];
            
            
        }
        if (buttonIndex==2) {
            NSString *astrUserid=[[mutTimeline objectAtIndex:indexpath] objectForKey:@"user_id"];
            NSString *astrImageid=[[mutTimeline objectAtIndex:indexpath] objectForKey:@"image_id"];
            NSString *aStrDisplyimage=[NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@-%@.jpg",astrUserid, astrImageid ];
            NSURL *aimageurl=[NSURL URLWithString:aStrDisplyimage];
            
            UIImage *img=[UIImage imageWithData:[NSData dataWithContentsOfURL:aimageurl]];
            NSData *imageData = UIImagePNGRepresentation(img); //convert image into .png format.

            NSFileManager *fileManager = [NSFileManager defaultManager];//create instance of NSFileManager
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //create an array and store result of our search for the documents directory in it
            
            NSString *documentsDirectory = [paths objectAtIndex:0]; //create NSString object, that holds our exact path to the documents directory
            
            NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"insta.igo"]]; //add our image to the path
            
            [fileManager createFileAtPath:fullPath contents:imageData attributes:nil]; //finally save the path (image)
            
            NSLog(@"image saved");
            
            
            CGRect rect = CGRectMake(0 ,0 , 0, 0);
            UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
            [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIGraphicsEndImageContext();
            NSString *fileNameToSave = [NSString stringWithFormat:@"Documents/insta.igo"];
            NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:fileNameToSave];
            NSLog(@"jpg path %@",jpgPath);
            NSString *newJpgPath = [NSString stringWithFormat:@"file://%@",jpgPath]; //[[NSString alloc] initWithFormat:@"file://%@", jpgPath] ];
            NSLog(@"with File path %@",newJpgPath);
            NSURL *igImageHookFile = [[NSURL alloc] initFileURLWithPath:newJpgPath];
            NSLog(@"url Path %@",igImageHookFile);
            
            self.doc.UTI = @"com.instagram.exclusivegram";
            self.doc = [self setupControllerWithURL:igImageHookFile usingDelegate:self];
            self.doc=[UIDocumentInteractionController interactionControllerWithURL:igImageHookFile];
            [self.doc presentOpenInMenuFromRect: rect    inView: self.view animated: YES ];
        }
        if (buttonIndex==4)
        {
            NSString *aPost=[[mutTimeline objectAtIndex:indexpath] objectForKey:@"image_id"];
            [self postDelete:(NSString*)aPost completionBlock:^(BOOL result) {
                
                [self viewWillAppear:YES];
            }];
        }
        if (buttonIndex==3) {
            SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            
            //[mySLComposerSheet setInitialText:@"iOS 6 Social Framework test!"];
            NSString *astrUserid=[[mutTimeline objectAtIndex:indexpath] objectForKey:@"user_id"];
            NSString *astrImageid=[[mutTimeline objectAtIndex:indexpath] objectForKey:@"image_id"];
            NSString *aStrDisplyimage=[NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@-%@.jpg",astrUserid, astrImageid ];
            NSURL *aimageurl=[NSURL URLWithString:aStrDisplyimage];
            
            [mySLComposerSheet addImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:aimageurl]]];
            indexpath=0;
            [self presentViewController:mySLComposerSheet animated:YES completion:nil];
        }
    }
    else if (actionSheet==actionSheetOtherUser)
    {
        
        if (buttonIndex == 0) {
            
        }
        if (buttonIndex ==1){
            SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            NSString *astrUserid=[[mutTimeline objectAtIndex:indexpath] objectForKey:@"user_id"];
            NSString *astrImageid=[[mutTimeline objectAtIndex:indexpath] objectForKey:@"image_id"];
            NSString *aStrDisplyimage=[NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@-%@.jpg",astrUserid, astrImageid ];
            NSURL *aimageurl=[NSURL URLWithString:aStrDisplyimage];
            
            [mySLComposerSheet addImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:aimageurl]]];
            [self presentViewController:mySLComposerSheet animated:YES completion:nil];
            
        }
        if (buttonIndex==2) {
            
            NSString *astrUserid=[[mutTimeline objectAtIndex:indexpath] objectForKey:@"user_id"];
            NSString *astrImageid=[[mutTimeline objectAtIndex:indexpath] objectForKey:@"image_id"];
            NSString *aStrDisplyimage=[NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@-%@.jpg",astrUserid, astrImageid ];
            NSURL *aimageurl=[NSURL URLWithString:aStrDisplyimage];
            
            UIImage *img=[UIImage imageWithData:[NSData dataWithContentsOfURL:aimageurl]];
            NSData *imageData = UIImagePNGRepresentation(img); //convert image into .png format.
            
            NSFileManager *fileManager = [NSFileManager defaultManager];//create instance of NSFileManager
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //create an array and store result of our search for the documents directory in it
            
            NSString *documentsDirectory = [paths objectAtIndex:0]; //create NSString object, that holds our exact path to the documents directory
            
            NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"insta.igo"]]; //add our image to the path
            
            [fileManager createFileAtPath:fullPath contents:imageData attributes:nil]; //finally save the path (image)
            
            NSLog(@"image saved");
            CGRect rect = CGRectMake(0 ,0 , 0, 0);
            UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
            [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIGraphicsEndImageContext();
            NSString *fileNameToSave = [NSString stringWithFormat:@"Documents/insta.igo"];
            NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:fileNameToSave];
            NSLog(@"jpg path %@",jpgPath);
            NSString *newJpgPath = [NSString stringWithFormat:@"file://%@",jpgPath]; //[[NSString alloc] initWithFormat:@"file://%@", jpgPath] ];
            NSLog(@"with File path %@",newJpgPath);
            NSURL *igImageHookFile = [[NSURL alloc] initFileURLWithPath:newJpgPath];
            NSLog(@"url Path %@",igImageHookFile);
            
            self.doc.UTI = @"com.instagram.exclusivegram";
            self.doc = [self setupControllerWithURL:igImageHookFile usingDelegate:self];
            self.doc=[UIDocumentInteractionController interactionControllerWithURL:igImageHookFile];
            [self.doc presentOpenInMenuFromRect: rect    inView: self.view animated: YES ];
        }
        if (buttonIndex==3) {
            SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            
            //[mySLComposerSheet setInitialText:@"iOS 6 Social Framework test!"];
            NSString *astrUserid=[[mutTimeline objectAtIndex:indexpath] objectForKey:@"user_id"];
            NSString *astrImageid=[[mutTimeline objectAtIndex:indexpath] objectForKey:@"image_id"];
            NSString *aStrDisplyimage=[NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@-%@.jpg",astrUserid, astrImageid ];
            NSURL *aimageurl=[NSURL URLWithString:aStrDisplyimage];
            
            [mySLComposerSheet addImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:aimageurl]]];
            indexpath=0;
            [self presentViewController:mySLComposerSheet animated:YES completion:nil];
        }
    }
    else if (actionSheet==actionSheetProfile)
    {
        if (buttonIndex == 0) {
            UIStoryboard *storyboard = self.navigationController.storyboard;
            
            ProfileViewController *fllowerPrfile = [storyboard instantiateViewControllerWithIdentifier:@"followerProfile"];
            fllowerPrfile.userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"id"];
            
            //Push to detail View
            [self.navigationController pushViewController:fllowerPrfile animated:YES];
        }
        if (buttonIndex ==1){
            [self performSegueWithIdentifier:@"contect" sender:NULL];
        }
        if (buttonIndex==2) {
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"id"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [ApplicationDelegate Initialize];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate {
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.delegate = interactionDelegate;
    return interactionController;
}

-(void)LoadMore:(NSString *)postID completionBlock:(void (^)(BOOL result)) return_block{
}

#pragma mark; likeApiCall
-(void)LikeApicall:(NSString *)imageID completionBlock:(void (^)(BOOL result)) return_block{
    
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/post_like.php"]];
    __unsafe_unretained ASIFormDataRequest *request = _request;
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] forKey:@"user_id"];
    [request setPostValue:imageID forKey:@"image_id"];
    
    [request startAsynchronous];
    [request setCompletionBlock:^{
        NSMutableDictionary *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        NSLog(@"News Root %@",root);
        if([root[@"status"]isEqualToString:@"success"])
        {
            return_block(TRUE);
        }
    }];
    
    [request setFailedBlock:^{
        NSError *error=[request error];
        [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                        type:AJNotificationTypeRed
                                       title:error.localizedDescription
                             linedBackground:AJLinedBackgroundTypeDisabled
                                   hideAfter:5.0];
    }];
}

-(void)postDelete:(NSString *)imageID completionBlock:(void (^)(BOOL result)) return_block{
    
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/post_delete.php"]];
    __unsafe_unretained ASIFormDataRequest *request = _request;
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    //[request setPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] forKey:@"user_id"];
    [request setPostValue:imageID forKey:@"image_id"];
    
    [request startAsynchronous];
    [request setCompletionBlock:^{
        NSMutableDictionary *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        NSLog(@"News Root %@",root);
        if([root[@"status"]isEqualToString:@"success"])
        {
            return_block(TRUE);
        }
    }];
    
    [request setFailedBlock:^{
        NSError *error=[request error];
        [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                        type:AJNotificationTypeRed
                                       title:error.localizedDescription
                             linedBackground:AJLinedBackgroundTypeDisabled
                                   hideAfter:5.0];
    }];
}

- (IBAction)serch:(id)sender {
    [self HidePhotoView];
    SerchViewController *serchVC = [self.storyboard instantiateViewControllerWithIdentifier:@"serch"];
    
    [self.navigationController pushViewController:serchVC animated:YES];
}

- (IBAction)profile:(id)sender {
    [self HidePhotoView];
    UIStoryboard *storyboard = self.navigationController.storyboard;
    
    ProfileViewController *fllowerPrfile = [storyboard instantiateViewControllerWithIdentifier:@"followerProfile"];
    fllowerPrfile.userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"id"];
    
    //Push to detail View
    [self.navigationController pushViewController:fllowerPrfile animated:YES];
    //[actionSheetProfile showInView:self.view];
}

-(void)expand
{
    if(hidden)
        return;
    hidden = YES;
    [self HidePhotoView];
    [self hideTabBar:self.tabBarController];
    
    //[hederview  setHidden:YES];
    [UIView animateWithDuration:0.0 animations:^{
        [hederview setFrame:CGRectMake(0, -50, 320, 50)];
        [tblview setContentInset:UIEdgeInsetsMake(0,0,0,0)];
    }completion:^(BOOL finished){
        //[hederview setHidden:YES];
    }];
}

-(void)contract
{
        if(!hidden)
            return;
    
        hidden = NO;
    [self HidePhotoView];
    //[hederview setHidden:NO];
    [self showTabBar:self.tabBarController];
    
    //[hederview setHidden:NO];
    
    [UIView animateWithDuration:0.2 animations:^{
        [hederview setFrame:CGRectMake(0, 20, 320,50)];
        [tblview setContentInset:UIEdgeInsetsMake(70,0,0,0)];
    }completion:^(BOOL finished){
        //[hederview setHidden:NO];
    }];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods
- (void)hideTabBar:(UITabBarController *) tabbarcontroller
{
    [hederview setHidden:YES];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    
    for(UIView *view in tabbarcontroller.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            [view setFrame:CGRectMake(view.frame.origin.x,[UIScreen mainScreen].bounds.size.height, view.frame.size.width, view.frame.size.height)];
        }
        else
        {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, [UIScreen mainScreen].bounds.size.height)];
        }
    }
    [UIView commitAnimations];
}

- (void)showTabBar:(UITabBarController *) tabbarcontroller
{
    [hederview setHidden:NO];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    for(UIView *view in tabbarcontroller.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            [view setFrame:CGRectMake(view.frame.origin.x, [UIScreen mainScreen].bounds.size.height-tabbarcontroller.tabBar.frame.size.height+3, view.frame.size.width, view.frame.size.height)];
        }
        else
        {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, [UIScreen mainScreen].bounds.size.height-tabbarcontroller.tabBar.frame.size.height+3)];
        }
    }
    [UIView commitAnimations];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self HidePhotoView];
    startContentOffset = lastContentOffset = scrollView.contentOffset.y;
    //NSLog(@"scrollViewWillBeginDragging: %f", scrollView.contentOffset.y);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //[self HidePhotoView];
    CGFloat currentOffset = scrollView.contentOffset.y;
    if(currentOffset == 0)
    {
        [self contract];
        return;
    }
    CGFloat differenceFromStart = startContentOffset - currentOffset;
    CGFloat differenceFromLast = lastContentOffset - currentOffset;
    lastContentOffset = currentOffset;
    
    if((differenceFromStart) < 0)
    {
        // scroll up
        if(scrollView.isTracking && (abs(differenceFromLast)>1))
            [self expand];
    }
    else {
        if(scrollView.isTracking && (abs(differenceFromLast)>1))
            [self contract];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    [self HidePhotoView];
    [self contract];
    return YES;
}

-(void)HidePhotoView
{
    TabbarControllerViewController *tab = (TabbarControllerViewController*)self.tabBarController;
    [tab hidePhotoView];
}

-(void)gotoProfilePage:(MyTapGestureRecognizer *)gesture
{
    
    UIStoryboard *storyboard = self.navigationController.storyboard;
    
    ProfileViewController *fllowerPrfile = [storyboard instantiateViewControllerWithIdentifier:@"followerProfile"];
    
    fllowerPrfile.userId=gesture.userid;
    
    //Push to detail View
    [self.navigationController pushViewController:fllowerPrfile animated:YES];
    [hederview setHidden:NO];
    [self showTabBar:self.tabBarController];
    [self HidePhotoView];
    hidden = NO;
}

- (IBAction)btnScrollTop:(id)sender {
    [tblview scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

- (NSMutableArray*)getHashUsernameRange:(NSString*)str
{
    NSString *preStr = @"";
    NSString *tempstr = [NSString stringWithFormat:@"%@",str];
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    while(true){
        NSRange range = [tempstr rangeOfString:@"#"];
        if(range.location == NSNotFound)
            break;
        preStr = [NSString stringWithFormat:@"%@%@", preStr, [tempstr substringToIndex:range.location]];
      
        NSString *temp = [tempstr substringFromIndex:range.location];
        NSRange spacerange = [temp rangeOfString:@" "];
        NSRange alpharange = [temp rangeOfString:@"@"];
        NSRange sharprange = [[temp substringFromIndex:1] rangeOfString:@"#"];
        int index = temp.length;
        if(spacerange.location != NSNotFound && spacerange.location < index)
            index = spacerange.location;
        if(alpharange.location != NSNotFound && alpharange.location < index)
            index = alpharange.location;
        if(sharprange.location != NSNotFound && sharprange.location+1 < index)
            index = sharprange.location+1;
        NSRange newrange;
        newrange.location = preStr.length;
        newrange.length = index;
        [arr addObject:NSStringFromRange(newrange)];
        
        NSString *hashword = [temp substringToIndex:index];
        tempstr = [temp substringFromIndex:index];
        preStr = [NSString stringWithFormat:@"%@%@", preStr, hashword];
    }
    
    preStr = @"";
    tempstr = [NSString stringWithFormat:@"%@",str];
    while(true){
        NSRange range = [tempstr rangeOfString:@"@"];
        if(range.location == NSNotFound)
            break;
        preStr = [NSString stringWithFormat:@"%@%@", preStr, [tempstr substringToIndex:range.location]];
        
        NSString *temp = [tempstr substringFromIndex:range.location];
        NSRange spacerange = [temp rangeOfString:@" "];
        NSRange alpharange = [[temp substringFromIndex:1] rangeOfString:@"@"];
        NSRange sharprange = [temp rangeOfString:@"#"];
        int index = temp.length;
        if(spacerange.location != NSNotFound && spacerange.location < index)
            index = spacerange.location;
        if(alpharange.location != NSNotFound && alpharange.location+1 < index)
            index = alpharange.location+1;
        if(sharprange.location != NSNotFound && sharprange.location < index)
            index = sharprange.location;
        NSRange newrange;
        newrange.location = preStr.length;
        newrange.length = index;
        [arr addObject:NSStringFromRange(newrange)];
        
        NSString *hashword = [temp substringToIndex:index];
        tempstr = [temp substringFromIndex:index];
        preStr = [NSString stringWithFormat:@"%@%@", preStr, hashword];
    }
    return arr;
}

- (void)CommentLabelClicked:(MyTapGestureRecognizer *)gesture
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    UILabel *lbl = gesture.eventLabel;
    CGPoint p = [gesture locationInView:lbl];
    NSAttributedString *attributedstr = [lbl attributedText];
    CGSize lblsize = lbl.frame.size;
    NSString *str = attributedstr.string;
    CGSize usernamesize = CGSizeMake(lblsize.width,999);
    NSString *preStr = @"";
    
    while(true){
        NSRange range = [str rangeOfString:@"#"];
        if(range.location == NSNotFound)
            break;
        preStr = [NSString stringWithFormat:@"%@%@", preStr, [str substringToIndex:range.location]];
        CGSize prevSize =[preStr boundingRectWithSize: usernamesize options:NSStringDrawingUsesLineFragmentOrigin attributes: @{NSFontAttributeName:lbl.font} context: nil].size;
        NSString *temp = [str substringFromIndex:range.location];
        NSRange spacerange = [temp rangeOfString:@" "];
        NSRange alpharange = [temp rangeOfString:@"@"];
        NSRange sharprange = [[temp substringFromIndex:1] rangeOfString:@"#"];
        int index = temp.length;
        if(spacerange.location != NSNotFound && spacerange.location < index)
            index = spacerange.location;
        if(alpharange.location != NSNotFound && alpharange.location < index)
            index = alpharange.location;
        if(sharprange.location != NSNotFound && sharprange.location+1 < index)
            index = sharprange.location+1;
        NSString *hashword = [temp substringToIndex:index];
        str = [temp substringFromIndex:index];
        CGSize afterSize =[[NSString stringWithFormat:@"%@%@",preStr,hashword] boundingRectWithSize: usernamesize options:NSStringDrawingUsesLineFragmentOrigin attributes: @{NSFontAttributeName:lbl.font} context: nil].size;
        
        float posx_prev = [preStr sizeWithFont:lbl.font
                    forWidth:CGRectGetMaxX(lbl.frame)
               lineBreakMode:NSLineBreakByWordWrapping].width;
        float posx_next = [[NSString stringWithFormat:@"%@%@",preStr,hashword] sizeWithFont:lbl.font
                                  forWidth:CGRectGetMaxX(lbl.frame)
                             lineBreakMode:NSLineBreakByWordWrapping].width;
        
        float posy_hash = [hashword sizeWithFont:lbl.font forWidth:CGRectGetMaxX(lbl.frame) lineBreakMode:NSLineBreakByWordWrapping].height;
        preStr = [NSString stringWithFormat:@"%@%@", preStr, hashword];
        CGRect rt;
        if(prevSize.height == afterSize.height){
            rt.origin.x = posx_prev;
            rt.origin.y = afterSize.height-posy_hash+10;
            rt.size.width = posx_next-posx_prev;
            rt.size.height = posy_hash;
        }else{
            rt.origin.x = 0;
            rt.origin.y = afterSize.height-posy_hash+10;
            rt.size.width = posx_next;
            rt.size.height = posy_hash;
        }
        if( [self ptInRect:p withRect:rt]){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            UIStoryboard *storyboard = self.navigationController.storyboard;
            ExploreViewController *exploreController = [storyboard instantiateViewControllerWithIdentifier:@"ExploreView"];
            [exploreController InitializeHashtag:hashword];
            [self.navigationController pushViewController:exploreController animated:YES];
            return;
        }
    }
    
    str = attributedstr.string;
    preStr = @"";
    while(true){
        NSRange range = [str rangeOfString:@"@"];
        if(range.location == NSNotFound)
            break;
        preStr = [NSString stringWithFormat:@"%@%@", preStr, [str substringToIndex:range.location]];
        CGSize prevSize =[preStr boundingRectWithSize: usernamesize options:NSStringDrawingUsesLineFragmentOrigin attributes: @{NSFontAttributeName:lbl.font} context: nil].size;
        NSString *temp = [str substringFromIndex:range.location];
        NSRange spacerange = [temp rangeOfString:@" "];
        NSRange alpharange = [[temp substringFromIndex:1] rangeOfString:@"@"];
        NSRange sharprange = [temp rangeOfString:@"#"];
        int index = temp.length;
        if(spacerange.location != NSNotFound && spacerange.location < index)
            index = spacerange.location;
        if(alpharange.location != NSNotFound && alpharange.location+1 < index)
            index = alpharange.location+1;
        if(sharprange.location != NSNotFound && sharprange.location < index)
            index = sharprange.location;
        NSString *hashword = [temp substringToIndex:index];
        str = [temp substringFromIndex:index];
        CGSize afterSize =[[NSString stringWithFormat:@"%@%@",preStr,hashword] boundingRectWithSize: usernamesize options:NSStringDrawingUsesLineFragmentOrigin attributes: @{NSFontAttributeName:lbl.font} context: nil].size;
        
        float posx_prev = [preStr sizeWithFont:lbl.font
                                      forWidth:CGRectGetMaxX(lbl.frame)
                                 lineBreakMode:NSLineBreakByWordWrapping].width;
        float posx_next = [[NSString stringWithFormat:@"%@%@",preStr,hashword] sizeWithFont:lbl.font
                                                                                   forWidth:CGRectGetMaxX(lbl.frame)
                                                                              lineBreakMode:NSLineBreakByWordWrapping].width;
        
        float posy_hash = [hashword sizeWithFont:lbl.font forWidth:CGRectGetMaxX(lbl.frame) lineBreakMode:NSLineBreakByWordWrapping].height;
        preStr = [NSString stringWithFormat:@"%@%@", preStr, hashword];
        CGRect rt;
        if(prevSize.height == afterSize.height){
            rt.origin.x = posx_prev;
            rt.origin.y = afterSize.height-posy_hash+10;
            rt.size.width = posx_next-posx_prev;
            rt.size.height = posy_hash;
        }else{
            rt.origin.x = 0;
            rt.origin.y = afterSize.height-posy_hash+10;
            rt.size.width = posx_next;
            rt.size.height = posy_hash;
        }
        if( [self ptInRect:p withRect:rt]){
            hashword = [hashword substringFromIndex:1];
            ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/get_userid.php"]];
            __unsafe_unretained ASIFormDataRequest *request = _request;
            
            [request addRequestHeader:@"Content-Type" value:@"application/json"];
            [request setPostValue:hashword forKey:@"username"];
            
            [request startAsynchronous];
            [request setCompletionBlock:^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                NSMutableDictionary *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
                if(root){
                    NSString *uid = [root objectForKey:@"id"];
                    UIStoryboard *storyboard = self.navigationController.storyboard;
                    ProfileViewController *fllowerPrfile = [storyboard instantiateViewControllerWithIdentifier:@"followerProfile"];
                    fllowerPrfile.userId = uid;
                    [self.navigationController pushViewController:fllowerPrfile animated:YES];
                    return;
                }
            }];
            
            [request setFailedBlock:^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                NSError *error=[request error];
                [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                                type:AJNotificationTypeRed
                                               title:error.localizedDescription
                                     linedBackground:AJLinedBackgroundTypeDisabled
                                           hideAfter:5.0];
            }];
            return;
        }
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (BOOL)ptInRect:(CGPoint)pt withRect:(CGRect)rt
{
    if(pt.x < rt.origin.x)
        return NO;
    if(pt.x > rt.origin.x+rt.size.width)
        return NO;
    if(pt.y < rt.origin.y)
        return NO;
    if(pt.y > rt.origin.y+rt.size.height)
        return NO;
    return YES;
}
@end
