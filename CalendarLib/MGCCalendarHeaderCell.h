//
//  MGCCalendarHeaderCell.h
//  Calendar
//
//  Copyright © 2016 Julien Martin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MGCCalendarHeaderCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UILabel *dayNumberLabel;
@property (nonatomic, strong) IBOutlet UILabel *dayNameLabel;
@property (nonatomic, strong) NSDate *date;
@property (weak, nonatomic) IBOutlet UIView *highlightView;

//colors
@property (nonatomic, strong) UIColor *dayBackgroundColor;
@property (nonatomic, strong) UIColor *selectedDayBackgroundColor;
@property (nonatomic, strong) UIColor *selectedDayTextColor;
@property (nonatomic, strong) UIColor *dayTextColor;
@property (nonatomic, strong) UIColor *todayColor;
@property (nonatomic, strong) UIColor *pastDateColor;
@property (nonatomic, strong) UIColor *weekendColor;

// fonts
@property (nonatomic, strong) UIFont *dayNameLabelFont;
@property (nonatomic, strong) UIFont *dayNumberLabelFont;
@property (nonatomic, strong) UIFont *dayNumberLabelFontSelected;

@end
