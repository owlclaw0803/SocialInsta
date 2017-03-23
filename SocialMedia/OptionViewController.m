//
//  OptionViewController.m
//  SocialMedia
//
//  Created by PARMARTH MORI on 15/07/14.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import "OptionViewController.h"

@interface OptionViewController ()

@end

@implementation OptionViewController

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
    
    _photoOptions = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Dismiss" destructiveButtonTitle:nil otherButtonTitles:@"Camera",@"Album", nil];
    _photoOptions.tag = 0;
    _photoOptions.delegate = self;
    
    _panoramaOptions = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Dismiss" destructiveButtonTitle:nil otherButtonTitles:@"Take New Panorama",@"Choose From Library", nil];
    _panoramaOptions.tag = 1;
    _panoramaOptions.delegate = self;
    
    _imagePickerController=[[UIImagePickerController alloc]init];
    _imagePickerController.delegate=self;
    
    panoramaImagePicker = [[CRVPanoramaImagePicker alloc] init];
    [panoramaImagePicker setDisablePortraitImages:YES];
    [panoramaImagePicker setGotPanoramaImage:^(UIImage * image) {
        NSLog(@"Got the image: %@", image);
        //        [selectedImage setImage:image];
        editPhotview = [self.storyboard
                        instantiateViewControllerWithIdentifier:@"editphoto"];
        self.hidesBottomBarWhenPushed=NO;
        
        if (image)
        {
            editPhotview.imageObj=image;
            editPhotview.aBoolpano=YES;
        }
        // [self dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController pushViewController:editPhotview animated:YES];
        [self dismissViewControllerAnimated:YES completion:NULL];
        // [self setSelectedIndex:3];
    }];


	// Do any additional setup after loading the view.
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
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [video setFrame:CGRectMake(100, [UIScreen mainScreen].bounds.size.height, 46, 30)];
    [panaroma setFrame:CGRectMake(100, [UIScreen mainScreen].bounds.size.height, 46, 30)];
    
    [Photos setFrame:CGRectMake(100, [UIScreen mainScreen].bounds.size.height, 46, 30)];
    
    [UIView animateWithDuration:0.5 animations:^{
        
        [video setFrame:CGRectMake(38, [UIScreen mainScreen].bounds.size.height-110, 66, 43)];
        [panaroma setFrame:CGRectMake(115, [UIScreen mainScreen].bounds.size.height-178, 85, 43)];
        
        [Photos setFrame:CGRectMake(216, [UIScreen mainScreen].bounds.size.height-110, 66, 43)];
    }];
}

-(void)viewDidLayoutSubviews:(BOOL)animated{
    
    
    [panaroma setFrame:CGRectMake(66, 379, 46, 30)];
    [video setFrame:CGRectMake(191, 379, 46, 30)];
    [Photos setFrame:CGRectMake(42, 443, 46, 30)];
    
    [UIView animateWithDuration:0.5 animations:^{

        [panaroma setFrame:CGRectMake(60, [UIScreen mainScreen].bounds.size.height, 46, 30)];
        [video setFrame:CGRectMake(60, [UIScreen mainScreen].bounds.size.height, 46, 30)];
        [Photos setFrame:CGRectMake(60, [UIScreen mainScreen].bounds.size.height, 46, 30)];

    }];
}

- (IBAction)panaroma:(id)sender {
    [_panoramaOptions showInView:self.view];
}

- (IBAction)video:(id)sender {
    [_photoOptions showInView:self.view];
//    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
//        return;
//    }
//    
//    _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
//    _imagePickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
//    _imagePickerController.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
//    _imagePickerController.delegate = self;
//    
//    [self.navigationController presentViewController:_imagePickerController animated:YES completion:NULL];
}

- (IBAction)photos:(id)sender {
    [_photoOptions showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet.tag==0) {
        if (buttonIndex == 0) {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                [_imagePickerController setPreferredContentSize:CGSizeMake(320, 450)];
                //[_imagePickerController setContentSizeForViewInPopover:CGSizeMake(320,320)];
                //imagePickerController.sourceType=UIImagePickerControllerCameraCaptureModeVideo;
                _imagePickerController.mediaTypes = @[(NSString *) kUTTypeImage, (NSString *) kUTTypeMovie];
                _imagePickerController.allowsEditing = NO;
                [self presentViewController:_imagePickerController animated:YES completion:nil];
            }
            
            else{
                UIAlertView *alt=[[UIAlertView alloc]initWithTitle:@"Camera" message:@"Camera is Not Available" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                [alt show];
            }
        }
        
        if (buttonIndex == 1){
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [_imagePickerController setPreferredContentSize:CGSizeMake(320, 450)];
                _imagePickerController.mediaTypes = @[(NSString *) kUTTypeImage];
                _imagePickerController.allowsEditing = NO;
                _imagePickerController.allowsImageEditing = NO;
                [self presentViewController:_imagePickerController animated:YES completion:nil];
            }
        }
    }
    else {
        
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
            [self presentViewController:panoramaImagePicker animated:YES completion:nil];
        }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{

    [self dismissViewControllerAnimated:YES completion:nil];
    
    //UIStoryboard *storyboard = self.navigationController.storyboard;
    editPhotview = [self.storyboard instantiateViewControllerWithIdentifier:@"editphoto"];
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
    [self.navigationController pushViewController:editPhotview animated:YES];
    //[self setSelectedIndex:2];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    UIStoryboard *storyboard = self.navigationController.storyboard;
    editPhotview = [storyboard instantiateViewControllerWithIdentifier:@"editphoto"];
    self.hidesBottomBarWhenPushed = NO;
    
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    UIImage *aImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    CGFloat imageWidth = aImage.size.width;
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage])
    {
        //if (imageWidth > 500) {
        //    editPhotview.aBoolpano = YES;
        //}
        editPhotview.imageObj = [info objectForKey:UIImagePickerControllerOriginalImage];
        
    }
    else if ([mediaType isEqualToString:@"public.movie"])
    {
        picker.videoQuality = UIImagePickerControllerQualityTypeMedium;
		picker.videoMaximumDuration = 0.15;
        NSURL *url = info[UIImagePickerControllerMediaURL];
        editPhotview.videoURL = info[UIImagePickerControllerMediaURL];
        NSString *urlString=[url path];
        AVAsset *asset = [AVAsset assetWithURL:url];
        
        //  Get thumbnail at the very start of the video
        CMTime thumbnailTime = [asset duration];
        thumbnailTime.value = 0;
        
        //  Get image from the video at the given time
        AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        
        CGImageRef imageRef = [imageGenerator copyCGImageAtTime:thumbnailTime actualTime:NULL error:NULL];
        UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
        CIImage *ciImage = [[CIImage alloc] initWithCGImage:thumbnail.CGImage options:nil];
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI/2);
        ciImage = [ciImage imageByApplyingTransform:transform];
        UIImage *screenfxImage = [UIImage imageWithCIImage:ciImage];
        CGImageRelease(imageRef);
        
        editPhotview.videoURL = url;
        editPhotview.videoStr = urlString;
        editPhotview.videoImage = screenfxImage;
    }

    [self.navigationController pushViewController:editPhotview animated:YES];
    //[self setSelectedIndex:2];
}

@end
