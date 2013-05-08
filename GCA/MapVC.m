//Copyright (c) 2012-2013, German Neuroinformatics Node (G-Node)
//Copyright (c) 2012-2013, Christian Kellner <kellner@bio.lmu.de>
//License: BSD-3 (see LICENSE)

#import "MapVC.h"
#import "PoiManager.h"
#import <MapKit/MapKit.h>

@interface MapVC () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) PoiManager *poiManager;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *locateMeButton;
@property (strong, nonatomic) UIColor *notSelectedColor;

@end

@implementation MapVC
@synthesize mapView;
@synthesize poiManager = _poiManager;
@synthesize locateMeButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

+ (MKMapRect) rectFromAnnotation:(id<MKAnnotation>) annotation
{
    MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
    MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
    return pointRect;
}

- (void)loadData
{
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"BC12" ofType:@"json"];
    self.poiManager = [[PoiManager alloc] initFromFile:jsonPath];
    
    NSArray *annotations = [self.poiManager pois];
    [self.mapView addAnnotations:annotations];
    
    MKMapRect flyTo;
    
    if (annotations.count > 0)
        flyTo = [MapVC rectFromAnnotation:[annotations objectAtIndex:0]];
    
    for (int i = 1; i < annotations.count; i++) {
        POI *poi = [annotations objectAtIndex:i];
        
        if (poi.poiType != PT_VENUE && poi.poiType != PT_FOOD)
            continue;
        
        MKMapRect pointRect = [MapVC rectFromAnnotation:poi];
        flyTo = MKMapRectUnion(flyTo, pointRect);
    }
    
    // Position the map so that all overlays and annotations are visible on screen.
    self.mapView.visibleMapRect = flyTo;
    
    POI *venuePOI = [[self.poiManager poisMatchingType:PT_VENUE] lastObject];
    [self.mapView selectAnnotation:venuePOI animated:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.mapView.delegate = self;
    self.notSelectedColor = self.locateMeButton.tintColor;
    [self loadData];
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [self setLocateMeButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

# pragma - mapView delegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView *view = nil;
    if ([annotation isKindOfClass:[POI class]]) {
        POI *poi = (POI *) annotation;
        view = poi.view;
    
        if (poi.cid) {
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:self
                            action:@selector(showDetails:)
                  forControlEvents:UIControlEventTouchUpInside];
            view.rightCalloutAccessoryView = rightButton;
            rightButton.tag = poi.poiId;
        }
    }
    
    return view;
}

- (void)showDetails:(id)sender
{
    //[self.navigationController setToolbarHidden:YES animated:NO];

    UIButton *button = sender;
    POI *poi = [self.poiManager poiById:button.tag];
    //NSLog(@"%@ -> %@\n", sender, poi.cid);
    NSString *urlString = [NSString stringWithFormat:@"http://maps.apple.com/maps?cid=%@", poi.cid];
    NSURL *target = [NSURL URLWithString:urlString];
    [[UIApplication sharedApplication] openURL:target];
}
- (IBAction)locateMe:(id)sender
{
    self.mapView.showsUserLocation = YES;
    self.locateMeButton.tintColor = [UIColor colorWithRed:11/255.0 green:57/255.0 blue:152/255.0 alpha:1.0];
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (! self.mapView.userLocationVisible) {
        //NSLog(@"Adjusting user pos!");
        MKMapRect visLoc = self.mapView.visibleMapRect;
        MKUserLocation *location = self.mapView.userLocation;
        MKMapRect userRect = [MapVC rectFromAnnotation:location];
        visLoc = MKMapRectUnion(visLoc, userRect);
        [self.mapView setVisibleMapRect:visLoc animated:YES];
    }
}


- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    self.locateMeButton.tintColor = self.notSelectedColor;
}

@end
