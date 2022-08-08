//
//  TabBarVC.m
//  GCA
//
//  Created by Christian Kellner on 13/09/16.
//  Copyright © 2016 G-Node. All rights reserved.
//

#import "TabBarVC.h"
#import "ConferenceKit/CKDataStore.h"
#import "AbstractModel/Conference.h"

@interface TabBarVC ()

@end

@implementation TabBarVC 

+ (BOOL)setConference:(Conference*)conference for:(UIViewController*)vc {

    if ([vc conformsToProtocol:@protocol(ConferenceAware)]) {
        UIViewController <ConferenceAware> *ca = (UIViewController <ConferenceAware> *) vc;
        [ca setConference:conference];
        return YES;
    }

    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    CKDataStore *store = [CKDataStore defaultStore];

    NSLog(@"Initializing MapVC");
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Conference"];
    NSError *error = nil;
    NSArray *arr = [store.managedObjectContext executeFetchRequest:request error:&error];

    if (!arr || [arr count] < 1) {
        NSLog(@"Could not fetch conference!");
        return;
    }

    Conference *conference = arr[0];

    for (UIViewController *vc in self.viewControllers) {
        NSLog(@"x: %@", vc);
        if (![TabBarVC setConference:conference for:vc] && [vc isKindOfClass:[UINavigationController class]]) {
            UINavigationController *ng = (UINavigationController *) vc;
            for (UIViewController *vc in ng.viewControllers) {
                NSLog(@"xy: %@", vc);
                [TabBarVC setConference:conference for:vc];
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
