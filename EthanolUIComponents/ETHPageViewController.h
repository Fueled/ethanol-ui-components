//
//  ETHPageViewController.h
//  Ethanol
//
//  Created by Stephane Copin on 6/30/14.
//  Copyright (c) 2014 Fueled. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef UIViewController * __nonnull (^ ETHPageViewControllerFactoryBlock)(void);

@interface ETHPageViewController : UIPageViewController

@property (nonatomic, strong, readonly) UIPageControl * regularPageControl;
@property (nonatomic, strong, readonly) UIPageControl * compactPageControl;
@property (nonatomic, strong, readonly) NSArray<UIViewController *> * pageViewControllers; // Should be overriden in subclasses

@property (nonatomic, strong, readonly) UIViewController * currentViewController;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) UIEdgeInsets titleViewInset;
@property (nonatomic, assign) CGFloat regularTitleViewSpacing; // Defaults to 20.0
@property (nonatomic, assign) UIEdgeInsets titleInset;
@property (nonatomic, assign) UIEdgeInsets pageControlInset;
@property (nonatomic, assign) CGFloat minimumTitleAlpha;

- (void)willChangeToPage:(NSInteger)page; // This method can be overriden in subclass.
- (void)didChangeToPage:(NSInteger)page; // This method can be overriden in subclass.

@end

NS_ASSUME_NONNULL_END
