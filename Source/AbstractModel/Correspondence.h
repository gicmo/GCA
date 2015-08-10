//
//  Correspondence.h
//  GCA
//
//  Created by Christian Kellner on 10/08/15.
//  Copyright (c) 2015 G-Node. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Abstract, Author;

@interface Correspondence : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) Abstract *forAbstract;
@property (nonatomic, retain) Author *ofAuthor;

@end
