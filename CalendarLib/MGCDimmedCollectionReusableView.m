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
        CGFloat patternWidth = 1;
        CGFloat offset = 12;
        
        self.itemHeight = 65;
        
        int numberOfLinesInBlock = self.frame.size.height * 2 / (patternWidth + offset) ;
        int numberOfIterations = numberOfLinesInBlock;
        int leftBottomX = 0; // left bottom
        int leftBottomY = self.itemHeight; // left bottom and height of block
        
        CGFloat height = self.frame.size.height + 100; // + 100 is castil
        int numberOfBlocksInColumn = height / self.itemHeight;
        
        for (int j = 0; j < numberOfBlocksInColumn; ++j) {
            // left y
            int currentStartY = leftBottomY * j > 0 ? leftBottomY * j : leftBottomY;
            
            for (int i = 0; i < numberOfIterations; ++i){
                UIBezierPath *linePath = [UIBezierPath bezierPath];
                [linePath setLineWidth:patternWidth];
                int step = i * (patternWidth + offset) > 0 ?  i * (patternWidth + offset) :  patternWidth + offset;
                
                [linePath moveToPoint:CGPointMake(0, currentStartY - step)];
                [linePath addLineToPoint:CGPointMake(leftBottomX + step, currentStartY)];
                [color1 setStroke];
                [linePath stroke];
            }
        }
    }
}


@end
