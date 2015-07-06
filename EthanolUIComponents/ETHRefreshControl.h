//
//  ETHRefreshControl.h
//  Ethanol
//
//  Created by Stephane Copin on 4/24/14.
//  Copyright (c) 2014 Fueled. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ETHRefreshControlEvent) {
  kETHRefreshControlEventStandingBy,
  kETHRefreshControlEventPulling,
  kETHRefreshControlEventRefreshing,
  kETHRefreshControlEventRefreshingCancelled,
  kETHRefreshControlEventPullingToRefreshing,
  kETHRefreshControlEventResetting,
  kETHRefreshControlEventResetted,
};

@interface ETHRefreshControl : UIControl

@property (nonatomic, weak, readonly, nullable) UIScrollView * scrollView;
@property (nonatomic, assign, getter=isRefreshing, readonly) BOOL refreshing;
@property (nonatomic, assign, readonly, nullable) id<UIScrollViewDelegate> originalDelegate;
@property (nonatomic, assign) CGFloat actualHeight;
@property (nonatomic, assign) CGFloat pullToRefreshHeight;

- (void)beginRefreshing;
- (void)cancelRefreshing;
- (void)endRefreshing;

@end

NS_ASSUME_NONNULL_END
