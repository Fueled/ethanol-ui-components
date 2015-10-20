//
//  ETHPageViewController.h
//  Ethanol
//
//  Created by Stephane Copin on 6/30/14.
//  Copyright (c) 2014 Fueled. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EthanolUIComponents/ETHPageViewControllerTitleView.h>

NS_ASSUME_NONNULL_BEGIN

typedef UIViewController * __nonnull (^ ETHPageViewControllerFactoryBlock)(void);

@interface ETHPageViewController : UIPageViewController

@property (nonatomic, strong, readonly) ETHPageViewControllerTitleView * titleView;

@property (nonatomic, strong, readonly) NSArray<UIViewController *> * pageViewControllers; // Should be overriden in subclasses

@property (nonatomic, strong, readonly) UIViewController * currentViewController;
@property (nonatomic, assign) NSInteger currentPage;
- (void)setCurrentPage:(NSInteger)page animated:(BOOL)animated;

- (void)willChangeToPage:(NSInteger)page; // This method can be overriden in subclass.
- (void)didChangeToPage:(NSInteger)page; // This method can be overriden in subclass.

@end

NS_ASSUME_NONNULL_END
