//
//  ETHPlaceholderTextView.h
//  Ethanol
//
//  Created by Stephane Copin on 6/17/14.
//  Copyright (c) 2014 Fueled. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
IB_DESIGNABLE

@interface ETHPlaceholderTextView : UITextView

@property (nonatomic, assign) UIEdgeInsets placeholderInsets;

@property (nonatomic, strong) IBInspectable NSString *placeholder;
@property (nonatomic, strong) IBInspectable NSAttributedString *attributedPlaceholder;

@end

NS_ASSUME_NONNULL_END