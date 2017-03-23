//
//  MapViewController.m
//

#import "MapView.h"
#import "MKMapView+ZoomLevel.h"
#import "ShowRouteOnMap.h"
@interface MapView()



@end

@implementation MapView

@synthesize lineColor;
@synthesize userlatitude,userlongitude;
- (id) initWithFrame:(CGRect) frame
{
	self = [super initWithFrame:frame];
    mutArrLocationPath = [[NSMutableArray alloc] init];
	if (self != nil) {
		mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		mapView.showsUserLocation = YES;
        [mapView setDelegate:self];
		[self addSubview:mapView];
	}
	return self;
}
-(void)GetCurrentLoc{
    CLLocation *userLoc = mapView.userLocation.location;
    CLLocationCoordinate2D usercurrentCoordinate = userLoc.coordinate;
    self.userlatitude =  usercurrentCoordinate.latitude;
    self.userlongitude =  usercurrentCoordinate.longitude;
    self.lineColor = [UIColor colorWithWhite:0.2 alpha:0.5];
}
-(NSMutableArray *)decodePolyLine: (NSMutableString *)encoded {
	[encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
								options:NSLiteralSearch
								  range:NSMakeRange(0, [encoded length])];
	NSInteger len = [encoded length];
	NSInteger index = 0;
	NSMutableArray *array = [[NSMutableArray alloc] init];
	NSInteger lat=0;
	NSInteger lng=0;
	while (index < len) {
		NSInteger b;
		NSInteger shift = 0;
		NSInteger result = 0;
		do {
			b = [encoded characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lat += dlat;
		shift = 0;
		result = 0;
		do {
			b = [encoded characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lng += dlng;
		NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
		NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
		CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
		[array addObject:loc];
	}
	
	return array;
}

-(NSArray*) calculateRoutesFrom:(CLLocationCoordinate2D) f to: (CLLocationCoordinate2D) t {
    NSError *error;
	NSString* saddr = [NSString stringWithFormat:@"%f,%f", f.latitude, f.longitude];
	NSString* daddr = [NSString stringWithFormat:@"%f,%f", t.latitude, t.longitude];
	
	NSString* apiUrlStr = [NSString stringWithFormat:@"http://maps.google.com/maps?output=dragdir&saddr=%@&daddr=%@", saddr, daddr];
	NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
    NSString *apiResponse = [NSString stringWithContentsOfURL:apiUrl encoding:NSUTF8StringEncoding error:&error];
   if(apiResponse!=nil){
     NSString* tooltipHtml = [apiResponse stringByMatching:@"tooltipHtml:\\\"([^\\\"]*)\\\"" capture:1L];
     [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTime" object:tooltipHtml];
       NSString* encodedPoints = [apiResponse stringByMatching:@"points:\\\"([^\\\"]*)\\\"" capture:1L];
       
       return [self decodePolyLine:[encodedPoints mutableCopy]];
   }
    return 0;
}

-(void) centerMap {
	MKCoordinateRegion region;

	CLLocationDegrees maxLat = -90;
	CLLocationDegrees maxLon = -180;
	CLLocationDegrees minLat = 90;
	CLLocationDegrees minLon = 180;
	for(int idx = 0; idx < routes.count; idx++)
	{
		CLLocation* currentLocation = [routes objectAtIndex:idx];
		if(currentLocation.coordinate.latitude > maxLat)
			maxLat = currentLocation.coordinate.latitude;
		if(currentLocation.coordinate.latitude < minLat)
			minLat = currentLocation.coordinate.latitude;
		if(currentLocation.coordinate.longitude > maxLon)
			maxLon = currentLocation.coordinate.longitude;
		if(currentLocation.coordinate.longitude < minLon)
			minLon = currentLocation.coordinate.longitude;
	}
	region.center.latitude     = (maxLat + minLat) / 2;
	region.center.longitude    = (maxLon + minLon) / 2;
	region.span.latitudeDelta  = maxLat - minLat;
	region.span.longitudeDelta = maxLon - minLon;
	//grv_100413 for set zoom level
	//[mapView setRegion:region animated:YES];
    [mapView setCenterCoordinate:region.center zoomLevel:8 animated:YES];
}

-(void) showRouteFrom: (Place*) f to:(Place*) t {
	if(routes) {
		[mapView removeAnnotations:[mapView annotations]];
		//[routes release];
	}
	self.lineColor = [UIColor colorWithRed:78.0/255.0 green:74.0/255.0 blue:124.0/255.0 alpha:1.0];
	PlaceMark* from = [[PlaceMark alloc] initWithPlace:f];
	PlaceMark* to = [[PlaceMark alloc] initWithPlace:t];
	
	[mapView addAnnotation:from];
	[mapView addAnnotation:to];
	
	routes = [self calculateRoutesFrom:from.coordinate to:to.coordinate];
    if([routes count]&& ApplicationDelegate.boolCenterMap){
        [self centerMap];
        ApplicationDelegate.boolCenterMap = FALSE;
    }
    [mutArrLocationPath removeAllObjects];
    for (CLLocation *loc in routes) {
        NSString *aStr = [NSString stringWithFormat:@"%f,%f", loc.coordinate.latitude, loc.coordinate.longitude];
        [mutArrLocationPath addObject:aStr];
    }
    if (_routeLine) {
        [mapView removeOverlay:_routeLine];
        _routeLine = nil;
    }  
    [ShowRouteOnMap loadRouteOn:mutArrLocationPath onMap:mapView forDelegate:self];
    [mapView addOverlay:_routeLine];
    //Show Annot Continous
    //[mapView selectAnnotation:to animated:NO];
}
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
	MKOverlayView* overlayView = nil;
    self.routeLineView = [[MKPolylineView alloc] initWithPolyline:self.routeLine] ;
    self.routeLineView.fillColor = self.lineColor;
    self.routeLineView.strokeColor = self.lineColor;
    self.routeLineView.lineWidth = 7;
    overlayView = self.routeLineView;
	return overlayView;
}
- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation {
    MKPinAnnotationView *newAnnotationPin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"simpleAnnotation"];
    newAnnotationPin.pinColor = MKPinAnnotationColorPurple;
    if([[annotation title]isEqualToString:@"Friend Name"]){
        newAnnotationPin.canShowCallout = YES;
        UIButton *disclosureButton = [UIButton buttonWithType: UIButtonTypeDetailDisclosure];
        newAnnotationPin.rightCalloutAccessoryView = disclosureButton;
    }else{
        newAnnotationPin.canShowCallout = NO;
    }
    return newAnnotationPin;
}

#pragma mark mapView delegate functions


- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if([[[view annotation] title]isEqualToString:@"Friend Location"]){
    }else {
        return;
    }
}
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    //put your code here to redirct in safari.
    [self GetCurrentLoc];
    NSString *saddr = [NSString stringWithFormat:@"%f%f",self.userlatitude,self.userlongitude];
    NSString *daddr = [NSString stringWithFormat:@"%f%f",ApplicationDelegate.trackLat,ApplicationDelegate.trackLong];
    
    NSString *strURL = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%@&daddr=%@",saddr,daddr];
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:strURL]];
    
    
}



- (void)dealloc {
	if(routes) {
		[routes release];
	}
    mapView.delegate = nil;
    [super dealloc];
}



@end
