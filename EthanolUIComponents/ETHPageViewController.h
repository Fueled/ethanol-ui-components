//
//  ETHPageViewController.h
//  Ethanol
//
//  Created by Stephane Copin on 6/30/14.
//  Copyright (c) 2015 Fueled Digital Media, LLC.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <UIKit/UIKit.h>
#import "ETHPageViewControllerTitleView.h"

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
