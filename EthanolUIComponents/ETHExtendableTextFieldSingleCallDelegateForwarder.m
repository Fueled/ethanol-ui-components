//
//  ETHExtendedTextFieldSingleCallDelegateForwarder.m
//  Ethanol
//
//  Created by Stephane Copin on 1/7/15.
//  Copyright (c) 2015 Fueled. All rights reserved.
//

#import "ETHExtendableTextFieldSingleCallDelegateForwarder.h"
#import <NSInvocationHelpers/NSInvocation+Helpers.h>

@interface ETHExtendableTextField (ProxyDelegate)

@property (nonatomic, strong, readonly) ETHExtendableTextFieldDelegateProxy * proxyDelegate;

@end

@interface ETHExtendableTextFieldDelegateProxy (DelegateCallInfo)

@property (nonatomic, strong) NSMutableSet * delegateCallInProgressDictionary;
@property (nonatomic, strong) NSLock * delegateCallInProgressDictionaryLock;

@end

@interface ETHExtendableTextFieldSingleCallDelegateForwarder ()

@property (nonatomic, strong) NSMutableDictionary * delegateCallReturnValues;
@property (nonatomic, strong) NSLock * delegateCallReturnValuesLock;

@end

@implementation ETHExtendableTextFieldSingleCallDelegateForwarder

- (instancetype)init
{
  self = [super init];
  if (self) {
    _delegateCallReturnValues = [NSMutableDictionary dictionary];
    _delegateCallReturnValuesLock = [[NSLock alloc] init];
  }
  return self;
}

- (BOOL)isEqual:(id)object {
  return [self.delegate isEqual:object];
}

- (NSUInteger)hash {
  return [self.delegate hash];
}

- (Class)superclass {
  return [self.delegate superclass];
}

- (Class)class {
  return [self.delegate class];
}

- (NSString *)description {
  return [self.delegate description];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (id)performSelector:(SEL)aSelector {
  return [self.delegate performSelector:aSelector];
}

- (id)performSelector:(SEL)aSelector withObject:(id)object {
  return [self.delegate performSelector:aSelector withObject:object];
}

- (id)performSelector:(SEL)aSelector withObject:(id)object1 withObject:(id)object2 {
  return [self.delegate performSelector:aSelector withObject:object1 withObject:object2];
}
#pragma clang diagnostic pop

- (BOOL)isKindOfClass:(Class)aClass {
  return [self.delegate isKindOfClass:aClass];
}

- (BOOL)isMemberOfClass:(Class)aClass {
  return [self.delegate isMemberOfClass:aClass];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
  return [self.delegate conformsToProtocol:aProtocol];
}

- (BOOL)respondsToSelector:(SEL)selector {
  return [self.delegate respondsToSelector:selector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
  return [(id)self.delegate methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
  if([self respondsToSelector:invocation.selector]) {
    BOOL inProgress = NO;
    [self.textField.proxyDelegate.delegateCallInProgressDictionaryLock lock];
    NSDictionary * delegateCallInProgressDictionary = [self.textField.proxyDelegate.delegateCallInProgressDictionary copy];
    [self.textField.proxyDelegate.delegateCallInProgressDictionaryLock unlock];
    for(NSValue * value in delegateCallInProgressDictionary) {
      if((SEL)[value pointerValue] == invocation.selector) {
        inProgress = YES;
        
        [self.delegateCallReturnValuesLock lock];
        if(self.delegateCallReturnValues[value] == nil) {
          [self.delegateCallReturnValuesLock unlock];
          
          [invocation invokeWithTarget:self.delegate];
          
          [self.delegateCallReturnValuesLock lock];
          self.delegateCallReturnValues[value] = [invocation objectReturnValue] ?: [NSNull null];
          [self.delegateCallReturnValuesLock unlock];
        } else {
          [self.delegateCallReturnValuesLock unlock];
          // This won't crash because of NSNull because this is a noop when the method returns void
          [invocation setObjectReturnValue:self.delegateCallReturnValues[value]];
        }
        break;
      }
    }
    
    if(!inProgress) {
      [invocation invokeWithTarget:self.delegate];
    }
  } else {
    [super forwardInvocation:invocation];
  }
}

@end
