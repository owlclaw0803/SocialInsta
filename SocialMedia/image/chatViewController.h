//
//  chatViewController.h
//  SocialMedia
//
//  Created by PARMARTH MORI on 03/07/14.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "MyTapGestureRecognizer.h"
#import <MediaPlayer/MediaPlayer.h>

@interface chatViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>
{
    IBOutlet UITableView *tblview;
    IBOutlet UILabel *lblUserName;
    IBOutlet UITextField *txtChatVIew;
    IBOutlet AsyncImageView *userImage;
    IBOutlet UIView *viewText;

    __weak IBOutlet UIImageView *msgborder;
    int attachmentcount;
    
    NSMutableArray *chatMutArray;
    int user_Chatid;
    NSTimer *timer;
    
    UIImage *tempattachimg;
    
    NSURL *tempvideoURL;
    NSString *tempvideoStr;
    int NewAttachment;
    
    NSMutableArray *attachments;
    NSMutableArray *img_attachments;
    NSMutableArray *btn_attachments;
    
    BOOL bFirst;
}

@property(strong,nonatomic)NSString *userid;
@property(strong,nonatomic)NSString *username;

- (IBAction)postSend:(id)sender;
-(void)GetPostedMsz:(NSString *)userid completionBlock:(void (^)(BOOL result)) return_block;
-(void)getpost;
-(void)SendMsz:(NSString *)userid completionBlock:(void (^)(BOOL result)) return_block;
- (IBAction)backClick:(id)sender;
- (void)gotoProfilePage:(MyTapGestureRecognizer *)gesture;
- (IBAction)attachmentfile:(id)sender;
-(void)updateattachmentpicApi:(UIImage *)image  completionBlock:(void (^)(BOOL result)) return_block;
-(void)updateattachmentvideoApi:(NSString *)image  completionBlock:(void (^)(BOOL result)) return_block;

- (void)showattachment:(MyTapGestureRecognizer *)gesture;
- (void)closeattachment:(MyTapGestureRecognizer *)gesture;

- (void)showTabBar:(UITabBarController *) tabbarcontroller;
- (void)hideTabBar:(UITabBarController *) tabbarcontroller;
-(UIImage*) makeImageSmaller:(UIImage*)image;

@property(nonatomic,strong) MPMoviePlayerController *player;
@property (strong, nonatomic)    UIActionSheet *photoOptions;
@end
