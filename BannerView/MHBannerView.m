//
//  MHBannerView.m
//  TempOC
//
//  Created by luomh on 2019/7/4.
//  Copyright © 2019 luomh. All rights reserved.
//

#import "MHBannerView.h"

@import SDWebImage;

typedef NS_ENUM(NSUInteger, MHImageLoadType) {
    MHImageLoadTypeName,
    MHImageLoadTypeURL,
    MHImageLoadTypePath,
};

@interface MHBannerView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) CGRect scrollViewFrame;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, strong) UIImage *defaultImage;
@property (nonatomic, copy) NSArray *imageArray;
@property (nonatomic, assign) MHImageLoadType imageLoadType;

@property(nonatomic, strong) UIImageView *leftImageView;
@property(nonatomic, strong) UIImageView *centerImageView;
@property(nonatomic, strong) UIImageView *rightImageView;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSTimeInterval timerInterval;
@property (nonatomic, assign) BOOL timerIsRunning;

@property (nonatomic, assign) NSInteger pageControlBottomMargin;

@end

@implementation MHBannerView

#pragma mark - Override
- (void)dealloc {
    [self.timer invalidate];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        // 将当前显示图片设置为第一张
        self.currentPage = 0;
        self.defaultImage = [UIImage imageNamed:@"tempImage"];
        self.scrollView.frame = self.bounds;
        self.timerInterval = 4;
        self.pageControlBottomMargin = 30;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (CGRectGetWidth(self.scrollViewFrame) == 0) {
        self.scrollView.frame = self.bounds;
    }
}

#pragma mark - Public mehtods
- (void)showWithImageUrls:(NSArray<NSString *> *)imageUrls {
    self.imageArray = imageUrls;
    self.imageLoadType = MHImageLoadTypeURL;
    [self setupUI];
    [self startTimerAfterDelay:self.timerInterval];
}

- (void)showWithImageNames:(NSArray<NSString *> *)imageNames {
    self.imageArray = imageNames;
    self.imageLoadType = MHImageLoadTypeName;
    [self setupUI];
    [self startTimerAfterDelay:self.timerInterval];
}

- (void)showWithImagePaths:(NSArray<NSString *> *)paths {
    self.imageArray = paths;
    self.imageLoadType = MHImageLoadTypePath;
    [self setupUI];
    [self startTimerAfterDelay:self.timerInterval];
}

#pragma mark - Private mehtods
- (void)setupUI {
    self.scrollViewFrame = self.scrollView.frame;
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollViewFrame) * 3, CGRectGetHeight(self.scrollViewFrame));
    // 这里一定要将偏移量设置为显示中间那张图。
    self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollViewFrame), 0);
    [self addSubview:self.scrollView];
    
    [self creaetLeftImageView];
    [self createCenterImageView];
    [self createRightImageView];
    
    self.pageControl.numberOfPages = self.imageArray.count;
    [self addSubview:self.pageControl];
}

//左边视图
- (void)creaetLeftImageView {
    NSInteger index = (self.currentPage - 1 + self.imageArray.count) % self.imageArray.count;
    self.leftImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.scrollViewFrame), CGRectGetHeight(self.scrollViewFrame));
    [self assignValue:self.imageArray[index] toImageView:self.leftImageView];
    self.leftImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.leftImageView.userInteractionEnabled = YES;
    [self.scrollView addSubview:self.leftImageView];
}

//中间视图
- (void)createCenterImageView {
    self.centerImageView.frame = CGRectMake(CGRectGetWidth(self.scrollViewFrame), 0, CGRectGetWidth(self.scrollViewFrame), CGRectGetHeight(self.scrollViewFrame));
    [self assignValue:self.imageArray[self.currentPage] toImageView:self.centerImageView];
    self.centerImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.centerImageView.userInteractionEnabled = YES;
    [self.scrollView addSubview:self.centerImageView];
}

//右边视图
- (void)createRightImageView{
    self.rightImageView.frame = CGRectMake(CGRectGetWidth(self.scrollViewFrame) * 2, 0, CGRectGetWidth(self.scrollViewFrame), CGRectGetHeight(self.scrollViewFrame));
    NSInteger index = (self.currentPage + 1 + self.imageArray.count) % self.imageArray.count;
    [self assignValue:self.imageArray[index] toImageView:self.rightImageView];
    self.rightImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.rightImageView.userInteractionEnabled = YES;
    [self.scrollView addSubview:self.rightImageView];
}

