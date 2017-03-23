//
//  HomeViewController.h
//  SocialMedia
//
//  Created by PARMARTH MORI on 02/07/14.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileViewController.h"
#import <Social/Social.h>
#import "CommntViewController.h"
#import "SerchViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "PhotoDescriptionViewController.h"
#import "UITabBarController+hidable.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "MyTapGestureRecognizer.h"

@interface HomeViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIDocumentInteractionControllerDelegate,AVAudioPlayerDelegate,UITabBarControllerDelegate>
{
    IBOutlet UITableView *tblview;
    UIView *landscapeView;
    int indexpath;
    NSMutableArray *heights;
    CGFloat startContentOffset;
    CGFloat lastContentOffset;
    BOOL hidden;
    BOOL isMoreHidden;
    BOOL isComment;
    IBOutlet UIView *hederview;
    int refreshcell;
}
@property(strong,nonatomic)NSMutableArray *mutTimeline;
@property(nonatomic,retain)UIDocumentInteractionController *doc;
@property (strong, nonatomic) UIActionSheet *actionSheetCurrentUser;
@property (strong, nonatomic) UIActionSheet *actionSheetOtherUser;
@property (strong, nonatomic) UIActionSheet *actionSheetProfile;
@property (strong, nonatomic) UIImagePickerController *imagePickerConteroller;
@property(nonatomic,strong)MPMoviePlayerController *player;

-(void)LikeApicall:(NSString *)imageID completionBlock:(void (^)(BOOL result)) return_block;
-(void)postDelete:(NSString *)imageID completionBlock:(void (^)(BOOL result)) return_block;
-(void)LoadMore:(NSString *)postID completionBlock:(void (^)(BOOL result)) return_block;

- (IBAction)serch:(id)sender;
- (IBAction)profile:(id)sender;
- (IBAction)CommentExpand:(id)sender;
- (IBAction)BackViewExpand:(id)sender;
- (IBAction)btnScrollTop:(id)sender;
- (void)HidePhotoView;
- (void)gotoProfilePage:(MyTapGestureRecognizer *)gesture;
- (void)CommentLabelClicked:(MyTapGestureRecognizer *)gesture;
- (BOOL)ptInRect:(CGPoint)pt withRect:(CGRect)rt;
- (NSMutableArray*)getHashUsernameRange:(NSString*)str;

@property (weak, nonatomic) IBOutlet UIButton *m_searchbtn;
@property (weak, nonatomic) IBOutlet UIImageView *m_logoimg;
@property (weak, nonatomic) IBOutlet UIButton *m_userbtn;

@end
