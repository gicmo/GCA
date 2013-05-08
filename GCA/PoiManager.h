//Copyright (c) 2012-2013, German Neuroinformatics Node (G-Node)
//Copyright (c) 2012-2013, Christian Kellner <kellner@bio.lmu.de>
//License: BSD-3 (see LICENSE)

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef enum {
    PT_VENUE = 0,
    PT_UNI = 1,
    PT_HOTEL = 2,
    PT_HOTEL_2 = 3,
    PT_TRANSPORT = 4,
    PT_FOOD = 5
} kPoiType;

@interface POI : MKPointAnnotation <MKAnnotation>
@property (nonatomic, readonly) MKAnnotationView *view;
@property kPoiType poiType;
@property (nonatomic, strong) NSString *cid;
@property (nonatomic) NSInteger poiId;
@end

@interface PoiManager : NSObject
- (PoiManager *) initFromFile:(NSString *)path;
@property (nonatomic, readonly) NSArray *pois; //id<MKAnnotation>
- (NSArray *) poisMatchingType:(kPoiType) poiType;
- (POI *) poiById:(NSInteger)poiId;
@end
