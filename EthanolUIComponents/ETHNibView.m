//
//  ETHNibView.m
//
//  Created by Stéphane Copin on 12/7/12.
//
//

#import "ETHNibView.h"

@interface ETHNibView ()

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (assign, nonatomic) BOOL shouldAwakeFromNib;

@end

@implementation ETHNibView
@synthesize contentView = _contentView;

- (id)init {
  self = [super init];
	if(self) {
		self.shouldAwakeFromNib = YES;
    [self createFromNib];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if(self) {
    
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
	if(self) {
		self.shouldAwakeFromNib = YES;
    [self createFromNib];
  }
  return self;
}

- (NSString *)nibName {
	return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
  [super awakeFromNib];
	
	self.shouldAwakeFromNib = NO;
  [self createFromNib];
}

- (void)createFromNib {
  if(self.contentView == nil) {
		// IF your code crashes here, you probably forgot to link contentView in IB
		[[NSBundle bundleForClass:[ETHNibView class]] loadNibNamed:[self nibName] owner:self options:nil];
		if(self.shouldAwakeFromNib) {
			[self awakeFromNib];
		}
		
		self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.contentView];
		
		NSLayoutConstraint * leadingConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
		NSLayoutConstraint * topConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
		NSLayoutConstraint * trailingConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
		NSLayoutConstraint * bottomConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
		
		[self addConstraints:@[leadingConstraint, topConstraint, trailingConstraint, bottomConstraint]];
  }
}

@end
