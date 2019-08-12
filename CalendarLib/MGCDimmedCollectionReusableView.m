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
        UIColor *color1 = self.strokeColor;
        CGFloat lineWidth = self.patternWidth;
        CGFloat offset = self.patternOffset;
        
        
        int numberOfLines = self.frame.size.height * 2 / (lineWidth + offset) ;
        int leftBottomX = 0; // left bottom
        int leftBottomY = self.frame.size.height; // left bottom and height of block
        
        int rightTopY = 0;
        int rightTopX = self.frame.size.width;
        
        for (int j = 1; j <= numberOfLines; ++j) {
        
            UIBezierPath *linePath = [UIBezierPath bezierPath];
            [linePath setLineWidth:lineWidth];
            int step = j * (lineWidth + offset);
            
            [linePath moveToPoint:CGPointMake(MAX(step - self.frame.size.height, leftBottomX), MAX(leftBottomY - step, rightTopY))];
            [linePath addLineToPoint:CGPointMake(MIN(leftBottomX + step, rightTopX), MIN(leftBottomY, self.frame.size.width + self.frame.size.height - step))];
            [color1 setStroke];
            [linePath stroke];
            
        }
    }
}


@end
