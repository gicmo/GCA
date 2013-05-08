//Copyright (c) 2012-2013, German Neuroinformatics Node (G-Node)
//Copyright (c) 2012-2013, Christian Kellner <kellner@bio.lmu.de>
//License: BSD-3 (see LICENSE)

#import "PoiManager.h"



@implementation POI
@synthesize view = _view;
@synthesize poiType = _poiType;
@synthesize cid = _cid;

-(MKAnnotationView *) view
{
    if (!_view) {
        MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:self reuseIdentifier:nil];
        pin.canShowCallout = YES;
        switch (self.poiType) {
            case PT_FOOD:
                pin.pinColor = MKPinAnnotationColorGreen;
                break;
                
            case PT_VENUE:
            case PT_UNI:
                pin.pinColor = MKPinAnnotationColorRed;
                break;
                
            default:
                pin.pinColor = MKPinAnnotationColorPurple;
                break;
        }
        _view = pin;
    }
    
    return _view;
}

@end

// ------------------------------------------

@interface PoiManager()
@property (strong, nonatomic) NSArray *data;
@end

@implementation PoiManager
@synthesize data = _data;

- (PoiManager *) initFromFile:(NSString *)path
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
        
        POI *poi = [[POI alloc] init];
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

- (NSArray *) poisMatchingType:(kPoiType) poiType
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (POI *poi in self.pois) {
        if (poi.poiType == poiType) {
            [array addObject:poi];
        }
    }
    
    return [array copy];
}

- (POI *)poiById:(NSInteger)poiId
{
    return [self.pois objectAtIndex:poiId];
}

@end
