//
//  RecordVideoViewController.m
//  SocialMedia
//
//  Created by Khalid  on 29/10/2014.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import "RecordVideoViewController.h"
#import "KZCameraView.h"

@interface RecordVideoViewController ()

@property (nonatomic, strong) KZCameraView *cam;

@end

@implementation RecordVideoViewController

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
    
    //Create CameraView
	self.cam = [[KZCameraView alloc]initWithFrame:CGRectMake(0.0, 70.0, self.view.frame.size.width, self.view.frame.size.height - 70.0) withVideoPreviewFrame:CGRectMake(0.0, 70.0, self.view.frame.size.width, self.view.frame.size.height - 70.0)];
    self.cam.maxDuration = 15.0;
    self.cam.showCameraSwitch = YES; //Say YES to button to switch between front and back cameras
    
    [self.view addSubview:self.cam];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (IBAction)back:(id)sender {
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"VideoPath"];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)saveVideo:(id)sender {
    [self.cam saveVideoWithCompletionBlock:^(BOOL success) {
        if (success)
        {
            [self dismissViewControllerAnimated:YES completion:NULL];
            //[self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

@end
