//
//  MGCTimeRowsView.m
//  Graphical Calendars Library for iOS
//
//  Distributed under the MIT License
//  Get the latest version from here:
//
//    https://github.com/jumartin/Calendar
//
//  Copyright (c) 2014-2015 Julien Martin
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "MGCTimeRowsView.h"
#import "NSCalendar+MGCAdditions.h"
#import "MGCAlignedGeometry.h"


@interface MGCTimeRowsView()

@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSUInteger rounding;
@property (nonatomic) NSString *templateTime;
@property (nonatomic) CGRect hourStringRect;
@property (nonatomic) CGRect minuteStringRect;

@end


@implementation MGCTimeRowsView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        _calendar = [NSCalendar currentCalendar];
        _hourSlotHeight = 65;
        _insetsHeight = 45;
        _timeColumnWidth = 40;
        _hourFont = [UIFont boldSystemFontOfSize:10];
        _halfHourFont = [UIFont systemFontOfSize:8];
        _timeColor = [UIColor lightGrayColor];
        _minuteStepColor = [UIColor lightGrayColor];
        _currentTimeColor = [UIColor redColor];
        _rounding = 15;
        _hourRange = NSMakeRange(0, 24);
        _accentColor = [UIColor blueColor];
        _templateTime = @"12:30";
        
        _hourStringRect = [_templateTime boundingRectWithSize:CGSizeMake(9999, 50) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: _hourFont} context:nil];
        _minuteStringRect = [_templateTime boundingRectWithSize:CGSizeMake(9999, 50) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: _halfHourFont} context:nil];
        
        self.showsCurrentTime = YES;
    }
    return self;
}

- (void)setWorktimeValues:(MGCWorktimeValues)worktimeValues {
    _worktimeValues = worktimeValues;
    [self setNeedsDisplay];
}

- (void)setShowsCurrentTime:(BOOL)showsCurrentTime
{
    _showsCurrentTime = showsCurrentTime;
    
    [self.timer invalidate];
    if (_showsCurrentTime) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(timeChanged:) userInfo:nil repeats:YES];
    }
    
    [self setNeedsDisplay];
}

- (BOOL)showsHalfHourLines
{
    return self.hourSlotHeight > (((self.minuteStringRect.size.height / 3) + 2) * 12);
}

- (BOOL)showsFifteenHourLines
{
    return self.hourSlotHeight > (((self.minuteStringRect.size.height / 3) + 4) * 12);
}

- (void)setHourRange:(NSRange)hourRange
{
    NSAssert(hourRange.length >= 1 && NSMaxRange(hourRange) <= 24, @"Invalid hour range %@", NSStringFromRange(hourRange));
    _hourRange = hourRange;
}

- (void)setTimeMark:(NSTimeInterval)timeMark
{
    _timeMark = timeMark;
    [self setNeedsDisplay];
}

- (void)timeChanged:(NSDictionary*)dictionary
{
    [self setNeedsDisplay];
}

// time is the interval since the start of the day.
// result can be negative if hour range doesn't start at 0
- (CGFloat)yOffsetForTime:(NSTimeInterval)time rounded:(BOOL)rounded
{
    if (rounded) {
        time = roundf(time / (self.rounding * 60)) * (self.rounding * 60);
    }
    return (time / 3600. - self.hourRange.location) * self.hourSlotHeight + self.insetsHeight;
}

// time is the interval since the start of the day
- (NSString*)stringForTime:(NSTimeInterval)time rounded:(BOOL)rounded minutesOnly:(BOOL)minutesOnly
{
    if (rounded && !minutesOnly) {
        time = roundf(time / (self.rounding * 60)) * (self.rounding * 60);
    }
    
    int hour = (int)(time / 3600) % 24;
    int minutes = ((int)time % 3600) / 60;

    if (minutesOnly) {
        return [NSString stringWithFormat:@":%02d", minutes];
    }
    // show only hours for week view
    if (self.viewType == MGCWeekViewType && rounded == YES) {
        return [NSString stringWithFormat:@"%02d", hour];
    }
    return [NSString stringWithFormat:@"%02d:%02d", hour, minutes];
}

