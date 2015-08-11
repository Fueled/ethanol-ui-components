//
//  ETHPageViewController.m
//  Ethanol
//
//  Created by Stephane Copin on 6/30/14.
//  Copyright (c) 2014 Fueled. All rights reserved.
//

#import "ETHPageViewController.h"

@import EthanolUtilities;
@import EthanolTools;

#define kTitleViewHorizontalMargin 80.0f
#define kTitleViewMaxHeight 26.0f

#define kPageControlHeight 6.0f

#define kPageControlTopMargin 2.0f

#define kTitleViewCompactMinimumAlpha 0.45f
#define kTitleViewRegularMinimumAlpha 0.45f

@interface ETHPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong, readonly) NSArray<UIViewController *> * cachedPageViewControllers;
@property (nonatomic, strong, readonly) UIView * titleViewContainer;
@property (nonatomic, strong) UIScrollView * compactTitleScrollView;
@property (nonatomic, strong) UIView * titleView;
@property (nonatomic, strong) UIPanGestureRecognizer * panGestureRecognizer;
@property (nonatomic, strong) CADisplayLink * displayLink;
@property (nonatomic, strong) NSArray<UIView *> * titleViews;
@property (nonatomic, strong) UIImageView * placeholderImageTitleView;
@property (nonatomic, assign) UITraitCollection * targetTraitCollection;
@property (nonatomic, assign) CGSize targetSize;
@property (nonatomic, strong) id<UIViewControllerTransitionCoordinator> targetCoordinator;
@property (nonatomic, strong) UIScrollView * internalScrollView;

@end

@implementation ETHPageViewController
@synthesize compactPageControl = _compactPageControl;
@synthesize regularPageControl = _regularPageControl;
@synthesize titleViewContainer = _titleViewContainer;
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
	
	_compactMinimumTitleAlpha = kTitleViewCompactMinimumAlpha;
	_regularMinimumTitleAlpha = kTitleViewRegularMinimumAlpha;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self generateTitleViewForRegularSizeClass:[self isRegularHorizontalSizeClass] size:self.view.bounds.size];
	self.navigationItem.titleView = self.titleViewContainer;
	
	self.placeholderImageTitleView = [[UIImageView alloc] init];
	[self.titleViewContainer addSubview:self.placeholderImageTitleView];
	
	[self setViewControllers:@[self.cachedPageViewControllers.firstObject]
								 direction:UIPageViewControllerNavigationDirectionForward
									animated:NO
								completion:nil];
	
	__weak ETHPageViewController * weakSelf = self;
	self.displayLink = [CADisplayLink eth_displayLinkWithBlock:^(CADisplayLink *displayLink) {
		[weakSelf updateTitleViewPosition];
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
	return self.compactPageControl.currentPage;
}

- (void)setTitleViewInset:(UIEdgeInsets)titleViewInset {
	_titleViewInset = titleViewInset;
	
	[self regenerateTitleView];
}

- (void)setTitleInset:(UIEdgeInsets)titleInset {
	_titleInset = titleInset;
	
	[self regenerateTitleView];
}

- (void)setPageControlInset:(UIEdgeInsets)pageControlInset {
	_pageControlInset = pageControlInset;
	
	[self regenerateTitleView];
}

- (void)setCompactMinimumTitleAlpha:(CGFloat)compactMinimumTitleAlpha {
	_compactMinimumTitleAlpha = compactMinimumTitleAlpha;
	
	if(![self isRegularHorizontalSizeClass]) {
		[self updateTitleViewPosition];
	}
}

- (void)setRegularMinimumTitleAlpha:(CGFloat)regularMinimumTitleAlpha {
	_regularMinimumTitleAlpha = regularMinimumTitleAlpha;
	
	if([self isRegularHorizontalSizeClass]) {
		[self updateTitleViewPosition];
	}
}

- (void)setRegularTitleViewSpacing:(CGFloat)regularTitleViewSpacing {
	_regularTitleViewSpacing = regularTitleViewSpacing;
	
	[self regenerateTitleView];
}

- (void)regenerateTitleView {
	[self generateTitleViewForRegularSizeClass:[self isRegularHorizontalSizeClass] size:self.view.bounds.size];
}

- (void)willTransitionToTraitCollection:(nonnull UITraitCollection *)newCollection withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
	[super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
	
	self.targetTraitCollection = newCollection;
	self.targetCoordinator = coordinator;
	
	[self tryToUpdateTitle];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
	self.targetSize = size;
	self.targetCoordinator = coordinator;
	
	[self tryToUpdateTitle];
}

- (void)tryToUpdateTitle {
	if(self.targetSize.width >= 0.0 && self.targetTraitCollection != nil && self.targetCoordinator != nil) {
		BOOL isRegularHorizontalSizeClass = self.targetTraitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular;
		[self.targetCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
			[self animationBlockForSwitchingRegularTitleView:isRegularHorizontalSizeClass size:self.targetSize]();
		} completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
			[self animationCompletionBlockForSwitchingRegularTitleView:isRegularHorizontalSizeClass](true);
		}];
		self.targetSize = CGSizeMake(-1.0, -1.0);
		self.targetTraitCollection = nil;
		self.targetCoordinator = nil;
	}
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
	
	[self updateTitleViewPosition];
	self.compactPageControl.currentPage = page;
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
	self.compactPageControl.currentPage = page;
	
	[self didChangeToPage:page];
}

