//
//  MGCStandardEventView.m
//  Graphical Calendars Library for iOS
//
//  Distributed under the MIT License
//  Get the latest version from here:
//
//	https://github.com/jumartin/Calendar
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

#import "MGCStandardEventView.h"

static CGFloat kSpace = 2;
static CGFloat kBigSpace = 18;

@interface MGCStandardEventView ()

@property (nonatomic) UIView *leftBorderView;
@property (nonatomic) NSMutableAttributedString *attrString;

@end


@implementation MGCStandardEventView


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
		self.contentMode = UIViewContentModeRedraw;
		
		_color = [UIColor blackColor];
        _textColor = [UIColor blackColor];
		_style = MGCStandardEventViewStylePlain|MGCStandardEventViewStyleSubtitle;
		_font = [UIFont boldSystemFontOfSize:14];
        _subtitleFont = [UIFont boldSystemFontOfSize:13];
        _detailsFont = [UIFont systemFontOfSize:12];
		_leftBorderView = [[UIView alloc]initWithFrame:CGRectZero];
		[self addSubview:_leftBorderView];
	}
    return self;
}

- (void)redrawStringInRect:(CGRect)rect
{
	// attributed string can't be created with nil string
	NSMutableString *s = [NSMutableString stringWithString:@""];
	
	if (self.style & MGCStandardEventViewStyleDot) {
		[s appendString:@"\u2022 "]; // 25CF // 2219 // 30FB
	}
	
	if (self.title) {
        [s appendString:@"\n"];
		[s appendString:self.title];
	}
    
    self.font = [UIFont boldSystemFontOfSize:14];
	NSMutableAttributedString *as = [[NSMutableAttributedString alloc]initWithString:s attributes:@{NSFontAttributeName: self.font }];
	
	if ([self shouldDrawSubtitleInRect:rect] && self.subtitle && self.subtitle.length > 0 && self.style & MGCStandardEventViewStyleSubtitle) {
		NSMutableString *s  = [NSMutableString stringWithFormat:@"\n%@", self.subtitle];
		NSMutableAttributedString *subtitle = [[NSMutableAttributedString alloc]initWithString:s attributes:@{NSFontAttributeName:self.subtitleFont}];
		[as appendAttributedString:subtitle];
	}
	
    if ([self shouldDrawDetailsInRect:rect] && self.detail && self.detail.length > 0 && self.style & MGCStandardEventViewStyleDetail) {
		
		NSMutableString *s = [NSMutableString stringWithFormat:@"\n%@", self.detail];
		NSMutableAttributedString *detail = [[NSMutableAttributedString alloc]initWithString:s attributes:@{NSFontAttributeName:self.detailsFont}];
		[as appendAttributedString:detail];
	}
	
	//NSTextTab *t = [[NSTextTab alloc]initWithTextAlignment:NSTextAlignmentRight location:rect.size.width options:[[NSDictionary alloc] init]];
	//NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
	//style.tabStops = @[t];
	//style.hyphenationFactor = .4;
	//style.lineBreakMode = NSLineBreakByTruncatingMiddle;
	//[as addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, as.length)];
	
	//UIColor *color = self.selected ? [UIColor whiteColor] : self.textColor;
	[as addAttribute:NSForegroundColorAttributeName value:self.textColor range:NSMakeRange(0, as.length)];
	
	self.attrString = as;
}

