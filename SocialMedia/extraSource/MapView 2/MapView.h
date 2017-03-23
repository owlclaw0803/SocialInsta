//
//  MapViewController.h
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "RegexKitLite.h"
#import "Place.h"
#import "PlaceMark.h"

@interface MapView : UIView<MKMapViewDelegate> {
    NSMutableArray *mutArrLocationPath;
	MKMapView* mapView;
	NSArray* routes;
	UIColor* lineColor;
    int zoomLevel;
}
@property (nonatomic, retain) MKPolyline* routeLine;
@property (nonatomic, retain) MKPolylineView* routeLineView;
@property (nonatomic, retain) UIColor* lineColor;
@property (nonatomic) float  userlatitude;
@property (nonatomic) float  userlongitude;
-(void) showRouteFrom: (Place*) f to:(Place*) t;
-(NSMutableArray *)decodePolyLine: (NSMutableString *)encoded;
-(NSArray*) calculateRoutesFrom:(CLLocationCoordinate2D) from to: (CLLocationCoordinate2D) to;
-(void) centerMap;
-(void)GetCurrentLoc;
@end