#pragma mark - Custom getters

- (NSArray<UIViewController *> *)cachedPageViewControllers {
	if(_cachedPageViewControllers == nil) {
		_cachedPageViewControllers = self.pageViewControllers;
	}
	return _cachedPageViewControllers;
}

- (UIPageControl *)compactPageControl {
	if(_compactPageControl == nil) {
		_compactPageControl = [[ETHInjector defaultInjector] instanceForClass:[UIPageControl class]];
		_compactPageControl.numberOfPages = self.cachedPageViewControllers.count;
		_compactPageControl.currentPage = 0;
	}
	return _compactPageControl;
}

- (UIPageControl *)regularPageControl {
	if(_regularPageControl == nil) {
		_regularPageControl = [[ETHInjector defaultInjector] instanceForClass:[UIPageControl class]];
		_regularPageControl.numberOfPages = 1;
		_regularPageControl.currentPage = 0;
	}
	return _regularPageControl;
}

- (UIView *)titleViewForViewController:(UIViewController *)viewController forCenterPosition:(CGPoint)centerPosition {
	if(viewController.navigationItem.titleView != nil) {
		return viewController.navigationItem.titleView;
	} else {
		UILabel * (^ createLabelWithSize)(CGSize size) = ^(CGSize size) {
			UILabel * label = [[UILabel alloc] initWithFrame:CGSizeEqualToSize(size, CGSizeZero) ? CGRectZero : CGRectMake(centerPosition.x - size.width / 2.0,
																																																										 centerPosition.y - size.height / 2.0,
																																																										 size.width,
																																																										 size.height)];
			label.font = [[UINavigationBar appearance] titleTextAttributes][NSFontAttributeName];
			label.text = viewController.title ?: viewController.navigationItem.title;
			label.textAlignment = NSTextAlignmentCenter;
			UIColor * textColor = [[UINavigationBar appearance] titleTextAttributes][NSForegroundColorAttributeName];
			if(textColor != nil) {
				label.textColor = [UIColor whiteColor];
			}
			
			if(CGSizeEqualToSize(size, CGSizeZero)) {
				[label sizeToFit];
			}
			
			return label;
		};
		
		// It hurts me a lot having to do that, but it's the fastest workaround.
		// If I don't do this, the sizeToFit will be animated because this method might be called from an animation block...
		// +[UIView performWithoutAnimation] doesn't do it
		return createLabelWithSize(createLabelWithSize(CGSizeZero).bounds.size);
	}
}

- (UIScrollView *)generateCompactTitleScrollView {
	UIScrollView * compactTitleScrollView = [[UIScrollView alloc] init];
	
	CGFloat sizeToUse = self.view.frame.size.width > self.view.frame.size.height ? self.view.frame.size.height : self.view.frame.size.width;
	CGSize size = CGSizeMake(sizeToUse - 2.0 * kTitleViewHorizontalMargin, kTitleViewMaxHeight);
	
	NSMutableArray * views = [NSMutableArray array];
	for(NSInteger i = 0;i < self.cachedPageViewControllers.count;++i) {
		UIViewController * viewController = self.cachedPageViewControllers[i];
		
		UIView * containerView = [[UIView alloc] initWithFrame:CGRectMake(size.width * i, 0.0f, size.width, size.height)];
		containerView.clipsToBounds = false;
		
		UIView * view = [self titleViewForViewController:viewController forCenterPosition:CGPointMake(CGRectGetWidth(containerView.frame) / 2.0, CGRectGetHeight(containerView.frame) / 2.0)];
		
		[containerView addSubview:view];
		[compactTitleScrollView addSubview:containerView];
		[views addObject:view];
	}
	
	self.titleViews = views;
	
	compactTitleScrollView.showsHorizontalScrollIndicator = NO;
	compactTitleScrollView.pagingEnabled = YES;
	compactTitleScrollView.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
	compactTitleScrollView.contentSize = CGSizeMake(size.width * 2.0f, size.height);
	compactTitleScrollView.scrollsToTop = NO;
	
	return compactTitleScrollView;
}

