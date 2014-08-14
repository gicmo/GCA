//
//  Correspondence.h
//  AbstractManager
//
//  Created by Christian Kellner on 8/9/12.
//  Copyright (c) 2012 G-Node. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Abstract, Author;

@interface Correspondence : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) Abstract *forAbstract;
@property (nonatomic, retain) Author *ofAuthor;

@end
