//
//  CKMarkdownParser.h
//  INCF 13
//
//  Created by Christian Kellner on 16/08/2013.
//  Copyright (c) 2013 G-Node. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKMarkdownParser : NSObject

@property (nonatomic, strong) NSDictionary *attrHeaderL1;
@property (nonatomic, strong) NSDictionary *attrHeaderL2;
@property (nonatomic, strong) NSDictionary *attrHeaderL3;
@property (nonatomic, strong) NSDictionary *attrParagraph;
@property (nonatomic, strong) NSDictionary *attrBlockCode;

+ (NSAttributedString *)parseString:(NSString *)text;
@end
