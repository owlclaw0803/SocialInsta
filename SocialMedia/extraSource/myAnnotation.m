//
//  myAnnotation.m
//  FollowMe
//
//  Created by PARMARTH MORI on 29/05/14.
//  Copyright (c) 2014 Jay Pathak. All rights reserved.
//

#import "myAnnotation.h"

@implementation myAnnotation
@synthesize name = _name;
@synthesize address = _address;
@synthesize coordinate = _coordinate;
@synthesize identyfier=_identyfier;



- (id)initWithName:(NSString*)name address:(NSString*)address coordinate:(CLLocationCoordinate2D)coordinate identyfier:(int)identyfier {
    if ((self = [super init])) {
        _name = [name copy];
        _address = [address copy];
        _coordinate = coordinate;
        _identyfier = identyfier;
    }
    return self;
}@end
