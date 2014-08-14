//Copyright (c) 2012-2013, German Neuroinformatics Node (G-Node)
//Copyright (c) 2012-2013, Christian Kellner <kellner@bio.lmu.de>
//License: BSD-3 (see LICENSE)

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreGraphics/CoreGraphics.h>

typedef enum {
    PT_VENUE = 0,
    PT_UNI = 1,
    PT_HOTEL = 2,
    PT_HOTEL_2 = 3,
    PT_TRANSPORT = 4,
    PT_FOOD = 5
} kCKPoiType;

@interface CKPoI : MKPointAnnotation <MKAnnotation>
@property kCKPoiType poiType;
@property (nonatomic, strong) NSString *cid;
@property (nonatomic) NSInteger poiId;
-(MKMapItem *) asMapItem;
@end

@interface CKPoIManager : NSObject
@property (nonatomic, readonly) NSArray *pois; //id<MKAnnotation>

- (CKPoIManager *) initFromFile:(NSString *)path;
- (NSArray *) poisMatchingType:(kCKPoiType) poiType;
- (CKPoI *) poiById:(NSInteger)poiId;
- (MKMapRect) boundingBoxForPoIs;

@end
