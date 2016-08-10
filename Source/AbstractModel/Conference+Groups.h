//
//  Conference+Groups.h
//  GCA
//
//  Created by Christian Kellner on 10/08/2016.
//  Copyright © 2016 G-Node. All rights reserved.
//

#import "Conference.h"
#import "Group.h"

@interface Conference (Groups)

-(Group *)groupForSortID:(uint32_t) aid;

@end
