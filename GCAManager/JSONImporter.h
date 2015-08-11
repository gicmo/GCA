//
//  JSONImporer.h
//  AbstractManager
//
//  Created by Christian Kellner on 8/28/12.
//  Copyright (c) 2012 G-Node. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#include "Conference.h"

@interface JSONImporter : NSObject
-(id) initWithContext:(NSManagedObjectContext *)context;
-(BOOL) importAbstracts:(NSData *)data intoConference:(Conference *)conference;
-(BOOL) importConference:(NSData *)data;

@property (nonatomic, strong) NSManagedObjectContext *context;
@end
