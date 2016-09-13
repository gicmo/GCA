//
//  MapVC.m
//  INCF 13
//
//  Created by Christian Kellner on 15/08/2013.
//  Copyright (c) 2013 G-Node. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "CKPoiManager.h"
#import "MapVC.h"
#import "UIColor+ConferenceKit.h"
#import "AbstractModel/Conference.h"

@interface MapVC () <MKMapViewDelegate, CLLocationManagerDelegate, ConferenceAware>
@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (strong, nonatomic) CKPoIManager *poiManager;
@property (weak, nonatomic) IBOutlet UIButton *locateMe;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonConstraint;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) Conference *conference;
@end

@implementation MapVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.poiManager = [[CKPoIManager alloc] initFromJSON:self.conference.map];
    self.map.delegate = self;
    
    NSArray *annotations = [self.poiManager pois];
    [self.map addAnnotations:annotations];
    self.map.showsUserLocation = YES;
    
    [self.locateMe setTitleColor:[UIColor ckColor] forState:UIControlStateHighlighted];
    
    UIImage *source = [UIImage imageNamed:@"01-Location-Arrow.png"];
    
    UIImage *hlImg =  [self createColoredImageFromImage:source withColor:[UIColor redColor]];
    [self.locateMe setImage:hlImg forState:UIControlStateHighlighted];
    
    UIImage *selImg =  [self createColoredImageFromImage:source withColor:[UIColor blueColor]];
    [self.locateMe setImage:selImg forState:UIControlStateSelected];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.buttonConstraint.constant += 60;
    }
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
}


-(UIImage *)createColoredImageFromImage:(UIImage *)source withColor:(UIColor *)color
{
    CGFloat scale = source.scale;
    CGRect rect = CGRectMake(0, 0, source.size.width * scale, source.size.height * scale);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClipToMask(context, rect, source.CGImage);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *flippedImage = [UIImage imageWithCGImage:img.CGImage
                                                scale:scale
                                          orientation:UIImageOrientationDownMirrored];
    return flippedImage;
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    CKPoI *venuePOI = [[self.poiManager poisMatchingType:PT_VENUE] lastObject];

    MKMapPoint point = MKMapPointForCoordinate(venuePOI.coordinate);
    double offset = 20000;
    MKMapRect pointRect = MKMapRectMake(point.x-offset, point.y-offset, 2*offset, 2*offset);

    for (CKPoI *poi in self.poiManager.pois) {
        if (poi.zoomTo) {
            NSLog(@"zooming to %@", poi.title);
            double offset = 2000;
            point = MKMapPointForCoordinate(poi.coordinate);
            MKMapRect prect = MKMapRectMake(point.x-offset, point.y-offset, 2*offset, 2*offset);
            pointRect = MKMapRectUnion(pointRect, prect);
        }
    }

    self.map.visibleMapRect = pointRect;
}

# pragma - mapView delegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKPinAnnotationView *pin = nil;
    if ([annotation isKindOfClass:[CKPoI class]]) {
        CKPoI *poi = (CKPoI *)annotation;
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:poi reuseIdentifier:nil];
        pin.canShowCallout = YES;
        switch (poi.poiType) {
            case PT_TRANSPORT:
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
        
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [rightButton addTarget:self
                        action:@selector(showDetails:)
              forControlEvents:UIControlEventTouchUpInside];
        pin.rightCalloutAccessoryView = rightButton;
        rightButton.tag = poi.poiId;
    }
    
    return pin;
}

-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    CKPoI *venuePOI = nil;
    
    for (MKAnnotationView *view in views) {
        if ([view.annotation isKindOfClass:[CKPoI class]]) {
        
            CKPoI *poi = (CKPoI *)view.annotation;
            if (poi.poiType == PT_VENUE) {
                venuePOI = poi;
                break;
            }
        }
    }
    
    if (venuePOI) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.4 * NSEC_PER_SEC),
                       dispatch_get_main_queue(),
                       ^(){
                           [self.map selectAnnotation:venuePOI animated:YES];
                       });
    }
}

- (void)showDetails:(id)sender
{
    UIButton *button = sender;
    CKPoI *poi = [self.poiManager poiById:button.tag];
    MKMapItem *item = [poi asMapItem];
    [item openInMapsWithLaunchOptions:nil];
    
}

-(void)toggleTracking
{
    if (self.map.userTrackingMode == MKUserTrackingModeNone) {
        self.map.userTrackingMode = MKUserTrackingModeFollow;
        self.locateMe.selected = YES;
    } else {
        self.map.userTrackingMode = MKUserTrackingModeNone;
        self.locateMe.selected = NO;
    }
}

- (IBAction)locateMeClicked:(id)sender {
    [self toggleTracking];
}

#pragma mark -
- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (status == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    } else if (status == kCLAuthorizationStatusDenied) {
        NSLog(@"Location services denied");
        self.locateMe.enabled = NO;
    }
}

@end
