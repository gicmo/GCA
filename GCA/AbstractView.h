//
//  AbstractView.h
//  GCA
//
//  Created by Christian Kellner on 8/29/12.
//
//

#import <UIKit/UIKit.h>

#import "Abstract.h"

@interface AbstractView : UIView
- (id)initWithFrame:(CGRect)frame andAbstract:(Abstract *) abstract;
@property (nonatomic, strong) Abstract *abstract;
@end
