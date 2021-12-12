//
//  MGCCalendarHeaderCell.m
//  Calendar
//
//  Copyright © 2016 Julien Martin. All rights reserved.
//

#import "MGCCalendarHeaderCell.h"

@interface MGCCalendarHeaderCell ()

@property (nonatomic, assign, getter=isToday) BOOL today;
@property (nonatomic, assign, getter=isPastDay) BOOL pastDay;
@property (nonatomic, assign, getter=isWeekend) BOOL weekend;


@end

@implementation MGCCalendarHeaderCell

- (instancetype)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        //self.selectedDayBackgroundColor = [UIColor whiteColor];
        self.selectedDayTextColor = [UIColor darkGrayColor];
        self.dayTextColor = [UIColor blackColor];
        self.pastDateColor = [UIColor colorWithRed:0.11 green:0.14 blue:0.22 alpha:0.38];
        self.todayColor = [UIColor colorWithRed:0.25 green:0.47 blue:0.97 alpha:1.0];
        self.weekendColor = [UIColor colorWithRed:0.98 green:0.32 blue:0.5 alpha:1.0];
    }
    return self;
}

- (void)setDate:(NSDate *)date{
    _date = date;
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"E"];
    
    self.dayNameLabel.text = [dateFormatter stringFromDate:date];
    
    [dateFormatter setDateFormat:@"d"];
    
    self.dayNumberLabel.text = [dateFormatter stringFromDate:date];
    
    //the cell is the current day
    self.today = [[NSCalendar currentCalendar] isDate:[NSDate date] inSameDayAsDate:date];
    self.pastDay = [self.date timeIntervalSinceNow] < 0.0;
    
    //tthe cell is a weekend day
    self.weekend = [[NSCalendar currentCalendar] isDateInWeekend:date];
}

- (void)setSelected:(BOOL)selected{
    
    [super setSelected:selected];
    
    //force layout to color the view
    [self setNeedsLayout];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.dayNameLabel.font = self.dayNameLabelFont;
    
    if (self.isSelected) {
        
        self.highlightView.backgroundColor = self.selectedDayBackgroundColor;
        self.dayNumberLabel.layer.masksToBounds = YES;
        self.dayNumberLabel.layer.cornerRadius = 15.0;
        self.dayNumberLabel.textColor = self.selectedDayTextColor;
        self.dayNameLabel.textColor = self.selectedDayTextColor;
        self.dayNumberLabel.font = self.dayNumberLabelFontSelected;
        
    } else {
        
        self.highlightView.backgroundColor = self.dayBackgroundColor;
        self.dayNumberLabel.backgroundColor = [UIColor clearColor];
        self.dayNumberLabel.backgroundColor = [UIColor clearColor];
        self.dayNumberLabel.textColor = self.dayTextColor;
        self.dayNameLabel.textColor = self.dayTextColor;
        self.dayNumberLabel.font = self.dayNumberLabelFontSelected;
    }
    
    if (self.isWeekend && !self.isToday) {
        //self.dayNumberLabel.textColor = self.weekendColor;
        //self.dayNameLabel.textColor = self.weekendColor;
    }
    
    if (self.isPastDay) {
        //self.dayNumberLabel.textColor = self.pastDateColor;
        //self.dayNameLabel.textColor = self.pastDateColor;
    }
    
    if (self.isToday) {
        //self.dayNumberLabel.textColor = self.todayColor;
        //self.dayNameLabel.textColor = self.todayColor;
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];

    self.backgroundColor = [UIColor whiteColor];
    self.dayNameLabel.textColor = [UIColor blackColor];
    self.dayNumberLabel.textColor = [UIColor blackColor];
    self.today = NO;
    self.weekend = NO;
    
    self.selectedDayBackgroundColor = [UIColor colorWithRed:0.25 green:0.47 blue:0.97 alpha:0.16];
    self.selectedDayTextColor = [UIColor darkGrayColor];
    self.pastDateColor = [UIColor colorWithRed:0.75 green:0.78 blue:0.82 alpha:1.0];
    self.todayColor = [UIColor colorWithRed:0.25 green:0.47 blue:0.97 alpha:1.0];
    self.weekendColor = [UIColor colorWithRed:0.98 green:0.32 blue:0.5 alpha:1.0];
}

@end
