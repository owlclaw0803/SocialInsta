//
//  PlaceMark.h
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Place.h"

@interface PlaceMark : NSObject <MKAnnotation> {

	CLLocationCoordinate2D coordinate;
	Place* place;
    int idAnnot;
}
@property (nonatomic) int idAnnot;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) Place* place;

-(id) initWithPlace: (Place*) p;

@end