- (NSAttributedString*)attributedStringForTimeMark:(MGCDayPlannerTimeMark)mark time:(NSTimeInterval)ti
{
    NSAttributedString *attrStr = nil;
    
    if ([self.delegate respondsToSelector:@selector(timeRowsView:attributedStringForTimeMark:time:)]) {
        attrStr = [self.delegate timeRowsView:self attributedStringForTimeMark:mark time:ti];
    }
    
    if (!attrStr) {
        BOOL rounded = (mark != MGCDayPlannerTimeMarkCurrent);
        BOOL minutesOnly = (mark == MGCDayPlannerTimeMarkFloating || (mark == MGCDayPlannerTimeMarkHalf && self.viewType == MGCWeekViewType));
    
        NSString *str = [self stringForTime:ti rounded:rounded minutesOnly:minutesOnly];
    
        NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
        style.alignment = mark == MGCDayPlannerTimeMarkCurrent ? NSTextAlignmentCenter : NSTextAlignmentRight;
        
        UIColor *foregroundColor = [UIColor lightGrayColor];
        
        if (mark == MGCDayPlannerTimeMarkCurrent) {
            foregroundColor = [UIColor whiteColor];
        } else if (mark == MGCDayPlannerTimeMarkHalf) {
            foregroundColor = self.minuteStepColor;
        } else if (mark == MGCDayPlannerTimeMarkDivider) {
            foregroundColor = self.accentColor;
        } else {
            foregroundColor = self.accentColor;
        }
        
        UIFont *font = (mark == MGCDayPlannerTimeMarkHalf) ? self.halfHourFont : self.hourFont;
        
        attrStr = [[NSAttributedString alloc]initWithString:str attributes:@{ NSFontAttributeName: font, NSForegroundColorAttributeName: foregroundColor, NSParagraphStyleAttributeName: style }];
    }
    return attrStr;
}

- (BOOL)canDisplayTime:(NSTimeInterval)ti
{
    CGFloat hour = ti/3600.;
    return hour >= self.hourRange.location && hour <= NSMaxRange(self.hourRange);
}

