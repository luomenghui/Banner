//
//  ViewController.m
//  BannerDemo
//
//  Created by luomh on 2019/7/8.
//  Copyright © 2019 luomh. All rights reserved.
//

#import "ViewController.h"
#import "MHBannerView.h"

#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width

@interface ViewController ()

@property (nonatomic, strong) MHBannerView *bannerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupUI];
}

- (void)setupUI {
    
    NSArray *paths = @[[self conversionUrlFromString:@"1"],
                       [self conversionUrlFromString:@"2"],
                       [self conversionUrlFromString:@"3"],
                       [self conversionUrlFromString:@"4"],
                       [self conversionUrlFromString:@"5"]];
    
    self.bannerView = [[MHBannerView alloc] initWithFrame:CGRectMake(0, 100, SCREENWIDTH, 200)];
    [self.bannerView showWithImagePaths:paths];
    [self.view addSubview:_bannerView];
}

- (NSString *)conversionUrlFromString:(NSString *)name {
    return [[NSBundle mainBundle] pathForResource:name ofType:@"jpg"];
}


@end
