//
//  ProfileViewController.h
//  SocialMedia
//
//  Created by PARMARTH MORI on 02/07/14.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Base64.h"
#import "chatViewController.h"
#import "CommntViewController.h"
#import "SerchViewController.h"
#import "SocialSettingViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MapviewViewController.h"
#import "AsyncImageView.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "MyTapGestureRecognizer.h"
#import "WebsiteViewController.h"

@class GKImagePicker;

@interface ProfileViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIDocumentInteractionControllerDelegate,AVAudioPlayerDelegate,UIAlertViewDelegate>
{
    IBOutlet UIImageView    *userImageview;
    IBOutlet UIImageView    *coverpageImage;
    IBOutlet UIImageView    *privateProfileImageView;

    IBOutlet UIButton   *btnCollection;
    IBOutlet UIButton   *btnsettings;
    IBOutlet UIButton   *lblWebsite;
    IBOutlet UIButton   *followButton;
    IBOutlet UIButton   *btntable;
    IBOutlet UIView     *hederview;
    IBOutlet UILabel    *lblProfileName;
    IBOutlet UIView     *btnCollectionview;
    
    UIView      *landscapeView;

    //__weak IBOutlet UIImageView *coverPhoto;
    
    IBOutlet UIButton   *serch1;
    IBOutlet UIButton   *btnmsz;
    IBOutlet UIButton   *btnFollowRequest;
    
    IBOutlet UIView *viewHederNavigation;
    IBOutlet UIView *myviewHederNavigation;
    IBOutlet UITableView *tblview;
    IBOutlet UILabel *lblAboutMe;
    IBOutlet UILabel *lblLIkes;
    IBOutlet UILabel *Following;
    IBOutlet UILabel *lblFollower;
    IBOutlet UILabel *lblPost;
    
    NSMutableArray      *followersArray;
    NSMutableArray      *followersPendingArray;
    NSMutableArray      *followingArray;
    NSMutableArray      *followingPendingArray;
    
    int indexpath;
    
    NSString *deleteImageId;
    NSString *privateProfile;
    UIImage *shareimage;
    CGFloat lastContentOffset;
    
    NSMutableArray *heights; CGFloat startContentOffset;
    NSMutableString *coverString;
    
    BOOL hidden;
    BOOL coverphoto;
    BOOL isMyProfile;
    
    BOOL isPhotoFromLibrary;
    BOOL isCoverPhoto;
    BOOL isComment;
}

- (IBAction)serch1:(id)sender;
- (IBAction)settings:(id)sender;
- (IBAction)serch:(id)sender;
- (IBAction)switchController:(id)sender;
- (IBAction)GoToMsz:(id)sender;
- (IBAction)callection:(id)sender;
- (IBAction)tableview:(id)sender;
- (IBAction)mapview:(id)sender;
- (IBAction)btnProfileScrollTop:(id)sender;
- (IBAction)btnFollowRequestClicked:(id)sender;

@property(nonatomic,strong)MPMoviePlayerController *player;
@property (nonatomic, retain) UIImage *croppedPhoto;
@property(strong,nonatomic)NSMutableArray *picMutArray;
@property(strong,nonatomic)NSString *userId;
@property(strong,nonatomic)NSMutableArray *mutArrayProfileImages;
@property(strong,nonatomic)NSMutableDictionary *mutDictProfileInfo;
@property (strong, nonatomic) UIActionSheet *actionShare;
@property (strong, nonatomic) UIActionSheet *profilePicAction;
@property (strong, nonatomic) UIActionSheet *changeCoverPicAction;
@property (strong, nonatomic) UIActionSheet *profileCoverPicAction;
@property (strong, nonatomic) UIImagePickerController *imagePickerObj;
@property(strong,nonatomic) UIDocumentInteractionController *doc;

-(void)LikeApicall:(NSString *)imageID completionBlock:(void (^)(BOOL result)) return_block;
-(void)postDelete:(NSString *)imageID completionBlock:(void (^)(BOOL result)) return_block;
-(void)updateprofilepicApi:(NSString *)image  completionBlock:(void (^)(BOOL result)) return_block;
-(void)handleTapFrom:(UITapGestureRecognizer *)gesture;
- (IBAction)CommentExpand:(id)sender;
- (IBAction)BackViewExpand:(id)sender;
- (IBAction)pushImageDescription:(id)sender;
-(void)HidePhotoView;
- (void)gotoProfilePage:(MyTapGestureRecognizer *)gesture;
- (void)CommentLabelClicked:(MyTapGestureRecognizer *)gesture;
- (NSMutableArray*)getHashUsernameRange:(NSString*)str;
@end
