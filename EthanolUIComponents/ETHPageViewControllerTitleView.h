//
//  ETHPageViewControllerTitleView.h
//  EthanolUIComponents
//
//  Created by Stephane Copin on 8/12/15.
//  Copyright © 2015 Stephane Copin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EthanolUIComponents/ETHNibView.h>

NS_ASSUME_NONNULL_BEGIN

@interface ETHPageViewControllerTitleView : ETHNibView

@property (nonatomic, strong) IBOutlet UIPageControl *regularPageControl;
@property (nonatomic, strong) IBOutlet UIPageControl *compactPageControl;
@property (nonatomic, copy, nullable) NSArray<UIView *> * titleViews;

- (void)replaceTitleViewsAtIndexes:(NSIndexSet *)indexes withTitleViews:(NSArray *)array;

// if animated, indexes.count must be equal to array.count
- (void)replaceTitleViewsAtIndexes:(NSIndexSet *)indexes withTitleViews:(NSArray *)array animated:(BOOL)animated;

@property (nonatomic, assign) UIEdgeInsets titleViewInset;
@property (nonatomic, assign) CGFloat regularTitleViewSpacing; // Defaults to 20.0
@property (nonatomic, assign) UIEdgeInsets titleInset;
@property (nonatomic, assign) UIEdgeInsets pageControlInset;
@property (nonatomic, assign) CGFloat compactMinimumTitleAlpha;
@property (nonatomic, assign) CGFloat regularMinimumTitleAlpha;

@end

NS_ASSUME_NONNULL_END