- (void)drawRect:(CGRect)rect
{
    const CGFloat kSpacing = 6;
    const CGSize kCurrentTimeSize = CGSizeMake(52, 17);
    const CGFloat dash[2]= {2, 3};
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGSize markSizeMax = CGSizeMake(self.timeColumnWidth - 2.*kSpacing, CGFLOAT_MAX);
    
    // calculate rect for current time mark
    NSDateComponents *comps = [self.calendar components:NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:[NSDate date]];
    NSTimeInterval currentTime = comps.hour*3600.+comps.minute*60.+comps.second;
    
    NSAttributedString *markAttrStr = [self attributedStringForTimeMark:MGCDayPlannerTimeMarkCurrent time:currentTime];
    CGSize markSize = [markAttrStr boundingRectWithSize:markSizeMax options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    CGFloat y = [self yOffsetForTime:currentTime rounded:NO];
    CGRect rectCurTime = CGRectZero;
    
    // draw current time mark
    if (self.showsCurrentTime && [self canDisplayTime:currentTime]) {
        
        //[markAttrStr drawInRect:rectCurTime];
        CGRect lineRect = CGRectMake(self.timeColumnWidth - kSpacing, y, self.bounds.size.width - self.timeColumnWidth + kSpacing, 1);
        CGContextSetFillColorWithColor(context, self.currentTimeColor.CGColor);
        UIRectFill(lineRect);
        
        //draw rectangle with time label where time label inside
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, y - kCurrentTimeSize.height / 2, kCurrentTimeSize.width, kCurrentTimeSize.height) byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:kCurrentTimeSize];
        [path setLineWidth:1];
        
        CGContextSetStrokeColorWithColor(context, self.currentTimeColor.CGColor);
        [path fill];
        rectCurTime =  CGRectMake(0, y - kCurrentTimeSize.height/2 + 2, kCurrentTimeSize.width, kCurrentTimeSize.height);
        [markAttrStr drawInRect:rectCurTime];
    }
    
    // calculate rect for the floating time mark
    NSAttributedString *floatingMarkAttrStr = [self attributedStringForTimeMark:MGCDayPlannerTimeMarkFloating time:self.timeMark];
    markSize = [floatingMarkAttrStr boundingRectWithSize:markSizeMax options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    y = [self yOffsetForTime:self.timeMark rounded:YES];
    CGRect rectTimeMark = CGRectMake(kSpacing, y - markSize.height/2., markSizeMax.width, markSize.height);
    
    BOOL drawTimeMark = self.timeMark != 0 && [self canDisplayTime:self.timeMark];
    CGFloat lineWidth = 1. / [UIScreen mainScreen].scale;
    
    // draw the hour marks
    for (NSUInteger i = self.hourRange.location; i <=  NSMaxRange(self.hourRange); i++) {
        
        BOOL shouldDraw = YES;
        // if worktime values equal to normal hours then skip normal drawing
        if (self.worktimeValues.start == i || self.worktimeValues.end == i) {
            shouldDraw = YES;
            //continue;
        }
        
        markAttrStr = [self attributedStringForTimeMark:MGCDayPlannerTimeMarkHeader time:(i % 24)*3600];
        markSize = [markAttrStr boundingRectWithSize:markSizeMax options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        
        y = MGCAlignedFloat((i - self.hourRange.location) * self.hourSlotHeight + self.insetsHeight) - lineWidth * .5;
        CGRect r = MGCAlignedRectMake(kSpacing, y - markSize.height / 2., markSizeMax.width, markSize.height);

        if ((!CGRectIntersectsRect(r, rectCurTime) || !self.showsCurrentTime) && shouldDraw == YES) {
            [markAttrStr drawInRect:r];
         }
        
        CGContextSetStrokeColorWithColor(context, self.timeColor.CGColor);
        CGContextSetLineWidth(context, lineWidth);
        CGContextSetLineDash(context, 0, NULL, 0);
        CGContextMoveToPoint(context, self.timeColumnWidth + 4, y);
        CGContextAddLineToPoint(context, self.timeColumnWidth + rect.size.width, y);
        CGContextStrokePath(context);
        
        
        // 30 minutes lines
        if (self.showsHalfHourLines && i < NSMaxRange(self.hourRange) && shouldDraw) {
            y = MGCAlignedFloat(y + self.hourSlotHeight/2.) - lineWidth * .5;
            CGContextSetLineDash(context, 0, dash, 2);
            CGContextMoveToPoint(context, self.timeColumnWidth + 4, y);
            CGContextAddLineToPoint(context, self.timeColumnWidth + rect.size.width, y);
            CGContextStrokePath(context);
            
            markAttrStr = [self attributedStringForTimeMark:MGCDayPlannerTimeMarkHalf time:(i % 24)*3600 + 30*60];
            markSize = [markAttrStr boundingRectWithSize:markSizeMax options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
            
            CGRect r = MGCAlignedRectMake(kSpacing, y - markSize.height / 2., markSizeMax.width, markSize.height);
            if (!CGRectIntersectsRect(r, rectCurTime) || !self.showsCurrentTime) {
                [markAttrStr drawInRect:r];
            }
        }
        
        if (self.showsFifteenHourLines && i < NSMaxRange(self.hourRange)) {
                   
                   // 15 minutes lines
            
            CGContextSetStrokeColorWithColor(context, self.timeColor.CGColor);
                   y = MGCAlignedFloat(y - self.hourSlotHeight/4.) - lineWidth * .5;
                   CGContextSetLineDash(context, 0, dash, 2);
                   CGContextMoveToPoint(context, self.timeColumnWidth + 4, y);
                   CGContextAddLineToPoint(context, self.timeColumnWidth + rect.size.width, y);
                   CGContextStrokePath(context);
                   
                   markAttrStr = [self attributedStringForTimeMark:MGCDayPlannerTimeMarkHalf time:(i % 24)*3600 + 15*60];
                   markSize = [markAttrStr boundingRectWithSize:markSizeMax options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
                   CGRect r = MGCAlignedRectMake(kSpacing, y - markSize.height / 2., markSizeMax.width, markSize.height);
                   if (!CGRectIntersectsRect(r, rectCurTime) || !self.showsCurrentTime) {
                       [markAttrStr drawInRect:r];
                   }
                   
                    // 45 minutes lines
                   y = MGCAlignedFloat(y + (self.hourSlotHeight/4.) * 2) - lineWidth * .5;
                   
            CGContextSetStrokeColorWithColor(context, self.timeColor.CGColor);
                   CGContextSetLineDash(context, 0, dash, 2);
                   CGContextMoveToPoint(context, self.timeColumnWidth + 4, y);
                   CGContextAddLineToPoint(context, self.timeColumnWidth + rect.size.width, y);
                   CGContextStrokePath(context);
                   
                   markAttrStr = [self attributedStringForTimeMark:MGCDayPlannerTimeMarkHalf time:(i % 24)*3600 + 45*60];
                   markSize = [markAttrStr boundingRectWithSize:markSizeMax options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
                   r = MGCAlignedRectMake(kSpacing, y - markSize.height / 2., markSizeMax.width, markSize.height);
                   if (!CGRectIntersectsRect(r, rectCurTime) || !self.showsCurrentTime) {
                       [markAttrStr drawInRect:r];
                   }
               }
        
        // don't draw time mark if it intersects any other mark
        drawTimeMark &= !CGRectIntersectsRect(r, rectTimeMark);
    }
    
    if ((self.worktimeValues.start != 0 || self.worktimeValues.end != 0) && self.worktimeValues.start < 25 && self.worktimeValues.end < 25) {
        NSUInteger leftOffset = 2;
        
        for (int i = 0; i < 2; ++i){
            NSUInteger hour = i == 0 ? self.worktimeValues.start : self.worktimeValues.end;
            NSUInteger minute = i == 0 ? self.worktimeValues.startMinute : self.worktimeValues.endMinute;
            NSAttributedString *markAttrStr = [self attributedStringForTimeMark:MGCDayPlannerTimeMarkDivider time:(hour % 24)*3600 + minute * 60];
            CGSize markSize = [markAttrStr boundingRectWithSize:markSizeMax options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
            
            CGFloat minuteOffset = minute == 0 ? 0 : (self.hourSlotHeight / (60.0 / minute));
            
            CGFloat y = MGCAlignedFloat((hour - self.hourRange.location) * self.hourSlotHeight + minuteOffset + self.insetsHeight) - lineWidth * .5;
            CGRect r = MGCAlignedRectMake(0, y - markSize.height / 2., markSizeMax.width, markSize.height);

            if (!CGRectIntersectsRect(r, rectCurTime) || !self.showsCurrentTime) {
                
                CGRect rectMark = r;
                rectMark.origin.x = kSpacing;
                [markAttrStr drawInRect:rectMark];
            }
             
            // draw time line
            CGRect lineRect = CGRectMake(self.timeColumnWidth + 4, y, self.bounds.size.width - self.timeColumnWidth + leftOffset, 1);
            CGContextSetFillColorWithColor(context, self.accentColor.CGColor);
            UIRectFill(lineRect);
            
            //draw rectangle around time label
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(r.origin.x + 8, r.origin.y - 1, 46, 15) cornerRadius:5];
            [path setLineWidth:1];
            
            CGContextSetStrokeColorWithColor(context, self.accentColor.CGColor);
            [path stroke];
            
            // draw triangle
            UIBezierPath *trianglePath = [UIBezierPath new];
            [trianglePath moveToPoint:(CGPoint){r.origin.x + 9, r.origin.y + 2.5}]; //right top
            [trianglePath addLineToPoint:(CGPoint){r.origin.x + 9, r.origin.y + 9.5}]; // right bottom
            [trianglePath addLineToPoint:(CGPoint){r.origin.x, r.origin.y + (r.size.height / 2)}]; // left middle
            [trianglePath addLineToPoint:(CGPoint){r.origin.x + 9, r.origin.y + 2.5}]; // right top
            [trianglePath fill];
        }
    }
    
    if (drawTimeMark) {
        [floatingMarkAttrStr drawInRect:rectTimeMark];
    }
}

@end
