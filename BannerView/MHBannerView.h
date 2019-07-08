//
//  MHBannerView.h
//  TempOC
//
//  Created by luomh on 2019/7/4.
//  Copyright © 2019 luomh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MHBannerView : UIView


- (void)showWithImageUrls:(NSArray<NSString *> *)imageUrls;

- (void)showWithImageNames:(NSArray<NSString *> *)imageNames;

- (void)showWithImagePaths:(NSArray<NSString *> *)paths;

@end

NS_ASSUME_NONNULL_END