- (UIView *)generateCompactTitleViewWithInitialFrame:(CGRect)frame finalSize:(CGSize *)finalSize {
	UIView * compactTitleView = [[UIView alloc] initWithFrame:frame];
	
	UIScrollView * scrollView = [self generateCompactTitleScrollView];
	
	CGRect titleViewFrame = CGRectMake(0.0f,
																		 0.0f,
																		 scrollView.frame.size.width,
																		 scrollView.frame.size.height + kPageControlTopMargin + kPageControlHeight);
	
	CGRect pageControlFrame = CGRectMake(0.0f,
																			 scrollView.frame.size.height + kPageControlTopMargin,
																			 scrollView.frame.size.width,
																			 kPageControlHeight);
	
	titleViewFrame = UIEdgeInsetsInsetRect(titleViewFrame, self.titleInset);
	pageControlFrame = UIEdgeInsetsInsetRect(pageControlFrame, self.pageControlInset);
	
	titleViewFrame = UIEdgeInsetsInsetRect(titleViewFrame, self.titleViewInset);
	pageControlFrame = UIEdgeInsetsInsetRect(pageControlFrame, self.titleViewInset);
	
	[compactTitleView addSubview:scrollView];
	[compactTitleView addSubview:self.compactPageControl];
	
	*finalSize = titleViewFrame.size;
	self.compactPageControl.frame = pageControlFrame;
	
	self.compactTitleScrollView = scrollView;
	
	return compactTitleView;
}

- (UIView *)generateRegularTitleViewWithInitialFrame:(CGRect)frame finalSize:(CGSize *)finalSize {
	UIView * regularTitleView = [[UIView alloc] initWithFrame:frame];
	
	CGSize maxSize;
	for(UIViewController * viewController in self.cachedPageViewControllers) {
		UIView * viewControllerTitleView = [self titleViewForViewController:viewController forCenterPosition:CGPointZero];

		maxSize.width = MAX(maxSize.width, viewControllerTitleView.bounds.size.width);
		maxSize.height = MAX(maxSize.height, viewControllerTitleView.bounds.size.height);
	}
	
	CGSize titleViewSize = CGSizeMake(maxSize.width * self.cachedPageViewControllers.count + self.regularTitleViewSpacing * (self.cachedPageViewControllers.count - 1),
																		maxSize.height);
	
	CGFloat currentCenterX = 0.0;
	NSMutableArray * views = [NSMutableArray array];
	for(UIViewController * viewController in self.cachedPageViewControllers) {
		currentCenterX += maxSize.width / 2.0;
		UIView * viewControllerTitleView = [self titleViewForViewController:viewController forCenterPosition:CGPointMake(currentCenterX, maxSize.height / 2.0)];
		[regularTitleView addSubview:viewControllerTitleView];
		[views addObject:viewControllerTitleView];
		currentCenterX += maxSize.width / 2.0 + self.regularTitleViewSpacing;
	}
	
	self.titleViews = views;
	
	*finalSize = CGSizeMake(titleViewSize.width, titleViewSize.height + kPageControlTopMargin + kPageControlHeight);
	
	[regularTitleView addSubview:self.regularPageControl];
	
	self.regularPageControl.frame = CGRectMake([self regularPageControlPositionFromPagePosition:[self currentPosition]] - titleViewSize.width / 2.0,
																						 titleViewSize.height + kPageControlTopMargin,
																						 titleViewSize.width,
																						 kPageControlHeight);
	
	return regularTitleView;
}

- (UIView *)titleViewContainer {
	if(_titleViewContainer == nil) {
		_titleViewContainer = [[UIView alloc] init];
	}
	return _titleViewContainer;
}

