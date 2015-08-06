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

#define kTitleViewMinimumAlpha 0.45f

@interface ETHPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong, readonly) NSArray<UIViewController *> * cachedPageViewControllers;
@property (nonatomic, strong, readonly) UIScrollView * titleScrollView;
@property (nonatomic, strong, readonly) UIView * titleView;
@property (nonatomic, strong) UIPanGestureRecognizer * panGestureRecognizer;
@property (nonatomic, strong) CADisplayLink * displayLink;
@property (nonatomic, strong) NSArray<UIView *> * titleViews;

@end

@implementation ETHPageViewController
@synthesize pageControl     = _pageControl;
@synthesize titleScrollView = _titleScrollView;
@synthesize titleView       = _titleView;
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
	
	_minimumTitleAlpha = kTitleViewMinimumAlpha;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.navigationItem.titleView = self.titleView;
	
	[self setViewControllers:@[self.cachedPageViewControllers.firstObject]
								 direction:UIPageViewControllerNavigationDirectionForward
									animated:NO
								completion:nil];
	
	self.pageControl.currentPage = 0;
	
	__weak ETHPageViewController * weakSelf = self;
	self.displayLink = [CADisplayLink eth_displayLinkWithBlock:^(CADisplayLink *displayLink) {
		[weakSelf updateTitleViewPosition];
	}];
	NSRunLoop *runner = [NSRunLoop currentRunLoop];
	[self.displayLink addToRunLoop:runner forMode:NSRunLoopCommonModes];
	
	UIScrollView * innerScrollView = (UIScrollView *)[[self class] searchForViewOfType:[UIScrollView class] inView:self.view];
	innerScrollView.scrollsToTop = false;
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
	return self.pageControl.currentPage;
}

- (void)setTitleViewInset:(UIEdgeInsets)titleViewInset {
	_titleViewInset = titleViewInset;
	
	[self invalidateTitleView];
}

- (void)setTitleInset:(UIEdgeInsets)titleInset {
	_titleInset = titleInset;
	
	[self invalidateTitleView];
}

- (void)setPageControlInset:(UIEdgeInsets)pageControlInset {
	_pageControlInset = pageControlInset;
	
	[self invalidateTitleView];
}

- (void)setMinimumTitleAlpha:(CGFloat)minimumTitleAlpha {
	_minimumTitleAlpha = minimumTitleAlpha;
	
	[self updateTitleViewPosition];
}

- (void)invalidateTitleView {
	_titleView = nil;
	
	self.navigationItem.titleView = self.titleView;
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
	self.pageControl.currentPage = page;
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
	self.pageControl.currentPage = page;
	
	[self didChangeToPage:page];
}

#pragma mark - Custom getters

- (NSArray<UIViewController *> *)cachedPageViewControllers {
	if(_cachedPageViewControllers == nil) {
		_cachedPageViewControllers = self.pageViewControllers;
	}
	return _cachedPageViewControllers;
}

- (UIPageControl *)pageControl {
	if(_pageControl == nil) {
		_pageControl = [[ETHInjector defaultInjector] instanceForClass:[UIPageControl class]];
		_pageControl.numberOfPages = self.cachedPageViewControllers.count;
		_pageControl.currentPage = 0;
	}
	return _pageControl;
}

