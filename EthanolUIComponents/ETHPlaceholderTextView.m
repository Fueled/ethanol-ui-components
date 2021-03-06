//
//  ETHPlaceholderTextView.m
//  Ethanol
//
//  Created by Stephane Copin on 6/17/14.
//  Copyright (c) 2014 Fueled Digital Media, LLC.
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

#import "ETHPlaceholderTextView.h"

#define kDefaultPlaceholderInset UIEdgeInsetsMake(8.0f, 4.0f, 9.0f, 4.0f)

@interface ETHPlaceholderTextView ()

@property (nonatomic, strong) UILabel *placeholderLabel;

@end

@implementation ETHPlaceholderTextView

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self commonInit];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		[self commonInit];
	}
	return self;
}

- (void)commonInit {
	self.placeholderInsets = kDefaultPlaceholderInset;

	UILabel *placeholderLabel = [[UILabel alloc] init];
	placeholderLabel.font = self.font;

	[self updatePlaceholderFrame];
	[self addSubview:placeholderLabel];
	self.placeholderLabel = placeholderLabel;

	[[NSNotificationCenter defaultCenter] addObserver:self
																					 selector:@selector(handleTextViewDidBeginEditing:)
																							 name:UITextViewTextDidBeginEditingNotification
																						 object:self];
	[[NSNotificationCenter defaultCenter] addObserver:self
																					 selector:@selector(handleTextViewDidChange:)
																							 name:UITextViewTextDidChangeNotification
																						 object:self];
	[[NSNotificationCenter defaultCenter] addObserver:self
																					 selector:@selector(handleTextViewDidEndEditing:)
																							 name:UITextViewTextDidEndEditingNotification
																						 object:self];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setText:(NSString *)text {
	[super setText:text];

	[self updatePlaceholderVisibility];
}

- (void)layoutSubviews {
	[super layoutSubviews];

	[self updatePlaceholderFrame];
}

- (void)updatePlaceholderFrame {
	self.placeholderLabel.frame = UIEdgeInsetsInsetRect(self.bounds, self.placeholderInsets);
	[self.placeholderLabel sizeToFit];
}

- (void)setFont:(UIFont *)font {
	[super setFont:font];

	self.placeholderLabel.font = font;
}

- (NSString *)placeholder {
	return self.placeholderLabel.text;
}

- (void)setPlaceholder:(NSString *)placeholder {
	self.placeholderLabel.text = placeholder;

	[self updatePlaceholderFrame];
}

- (NSAttributedString *)attributedPlaceholder {
	return self.placeholderLabel.attributedText;
}

- (void)setAttributedPlaceholder:(NSAttributedString *)attributedPlaceholder {
	self.placeholderLabel.attributedText = attributedPlaceholder;

	[self updatePlaceholderFrame];
}

- (void)handleTextViewDidBeginEditing:(NSNotification *)notification {
	[self updatePlaceholderVisibility];
}

- (void)handleTextViewDidChange:(NSNotification *)notification {
	[self updatePlaceholderVisibility];
}

- (void)handleTextViewDidEndEditing:(NSNotification *)notification {
	[self updatePlaceholderVisibility];
}

- (void)updatePlaceholderVisibility {
	self.placeholderLabel.hidden = self.text.length > 0;
	[self sendSubviewToBack:self.placeholderLabel];
}

@end
