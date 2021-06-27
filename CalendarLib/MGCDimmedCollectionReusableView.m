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
            [self drawStripPatternWithType:self.viewType];
            
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:r cornerRadius:5];
            [path setLineWidth:1];
            CGContextSetFillColorWithColor(context, self.scheduleBorderColor.CGColor);
            CGContextSetStrokeColorWithColor(context, self.scheduleBorderColor.CGColor);
            [path stroke];
            //[path fill];
            
            UIBezierPath *trianglePath = [UIBezierPath new];
            [trianglePath moveToPoint:(CGPoint){9, r.origin.y + 4}]; //right top
            [trianglePath addLineToPoint:(CGPoint){9, r.origin.y + 10}]; // right bottom
            [trianglePath addLineToPoint:(CGPoint){0, r.origin.y + (r.size.height / 2)}]; // left middle
            [trianglePath addLineToPoint:(CGPoint){9, r.origin.y + 4}]; // right top
            [trianglePath fill];
            r.origin.y = r.origin.y + 1.5;
            [attrSTr drawInRect:r];
        } else if (self.viewType == MCDimmedTypeMiddle) {
            [self drawStripPatternWithType:MCDimmedTypeMiddle];
        }
    }
}

static int extracted(MGCDimmedCollectionReusableView *object) {
    int rightTopX = object.frame.size.width;
    return rightTopX;
}

- (void)drawStripPatternWithType:(MCDimmedCollectionViewType)type {
    int leftY = self.frame.size.height + (type == MCDimmedTypeTop ? - 16 : 0); // left
    
    int numberOfLines = leftY + self.frame.size.width / (self.patternWidth + self.patternOffset);
    int leftX = 0; // left bottom
    
    int rightY = 0 + (type == MCDimmedTypeBottom ? 16 : 0); //;
    int rightX = extracted(self);
    
    for (int j = 1; j <= numberOfLines; ++j) {
        int step = j * (self.patternWidth + self.patternOffset);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetStrokeColorWithColor(context, self.strokeColor.CGColor);
        CGContextSetLineWidth(context, self.patternWidth);
        CGContextMoveToPoint(context, MAX(step - leftY + (type == MCDimmedTypeBottom ? 16 : 0), leftX), MAX(leftY - step, rightY));
        CGContextAddLineToPoint(context, MIN(leftX + step, rightX), MIN(leftY, self.frame.size.width + leftY - step));
        CGContextStrokePath(context);
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
        attrStr = [[NSAttributedString alloc]initWithString:str attributes:@{ NSFontAttributeName: font, NSForegroundColorAttributeName: self.scheduleBorderColor, NSParagraphStyleAttributeName: style }];
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