- (UIScrollView *)titleScrollView {
	if(_titleScrollView == nil) {
		UIScrollView * titleScrollView = [[UIScrollView alloc] init];
		
		CGSize size = CGSizeMake(self.view.frame.size.width - kTitleViewHorizontalMargin * 2.0f, kTitleViewMaxHeight);
		
		NSMutableArray * views = [NSMutableArray array];
		for(NSInteger i = 0;i < self.cachedPageViewControllers.count;++i) {
			UIViewController * viewController = self.cachedPageViewControllers[i];
			UIView * view;
			if(viewController.navigationItem.titleView != nil) {
				view = viewController.navigationItem.titleView;
			} else {
				UILabel * label = [[UILabel alloc] init];
				label.font = [[UINavigationBar appearance] titleTextAttributes][NSFontAttributeName];
				label.text = viewController.title;
				label.textAlignment = NSTextAlignmentCenter;
				UIColor * textColor = [[UINavigationBar appearance] titleTextAttributes][NSForegroundColorAttributeName];
				if(textColor != nil) {
					label.textColor = [UIColor whiteColor];
				}
				label.frame = CGRectMake(size.width * i, 0.0f, size.width, size.height);
				
				view = label;
			}
			
			[titleScrollView addSubview:view];
			[views addObject:view];
		}
		
		self.titleViews = views;
		
		titleScrollView.showsHorizontalScrollIndicator = NO;
		titleScrollView.pagingEnabled = YES;
		titleScrollView.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
		titleScrollView.contentSize = CGSizeMake(size.width * 2.0f, size.height);
		titleScrollView.scrollsToTop = false;
		_titleScrollView = titleScrollView;
	}
	return _titleScrollView;
}

- (UIView *)titleView {
	if(_titleView == nil) {
		UIView * titleView = [[UIView alloc] initWithFrame:self.titleScrollView.frame];
		
		CGRect titleViewFrame = CGRectMake(0.0f,
																			 0.0f,
																			 self.titleScrollView.frame.size.width,
																			 self.titleScrollView.frame.size.height + kPageControlTopMargin + kPageControlHeight);
		
		CGRect pageControlFrame = CGRectMake(0.0f,
																				 self.titleScrollView.frame.size.height + kPageControlTopMargin,
																				 titleView.frame.size.width,
																				 kPageControlHeight);
		
		titleViewFrame = UIEdgeInsetsInsetRect(titleViewFrame, self.titleInset);
		pageControlFrame = UIEdgeInsetsInsetRect(pageControlFrame, self.pageControlInset);
		
		titleViewFrame = UIEdgeInsetsInsetRect(titleViewFrame, self.titleViewInset);
		pageControlFrame = UIEdgeInsetsInsetRect(pageControlFrame, self.titleViewInset);
		
		titleView.frame = titleViewFrame;
		self.pageControl.frame = pageControlFrame;
		
		[titleView addSubview:_titleScrollView];
		[titleView addSubview:self.pageControl];
		
		titleView.clipsToBounds = NO;
		titleView.userInteractionEnabled = NO;
		_titleView = titleView;
	}
	return _titleView;
}

#pragma mark - Helper method

- (void)updateTitleViewPosition {
	CGFloat position = [self currentPosition];
	[self.titleScrollView setContentOffset:CGPointMake(position * self.titleView.frame.size.width, 0.0f)];
	
	[self updateTitleViewAlphaWithPosition:position];
}

- (void)updateTitleViewAlphaWithPosition:(CGFloat)position {
	CGFloat (^ calculateProgress)(CGFloat, CGFloat) = ^CGFloat(CGFloat origin, CGFloat offset) {
		offset -= origin;
		offset  = (CGFloat)fabs(offset);
		// Linear function
		CGFloat a = (1.0f - self.minimumTitleAlpha) / (0.0f - 0.5f);
		CGFloat b = 1.0f - a * 0.0f;
		offset = a * offset + b;
		if(offset < self.minimumTitleAlpha) {
			return self.minimumTitleAlpha;
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
	while((firstVisibleViewController = self.cachedPageViewControllers[offset]).view.superview == nil) {
		++offset;
	}
	CGRect rect = [[firstVisibleViewController.view superview] convertRect:firstVisibleViewController.view.frame fromView:self.view];
	rect.origin.x /= self.view.frame.size.width;
	rect.origin.x += (CGFloat)offset;
	return rect.origin.x;
}

- (void)setDelegate:(id<UIPageViewControllerDelegate> _Nullable)delegate {
	ETHLogWarning(@"Warning: Cannot set delegate on a ETHPageViewController (Instance is %@)", self);
}

- (void)setDataSource:(id<UIPageViewControllerDataSource> _Nullable)dataSource {
	ETHLogWarning(@"Warning: Cannot set dataSource on a ETHPageViewController (Instance is %@)", self);
}

@end
