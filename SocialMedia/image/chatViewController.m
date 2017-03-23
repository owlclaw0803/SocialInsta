//
//  chatViewController.m
//  SocialMedia
//
//  Created by PARMARTH MORI on 03/07/14.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import "chatViewController.h"
#import "AsyncImageView.h"
#import "SVPullToRefresh.h"
#import "ProfileViewController.h"
#import "TabbarControllerViewController.h"
#import "UIImage+FixOrientation.h"

@interface chatViewController ()

@end

@implementation chatViewController

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

    _photoOptions = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Dismiss" destructiveButtonTitle:nil otherButtonTitles:@"Photo",@"Video", nil];
    _photoOptions.tag = 0;
    _photoOptions.delegate = self;
    
    attachments = [[NSMutableArray alloc] init];
    img_attachments = [[NSMutableArray alloc] init];
    btn_attachments = [[NSMutableArray alloc] init];
    attachmentcount = 0;
    txtChatVIew.delegate = self;
    //[txtChatVIew addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEnd];
    userImage.layer.cornerRadius = userImage.frame.size.width/2;
    userImage.layer.masksToBounds = YES;
    [userImage.layer setBorderColor:[[UIColor colorWithRed:135.0/225.0 green:233.0/225.0 blue:135.0/225.0 alpha:1.0] CGColor]];
    [userImage.layer setBorderWidth: 1];
    
    tblview.tableFooterView = [[UIView alloc] init];
    viewText.layer.borderColor = [UIColor whiteColor].CGColor;
    viewText.layer.borderWidth = 1.0f;
    viewText.layer.cornerRadius = 5.0f;
    viewText.layer.masksToBounds = YES;
    
    BOOL isPost = [[NSUserDefaults standardUserDefaults] boolForKey:@"Post"];
    if (isPost==YES) {
        [self.tabBarController setSelectedIndex:0];
    }
    
    NSString *aStrDisplyimage = [NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@-profile.jpg", self.userid];
    [userImage setImageURL:[NSURL URLWithString:aStrDisplyimage]];
    chatMutArray = [[NSMutableArray alloc]init];
    lblUserName.text = self.username;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self GetPostedMsz:self.userid completionBlock:^(BOOL result) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [tblview reloadData];
        NSLog(@"%@",chatMutArray);
        if ([chatMutArray count] != 0) {
            int lastRowNumber = [tblview numberOfRowsInSection:0]-1;
            NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
            [tblview scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:NO];
            [tblview visibleCells];
        }
    }];
    
    NewAttachment = -1;
	// Do any additional setup after loading the view.
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)viewDidDisappear:(BOOL)animated{
    [timer invalidate];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [timer invalidate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)removeAttachment:(id)sender{
    float width = (txtChatVIew.frame.size.width-10)/3;
    float height = width * 450 / 320;
    int attachid = ((UIButton*)sender).tag-1000;
    int index = -1;
    for(int i = 0 ; i < attachments.count ; i++)
        if([[attachments objectAtIndex:i] intValue] == attachid){
            index = i;
            break;
        }
    if(index == -1)
        return;
    for(int i = img_attachments.count-1 ; i > index  ; i--){
        UIImageView *imgview = (UIImageView*)[img_attachments objectAtIndex:i];
        UIImageView *prevview = (UIImageView*)[img_attachments objectAtIndex:i-1];
        imgview.frame = prevview.frame;
    }
    for(int i = btn_attachments.count-1 ; i > index  ; i--){
        UIButton *btnview = (UIButton*)[btn_attachments objectAtIndex:i];
        UIButton *prevview = (UIButton*)[btn_attachments objectAtIndex:i-1];
        btnview.frame = prevview.frame;
    }
    attachmentcount--;
    [(UIImageView*)[img_attachments objectAtIndex:index]  removeFromSuperview];
    [(UIButton*)[btn_attachments objectAtIndex:index]  removeFromSuperview];
    [img_attachments removeObjectAtIndex:index];
    [btn_attachments removeObjectAtIndex:index];
    [attachments removeObjectAtIndex:index];
    CGRect frmviewText = viewText.frame;
    if(attachmentcount == 0 || attachmentcount == 3){
        frmviewText.size.height -= height;
        frmviewText.origin.y += height;
        viewText.frame = frmviewText;
    }
    
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/remove_attachment.php"]];
    _request.shouldAttemptPersistentConnection   = NO;
    __unsafe_unretained ASIFormDataRequest *request = _request;
    
    [request addRequestHeader:@"Content-Type" value:@"multipart/form-data"];
    [request addPostValue:[[NSUserDefaults standardUserDefaults]objectForKey:@"id" ] forKey:@"from_id"];
    [request addPostValue:self.userid forKey:@"to_id"];
    [request addPostValue:[NSString stringWithFormat:@"%d",attachid] forKey:@"attachmentid"];
    [request startAsynchronous];
}

-(UIImage*) makeImageSmaller:(UIImage*)image
{
    image = [image fixOrientation];
    float width = image.size.width*450/image.size.height;

    CGSize newSize = CGSizeMake(width, 450);
    UIGraphicsBeginImageContextWithOptions(newSize, YES, 1.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void)viewWillAppear:(BOOL)animated {
    
    if(NewAttachment == 0){

        UIImage* image1 = [self makeImageSmaller:tempattachimg];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [self updateattachmentpicApi:image1 completionBlock:^(BOOL result) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            float width = (txtChatVIew.frame.size.width-10)/3;
            float height = width * 450 / 320;
            if(attachmentcount == 0 || attachmentcount == 3){
                CGRect rt = viewText.frame;
                rt.origin.y -= height;
                rt.size.height += height;
                viewText.frame = rt;
                rt = tblview.frame;
                rt.size.height = rt.size.height - height - 2;
                tblview.frame = rt;
            }
            
            CGRect attachpos = CGRectMake((attachmentcount>=3?attachmentcount-3:attachmentcount)*(width+5)+txtChatVIew.frame.origin.x, ((int)(attachmentcount/3)*(height+2)+txtChatVIew.frame.origin.y+txtChatVIew.frame.size.height+2), width, height);
            
            UIImageView* tempattachimgview = [[UIImageView alloc] initWithFrame:attachpos];
            tempattachimgview.layer.borderWidth = 1.0f;
            [viewText addSubview:tempattachimgview];
            
            CGRect cropRect = CGRectMake(0, 0, 0, tempattachimg.size.height);
            cropRect.size.width = tempattachimg.size.height*320/450;
            
            CGImageRef imageRef = CGImageCreateWithImageInRect([tempattachimg CGImage], cropRect);
            // or use the UIImage wherever you like
            UIImage *image = [UIImage imageWithCGImage:imageRef];
            CGImageRelease(imageRef);
            
            tempattachimgview.image = image;
            attachmentcount ++;
            
            UIButton *btncancel = [[UIButton alloc] initWithFrame:CGRectMake(attachpos.origin.x+attachpos.size.width-10, attachpos.origin.y-10, 20,20)];
            [btncancel setBackgroundImage:[UIImage imageNamed:@"Cross.png"] forState:UIControlStateNormal];
            btncancel.tag = [[attachments objectAtIndex:attachments.count-1] intValue]+1000;
            btncancel.layer.zPosition = 40;
            [btncancel addTarget:self action:@selector(removeAttachment:) forControlEvents:UIControlEventTouchUpInside];
            [viewText addSubview:btncancel];
            [img_attachments addObject:tempattachimgview];
            [btn_attachments addObject:btncancel];
        }];
        NewAttachment = -1;
    }else if(NewAttachment == 1){
        UIImage* image1 = [tempattachimg fixOrientation];
        NSData *img = UIImageJPEGRepresentation(image1, 0.3f);
        NSString *imagestring = [Base64 encode:img];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [self updateattachmentvideoApi:imagestring completionBlock:^(BOOL result) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            float width = (txtChatVIew.frame.size.width-10)/3;
            float height = width * 450 / 320;
            if(attachmentcount == 0 || attachmentcount == 3){
                CGRect rt = viewText.frame;
                rt.origin.y -= height;
                rt.size.height += height;
                viewText.frame = rt;
                rt = tblview.frame;
                rt.size.height = rt.size.height - height - 2;
                tblview.frame = rt;
            }
            
            CGRect attachpos = CGRectMake((attachmentcount>=3?attachmentcount-3:attachmentcount)*(width+5)+txtChatVIew.frame.origin.x, ((int)(attachmentcount/3)*(height+2)+txtChatVIew.frame.origin.y+txtChatVIew.frame.size.height+2), width, height);
            
            UIImageView* tempattachimgview = [[UIImageView alloc] initWithFrame:attachpos];
            tempattachimgview.layer.borderWidth = 1.0f;
            
            CGRect cropRect = CGRectMake(0, 0, 0, tempattachimg.size.height);
            cropRect.size.width = tempattachimg.size.height*150/200;
            
            CGImageRef imageRef = CGImageCreateWithImageInRect([tempattachimg CGImage], cropRect);
            // or use the UIImage wherever you like
            UIImage *image = [UIImage imageWithCGImage:imageRef];
            CGImageRelease(imageRef);
            
            tempattachimgview.image = image;
            [viewText addSubview:tempattachimgview];
            attachmentcount ++;
            
            UIButton *btncancel = [[UIButton alloc] initWithFrame:CGRectMake(attachpos.origin.x+attachpos.size.width-10, attachpos.origin.y-10, 20,20)];
            [btncancel setBackgroundImage:[UIImage imageNamed:@"Cross.png"] forState:UIControlStateNormal];
            btncancel.tag = [[attachments objectAtIndex:attachments.count-1] intValue]+1000;
            btncancel.layer.zPosition = 40;
            [btncancel addTarget:self action:@selector(removeAttachment:) forControlEvents:UIControlEventTouchUpInside];
            [viewText addSubview:btncancel];
            
            [img_attachments addObject:tempattachimgview];
            [btn_attachments addObject:btncancel];
        }];
        NewAttachment = -1;
    }
    [super viewWillAppear:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [chatMutArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    for (UIView *view in cell.contentView.subviews) {
        if (view.tag != 1) {
            [view removeFromSuperview];
        }
    }
    
    [[cell viewWithTag:2]removeFromSuperview];
    [[cell viewWithTag:3]removeFromSuperview];
    [[cell viewWithTag:4]removeFromSuperview];
    AsyncImageView *imageview = [[AsyncImageView alloc]initWithFrame:CGRectMake(10, 10,40,40)];
    UIImageView *imageview1 = [[UIImageView alloc] init];
    [cell.contentView addSubview:imageview1];
    [imageview setTag:2];
    [cell.contentView addSubview:imageview];
    imageview.layer.cornerRadius = imageview.frame.size.width/2;
    imageview.layer.masksToBounds = YES;
    imageview.userInteractionEnabled = YES;
    MyTapGestureRecognizer *tapGestureRecognizer = [[MyTapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoProfilePage:)];
    tapGestureRecognizer.userid = [[chatMutArray objectAtIndex:indexPath.row] objectForKey:@"from_user_id"];
    [imageview addGestureRecognizer:tapGestureRecognizer];
    
    NSString *aStrDisplyimage = [NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/thumb/%@-profile.jpg", [[chatMutArray objectAtIndex:indexPath.row] objectForKey:@"from_user_id"]];
    [imageview setImageURL:[NSURL URLWithString:aStrDisplyimage]];
    NSString *str = [[chatMutArray objectAtIndex:indexPath.row] objectForKey:@"from_user_id"];
    NSString *str2 = self.userid;
    NSLog(@"%@  %@",str2,str);
    if ([str intValue] == [str2 intValue]) {
        [imageview.layer setBorderColor: [[UIColor colorWithRed:135.0/225.0 green:233.0/225.0 blue:135.0/225.0 alpha:1.0] CGColor]];
        [imageview.layer setBorderWidth: 1];
        imageview1.image = [UIImage imageNamed:@"portraitlinegreen.jpg"];
    }else{
        imageview1.image = [UIImage imageNamed:@"portraitline.jpg"];
        imageview1.backgroundColor = [UIColor whiteColor];
        [imageview.layer setBorderColor: [[UIColor whiteColor] CGColor]];
        [imageview.layer setBorderWidth: 1];
    }
    
    UILabel *lblCommntName = [[UILabel alloc]initWithFrame:CGRectMake(60, 15, 260, 20)];
    [lblCommntName setTag:3];
    [cell.contentView addSubview:lblCommntName];
    [lblCommntName setFont:[UIFont italicSystemFontOfSize:14.0]];
    lblCommntName.text = [[chatMutArray objectAtIndex:indexPath.row] objectForKey:@"from_username"];
    lblCommntName.lineBreakMode = NSLineBreakByWordWrapping;
    lblCommntName.numberOfLines = 0;
    lblCommntName.textColor = [UIColor whiteColor];

    UILabel *lblMsz = [[UILabel alloc]init];
    [lblMsz setTag:4];
    [cell.contentView addSubview:lblMsz];
    [lblMsz setFont:[UIFont italicSystemFontOfSize:13.0]];
    lblMsz.text = [[chatMutArray objectAtIndex:indexPath.row] objectForKey:@"msg"];
    lblMsz.lineBreakMode = NSLineBreakByWordWrapping;
    lblMsz.numberOfLines = 0;
    lblMsz.textColor = [UIColor whiteColor];
    
    CGSize usernamesize = CGSizeMake(245,999);
    CGSize usernameRect = [lblMsz.text boundingRectWithSize: usernamesize options: NSStringDrawingUsesLineFragmentOrigin attributes: @{NSFontAttributeName:lblMsz.font} context: nil].size ;
    [lblMsz setFrame :CGRectMake(60, lblCommntName.frame.size.height+lblCommntName.frame.origin.y,usernameRect.width+10 , usernameRect.height+10)];
    
    UILabel *lbldate = [[UILabel alloc]initWithFrame:CGRectMake(225, 10, 80, 50)];
    [lbldate setTag:5];
    [cell.contentView addSubview:lbldate];
    [lbldate setFont:[UIFont italicSystemFontOfSize:12.0]];
    lbldate.textColor = [UIColor whiteColor];
    lbldate.textAlignment = NSTextAlignmentRight;
    lbldate.text = [[chatMutArray objectAtIndex:indexPath.row] objectForKey:@"dt"];
    
    float curheight = lblMsz.frame.origin.y + lblMsz.frame.size.height+5;
    float width = (lbldate.frame.origin.x - imageview.frame.origin.x - imageview.frame.size.width)*0.5;
    float height = width*45/32;
    NSString * attachfiles = [[chatMutArray objectAtIndex:indexPath.row] objectForKey:@"attachment"];
    if(attachfiles && attachfiles.length > 0){
        NSArray *arr = [attachfiles componentsSeparatedByString:@"/"];
        NSString *str_from_id = [[chatMutArray objectAtIndex:indexPath.row] objectForKey:@"from_user_id"];
        NSString *str_to_id = [[chatMutArray objectAtIndex:indexPath.row] objectForKey:@"to_user_id"];
        for(int i = 0 ; i < arr.count ; i++){
            NSString *attachfile = [arr objectAtIndex:i];
            CGRect frm = CGRectMake(lblMsz.frame.origin.x, curheight, width, height);
            int uID;
            UIImageView *attachimg = [[UIImageView alloc] initWithFrame:frm];
            
            MyTapGestureRecognizer *tapGestureRecognizer1 = [[MyTapGestureRecognizer alloc] initWithTarget:self action:@selector(showattachment:)];
            
            tapGestureRecognizer1.attachimage = nil;
            
            if([attachfile characterAtIndex:attachfile.length-1] == 'v'){
                uID = [[attachfile substringToIndex:attachfile.length-1] intValue];
                tapGestureRecognizer1.mediatype = 1;
                tapGestureRecognizer1.videoid = uID;
                UIImageView *playbtn = [[UIImageView alloc] initWithFrame:CGRectMake(frm.size.width/4, (frm.size.height-frm.size.width/2
                                                                                                        )/2, frm.size.width/2, frm.size.width/2)];
                [playbtn setImage:[UIImage imageNamed:@"video.png"]];
                [attachimg addSubview:playbtn];
            }else{
                uID = [attachfile intValue];
                tapGestureRecognizer1.mediatype = 0;
            }
            NSString *attachpath = [NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/attachment/%@-%@-%d.jpg",str_from_id,str_to_id,uID];
            tapGestureRecognizer1.imageurl = attachpath;
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [self downloadImageWithURL:[NSURL URLWithString:attachpath] completionBlock:^(BOOL succeeded, UIImage *image) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                if (succeeded) {
                    tapGestureRecognizer1.attachimage = image;
                    CGRect cropRect = CGRectMake(0, 0, 0, image.size.height);
                    cropRect.size.width = image.size.height*320/450;
                    
                    if(image.size.width < cropRect.size.width){
                        cropRect = CGRectMake(0, 0, image.size.width, 0);
                        cropRect.size.height = image.size.height*450/320;
                    }
                    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
                    // or use the UIImage wherever you like
                    UIImage* newimage = [UIImage imageWithCGImage:imageRef];
                    CGImageRelease(imageRef);
                    
                    [attachimg setImage:newimage];
                    attachimg.hidden = NO;
                    [attachimg addGestureRecognizer:tapGestureRecognizer1];
                }
            }];
            
            [cell.contentView addSubview:attachimg];
            attachimg.hidden = YES;
            attachimg.userInteractionEnabled = YES;
            [attachimg addGestureRecognizer:tapGestureRecognizer1];
            
            curheight = curheight + attachimg.frame.size.height + 5;
        }
    }
    CGRect rtline = imageview1.frame;
    rtline.size.height = curheight;
    imageview1.frame = rtline;
    
    imageview1.frame = CGRectMake(29, 0, 1, curheight+15);

    if (indexPath.row == [chatMutArray count]-1) {
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width-15);
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    AsyncImageView *imageview = [[AsyncImageView alloc]initWithFrame:CGRectMake(10, 10,40,40)];
    [cell.contentView addSubview:imageview];
    imageview.layer.cornerRadius = imageview.frame.size.width/2;
    imageview.layer.masksToBounds = YES;
    
    UILabel *lblCommntName = [[UILabel alloc]initWithFrame:CGRectMake(60, 15, 260, 20)];
    [cell.contentView addSubview:lblCommntName];
    [lblCommntName setFont:[UIFont boldSystemFontOfSize:14.0]];
    lblCommntName.text = [[chatMutArray objectAtIndex:indexPath.row] objectForKey:@"from_username"];
    lblCommntName.lineBreakMode = NSLineBreakByWordWrapping;
    lblCommntName.numberOfLines = 0;
    lblCommntName.textColor = [UIColor whiteColor];
    
    UILabel *lblMsz = [[UILabel alloc]init];
    [cell.contentView addSubview:lblMsz];
    [lblMsz setFont:[UIFont boldSystemFontOfSize:13.0]];
    lblMsz.text = [[chatMutArray objectAtIndex:indexPath.row] objectForKey:@"msg"];
    lblMsz.lineBreakMode = NSLineBreakByWordWrapping;
    lblMsz.numberOfLines = 0;
    lblMsz.textColor = [UIColor whiteColor];
    
    CGSize usernamesize = CGSizeMake(245,999);
    CGSize usernameRect = [lblMsz.text boundingRectWithSize: usernamesize options: NSStringDrawingUsesLineFragmentOrigin
                                                attributes: @{NSFontAttributeName:lblMsz.font} context: nil].size ;
    [lblMsz setFrame :CGRectMake(60, lblCommntName.frame.size.height+lblCommntName.frame.origin.y,usernameRect.width+10 , usernameRect.height+10)];
    
    float width = (225 - imageview.frame.origin.x - imageview.frame.size.width)*0.5;
    float height = width*45/32;
    int addheight = 0;
    NSString * attachfiles = [[chatMutArray objectAtIndex:indexPath.row] objectForKey:@"attachment"];
    if(attachfiles && attachfiles.length > 0){
        NSArray *arr = [attachfiles componentsSeparatedByString:@"/"];
        addheight = (height+5)*arr.count;
    }
    return lblMsz.frame.size.height+lblMsz.frame.origin.y+20+addheight;
}

- (IBAction)postSend:(id)sender {
    if([txtChatVIew.text isEqual:@""])
        return;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self SendMsz:NULL completionBlock:^(BOOL result) {
        txtChatVIew.text = NULL;
        [tblview reloadData];
        int lastRowNumber = [tblview numberOfRowsInSection:0]-1;
        NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
        [tblview scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:YES];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

-(void)GetPostedMsz:(NSString *)userid completionBlock:(void (^)(BOOL result)) return_block{

    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/get_chat.php"]];
    __unsafe_unretained ASIFormDataRequest *request = _request;
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] forKey:@"from_user_id"];
    [request setPostValue:self.userid forKey:@"to_user_id"];
    request.timeOutSeconds = 50;
    [request startAsynchronous];
    [request setCompletionBlock:^{
        NSData* data = [request responseData];
        NSError *error;
        NSMutableArray *root = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        NSLog(@"News Root 1234564789 ====> %@",root);
        int i = 0;
        for (NSArray *arry in root) {
            [chatMutArray insertObject:arry atIndex:0];
            if ([[[root objectAtIndex:i] objectForKey:@"to_user_id"]isEqualToString:self.userid]) {
               user_Chatid = [[[root objectAtIndex:i]objectForKey:@"chat_id"] intValue];
            }
              i++;
        }
        return_block(TRUE);
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

-(void)getpost{

    if(bFirst){
        bFirst = NO;
        return;
    }
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/get_chat.php"]];
    __unsafe_unretained ASIFormDataRequest *request = _request;
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    //[request setPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] forKey:@"user_id"];
    [request setPostValue:[[chatMutArray lastObject]objectForKey:@"chat_id"] forKey:@"chat_id"];
    [request setPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] forKey:@"from_user_id"];
    [request setPostValue:self.userid forKey:@"to_user_id"];
    [request startAsynchronous];
    [request setCompletionBlock:^{
        NSMutableDictionary *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        [chatMutArray removeAllObjects];
        for (NSArray *arry in root) {
            [chatMutArray insertObject:arry atIndex:0];
        }
        [tblview reloadData];
        int lastRowNumber = [tblview numberOfRowsInSection:0]-1;
        NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
        [tblview scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:YES];
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

-(void)SendMsz:(NSString *)userid completionBlock:(void (^)(BOOL result)) return_block{
    
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/send_chat_msg.php"]];
    __unsafe_unretained ASIFormDataRequest *request = _request;
    
    NSString *attachmentfiles = @"";
    for(int i = 0 ; i < [attachments count] ; i++){
        attachmentfiles = [NSString stringWithFormat:@"%@%@", attachmentfiles, [attachments objectAtIndex:i]];
        if(i != [attachments count]-1)
            attachmentfiles = [NSString stringWithFormat:@"%@/", attachmentfiles];
    }
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] forKey:@"from_user_id"];
    [request setPostValue:self.userid forKey:@"to_user_id"];
    [request setPostValue:txtChatVIew.text forKey:@"msg"];
    [request setPostValue:attachmentfiles forKey:@"attachments"];
    [request startAsynchronous];
    [request setCompletionBlock:^{
        NSMutableDictionary *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        NSLog(@"News Root 123dsf sdf sdf sdf  ====>%@",root);
        if(root[@"id"]!=NULL)
        {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            [dic setValue:[root objectForKey:@"id"] forKey:@"chat_id"];
            [dic setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] forKey:@"from_user_id"];
            [dic setValue:self.userid forKey:@"to_user_id"];
            [dic setValue:self.username forKey:@"to_user_name"];
            [dic setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"] forKey:@"from_username"];
            [dic setValue:txtChatVIew.text forKey:@"msg"];
            [dic setValue:attachmentfiles forKey:@"attachment"];
            user_Chatid=[[root objectForKey:@"id"] intValue];
            NSDate *now = [NSDate date];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
           [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
            [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
            NSLog(@"The Current Time is %@",[dateFormatter stringFromDate:now]);
            [dic setValue:[dateFormatter stringFromDate:now] forKey:@"dt"];
            
            [chatMutArray addObject:dic];
            for(int i = 0 ; i < img_attachments.count ; i++){
                [[img_attachments objectAtIndex:i] removeFromSuperview];
            }
            for(int i = 0 ; i < btn_attachments.count ; i++){
                [[btn_attachments objectAtIndex:i] removeFromSuperview];
            }
            [attachments removeAllObjects];
            [btn_attachments removeAllObjects];
            [img_attachments removeAllObjects];
            float width = (txtChatVIew.frame.size.width-10)/3;
            float height = width * 450 / 320;
            CGRect frmtxtChatView = viewText.frame;
            if(attachmentcount > 0){
                int count = 1+(attachmentcount-1)/3;
                frmtxtChatView.size.height -= count*height;
                viewText.frame = frmtxtChatView;
                attachmentcount = 0;
            }
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
    bFirst = YES;
    timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(getpost) userInfo:nil repeats:YES];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    int gap = 256.0-viewText.frame.size.height;
    if(viewText.frame.origin.y + viewText.frame.size.height + 55 < [[UIScreen mainScreen] bounds].size.height){
        viewText.frame = CGRectMake(viewText.frame.origin.x, viewText.frame.origin.y+gap, viewText.frame.size.width, viewText.frame.size.height);
        tblview.frame = CGRectMake(tblview.frame.origin.x, tblview.frame.origin.y, tblview.frame.size.width, tblview.frame.size.height+gap);
    }
    [txtChatVIew resignFirstResponder];
    [UIView commitAnimations];
    
    int lastRowNumber = [tblview numberOfRowsInSection:0]-1;
    if(lastRowNumber > 0){
        NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
        [tblview scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
    [txtChatVIew resignFirstResponder];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;
{
    //captionTextView.text = @"";
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationBeginsFromCurrentState:YES];
    int gap = viewText.frame.size.height-256.0;
	viewText.frame = CGRectMake(viewText.frame.origin.x, viewText.frame.origin.y+gap, viewText.frame.size.width, viewText.frame.size.height);
    tblview.frame = CGRectMake(tblview.frame.origin.x, (tblview.frame.origin.y), tblview.frame.size.width, tblview.frame.size.height+gap);
	[UIView commitAnimations];
    
    int lastRowNumber = [tblview numberOfRowsInSection:0]-1;
    if(lastRowNumber > 0){
        NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
        [tblview scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if([string isEqualToString:@"\n"])
    {
        [self postSend:nil];
        return NO;
    }
    else
        return YES;
}

- (IBAction)backClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)gotoProfilePage:(MyTapGestureRecognizer *)gesture
{
    
    UIStoryboard *storyboard = self.navigationController.storyboard;
    
    ProfileViewController *fllowerPrfile = [storyboard instantiateViewControllerWithIdentifier:@"followerProfile"];
    
    fllowerPrfile.userId=gesture.userid;
    
    //Push to detail View
    [self.navigationController pushViewController:fllowerPrfile animated:YES];
    TabbarControllerViewController *tab = (TabbarControllerViewController*)self.tabBarController;
    [tab hidePhotoView];
}

- (IBAction)attachmentfile:(id)sender {
    
    int gap = 256.0-viewText.frame.size.height;
    if(viewText.frame.origin.y + viewText.frame.size.height + 55  < [[UIScreen mainScreen] bounds].size.height){
        viewText.frame = CGRectMake(viewText.frame.origin.x, viewText.frame.origin.y+gap, viewText.frame.size.width, viewText.frame.size.height);
        tblview.frame = CGRectMake(tblview.frame.origin.x, tblview.frame.origin.y, tblview.frame.size.width, tblview.frame.size.height+gap);
    }
    
    if(attachmentcount == 6)
        return;
    
    [_photoOptions showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [imagePickerController setPreferredContentSize:CGSizeMake(320, 450)];
    
    
    if (buttonIndex == 0) {
        imagePickerController.allowsEditing = NO;
        imagePickerController.mediaTypes = @[(NSString *) kUTTypeImage];
    }else if(buttonIndex == 1){
        imagePickerController.allowsEditing = YES;
        imagePickerController.videoMaximumDuration = 15.0;
        imagePickerController.mediaTypes = @[(NSString *) kUTTypeMovie];
    }
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage])
    {
        tempattachimg = [info objectForKey:UIImagePickerControllerOriginalImage];
        NewAttachment = 0;
    }
    else if ([mediaType isEqualToString:@"public.movie"] || [mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        picker.videoQuality = UIImagePickerControllerQualityTypeMedium;
        picker.videoMaximumDuration = 0.15;
        NSURL *url = info[UIImagePickerControllerMediaURL];
        //editPhotview.videoURL = info[UIImagePickerControllerMediaURL];
        NSString *urlString = [url path];
        
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
        AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        NSError *err = NULL;
        CMTime time = CMTimeMake(1, 60);
        CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
        NSLog(@"err==%@, imageRef==%@", err, imgRef);

        tempvideoURL = url;
        tempvideoStr = urlString;
        tempattachimg = [[UIImage alloc] initWithCGImage:imgRef];
        NewAttachment = 1;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)updateattachmentpicApi:(UIImage *)image  completionBlock:(void (^)(BOOL result)) return_block{
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/attach_video_image.php"]];
    _request.shouldAttemptPersistentConnection   = NO;
    __unsafe_unretained ASIFormDataRequest *request = _request;
    
    NSData *img = UIImageJPEGRepresentation(image, 0.3f);
    NSString *imagestring = [Base64 encode:img];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addPostValue:imagestring forKey:@"photo"];
    [request addPostValue:[[NSUserDefaults standardUserDefaults]objectForKey:@"id" ] forKey:@"from_id"];
    [request addPostValue:self.userid forKey:@"to_id"];
    [request addPostValue:@"0" forKey:@"type"];
    [request startAsynchronous];
    request.timeOutSeconds = 40;
    [request setCompletionBlock:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSDictionary *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        if(root[@"id"] != nil){
            [attachments addObject:root[@"id"]];
        }
        NSLog(@"update Root final %@",root);
        
        return_block(TRUE);
    }];
    [request setFailedBlock:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSError *error=[request error];
        [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                        type:AJNotificationTypeRed
                                       title:error.localizedDescription
                             linedBackground:AJLinedBackgroundTypeDisabled
                                   hideAfter:4.0];
    }];
}

-(void)updateattachmentvideoApi:(NSString *)image  completionBlock:(void (^)(BOOL result)) return_block{
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/attach_video_image.php"]];
    _request.shouldAttemptPersistentConnection   = NO;
    __unsafe_unretained ASIFormDataRequest *request = _request;

    [request addRequestHeader:@"Content-Type" value:@"multipart/form-data"];
    [request addFile:tempvideoStr forKey:@"video"];
    [request addPostValue:image forKey:@"photo"];
    [request addPostValue:[[NSUserDefaults standardUserDefaults]objectForKey:@"id" ] forKey:@"from_id"];
    [request addPostValue:self.userid forKey:@"to_id"];
    [request addPostValue:@"1" forKey:@"type"];
    request.timeOutSeconds = 60;
    [request startAsynchronous];

    [request setCompletionBlock:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSDictionary *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        if(root[@"id"] != nil){
            [attachments addObject:[NSString stringWithFormat:@"%@v",root[@"id"]]];
        }
        NSLog(@"update Root %@",root);
        return_block(TRUE);
    }];
    
    [request setFailedBlock:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSError *error=[request error];
        [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                        type:AJNotificationTypeRed
                                       title:error.localizedDescription
                             linedBackground:AJLinedBackgroundTypeDisabled
                                   hideAfter:4.0];
    }];
}

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES,image);
                               } else{
                                   completionBlock(NO,nil);
                                   
                               }
                           }];
}

- (void)closeattachment:(MyTapGestureRecognizer *)gesture
{
    [gesture.hideimageview removeFromSuperview];
    [gesture.hideview removeFromSuperview];
    if(gesture.tempclickview){
        [gesture.tempclickview removeFromSuperview];
        gesture.tempclickview = nil;
    }
    if(gesture.hidescroll){
        [gesture.hidescroll removeFromSuperview];
        gesture.hidescroll = nil;
    }
    gesture.hideimageview = nil;
    gesture.hideview = nil;
    if(self.player){
        [self.player stop];
        self.player = nil;
    }
    [self showTabBar:self.tabBarController];
}

- (void)showattachment:(MyTapGestureRecognizer *)gesture
{
    [self hideTabBar:self.tabBarController];
    int gap = 256.0-viewText.frame.size.height;
    if(viewText.frame.origin.y + viewText.frame.size.height + 55 < [[UIScreen mainScreen] bounds].size.height){
        viewText.frame = CGRectMake(viewText.frame.origin.x, viewText.frame.origin.y+gap, viewText.frame.size.width, viewText.frame.size.height);
        tblview.frame = CGRectMake(tblview.frame.origin.x, tblview.frame.origin.y, tblview.frame.size.width, tblview.frame.size.height+gap);
    }
    [txtChatVIew resignFirstResponder];
    CGSize screensize = [UIScreen mainScreen].bounds.size;
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    view.userInteractionEnabled = YES;
    view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:view];
    if(gesture.mediatype == 0){
        if(gesture.attachimage){
            CGSize size =  gesture.attachimage.size;
            if(size.width < size.height*2){
                UIImageView *imageview = [[UIImageView alloc] init];
                [view addSubview:imageview];
                imageview.image = gesture.attachimage;
                CGRect mainrect;
                if((float)size.width / size.height == (float)screensize.width/screensize.height){
                    mainrect.origin = CGPointMake(0, 0);
                    mainrect.size = screensize;
                }else if((float)size.width / size.height > (float)screensize.width/screensize.height){
                    mainrect.size.width = screensize.width;
                    mainrect.size.height = (float)screensize.width*size.height/size.width;
                    mainrect.origin.x = 0;
                    mainrect.origin.y = (screensize.height-mainrect.size.height)/2;
                }else{
                    mainrect.size.height = screensize.height;
                    mainrect.size.width = (float)screensize.height*size.width/size.height;
                    mainrect.origin.x = (screensize.width-mainrect.size.width)/2;
                    mainrect.origin.y = 0;
                }
                imageview.frame = mainrect;
                
                MyTapGestureRecognizer *tapGestureRecognizer1 = [[MyTapGestureRecognizer alloc] initWithTarget:self action:@selector(closeattachment:)];
                tapGestureRecognizer1.hideimageview = imageview;
                tapGestureRecognizer1.hideview = view;
                imageview.userInteractionEnabled = YES;
                [imageview addGestureRecognizer:tapGestureRecognizer1];
                
                MyTapGestureRecognizer *tapGestureRecognizer2 = [[MyTapGestureRecognizer alloc] initWithTarget:self action:@selector(closeattachment:)];
                tapGestureRecognizer2.hideimageview = imageview;
                tapGestureRecognizer2.hideview = view;
                [view addGestureRecognizer:tapGestureRecognizer2];
            }else{
                __block UIImageView *pano = [[UIImageView alloc]init];
                [pano setBackgroundColor:[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0]];
                UIScrollView *landscapeScroll = [[UIScrollView alloc]initWithFrame:view.frame];

                pano.transform = CGAffineTransformMakeRotation(M_PI_2);
                [landscapeScroll setContentSize:CGSizeMake(320, gesture.attachimage.size.width*320/gesture.attachimage.size.height)];
                [pano setFrame:CGRectMake(0, 0, 320,gesture.attachimage.size.width*320/gesture.attachimage.size.height)];
                pano.image = gesture.attachimage;
                [landscapeScroll setBounces:NO];
                [landscapeScroll setScrollEnabled:YES];
                [landscapeScroll addSubview:pano];
                [view addSubview:landscapeScroll];
                
                MyTapGestureRecognizer *tapGestureRecognizer5 = [[MyTapGestureRecognizer alloc] initWithTarget:self action:@selector(closeattachment:)];
                tapGestureRecognizer5.hideimageview = pano;
                tapGestureRecognizer5.hideview = view;
                tapGestureRecognizer5.hidescroll = landscapeScroll;
                pano.userInteractionEnabled = YES;
                [pano addGestureRecognizer:tapGestureRecognizer5];
                
                MyTapGestureRecognizer *tapGestureRecognizer6 = [[MyTapGestureRecognizer alloc] initWithTarget:self action:@selector(closeattachment:)];
                tapGestureRecognizer6.hideimageview = pano;
                tapGestureRecognizer6.hideview = view;
                tapGestureRecognizer6.hidescroll = landscapeScroll;
                landscapeScroll.userInteractionEnabled = YES;
                [landscapeScroll addGestureRecognizer:tapGestureRecognizer6];
                
                MyTapGestureRecognizer *tapGestureRecognizer7 = [[MyTapGestureRecognizer alloc] initWithTarget:self action:@selector(closeattachment:)];
                tapGestureRecognizer7.hideimageview = pano;
                tapGestureRecognizer7.hideview = view;
                tapGestureRecognizer7.hidescroll = landscapeScroll;
                [view addGestureRecognizer:tapGestureRecognizer7];
            }
        }
        else{
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            UIImageView *imageview = [[UIImageView alloc] init];
            [view addSubview:imageview];
            [self downloadImageWithURL:[NSURL URLWithString:gesture.imageurl] completionBlock:^(BOOL succeeded, UIImage *image) {
                if (succeeded) {
                    imageview.image = image;
                    CGSize size =  image.size;
                    CGRect mainrect;
                    if((float)size.width / size.height > (float)screensize.width/screensize.height){
                        mainrect.origin = CGPointMake(0, 0);
                        mainrect.size = screensize;
                    }else if((float)size.width / size.height > (float)screensize.width/screensize.height){
                        mainrect.size.width = screensize.width;
                        mainrect.size.height = (float)screensize.width*size.width/size.height;
                        mainrect.origin.x = 0;
                        mainrect.origin.y = (screensize.height-mainrect.size.height)/2;
                    }else{
                        mainrect.size.height = screensize.height;
                        mainrect.size.width = (float)screensize.height*size.height/size.width;
                        mainrect.origin.x = (screensize.width-mainrect.size.width)/2;
                        mainrect.origin.y = 0;
                    }
                    imageview.frame = mainrect;
                }
                MyTapGestureRecognizer *tapGestureRecognizer3 = [[MyTapGestureRecognizer alloc] initWithTarget:self action:@selector(closeattachment:)];
                tapGestureRecognizer3.hideimageview = imageview;
                tapGestureRecognizer3.hideview = view;
                imageview.userInteractionEnabled = YES;
                [imageview addGestureRecognizer:tapGestureRecognizer3];
                
                MyTapGestureRecognizer *tapGestureRecognizer4 = [[MyTapGestureRecognizer alloc] initWithTarget:self action:@selector(closeattachment:)];
                tapGestureRecognizer4.hideimageview = imageview;
                tapGestureRecognizer4.hideview = view;
                [view addGestureRecognizer:tapGestureRecognizer4];
                
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }];
        }
    }else{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/get_attachment_extension.php"]];
        __unsafe_unretained ASIFormDataRequest *request = _request;
        
        [request addRequestHeader:@"Content-Type" value:@"application/json"];
        [request setPostValue:[NSString stringWithFormat:@"%d",gesture.videoid] forKey:@"attachment_id"];
        [request setPostValue:self.userid forKey:@"to_user_id"];
        
        [request startAsynchronous];
        [request setCompletionBlock:^{
            NSError *error;
            NSMutableDictionary *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
            if(root[@"extension"] != nil){
                self.player = [[MPMoviePlayerController alloc] init];
                self.player.controlStyle = MPMovieControlStyleNone;
                [self.player setScalingMode:MPMovieScalingModeAspectFill];
                CGRect rt;
                rt.size.width = screensize.width;
                rt.size.height = (float)screensize.width*450/320;
                rt.origin.x = 0;
                rt.origin.y = (screensize.height-rt.size.height)/2;
                [self.player.view setFrame:rt];
                self.player.movieSourceType = MPMovieSourceTypeStreaming;
                UIView *tempclickview = [[UIView alloc] initWithFrame:rt];
                
                NSString *videourl = gesture.imageurl;
                videourl = [videourl stringByReplacingOccurrencesOfString: @"attachment/" withString:@"attachment/video-"];
                videourl = [videourl stringByReplacingOccurrencesOfString: @"jpg" withString:root[@"extension"]];
                [self.player setContentURL:[NSURL URLWithString:videourl]];
                [self.player.view setHidden:YES];
                [self.player prepareToPlay];
                [view addSubview:self.player.view];
                [self.player play];
                [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayerPlayState:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:self.player];
                
                [view addSubview:tempclickview];
                MyTapGestureRecognizer *tapGestureRecognizer5 = [[MyTapGestureRecognizer alloc] initWithTarget:self action:@selector(closeattachment:)];
                tapGestureRecognizer5.hideimageview = (UIImageView*)self.player.view;
                tapGestureRecognizer5.hideview = view;
                tapGestureRecognizer5.tempclickview = tempclickview;
                
                tempclickview.userInteractionEnabled = YES;
                [tempclickview addGestureRecognizer:tapGestureRecognizer5];
                
                
                MyTapGestureRecognizer *tapGestureRecognizer6 = [[MyTapGestureRecognizer alloc] initWithTarget:self action:@selector(closeattachment:)];
                tapGestureRecognizer6.hideimageview = (UIImageView*)self.player.view;
                tapGestureRecognizer6.hideview = view;
                view.userInteractionEnabled = YES;
                [view addGestureRecognizer:tapGestureRecognizer6];
            }
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
        
        [request setFailedBlock:^{
            NSError *error=[request error];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                            type:AJNotificationTypeRed
                                           title:error.localizedDescription
                                 linedBackground:AJLinedBackgroundTypeDisabled
                                       hideAfter:5.0];
        }];
    }
    
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

- (void)hideTabBar:(UITabBarController *) tabbarcontroller
{
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

@end
