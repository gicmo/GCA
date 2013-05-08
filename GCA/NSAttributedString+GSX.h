//Copyright (c) 2012-2013, German Neuroinformatics Node (G-Node)
//Copyright (c) 2012-2013, Christian Kellner <kellner@bio.lmu.de>
//License: BSD-3 (see LICENSE)


#import <Foundation/Foundation.h>

@interface NSAttributedString (GSX)
-(id) initWithGSX:(NSData *)gsxData andFormat:(NSDictionary *)format;
@end
