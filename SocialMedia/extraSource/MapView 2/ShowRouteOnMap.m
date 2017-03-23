//
//  ShowRouteOnMap.m
//  TrackYaApps
//
//

#import "ShowRouteOnMap.h"

@implementation ShowRouteOnMap

+ (void)loadRouteOn:(NSArray*)routePoints onMap:(MKMapView*)map forDelegate:(id)delegate {
    MKMapPoint northEastPoint; 
	MKMapPoint southWestPoint; 
	
	// create a c array of points. 
	MKMapPoint* pointArr = malloc(sizeof(CLLocationCoordinate2D) * routePoints.count);
	 
	for(int idx = 0; idx < routePoints.count; idx++)
	{
		// break the string down even further to latitude and longitude fields. 
		NSString* currentPointString = [routePoints objectAtIndex:idx];
		NSArray* latLonArr = [currentPointString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        
		CLLocationDegrees latitude  = [[latLonArr objectAtIndex:0] doubleValue];
		CLLocationDegrees longitude = [[latLonArr objectAtIndex:1] doubleValue];
        
        
		// create our coordinate and add it to the correct spot in the array 
		CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        
		MKMapPoint point = MKMapPointForCoordinate(coordinate);
        
		
		//
		// adjust the bounding box
		//
		
		// if it is the first point, just use them, since we have nothing to compare to yet. 
		if (idx == 0) {
			northEastPoint = point;
			southWestPoint = point;
		}
		else 
		{
			if (point.x > northEastPoint.x) 
				northEastPoint.x = point.x;
			if(point.y > northEastPoint.y)
				northEastPoint.y = point.y;
			if (point.x < southWestPoint.x) 
				southWestPoint.x = point.x;
			if (point.y < southWestPoint.y) 
				southWestPoint.y = point.y;
		}
        
		pointArr[idx] = point;
        
	}
	
	// create the polyline based on the array of points. 
    [delegate setRouteLine:[MKPolyline polylineWithPoints:pointArr count:routePoints.count]];
	//delegate.routeLine = [MKPolyline polylineWithPoints:pointArr count:mutArrLocationPath.count];
    //[delegate setRouteRect:MKMapRectMake(southWestPoint.x, southWestPoint.y, northEastPoint.x - southWestPoint.x, northEastPoint.y - southWestPoint.y)];
    ShowRouteOnMap *obj = [[ShowRouteOnMap alloc] init] ;

    [obj setRouteRect:MKMapRectMake(southWestPoint.x, southWestPoint.y, northEastPoint.x - southWestPoint.x, northEastPoint.y - southWestPoint.y)];
    
	// clear the memory allocated earlier for the points
	free(pointArr);
}

- (void)setRouteRect:(MKMapRect)rect {
    _routeRect = rect;
}
@end
