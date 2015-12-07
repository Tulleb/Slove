//
//  UILabel+MultiLineAutoSize.m
//  Slove
//
//  Created by Guillaume Bellut on 06/12/2015.
//  Copyright © 2015 Tulleb's Corp. All rights reserved.
//

#import "UILabel+MultiLineAutoSize.h"

@implementation UILabel (MultiLineAutoSize)

- (void)adjustFontSizeToFit {
	UIFont *font = self.font;
	CGSize size = self.frame.size;
	
	for (CGFloat maxSize = self.font.pointSize; maxSize >= self.minimumScaleFactor * self.font.pointSize; maxSize -= 1.f) {
		font = [font fontWithSize:maxSize];
		CGSize constraintSize = CGSizeMake(size.width, MAXFLOAT);
		
		CGRect textRect = [self.text boundingRectWithSize:constraintSize
												  options:NSStringDrawingUsesLineFragmentOrigin
											   attributes:@{NSFontAttributeName:font}
												  context:nil];
		
		CGSize labelSize = textRect.size;
		
		if (labelSize.height <= size.height) {
			// Decrease size by 1 because code isn't sufficient enough
			self.font = [font fontWithSize:maxSize - 1];
			[self setNeedsLayout];
			return;
		}
	}
	
	// set the font to the minimum size anyway
	self.font = font;
	[self setNeedsLayout];
}

@end
