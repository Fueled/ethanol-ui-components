//
//  ETHTextField+Subclass.h
//  EthanolUIComponents
//
//  Created by Stephane Copin on 9/10/15.
//  Copyright © 2015 Stephane Copin. All rights reserved.
//

#import "ETHTextField.h"

NS_ASSUME_NONNULL_BEGIN

@interface ETHTextField (Subclass) <ETHTextFieldDelegate>

@property (nonatomic, strong, readonly) id<ETHTextFieldDelegate> proxyDelegate;

@end

NS_ASSUME_NONNULL_END
