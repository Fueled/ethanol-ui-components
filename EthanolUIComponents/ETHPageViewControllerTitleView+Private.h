//
//  ETHPageViewControllerTitleView+Private.h
//  EthanolUIComponents
//
//  Created by Stephane Copin on 8/12/15.
//  Copyright © 2015 Stephane Copin. All rights reserved.
//

#import <EthanolUIComponents/ETHPageViewControllerTitleView.h>

@interface ETHPageViewControllerTitleView ()

@property (nonatomic, assign) CGFloat currentPosition;

- (void)animateTitleToHorizontalSizeClass:(UIUserInterfaceSizeClass)horizontalSizeClass usingCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator;
- (void)animateTitleToSize:(CGSize)size usingCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator;

@end
