//
//  TabbarControllerViewController.h
//  SocialMedia
//
//  Created by PARMARTH MORI on 01/07/14.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AVFoundation/AVFoundation.h>
#import "EditPhotoViewController.h"
#import "CRVPanoramaImagePicker.h"
#import "RecordVideoViewController.h"

@interface TabbarControllerViewController : UITabBarController<UITabBarDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UITabBarControllerDelegate>
{
    BOOL isopen;
//    UIView *view;
//    UIImagePickerController *imagepiker;
//    UIActionSheet *actionSheet;
//    EditPhotoViewController *editPhotview;
//    CRVPanoramaImagePicker *panoramaImagePicker;
    UIView *btnview;
    UIButton *panaroma;
    UIButton *video;
    UIButton *Photos;
    UIButton *snapChat;
    UIButton *btnForCamera;
    UIImageView *bgImage;
    
    BOOL isVideoRecording;
    
    int CameraType;
    EditPhotoViewController     *editPhotview;
    RecordVideoViewController   *recordVideo;
    CRVPanoramaImagePicker      *panoramaImagePicker;
}

-(void)onclickPhoto:(UIGestureRecognizer *)gr;
////@property (strong, nonatomic) CRVPanoramaImagePicker *panoramaImagePicker;
//@property (nonatomic) BOOL hasPresentedImagePicker;

- (void)panaroma:(UIGestureRecognizer *)gr;
- (void)video:(UIGestureRecognizer *)gr;
- (void)photos:(UIGestureRecognizer *)gr;
- (void)snapchat:(UIGestureRecognizer *)gr;

@property (strong, nonatomic)    UIActionSheet *photoOptions;
@property (strong, nonatomic)    UIActionSheet *videosOptions;
@property (strong, nonatomic)    UIActionSheet *panoramaOptions;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;

@property(strong,nonatomic)NSString *strExtension;

-(void)hidePhotoView;

@end
