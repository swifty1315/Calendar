//
//  MGCDimmedCollectionReusableView.m
//  CalendarLib
//
//  Created by Ilya Borshchov on 8/6/19.
//

#import "MGCDimmedCollectionReusableView.h"

@implementation MGCDimmedCollectionReusableView

- (void)drawRect:(CGRect)rect {
    
    if (self.shouldDrawShirt) {
        int numberOfLines = self.frame.size.height + self.frame.size.width / (self.patternWidth + self.patternOffset) ;
        int leftBottomX = 0; // left bottom
        int leftBottomY = self.frame.size.height; // left bottom and height of block
        
        int rightTopY = 0;
        int rightTopX = self.frame.size.width;
        
        for (int j = 1; j <= numberOfLines; ++j) {
            int step = j * (self.patternWidth + self.patternOffset);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetStrokeColorWithColor(context, self.strokeColor.CGColor);
            CGContextSetLineWidth(context, self.patternWidth);
            CGContextMoveToPoint(context, MAX(step - self.frame.size.height, leftBottomX), MAX(leftBottomY - step, rightTopY));
            CGContextAddLineToPoint(context, MIN(leftBottomX + step, rightTopX), MIN(leftBottomY, self.frame.size.width + self.frame.size.height - step));
            CGContextStrokePath(context);
        }
    }
}


@end
