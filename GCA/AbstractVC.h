//Copyright (c) 2012-2013, German Neuroinformatics Node (G-Node)
//Copyright (c) 2012-2013, Christian Kellner <kellner@bio.lmu.de>
//License: BSD-3 (see LICENSE)

#import <UIKit/UIKit.h>

#import "Abstract.h"

@protocol AbstrarctVCDelegate;


@interface AbstractVC : UIViewController

@property(nonatomic, strong) Abstract *abstract;
@property(nonatomic, weak) id<AbstrarctVCDelegate> delegate;
@property(nonatomic) BOOL showNavigator;


@end


@protocol AbstrarctVCDelegate
- (void) abstractVC:(AbstractVC *)controller nextAbstract:(Abstract *) abstract;
- (void) prevAbstract:(AbstractVC *)controller;
- (void) abstractChanged:(AbstractVC *)controller;
@end