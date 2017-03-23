//
//  MapviewViewController.h
//  SocialMedia
//
//  Created by PARMARTH MORI on 10/07/14.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MapView.h"
#import "Place.h"
#import "MKAnnotationView+WebCache.h"
#import "myAnnotation.h"
#import "PhotoDescriptionViewController.h"

@interface MapviewViewController : UIViewController<MKMapViewDelegate>
{
    IBOutlet UIButton *infobtn;
    NSMutableArray *mutArryPrser;
    NSMutableDictionary *mutDictParser;
    NSMutableString *mutStrParser;
    NSString *element;
    
    BOOL *aFlag;
    NSMutableArray *aArrayofLatLng;
    myAnnotation *pin ;
    IBOutlet UIView *informationview;
}
@property (strong, nonatomic) IBOutlet UIImageView *imageview;
- (IBAction)infoBtn:(id)sender;
@property (strong, nonatomic) IBOutlet MKMapView *mapview;
- (IBAction)back:(id)sender;
@property(strong,nonatomic)NSString *userid;

@end
