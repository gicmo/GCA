//
//  Reference.h
//  GCA
//
//  Created by Christian Kellner on 19/08/14.
//  Copyright (c) 2014 G-Node. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Abstract;

@interface Reference : NSManagedObject

@property (nonatomic, retain) NSString * doi;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) Abstract *ofAbstract;

@end
