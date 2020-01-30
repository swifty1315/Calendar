//
//  MGCDimmedCollectionReusableView.m
//  CalendarLib
//
//  Created by Ilya Borshchov on 8/6/19.
//

#import "MGCDimmedCollectionReusableView.h"
#import "MGCDateRange.h"

@implementation MGCDimmedCollectionReusableView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
    }
    return self;
}
- (void)drawRect:(CGRect)rect {
    
    if (self.shouldDrawShirt && self.viewType != MCDimmedTypeNone) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetStrokeColorWithColor(context, self.strokeColor.CGColor);
        CGContextSetLineWidth(context, self.patternWidth);

        if (self.viewType == MCDimmedTypeBottom || self.viewType == MCDimmedTypeTop) {
            NSAttributedString *attrSTr = [self attributedStringForDateTime: self.viewType == MCDimmedTypeTop ? self.timeRange.end : self.timeRange.start];
            
            CGRect r = CGRectZero;
            if (self.viewType == MCDimmedTypeTop) {
                r = CGRectMake(9, self.frame.size.height - 16, self.frame.size.width - 10, 15);
            } else if (self.viewType == MCDimmedTypeBottom) {
                r = CGRectMake(9, 1, self.frame.size.width - 10, 15);
            }
            
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:r cornerRadius:5];
            [path setLineWidth:1];
            CGContextSetFillColorWithColor(context, self.strokeColor.CGColor);
            CGContextSetStrokeColorWithColor(context, self.strokeColor.CGColor);
            [path stroke];
            
            UIBezierPath *trianglePath = [UIBezierPath new];
            [trianglePath moveToPoint:(CGPoint){9, r.origin.y + 4}]; //right top
            [trianglePath addLineToPoint:(CGPoint){9, r.origin.y + 10}]; // right bottom
            [trianglePath addLineToPoint:(CGPoint){0, r.origin.y + (r.size.height / 2)}]; // left middle
            [trianglePath addLineToPoint:(CGPoint){9, r.origin.y + 4}]; // right top
            [trianglePath fill];
            r.origin.y = r.origin.y + 1.5;
            [attrSTr drawInRect:r];
        } else if (self.viewType == MCDimmedTypeMiddle) {
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
}

- (NSAttributedString*)attributedStringForDateTime:(NSDate*)d
{
    NSAttributedString *attrStr = nil;
    
    if (!attrStr) {
        NSString *str = [self stringForDateTime:d];
        NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
        style.alignment = NSTextAlignmentCenter;
        UIFont *font = [UIFont boldSystemFontOfSize:10];
        attrStr = [[NSAttributedString alloc]initWithString:str attributes:@{ NSFontAttributeName: font, NSForegroundColorAttributeName: self.strokeColor, NSParagraphStyleAttributeName: style }];
    }
    return attrStr;
}

- (NSString*)stringForDateTime:(NSDate*)date
{
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"HH:mm"];
    [df setTimeZone:[NSTimeZone localTimeZone]];
    return [df stringFromDate:date];
}


@end
