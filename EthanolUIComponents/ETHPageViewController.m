//
//  ETHPageViewController.m
//  Ethanol
//
//  Created by Stephane Copin on 6/30/14.
//  Copyright (c) 2014 Fueled. All rights reserved.
//

#import "ETHPageViewController.h"
#import "ETHPageViewControllerTitleView.h"
#import "ETHPageViewControllerTitleView+Private.h"
#import <EthanolUtilities/EthanolUtilities.h>

@import EthanolUtilities;
@import EthanolTools;

#define kTitleViewHorizontalMargin 80.0f
#define kTitleViewMaxHeight 26.0f

#define kPageControlHeight 6.0f

#define kPageControlTopMargin 2.0f

#define kTitleViewCompactMinimumAlpha 0.45f
#define kTitleViewRegularMinimumAlpha 0.45f

#define kTitleViewDefaultFontSize 17.0

void addSizeConstraintsToView(UIView * view, CGFloat width, CGFloat height) {
	NSLayoutConstraint * widthConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:width];
	NSLayoutConstraint * heightConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:height];
	
	[view.superview addConstraints:@[widthConstraint, heightConstraint]];
}

static NSString * const ETHViewTintColorDidChangeNotification = @"ETHViewTintColorDidChangeNotification";

@interface UIView (TintColorDidChangeNotification)

- (void)ethanol_tintColorDidChange;

@end

@implementation UIView (TintColorDidChangeNotification)

+ (void)load {
	[self eth_swizzleSelector:@selector(tintColorDidChange) withSelector:@selector(ethanol_tintColorDidChange)];
}

- (void)ethanol_tintColorDidChange {
	[self ethanol_tintColorDidChange];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:ETHViewTintColorDidChangeNotification object:self];
}

@end

@interface ETHPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong, readonly) NSArray<UIViewController *> * cachedPageViewControllers;
@property (nonatomic, strong) UIPanGestureRecognizer * panGestureRecognizer;
@property (nonatomic, strong) CADisplayLink * displayLink;
@property (nonatomic, strong) UIScrollView * internalScrollView;
@property (nonatomic, strong) ETHPageViewControllerTitleView * titleView;
@property (nonatomic, strong, readonly) NSMutableArray<UILabel *> * generatedTitleLabels;

@end

@implementation ETHPageViewController
@synthesize cachedPageViewControllers = _cachedPageViewControllers;
@synthesize generatedTitleLabels = _generatedTitleLabels;

- (id)init {
	return [self initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
								 navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
															 options:nil];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
	self = [super initWithCoder:coder];
	if(self != nil) {
		[self ethanol_commonInit];
	}
	return self;
}

- (id)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style
				navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation
											options:(NSDictionary *)options {
	self = [super initWithTransitionStyle:style navigationOrientation:navigationOrientation options:options];
	if(self != nil) {
		[self ethanol_commonInit];
	}
	return self;
}

- (void)ethanol_commonInit {
	[super setDataSource:self];
	[super setDelegate:self];
}