- (void)generateTitleViewForRegularSizeClass:(BOOL)regular size:(CGSize)size {
	if(self.titleView != nil) {
		[self.placeholderImageTitleView removeFromSuperview];
		self.placeholderImageTitleView = [[UIImageView alloc] initWithFrame:self.titleView.frame];
		self.placeholderImageTitleView.image = [self snapshotOfView:self.titleView];
		[self.titleView.superview addSubview:self.placeholderImageTitleView];
		self.placeholderImageTitleView.alpha = 0.0;
	}
	
	CGRect initialFrame = self.titleView.frame;
	CGSize finalSize = CGSizeZero;
	
	[self.titleView removeFromSuperview];
	if(regular) {
		self.titleView = [self generateRegularTitleViewWithInitialFrame:initialFrame finalSize:&finalSize];
	} else {
		self.titleView = [self generateCompactTitleViewWithInitialFrame:initialFrame finalSize:&finalSize];
	}
	
	[self.titleViewContainer addSubview:self.titleView];
	
	self.titleViewContainer.frame = CGRectMake(self.titleViewContainer.frame.origin.x,
																						 self.titleViewContainer.frame.origin.y,
																						 size.width - 2.0 * kTitleViewHorizontalMargin,
																						 size.height);
	
	CGPoint center = CGPointMake(CGRectGetMidX(self.titleViewContainer.bounds), CGRectGetMidY(self.titleViewContainer.bounds));
	self.titleView.frame = CGRectMake(center.x - finalSize.width / 2.0, center.y - finalSize.height / 2.0, finalSize.width, finalSize.height);
	if(!regular) {
		self.compactPageControl.frame = CGRectMake(0.0,
																							 self.compactPageControl.frame.origin.y,
																							 finalSize.width,
																							 self.compactPageControl.frame.size.height);
	}
	self.placeholderImageTitleView.center = center;
}

#pragma mark - Helper method

- (void)updateTitleViewPosition {
	CGFloat position = [self currentPosition];
	self.compactTitleScrollView.contentOffset = [self compactTitleScrollViewContentOffsetFromPagePosition:position];
	self.regularPageControl.center = CGPointMake([self regularPageControlPositionFromPagePosition:position], self.regularPageControl.center.y);
	
	[self updateTitleViewAlphaWithPosition:position];
}

- (CGPoint)compactTitleScrollViewContentOffsetFromPagePosition:(CGFloat)pagePosition {
	return CGPointMake(pagePosition * self.titleView.frame.size.width, 0.0f);
}

- (CGFloat)regularPageControlPositionFromPagePosition:(CGFloat)pagePosition {
	return pagePosition * CGRectGetWidth(self.titleViews.firstObject.bounds) + CGRectGetMidX(self.titleViews.firstObject.bounds);
}

- (void)updateTitleViewAlphaWithPosition:(CGFloat)position {
	if([self isRegularHorizontalSizeClass]) {
		for(UIView * view in self.titleViews) {
			view.alpha = 1.0;
		}
		return;
	}
	
	CGFloat minimumTitleAlpha = [self isRegularHorizontalSizeClass] ? self.regularMinimumTitleAlpha : self.compactMinimumTitleAlpha;
	CGFloat (^ calculateProgress)(CGFloat, CGFloat) = ^CGFloat(CGFloat origin, CGFloat offset) {
		offset -= origin;
		offset  = (CGFloat)fabs(offset);
		// Linear function
		CGFloat a = (1.0f - minimumTitleAlpha) / (0.0f - 0.5f);
		CGFloat b = 1.0f - a * 0.0f;
		offset = a * offset + b;
		if(offset < minimumTitleAlpha) {
			return minimumTitleAlpha;
		} else if(offset > 1.0f) {
			return 1.0f;
		}
		return offset;
	};
	
	NSUInteger count = self.titleViews.count;
	for(NSUInteger i = 0;i < count;++i) {
		self.titleViews[i].alpha = calculateProgress(i * 1.0f, position);
	}
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

- (void(^)(void))animationBlockForSwitchingRegularTitleView:(BOOL)doSwitch size:(CGSize)size {
	[self generateTitleViewForRegularSizeClass:doSwitch size:size];
	self.titleView.alpha = 0.0;
	self.placeholderImageTitleView.alpha = 1.0;
	
	return ^{
		self.titleView.alpha = 1.0;
		self.placeholderImageTitleView.alpha = 0.0;
	};
}

- (void(^)(BOOL))animationCompletionBlockForSwitchingRegularTitleView:(BOOL)doSwitch {
	if([self isRegularHorizontalSizeClass] == doSwitch) {
		return ^(BOOL finished) {};
	}
	
	return ^(BOOL finished) {
		[self.placeholderImageTitleView removeFromSuperview];
		self.placeholderImageTitleView = nil;
	};
}

- (BOOL)isRegularHorizontalSizeClass {
	return self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular;
}

- (void)setDelegate:(id<UIPageViewControllerDelegate> _Nullable)delegate {
	ETHLogWarning(@"Warning: Cannot set delegate on a ETHPageViewController (Instance is %@)", self);
}

- (void)setDataSource:(id<UIPageViewControllerDataSource> _Nullable)dataSource {
	ETHLogWarning(@"Warning: Cannot set dataSource on a ETHPageViewController (Instance is %@)", self);
}

- (UIImage *)snapshotOfView:(UIView *)view {
	UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
	[view.layer renderInContext:UIGraphicsGetCurrentContext()];
	
	UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	return image;
}

@end
