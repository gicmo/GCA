//Copyright (c) 2012-2013, German Neuroinformatics Node (G-Node)
//Copyright (c) 2012-2013, Christian Kellner <kellner@bio.lmu.de>
//License: BSD-3 (see LICENSE)

#import "CKPoiManager.h"

@implementation CKPoI
@synthesize poiType = _poiType;
@synthesize cid = _cid;

-(MKMapItem *)asMapItem
{
    
    MKPlacemark *pm = [[MKPlacemark alloc] initWithCoordinate:self.coordinate addressDictionary:nil];
    MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:pm];
    item.name = self.title;
    return item;
}

@end

// ------------------------------------------

@interface CKPoIManager()
@property (strong, nonatomic) NSArray *data;
@end

@implementation CKPoIManager
@synthesize data = _data;

- (CKPoIManager *) initFromFile:(NSString *)path
{
    self = [super init];
    if (self) {
        [self loadData:path];
    }
    return self;
}

- (void)loadData:(NSString *)path
{
    NSString *fileContents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    NSData *data = [fileContents dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *root = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    NSInteger poiId = 0;
    for (NSDictionary *dict in root) {
        NSDictionary *pDict = [dict objectForKey:@"point"];
        CLLocationCoordinate2D point;
        point.latitude = [[pDict objectForKey:@"lat"] doubleValue];
        point.longitude = [[pDict objectForKey:@"long"] doubleValue];
        
        CKPoI *poi = [[CKPoI alloc] init];
        poi.coordinate = point;
        poi.title = [dict objectForKey:@"name"];
        poi.subtitle = [dict objectForKey:@"description"];
        poi.poiType = [[dict objectForKey:@"type"] integerValue];
        poi.cid = [dict objectForKey:@"cid"];
        poi.poiId = poiId++;
        
        [annotations addObject:poi];
    }
    
    self.data = annotations;
}

- (NSArray *) pois
{
    return self.data;
}

- (NSArray *) poisMatchingType:(kCKPoiType) poiType
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (CKPoI *poi in self.pois) {
        if (poi.poiType == poiType) {
            [array addObject:poi];
        }
    }
    
    return [array copy];
}

- (CKPoI *)poiById:(NSInteger)poiId
{
    return [self.pois objectAtIndex:poiId];
}

- (MKMapRect) rectFromPoI:(CKPoI *)poi
{
    MKMapPoint point = MKMapPointForCoordinate(poi.coordinate);
    MKMapRect pointRect = MKMapRectMake(point.x, point.y, 0, 0);
    return pointRect;

}

- (MKMapRect) boundingBoxForPoIs
{
    MKMapRect box = MKMapRectNull;
    
    if (self.data.count > 0) {
        box = [self rectFromPoI:[self.data objectAtIndex:0]];
    }
    
    for (int i = 0; i < self.data.count; i++) {
        MKMapRect rect = [self rectFromPoI:[self.data objectAtIndex:i]];
        box = MKMapRectUnion(box, rect);
    }
    
    return box;
}


@end