- (void)dealloc {
	[self.displayLink invalidate];
	self.displayLink = nil;
	
	[self removeObserver:self forKeyPath:@"navigationController" context:NULL];
	if(self.navigationController.navigationBar != nil) {
		[self.navigationController.navigationBar removeObserver:self forKeyPath:@"titleTextAttributes" context:NULL];
		
		[[NSNotificationCenter defaultCenter] removeObserver:self name:ETHViewTintColorDidChangeNotification object:self.navigationController.navigationBar];
	}
	
	for(UIViewController * viewController in self.cachedPageViewControllers) {
		[viewController removeObserver:self forKeyPath:@"title" context:NULL];
		[viewController removeObserver:self forKeyPath:@"navigationItem.title" context:NULL];
		[viewController removeObserver:self forKeyPath:@"navigationItem.titleView" context:NULL];
	}
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self addObserver:self forKeyPath:@"navigationController" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:NULL];
	if(self.navigationController.navigationBar != nil) {
		[self.navigationController.navigationBar addObserver:self forKeyPath:@"titleTextAttributes" options:0 context:NULL];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewTintColorDidChangeNotificationHandler:) name:ETHViewTintColorDidChangeNotification object:self.navigationController.navigationBar];
		
		[self updatePageControlsTintColor];
	}
	
	self.titleView = [[ETHPageViewControllerTitleView alloc] init];
	
	NSMutableArray * titleViews = [NSMutableArray array];
	for(UIViewController * viewController in self.cachedPageViewControllers) {
		[titleViews addObject:[self titleViewForViewController:viewController]];
	}
	self.titleView.titleViews = titleViews;
	
	self.navigationItem.titleView = self.titleView;
	self.navigationItem.titleView.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width - 2.0 * kTitleViewHorizontalMargin, self.navigationController.navigationBar.bounds.size.height);
	[self.navigationItem.titleView layoutIfNeeded];
	
	[self setViewControllers:@[self.cachedPageViewControllers.firstObject]
								 direction:UIPageViewControllerNavigationDirectionForward
									animated:NO
								completion:nil];
	
	__weak ETHPageViewController * weakSelf = self;
	self.displayLink = [CADisplayLink eth_displayLinkWithBlock:^(CADisplayLink *displayLink) {
		weakSelf.titleView.currentPosition = [self currentPosition];
	}];
	NSRunLoop *runner = [NSRunLoop currentRunLoop];
	[self.displayLink addToRunLoop:runner forMode:NSRunLoopCommonModes];
	
	self.internalScrollView = (UIScrollView *)[[self class] searchForViewOfType:[UIScrollView class] inView:self.view];
	self.internalScrollView.scrollsToTop = false;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
	if([keyPath isEqualToString:@"navigationController"]) {
		if(self.navigationController.navigationBar != nil) {
			[self.navigationController.navigationBar addObserver:self forKeyPath:@"titleTextAttributes" options:0 context:NULL];
		} else {
			[self.navigationController.navigationBar removeObserver:self forKeyPath:@"titleTextAttributes" context:NULL];
		}
	} else if([keyPath isEqualToString:@"titleTextAttributes"]) {
		for(UILabel * label in self.generatedTitleLabels) {
			label.font = [self.navigationController.navigationBar titleTextAttributes][NSFontAttributeName];
			label.textColor = [self.navigationController.navigationBar titleTextAttributes][NSForegroundColorAttributeName];
		}
	} else if([keyPath isEqualToString:@"title"] || [keyPath isEqualToString:@"navigationItem.title"] || [keyPath isEqualToString:@"navigationItem.titleView"]) {
		UIViewController * viewController = object;
		NSInteger index = [self.cachedPageViewControllers indexOfObject:viewController];
		if(index == NSNotFound || index >= self.titleView.titleViews.count) {
			return;
		}
		
		[self.titleView replaceTitleViewsAtIndexes:[NSIndexSet indexSetWithIndex:index]
																withTitleViews:@[[self titleViewForViewController:viewController]]
																			animated:YES];
	}
}

- (void)viewTintColorDidChangeNotificationHandler:(NSNotification *)notification {
	[self updatePageControlsTintColor];
}

- (void)updatePageControlsTintColor {
	self.titleView.compactPageControl.currentPageIndicatorTintColor = self.navigationController.navigationBar.tintColor;
	self.titleView.compactPageControl.pageIndicatorTintColor = [self.navigationController.navigationBar.tintColor colorWithAlphaComponent:0.25];
	self.titleView.regularPageControl.currentPageIndicatorTintColor = self.navigationController.navigationBar.tintColor;
}

+ (UIView *)searchForViewOfType:(Class)class inView:(UIView *)baseView {
	if([baseView isKindOfClass:[UIScrollView class]]) {
		return baseView;
	}
	
	for(UIView * subview in baseView.subviews) {
		UIView * foundView = [self searchForViewOfType:class inView:subview];
		if(foundView != nil) {
			return foundView;
		}
	}
	return nil;
}

