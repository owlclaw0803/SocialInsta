//
//  MapviewViewController.m
//  SocialMedia
//
//  Created by PARMARTH MORI on 10/07/14.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import "MapviewViewController.h"

@interface MapviewViewController ()

@end

@implementation MapviewViewController

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
    CLLocation *aLocation=_mapview.userLocation.location;
    CLLocationCoordinate2D locationCordinates=aLocation.coordinate;
    self.mapview.delegate = self;
    [_mapview setShowsUserLocation:YES];
    [_mapview setMapType:MKMapTypeStandard];
    [_mapview setScrollEnabled:YES];

    [_mapview setCenterCoordinate:locationCordinates animated:YES];
    [_mapview setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    _mapview.zoomEnabled=YES;

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
    // ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/get_image_locations.php"]];
    
    [super viewWillAppear:YES];
    BOOL isPost = [[NSUserDefaults standardUserDefaults] boolForKey:@"Post"];
    if (isPost==YES) {
        [self.tabBarController setSelectedIndex:0];
    }
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/get_image_locations.php"]];
    __unsafe_unretained ASIFormDataRequest *request = _request;
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    
    [request setPostValue:self.userid forKey:@"user_id"];
    
    [request startAsynchronous];
    [request setCompletionBlock:^{
        NSMutableArray *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        NSLog(@"News Root %@",root);
        if([root count]==0)
        {[AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                         type:AJNotificationTypeRed
                                        title:@"You have not add location for any photo"
                              linedBackground:AJLinedBackgroundTypeDisabled
                                    hideAfter:4.0];
        }else{
            mutArryPrser=Nil;
            mutArryPrser=[[NSMutableArray alloc]init];
            mutArryPrser=[root mutableCopy];
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

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView{
    
    for (int i=0; i<[mutArryPrser count]; i++) {
        //            MKPointAnnotation *aPoint=[[MKPointAnnotation alloc]init];
        //
        //
        CLLocationCoordinate2D cordinates=CLLocationCoordinate2DMake([[[mutArryPrser objectAtIndex:i]objectForKey:@"latitude"]floatValue ], [[[mutArryPrser objectAtIndex:i]objectForKey:@"longitude"] floatValue]);
        pin = [[myAnnotation alloc] initWithName:NULL address:NULL coordinate:cordinates identyfier:i];
        
        
        //        [aPoint setCoordinate:cordinates];
        //        aPoint.title=[[mutArryPrser objectAtIndex:i]objectForKey:@"name"];
        //            aPoint.subtitle=[[mutArryPrser objectAtIndex:i]objectForKey:@"vicinity"];
        [mapView addAnnotation:pin];
    }
    
    //    MKPointAnnotation *aPoint=[[MKPointAnnotation alloc]init];
    //
    //    CLLocationCoordinate2D cordinates=CLLocationCoordinate2DMake(41.888742,-87.63612999999999);
    //    [aPoint setCoordinate:cordinates];
    //
    //    aPoint.title=@"aghdfu";
    //
    //    [mapView addAnnotation:aPoint];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    if ([annotation isKindOfClass:[myAnnotation class]])
    {
        
        MKAnnotationView *pinView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        
        pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
        //pinView.canShowCallout = YES;
        for (int i=0; i<[mutArryPrser count] ; i++){
            
            [pinView removeFromSuperview];
            if([(myAnnotation*)annotation identyfier] == i)
            {
                NSString *astrImageid=[[mutArryPrser objectAtIndex:i] objectForKey:@"id"];
                NSString *aStrDisplyOtherimage=[NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@-%@.jpg",[[NSUserDefaults standardUserDefaults] objectForKey:@"id"], astrImageid ];
                NSURL *aOtherimageurl=[NSURL URLWithString:aStrDisplyOtherimage];
                [pinView setImageWithURL:aOtherimageurl];
                //[pinView setImage:[UIImage imageNamed:@"Push-pin-icon-1005132358.png"]];
                [pinView setBackgroundColor:[UIColor clearColor]];
                [pinView setFrame:CGRectMake(0, 0,50, 50)];
                pinView.layer.masksToBounds=YES;
                
                pinView.calloutOffset = CGPointMake(0, 10);
                
            }
        }
        
        // Add a detail disclosure button to the callout.
        //        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        //        pinView.rightCalloutAccessoryView = rightButton;
        //
        //        UIImageView *iconView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
        //        [iconView setImageWithURL:aOtherimageurl];
        //
        //        pinView.leftCalloutAccessoryView = iconView;
        return pinView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    myAnnotation *sac = (myAnnotation *)view.annotation;
    
    for (int i=0; i<[mutArryPrser count] ; i++){
        
        
        if([sac identyfier] == i)
            
        {
            
            [informationview setHidden:NO];
            NSString *astrImageid=[[mutArryPrser objectAtIndex:i] objectForKey:@"id"];
            NSString *aStrDisplyOtherimage=[NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@-%@.jpg",[[NSUserDefaults standardUserDefaults] objectForKey:@"id"], astrImageid ];
            NSURL *aOtherimageurl=[NSURL URLWithString:aStrDisplyOtherimage];
            [_imageview.layer setBorderColor: [[UIColor whiteColor] CGColor]];
            [_imageview.layer setBorderWidth:3.0];
            [_imageview setImageWithURL:aOtherimageurl];
            [infobtn setTag:i];
            
            
        }
    }
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touch_point = [touch locationInView:self.view];
    
    if (![informationview pointInside:touch_point withEvent:event])
    {
        [informationview setHidden:YES];
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    
    //MKPointAnnotation *annotation=view.annotation;
    // [self loadRoute:annotation.coordinate];
}

- (IBAction)infoBtn:(id)sender {
    
    UIButton *tempbtn=(UIButton*)sender;
    int tag=tempbtn.tag;
    
    UIStoryboard *storyboard = self.navigationController.storyboard;
    PhotoDescriptionViewController *detailPage = [storyboard
                                      instantiateViewControllerWithIdentifier:@"photoDescriptin"];
    detailPage.strImageid=[[mutArryPrser objectAtIndex:tag] objectForKey:@"id"] ;
    detailPage.strUserid=[[NSUserDefaults standardUserDefaults] objectForKey:@"id"];
    //set the product
    
    //Push to detail View
    [self.navigationController pushViewController:detailPage animated:YES];    
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