- (void)resetContent {
    // 重置偏移量
    CGPoint offset = CGPointMake(CGRectGetWidth(self.scrollViewFrame), 0);
    [self.scrollView setContentOffset:offset];
    
    // 重置图片
    NSInteger leftIndex = (self.currentPage - 1 + self.imageArray.count) % self.imageArray.count;
    NSInteger centerIndex = self.currentPage;
    NSInteger rightIndex = (self.currentPage + 1 + self.imageArray.count) % self.imageArray.count;
    [self assignValue:self.imageArray[leftIndex] toImageView:self.leftImageView];
    [self assignValue:self.imageArray[centerIndex] toImageView:self.centerImageView];
    [self assignValue:self.imageArray[rightIndex] toImageView:self.rightImageView];
}

- (void)autoScroll {
    if (!self.scrollView.isDragging || !self.scrollView.isDecelerating) {
        // 这里只对contentOffset进行设置，因为一旦设置了contentOffSet后代理就会自动调用
        // - (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView此方法，代码重用，会利用我们上面写好的逻辑帮我们处理剩下的东西。
        [self.scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.scrollViewFrame) * 2, 0) animated:YES];
    }
}

- (void)startTimer {
    [self.timer setFireDate:[NSDate distantPast]];
    self.timerIsRunning = YES;
}

- (void)startTimerAfterDelay:(NSTimeInterval)afterDelay {
    [self.timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:afterDelay]];
    self.timerInterval = YES;
}

- (void)stopTimer {
    [self.timer setFireDate:[NSDate distantFuture]];
    self.timerIsRunning = NO;
}

- (void)assignValue:(NSString *)image toImageView:(UIImageView *)imageView {
    if (![image isKindOfClass:[NSString class]] || image.length == 0) {
        return;
    }
    if (self.imageLoadType == MHImageLoadTypeName) {
        imageView.image = [UIImage imageNamed:image];
    } else if (self.imageLoadType == MHImageLoadTypeURL) {
        [imageView sd_setImageWithURL:[NSURL URLWithString:image] placeholderImage:self.defaultImage];
    } else if (self.imageLoadType == MHImageLoadTypePath) {
        imageView.image = [UIImage imageWithContentsOfFile:image];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    NSLog(@"+++ end deceleration +++");
    if (!self.timerIsRunning) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((self.timerInterval) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!self.timerIsRunning) {
                [self startTimer];
            }
        });
    }

    CGFloat distance = self.scrollView.contentOffset.x - CGRectGetWidth(self.scrollViewFrame);
    if (distance < 0) {
        // 往左翻页，将currentPage往上翻页
        self.currentPage = (self.currentPage - 1 + self.imageArray.count) % self.imageArray.count;
        [self resetContent];
    } else if (distance > 0) {
        // 往右翻页，将currentPage往下翻页
        self.currentPage = (self.currentPage + 1 + self.imageArray.count) % self.imageArray.count;
        [self resetContent];
    } else {
        //用户未翻页成功，什么都不做。
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
//    NSLog(@"+++ end scroll animation +++");
    [self scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    NSLog(@"+++ begin dragging +++");
    [self stopTimer];
}

#pragma mark - Properties
- (void)setCurrentPage:(NSInteger)currentPage {
    _currentPage = currentPage;
    [self.pageControl setCurrentPage:currentPage];
}

- (void)setPageControlBottomMargin:(NSInteger)pageControlBottomMargin {
    _pageControlBottomMargin = pageControlBottomMargin;
    self.pageControl.frame = CGRectMake(CGRectGetWidth(self.frame) - 80, CGRectGetHeight(self.frame) - self.pageControlBottomMargin, 40, 20);
}

- (UIImageView *)leftImageView{
    if (_leftImageView == nil) {
        _leftImageView = [[UIImageView alloc] init];
    }
    return _leftImageView;
}

- (UIImageView *)centerImageView{
    if (_centerImageView == nil) {
        _centerImageView = [[UIImageView alloc] init];
    }
    return _centerImageView;
}

- (UIImageView *)rightImageView{
    if (_rightImageView == nil) {
        _rightImageView = [[UIImageView alloc] init];
    }
    return _rightImageView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.scrollEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:self.timerInterval
                                                  target:self
                                                selector:@selector(autoScroll)
                                                userInfo:nil
                                                 repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 80, CGRectGetHeight(self.frame) - self.pageControlBottomMargin, 40, 20)];
    }
    return _pageControl;
}

@end
