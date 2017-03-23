//
//  TabbarControllerViewController.m
//  SocialMedia
//
//  Created by PARMARTH MORI on 01/07/14.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import "TabbarControllerViewController.h"
#import "SnapChatViewController.h"

@interface TabbarControllerViewController ()

@end

@implementation TabbarControllerViewController


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
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"VideoPath"];
    
    self.view.layer.zPosition = 99;
    isopen = YES;
    isVideoRecording = NO;
    self.delegate=self;
    
    //self.tabBar.frame=CGRectMake(0, 528, 320, 60);
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGSize sizetemp = self.tabBar.frame.size;

    self.tabBar.frame = CGRectMake(0, size.height-sizetemp.height+3, 320, sizetemp.height);
    self.tabBar.barStyle = UIBarStyleDefault;
    //self.tabBar.translucent=YES;
    
    self.tabBar.alpha=1.0;
    self.tabBar.layer.borderWidth = 0.0;
    self.tabBar.layer.zPosition = 99;
    for (UITabBarItem *item in self.tabBar.items) {
        if (item.tag == 1) {
            [item setFinishedSelectedImage:[[UIImage imageNamed:@"tab_home_dark"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]  withFinishedUnselectedImage:[[UIImage imageNamed:@"tab_home_light"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        } else if (item.tag == 2) {
            [item setFinishedSelectedImage:[[UIImage imageNamed:@"tab_explore_dark"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] withFinishedUnselectedImage:[[UIImage imageNamed:@"tab_explore_light"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        } else if (item.tag == 3) {
            [item setFinishedSelectedImage:[[UIImage imageNamed:@"tab_camera_dark"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] withFinishedUnselectedImage:[[UIImage imageNamed:@"tab_camera_light"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        } else if(item.tag == 4){
            [item initWithTitle:@"" image:[[UIImage imageNamed:@"tab_notification_light"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tab_notification_dark"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        }
        else if (item.tag == 5)
        {
            [item initWithTitle:@"" image:[[UIImage imageNamed:@"tab_coments_light"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tab_coments_dark"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        }
        [item setImageInsets:UIEdgeInsetsMake(4, 0, -4, 0)];
    }

    CGRect rt = self.tabBar.frame;
    btnForCamera = [[UIButton alloc] initWithFrame:CGRectMake(rt.size.width/2-32, 0, 64, rt.size.height)];
    [btnForCamera setBackgroundColor:[UIColor clearColor]];
    //[btnForCamera setBackgroundImage:[UIImage imageNamed:@"tab_camera_light"] forState:UIControlStateNormal];
    [self.tabBar addSubview:btnForCamera];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onclickPhoto:)];
    [btnForCamera addGestureRecognizer:tapRecognizer];
    
    btnview = [[UIView alloc] init];
    [btnview setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1.0]];

    Photos = [[UIButton alloc] initWithFrame:CGRectMake(49, 20, 37, 44)];
    [Photos setBackgroundImage:[UIImage imageNamed:@"btnphoto@2x.png"] forState:UIControlStateNormal];
    UITapGestureRecognizer *tapRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photos:)];
    [Photos addGestureRecognizer:tapRecognizer1];
    
    video = [[UIButton alloc] initWithFrame:CGRectMake(176, 20, 37, 44)];
    [video setBackgroundImage:[UIImage imageNamed:@"btnvideo@2x.png"] forState:UIControlStateNormal];
    UITapGestureRecognizer *tapRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(video:)];
    [video addGestureRecognizer:tapRecognizer2];
    
    panaroma = [[UIButton alloc] initWithFrame:CGRectMake(32, 102, 70, 43)];
    [panaroma setBackgroundImage:[UIImage imageNamed:@"panaroma@2x.png"] forState:UIControlStateNormal];
    UITapGestureRecognizer *tapRecognizer3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(panaroma:)];
    [panaroma addGestureRecognizer:tapRecognizer3];
    
    snapChat = [[UIButton alloc] initWithFrame:CGRectMake(169, 102, 50, 46)];
    [snapChat setBackgroundImage:[UIImage imageNamed:@"QuickSnap.png"] forState:UIControlStateNormal];
    UITapGestureRecognizer *tapRecognizer4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(snapchat:)];
    [snapChat addGestureRecognizer:tapRecognizer4];
    
    bgImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 260, 2)];
    [bgImage setImage:[UIImage imageNamed:@"background_@2x.png"]];
    
    [btnview addSubview:bgImage];
    [btnview addSubview:Photos];
    [btnview addSubview:video];
    [btnview addSubview:panaroma];
    [btnview addSubview:snapChat];
    [self.view addSubview:btnview];
    btnview.layer.zPosition = 50;
    btnview.frame = CGRectMake(30, [UIScreen mainScreen].bounds.size.height-45, 260, 0);
    [btnview setHidden:YES];
    
    _photoOptions = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Dismiss" destructiveButtonTitle:nil otherButtonTitles:@"Camera",@"Album", nil];
    _photoOptions.tag = 0;
    _photoOptions.delegate = self;
    
    _videosOptions = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Dismiss" destructiveButtonTitle:nil otherButtonTitles:@"Camera",@"Album", nil];
    _videosOptions.tag = 2;
    _videosOptions.delegate = self;
    
    _panoramaOptions = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Dismiss" destructiveButtonTitle:nil otherButtonTitles:@"Take New Panorama",@"Choose From Library", nil];
    _panoramaOptions.tag = 1;
    _panoramaOptions.delegate = self;
    
    _imagePickerController = [[UIImagePickerController alloc]init];
    _imagePickerController.delegate = self;
    
    panoramaImagePicker = [[CRVPanoramaImagePicker alloc] init];
    [panoramaImagePicker setDisablePortraitImages:YES];
    [panoramaImagePicker setGotPanoramaImage:^(UIImage * image) {
        NSLog(@"Got the image: %@", image);
        //        [selectedImage setImage:image];
        editPhotview = [self.storyboard instantiateViewControllerWithIdentifier:@"editphoto"];
        self.hidesBottomBarWhenPushed=NO;
        
        if (image)
        {
            editPhotview.imageObj = image;
            editPhotview.aBoolpano = YES;
        }
        // [self dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController pushViewController:editPhotview animated:YES];
        [self dismissViewControllerAnimated:YES completion:NULL];
        // [self setSelectedIndex:3];
    }];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    
    NSString *stringUrl = [[NSUserDefaults standardUserDefaults] valueForKey:@"VideoPath"];
    if (stringUrl.length>0 && isVideoRecording==YES) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:ApplicationDelegate.storyboardname bundle:nil];
        editPhotview = [storyboard instantiateViewControllerWithIdentifier:@"editphoto"];
        self.hidesBottomBarWhenPushed = NO;
        
        editPhotview.videoURL = [NSURL URLWithString:stringUrl];
        editPhotview.videoStr = stringUrl;
        editPhotview.videoImage = [self loadImagewithURL:[NSURL URLWithString:stringUrl]];
        
        [btnview setHidden:YES];
        btnview.frame = CGRectMake(30, [UIScreen mainScreen].bounds.size.height-46, 260, 0);
        isopen = YES;
        isVideoRecording = NO;
        [ApplicationDelegate.navigationController pushViewController:editPhotview animated:YES];
    }
}

-(void)onclickPhoto:(UIGestureRecognizer *)gr
{
    if (isopen==YES)
    {
        //        tbController
        //        = [tbController.viewControllers objectAtIndex:2];
        //[self setSelectedIndex:2];
        [btnview setHidden:NO];
        [UIView animateWithDuration:0.0 animations:^{
            btnview.frame = CGRectMake(30, [UIScreen mainScreen].bounds.size.height-46-160, 260, 160);
        }];
        isopen = NO;
    }
    else{
        //        tbController
        //        = [tbController.viewControllers objectAtIndex:0];
        //[self setSelectedIndex:0];
        [UIView animateWithDuration:0.0 animations:^{
            btnview.frame = CGRectMake(30, [UIScreen mainScreen].bounds.size.height-46, 260, 0);
        }completion:^(BOOL finished){
            [btnview setHidden:YES];
        }];
        isopen = YES;
    }
}

- (void)tabBarController:(UITabBarController *)tbController didSelectViewController:(UIViewController *)viewController {
    if (viewController == [tbController.viewControllers objectAtIndex:0])
    {
        isopen = YES;
    }
    if (viewController != [tbController.viewControllers objectAtIndex:2])
    {
        [btnview setHidden:YES];
        btnview.frame = CGRectMake(30, [UIScreen mainScreen].bounds.size.height-46, 260, 0);
        isopen = YES;
    }
    if ([viewController isKindOfClass:[UINavigationController class]])
    {
        [(UINavigationController *)viewController popToRootViewControllerAnimated:NO];
    }
}

-(void)hidePhotoView
{
    [btnview setHidden:YES];
    btnview.frame = CGRectMake(30, [UIScreen mainScreen].bounds.size.height-46, 260, 0);
    isopen = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)panaroma:(UIGestureRecognizer *)gr {
    isVideoRecording = NO;
    [btnview setHidden:YES];
    btnview.frame = CGRectMake(30, [UIScreen mainScreen].bounds.size.height-46, 260, 0);
    isopen=YES;
    [self presentViewController:panoramaImagePicker animated:YES completion:nil];
    //[_panoramaOptions showInView:self.view];
//    [btnview setHidden:YES];
//    btnview.frame = CGRectMake(30, [UIScreen mainScreen].bounds.size.height-46, 260, 0);
//    isopen=YES;
//    [self presentViewController:panoramaImagePicker animated:YES completion:nil];
}

- (void)video:(UIGestureRecognizer *)gr {
    [_videosOptions showInView:self.view];
}

- (void)photos:(UIGestureRecognizer *)gr {
    [_photoOptions showInView:self.view];
}

- (void)snapchat:(UIGestureRecognizer *)gr {
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        return;
    }
    _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    [_imagePickerController setPreferredContentSize:CGSizeMake(320, 450)];
    _imagePickerController.mediaTypes = @[(NSString *) kUTTypeImage];
    _imagePickerController.allowsEditing = NO;
    [btnview setHidden:YES];
    btnview.frame = CGRectMake(30, [UIScreen mainScreen].bounds.size.height-46, 260, 0);
    isopen=YES;
    CameraType = 2;
    [self presentViewController:_imagePickerController animated:YES completion:nil];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet.tag==0) {
        isVideoRecording = NO;
        if (buttonIndex == 0) {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                [_imagePickerController setPreferredContentSize:CGSizeMake(320, 450)];
                _imagePickerController.mediaTypes = @[(NSString *) kUTTypeImage];
                _imagePickerController.allowsEditing = NO;
                [btnview setHidden:YES];
                btnview.frame = CGRectMake(30, [UIScreen mainScreen].bounds.size.height-46, 260, 0);
                isopen=YES;
                [self presentViewController:_imagePickerController animated:YES completion:nil];
            }
            
            else{
                UIAlertView *alt = [[UIAlertView alloc]initWithTitle:@"Camera" message:@"Camera is Not Available" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                [alt show];
            }
        }
        
        if (buttonIndex == 1){
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [_imagePickerController setPreferredContentSize:CGSizeMake(320, 450)];
                _imagePickerController.mediaTypes = @[(NSString *) kUTTypeImage];
                _imagePickerController.allowsEditing = NO;
                [btnview setHidden:YES];
                btnview.frame = CGRectMake(30, [UIScreen mainScreen].bounds.size.height-46, 260, 0);
                isopen=YES;
                CameraType = 1;
                [self presentViewController:_imagePickerController animated:YES completion:nil];
            }
        }
    }
    else if (actionSheet.tag==1) {
        /*isVideoRecording = NO;
        if (buttonIndex == 0) {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                [_imagePickerController setPreferredContentSize:CGSizeMake(500, 450)];
                _imagePickerController.mediaTypes = @[(NSString *) kUTTypeImage, (NSString *) kUTTypeMovie];
                _imagePickerController.allowsEditing = NO;
                [self presentViewController:_imagePickerController animated:YES completion:nil];
            }
            
            else{
                UIAlertView *alt=[[UIAlertView alloc]initWithTitle:@"Camera" message:@"Camera is Not Available" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                [alt show];
            }
        }
        
        if (buttonIndex == 1) {
                [btnview setHidden:YES];
                btnview.frame = CGRectMake(30, [UIScreen mainScreen].bounds.size.height-46, 260, 0);
                isopen=YES;
                [self presentViewController:panoramaImagePicker animated:YES completion:nil];
            //[self presentViewController:panoramaImagePicker animated:YES completion:nil];
        }*/
    }
    else {
        if (buttonIndex == 0) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:ApplicationDelegate.storyboardname bundle:nil];
            recordVideo = [storyboard instantiateViewControllerWithIdentifier:@"record"];
            self.hidesBottomBarWhenPushed = NO;
            [btnview setHidden:YES];
            btnview.frame = CGRectMake(30, [UIScreen mainScreen].bounds.size.height-46, 260, 0);
            isopen = YES;
            [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"VideoPath"];
            isVideoRecording = YES;
            [self presentViewController:recordVideo animated:YES completion:NULL];
            //[ApplicationDelegate.navigationController pushViewController:recordVideo animated:YES];
        }
        
        else if (buttonIndex == 1) {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [_imagePickerController setPreferredContentSize:CGSizeMake(320, 450)];
                _imagePickerController.mediaTypes = @[(NSString *) kUTTypeMovie];
                _imagePickerController.allowsEditing = YES;
                _imagePickerController.videoMaximumDuration = 15.0;
                isVideoRecording = NO;
                [self presentViewController:_imagePickerController animated:YES completion:nil];
            }
        }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    if(CameraType == 1) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:ApplicationDelegate.storyboardname bundle:nil];
        editPhotview = [storyboard instantiateViewControllerWithIdentifier:@"editphoto"];
        self.hidesBottomBarWhenPushed = NO;
    
        if (image)
        {
            CGFloat imageWidth = image.size.width;
            //CGFloat imageHeight = image.size.height;
            if (imageWidth > 500) {
                editPhotview.aBoolpano = YES;
            }
            editPhotview.imageObj = image;
        }
    
        [btnview setHidden:YES];
        btnview.frame = CGRectMake(30, [UIScreen mainScreen].bounds.size.height-46, 260, 0);
        isopen = YES;
        [ApplicationDelegate.navigationController pushViewController:editPhotview animated:YES];
        //[self setSelectedIndex:2];
    } else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:ApplicationDelegate.storyboardname bundle:nil];
        SnapChatViewController *snapchatview = [storyboard instantiateViewControllerWithIdentifier:@"snapchatview"];
        self.hidesBottomBarWhenPushed = NO;
        
        if (image)
        {
            snapchatview.capturedimage = image;
        }
        
        [btnview setHidden:YES];
        btnview.frame = CGRectMake(30, [UIScreen mainScreen].bounds.size.height-46, 260, 0);
        isopen = YES;
        [ApplicationDelegate.navigationController pushViewController:snapchatview animated:YES];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    UIImage *aImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    CGFloat imageWidth = aImage.size.width;
    
    if(CameraType == 2){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:ApplicationDelegate.storyboardname bundle:nil];
        SnapChatViewController *snapchatview = [storyboard instantiateViewControllerWithIdentifier:@"snapchatview"];
        self.hidesBottomBarWhenPushed = NO;
        
        if ([mediaType isEqualToString:(NSString *)kUTTypeImage])
        {
            snapchatview.capturedimage = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        
        [btnview setHidden:YES];
        btnview.frame = CGRectMake(30, [UIScreen mainScreen].bounds.size.height-46, 260, 0);
        isopen = YES;
        [ApplicationDelegate.navigationController pushViewController:snapchatview animated:YES];
        return;
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:ApplicationDelegate.storyboardname bundle:nil];
    editPhotview = [storyboard instantiateViewControllerWithIdentifier:@"editphoto"];
    self.hidesBottomBarWhenPushed = NO;
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage])
    {
        editPhotview.imageObj = [info objectForKey:UIImagePickerControllerOriginalImage];
        
    }
    else if ([mediaType isEqualToString:@"public.movie"] || [mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        picker.videoQuality = UIImagePickerControllerQualityTypeMedium;
		picker.videoMaximumDuration = 0.15;
        NSURL *url = info[UIImagePickerControllerMediaURL];
        //editPhotview.videoURL = info[UIImagePickerControllerMediaURL];
        NSString *urlString = [url path];
        
        editPhotview.videoURL = url;
        editPhotview.videoStr = urlString;
        editPhotview.videoImage = [self loadImagewithURL:url];
    }
    
    [btnview setHidden:YES];
    btnview.frame = CGRectMake(30, [UIScreen mainScreen].bounds.size.height-46, 260, 0);
    isopen = YES;
    [ApplicationDelegate.navigationController pushViewController:editPhotview animated:YES];
    //[self setSelectedIndex:2];
}

- (UIImage*)loadImagewithURL:(NSURL *)vidURL {
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:vidURL options:nil];
    AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    NSError *err = NULL;
    CMTime time = CMTimeMake(1, 60);
    CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
    NSLog(@"err==%@, imageRef==%@", err, imgRef);
    
    return [[UIImage alloc] initWithCGImage:imgRef];
}

@end