- (BOOL)shouldDrawSubtitleInRect:(CGRect)rect {
    
    CGRect titleBoundingRect = [self.title boundingRectWithSize:CGSizeMake(rect.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:nil context:nil];
    
    CGRect subtitleBoundingRect = [self.subtitle boundingRectWithSize:CGSizeMake(rect.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:nil context:nil];
    
    return titleBoundingRect.size.height + subtitleBoundingRect.size.height < rect.size.height;
}

- (BOOL)shouldDrawDetailsInRect:(CGRect)rect {
    
    CGRect titleBoundingRect = [self.title boundingRectWithSize:CGSizeMake(rect.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:nil context:nil];
    
    CGRect subtitleBoundingRect = [self.subtitle boundingRectWithSize:CGSizeMake(rect.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:nil context:nil];
    
    CGRect detailBoundingRect = [self.detail boundingRectWithSize:CGSizeMake(rect.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:nil context:nil];
    
    return titleBoundingRect.size.height + subtitleBoundingRect.size.height + detailBoundingRect.size.height < rect.size.height;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	self.leftBorderView.frame = CGRectMake(0, 0, 3, self.bounds.size.height);
    self.leftBorderView.hidden = NO;
    self.leftBorderView.clipsToBounds = NO;
    self.clipsToBounds = NO;
    self.layer.cornerRadius = 3.0;
    self.leftBorderView.layer.cornerRadius = 3.0;
    if (@available(iOS 11.0, *)) {
        self.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner;
        self.leftBorderView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner;
    } else {
        // none here
    }
	[self setNeedsDisplay];
}

- (void)setColor:(UIColor*)color
{
	_color = color;
	[self resetColors];
}

- (void)setStyle:(MGCStandardEventViewStyle)style
{
	_style = style;
	self.leftBorderView.hidden = !(_style & MGCStandardEventViewStyleBorder);
	[self resetColors];
}

- (void)resetColors
{
	self.leftBorderView.backgroundColor = self.color;
	
	if (self.selected)
        self.backgroundColor = [self.color colorWithAlphaComponent:.3];
	else if (self.style & MGCStandardEventViewStylePlain)
        self.backgroundColor = [self.color colorWithAlphaComponent:.3];
	else
		self.backgroundColor = [UIColor clearColor];
	
	[self setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected
{
	[super setSelected:selected];
	[self resetColors];
}

- (void)setVisibleHeight:(CGFloat)visibleHeight
{
	[super setVisibleHeight:visibleHeight];
	[self setNeedsDisplay];
}

- (void)prepareForReuse
{
	[super prepareForReuse];
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGRect drawRect = CGRectInset(rect, self.style & MGCStandardEventViewStyleBigLeftOffset ? kBigSpace : kSpace, 0);
	if (self.style & MGCStandardEventViewStyleBorder) {
		drawRect.origin.x += kSpace;
		drawRect.size.width -= kSpace;
    } else if (self.style & MGCStandardEventViewStyleBigLeftOffset) {
        drawRect.origin.x += kBigSpace;
        drawRect.size.width -= kBigSpace;
    }
	
	[self redrawStringInRect:drawRect];
	
	CGRect boundingRect = [self.attrString boundingRectWithSize:CGSizeMake(drawRect.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
	drawRect.size.height = fminf(drawRect.size.height, self.visibleHeight);
	[self.attrString drawWithRect:drawRect options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    if (self.style & MGCStandardEventViewStyleLeftShadow) {
        UIBezierPath *shadowPath0 = [UIBezierPath bezierPathWithRoundedRect:self.leftBorderView.bounds cornerRadius:0];
        
        CALayer *layer0 = [[CALayer alloc] init];
        layer0.shadowPath = shadowPath0.CGPath;
        layer0.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25].CGColor;
        layer0.shadowOpacity = 1;
        layer0.shadowRadius = 2;
        layer0.shadowOffset = CGSizeMake(-2, 0);
        layer0.bounds = self.leftBorderView.bounds;
        layer0.position = self.leftBorderView.center;
        [self.leftBorderView.layer addSublayer:layer0];
    }
}

#pragma mark - NSCopying protocol

- (id)copyWithZone:(NSZone *)zone
{
	MGCStandardEventView *cell = [super copyWithZone:zone];
	cell.title = self.title;
	cell.subtitle = self.subtitle;
	cell.detail = self.detail;
	cell.color = self.color;
	cell.style = self.style;
	
	return cell;
}

@end
