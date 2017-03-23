//
//  myAnnotation.h
//  FollowMe
//
//  Created by PARMARTH MORI on 29/05/14.
//  Copyright (c) 2014 Jay Pathak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface myAnnotation : NSObject<MKAnnotation>
{

    int _identyfier;
    NSString *_name;
    NSString *_address;
    CLLocationCoordinate2D _coordinate;

}
@property (copy) NSString *name;
@property (copy) NSString *address;
@property  int identyfier;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id)initWithName:(NSString*)name address:(NSString*)address coordinate:(CLLocationCoordinate2D)coordinate identyfier:(int) identyfier;

@end
