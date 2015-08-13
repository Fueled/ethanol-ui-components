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

@import EthanolUtilities;
@import EthanolTools;

#define kTitleViewHorizontalMargin 80.0f
#define kTitleViewMaxHeight 26.0f

#define kPageControlHeight 6.0f

#define kPageControlTopMargin 2.0f

#define kTitleViewCompactMinimumAlpha 0.45f
#define kTitleViewRegularMinimumAlpha 0.45f

void addSizeConstraintsToView(UIView * view, CGFloat width, CGFloat height) {
	NSLayoutConstraint * widthConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:width];
	NSLayoutConstraint * heightConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:height];
	
	[view.superview addConstraints:@[widthConstraint, heightConstraint]];
}

@interface ETHPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong, readonly) NSArray<UIViewController *> * cachedPageViewControllers;
@property (nonatomic, strong) UIPanGestureRecognizer * panGestureRecognizer;
@property (nonatomic, strong) CADisplayLink * displayLink;
@property (nonatomic, strong) UIScrollView * internalScrollView;
@property (nonatomic, strong) ETHPageViewControllerTitleView * titleView;

@end

@implementation ETHPageViewController
@synthesize cachedPageViewControllers = _cachedPageViewControllers;

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

- (void)viewDidLoad
{
	[super viewDidLoad];
	
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

- (void)dealloc {
	[self.displayLink invalidate];
	self.displayLink = nil;
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
	}
	return _cachedPageViewControllers;
}

- (UIView *)titleViewForViewController:(UIViewController *)viewController {
	if(viewController.navigationItem.titleView != nil) {
		return viewController.navigationItem.titleView;
	} else {
		UILabel * label = [[UILabel alloc] init];
		label.translatesAutoresizingMaskIntoConstraints = NO;
		label.font = [[UINavigationBar appearance] titleTextAttributes][NSFontAttributeName];
		label.text = viewController.title ?: viewController.navigationItem.title;
		label.textAlignment = NSTextAlignmentCenter;
		UIColor * textColor = [[UINavigationBar appearance] titleTextAttributes][NSForegroundColorAttributeName];
		if(textColor != nil) {
			label.textColor = [UIColor whiteColor];
		}
		
		[label sizeToFit];
		
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
