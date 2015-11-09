//
//  ETHExtendableTextField+Subclass.h
//  Ethanol
//
//  Created by Stephane Copin on 1/6/15.
//  Copyright (c) 2015 Fueled. All rights reserved.
//

#import "ETHExtendableTextField.h"

NS_ASSUME_NONNULL_BEGIN

@interface ETHExtendableTextField (Subclass) <ETHExtendableTextFieldDelegate>

/**
 *  The proxyDelegate property should be used to call *custom* delegate. For example,
 *  `ETHExtendableTextField` uses `self.proxyDelegate` to call its custom textFieldTextShouldChange: and
 *  textFieldTextDidChange: delegate method, but uses `self.delegate` to call existing UITextField delegate methods.
 */
@property (nonatomic, strong, readonly) id<ETHExtendableTextFieldDelegate> proxyDelegate;

@end

NS_ASSUME_NONNULL_END