- (NSInteger)currentPage {
	return self.titleView.compactPageControl.currentPage;
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
	[super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
	
	[self.titleView animateTitleToHorizontalSizeClass:newCollection.horizontalSizeClass usingCoordinator:coordinator];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
	
	[self.titleView animateTitleToSize:size usingCoordinator:coordinator];
	
	[self.navigationItem.titleView layoutIfNeeded];
	CGFloat width =  size.width - 2.0 * kTitleViewHorizontalMargin;
	self.navigationItem.titleView.frame = CGRectMake((size.width - width) / 2.0, 0.0, size.width - 2.0 * kTitleViewHorizontalMargin, self.navigationController.navigationBar.bounds.size.height);
}

- (void)willChangeToPage:(NSInteger)page {
	
}

- (void)didChangeToPage:(NSInteger)page {
	
}

- (void)setCurrentPage:(NSInteger)page {
	[self setViewControllers:@[self.cachedPageViewControllers[page]]
								 direction:UIPageViewControllerNavigationDirectionForward
									animated:NO
								completion:nil];
	
	self.titleView.currentPosition = [self currentPosition];
	self.titleView.compactPageControl.currentPage = page;
}

- (UIViewController *)currentViewController {
	return self.cachedPageViewControllers[self.currentPage];
}

- (NSMutableArray *)generatedTitleLabels {
	if(_generatedTitleLabels == nil) {
		_generatedTitleLabels = [NSMutableArray array];
	}
	return _generatedTitleLabels;
}

#pragma mark - UIPageViewController delegate methods

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
			viewControllerBeforeViewController:(UIViewController *)viewController {
	NSInteger page = [self.cachedPageViewControllers indexOfObject:viewController];
	if(--page < 0) {
		return nil;
	}
	
	UIViewController * nextViewController = self.cachedPageViewControllers[page];
	return nextViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
			 viewControllerAfterViewController:(UIViewController *)viewController {
	NSInteger page = [self.cachedPageViewControllers indexOfObject:viewController];
	if(++page >= self.cachedPageViewControllers.count) {
		return nil;
	}
	
	UIViewController * nextViewController = self.cachedPageViewControllers[page];
	return nextViewController;
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
	[self willChangeToPage:[self.cachedPageViewControllers indexOfObject:pendingViewControllers.firstObject]];
}

- (void)pageViewController:(UIPageViewController *)pageViewController
				didFinishAnimating:(BOOL)finished
	 previousViewControllers:(NSArray *)previousViewControllers
			 transitionCompleted:(BOOL)completed {
	NSInteger page = [self.cachedPageViewControllers indexOfObject:pageViewController.viewControllers.firstObject];
	self.titleView.compactPageControl.currentPage = page;
	
	[self didChangeToPage:page];
}

#pragma mark - Custom getters

- (NSArray<UIViewController *> *)cachedPageViewControllers {
	if(_cachedPageViewControllers == nil) {
		_cachedPageViewControllers = self.pageViewControllers;
		for(UIViewController * viewController in _cachedPageViewControllers) {
			[viewController addObserver:self forKeyPath:@"title" options:0 context:NULL];
			[viewController addObserver:self forKeyPath:@"navigationItem.title" options:0 context:NULL];
			[viewController addObserver:self forKeyPath:@"navigationItem.titleView" options:0 context:NULL];
		}
	}
	return _cachedPageViewControllers;
}

- (UIView *)titleViewForViewController:(UIViewController *)viewController {
	if(viewController.navigationItem.titleView != nil) {
		return viewController.navigationItem.titleView;
	} else {
		UILabel * label = [[UILabel alloc] init];
		label.translatesAutoresizingMaskIntoConstraints = NO;
		label.font = [self.navigationController.navigationBar titleTextAttributes][NSFontAttributeName] ?: [UIFont boldSystemFontOfSize:kTitleViewDefaultFontSize];
		label.text = viewController.navigationItem.title ?: viewController.title;
		label.textAlignment = NSTextAlignmentCenter;
		label.textColor = [self.navigationController.navigationBar titleTextAttributes][NSForegroundColorAttributeName];
		NSShadow * shadow = [self.navigationController.navigationBar titleTextAttributes][NSShadowAttributeName];
		if(shadow != nil) {
			label.shadowOffset = shadow.shadowOffset;
			label.shadowColor = shadow.shadowColor;
		}
		
		[label sizeToFit];
		
		[self.generatedTitleLabels addObject:label];
		
		return label;
	}
}

#pragma mark - Helper method

- (BOOL)isRegularHorizontalSizeClass {
	return self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular;
}

- (void)setDelegate:(id<UIPageViewControllerDelegate> _Nullable)delegate {
	ETHLogWarning(@"Warning: Cannot set delegate on a ETHPageViewController (Instance is %@)", self);
}

- (void)setDataSource:(id<UIPageViewControllerDataSource> _Nullable)dataSource {
	ETHLogWarning(@"Warning: Cannot set dataSource on a ETHPageViewController (Instance is %@)", self);
}

- (CGFloat)currentPosition {
	NSUInteger offset = 0;
	UIViewController * firstVisibleViewController;
	while(offset < self.cachedPageViewControllers.count && (firstVisibleViewController = self.cachedPageViewControllers[offset]).view.superview == nil) {
		++offset;
	}
	
	if(offset >= self.cachedPageViewControllers.count) {
		CGFloat offset = self.internalScrollView.contentOffset.x;
		offset /= self.view.frame.size.width;
		return offset;
	}
	
	CGRect rect = [[firstVisibleViewController.view superview] convertRect:firstVisibleViewController.view.frame fromView:self.view];
	rect.origin.x /= self.view.frame.size.width;
	rect.origin.x += (CGFloat)offset;
	return rect.origin.x;
}

@end
