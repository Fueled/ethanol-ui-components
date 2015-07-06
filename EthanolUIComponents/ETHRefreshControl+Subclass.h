//
//  ETHRefreshControl+Subclass.h
//  Ethanol
//
//  Created by Stephane Copin on 5/20/14.
//  Copyright (c) 2014 Fueled. All rights reserved.
//

#import <EthanolUIComponents/ETHRefreshControl.h>

NS_ASSUME_NONNULL_BEGIN

@interface ETHRefreshControl (Subclass)

- (void)updateRefreshControlProgress:(CGFloat)progress pulling:(BOOL)pulling;
- (void)updateRefreshControlLayoutForEvent:(ETHRefreshControlEvent)event;

@end

NS_ASSUME_NONNULL_END
