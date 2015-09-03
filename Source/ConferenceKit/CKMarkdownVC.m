//
//  CKMarkdownVC.m
//  GCA
//
//  Created by Christian Kellner on 03/09/15.
//  Copyright (c) 2015 G-Node. All rights reserved.
//

#import "CKMarkdownVC.h"
#import "CKMarkdownView.h"
#import "CKMarkdownParser.h"
#import "UIColor+ConferenceKit.h"

@interface CKMarkdownVC ()
@property (nonatomic, strong) UIScrollView *container;
@property (nonatomic, strong) CKMarkdownView *mdView;
@property (nonatomic, strong) NSAttributedString *text;
@end

@implementation CKMarkdownVC

- (instancetype) initWithResource:(NSString *)name ofType:(NSString *)type {
    self = [super init];

    if (self == nil) {
        return self;
    }

    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"md"];
    NSString *fileContents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];

    self.text = [CKMarkdownParser parseString:fileContents];

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.container = [[UIScrollView alloc] init];
    self.container.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.container];

    self.mdView = [[CKMarkdownView alloc] init];
    self.mdView.text = self.text;
    self.mdView.fgColor = [UIColor ckColor];
    self.mdView.backgroundColor = [UIColor whiteColor];
    self.mdView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.container addSubview:self.mdView];
    self.view.backgroundColor = [UIColor whiteColor];

    CGFloat padding = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 100 : 10;

    //Constraints
    UIView *mdView = self.mdView;
    UIView *container = self.container;
    NSDictionary *viewsMap = NSDictionaryOfVariableBindings(mdView, container);

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[container]|"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:viewsMap]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[container]|"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:viewsMap]];



    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds) - 2*padding;
    [self.container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=pad)-[mdView(==width)]-(>=pad)-|"
                                                                      options:0
                                                                      metrics:@{@"width": @(width), @"pad": @(padding)}
                                                                        views:viewsMap]];

    CGSize size = CGSizeMake(width, CGFLOAT_MAX);
    CGSize height = [self.mdView sizeThatFits:size];
    [self.container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mdView(==height)]|"
                                                                           options:0
                                                                           metrics:@{@"height": @(height.height)}
                                                                             views:viewsMap]];


    self.container.contentInset = UIEdgeInsetsMake(40, 0, 88, 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
