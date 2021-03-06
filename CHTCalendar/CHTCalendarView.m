//
//  CHTCalendarView.m
//  CHTCalendar
//
//  Created by risenb_mac on 16/8/9.
//  Copyright © 2016年 risenb_mac. All rights reserved.
//

#import "CHTCalendarView.h"

@implementation UIView (FrameHelper)

- (CGFloat)x {
    return self.frame.origin.x;
}

- (CGFloat)y {
    return self.frame.origin.y;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (CGSize)size {
    return self.bounds.size;
}

- (void)setX:(CGFloat)x {
    CGRect rect = self.frame;
    rect.origin.x = x;
    self.frame = rect;
}

- (void)setY:(CGFloat)y {
    CGRect rect = self.frame;
    rect.origin.y = y;
    self.frame = rect;
}

- (void)setWidth:(CGFloat)width {
    CGRect rect = self.frame;
    rect.size.width = width;
    self.frame = rect;
}

- (void)setHeight:(CGFloat)height {
    CGRect rect = self.frame;
    rect.size.height = height;
    self.frame = rect;
}

- (void)setSize:(CGSize)size {
    CGRect rect = self.frame;
    rect.size = size;
    self.frame = rect;
}

@end

@implementation NSDate (CalendarHelper)

- (NSInteger)numberOfDaysInCurrentMonth {
    return [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self].length;
}

- (NSInteger)weeklyOfCurrentDay {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.firstWeekday = 2;
    return [calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitWeekOfYear forDate:self];
}

- (NSDate *)firstDayOfCurrentMonth {
    NSDate *firstDay = nil;
    BOOL isOk = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitMonth startDate:&firstDay interval:NULL forDate:self];
    if (!isOk) {
        NSLog(@"获取失败");
    }
    return firstDay;
}

- (NSInteger)yearOfCurrentDate {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:self];
    return components.year;
}

- (NSInteger)monthOfCurrentDate {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:self];
    return components.month;
}

- (NSInteger)dayOfCurrentDate {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:self];
    return components.day;
}

@end

static NSArray *chineseMonths;
static NSArray *chineseDays;
static const CGFloat timeInterval = 8 * 60 * 60;

@interface CHTCalendarView ()

@property (nonatomic, assign) CGFloat letterHeight;
@property (nonatomic, strong) NSDate *currentDay;
@property (nonatomic, assign) NSInteger displayYear;
@property (nonatomic, assign) NSInteger displayMonth;

@property (nonatomic, assign) NSInteger firstWeekly;
@property (nonatomic, assign) NSInteger daysOfDisplayMonth;

@end


@implementation CHTCalendarView

- (NSMutableArray *)selectedDays {
    if (_selectedDays == nil) {
        _selectedDays = [NSMutableArray array];
    }
    return _selectedDays;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (self.height < self.width) {
            self.height = self.width;
        }
        self.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
        [self setup];
    }
    return self;
}

- (void)setup {
    chineseMonths = @[@"正月", @"二月", @"三月", @"四月", @"五月", @"六月", @"七月", @"八月", @"九月", @"十月", @"十一月", @"腊月"];
    chineseDays = @[@"初一", @"初二", @"初三", @"初四", @"初五", @"初六", @"初七", @"初八", @"初九", @"初十",
                    @"十一", @"十二", @"十三", @"十四", @"十五", @"十六", @"十七", @"十八", @"十九", @"二十",
                    @"廿一", @"廿二", @"廿三", @"廿四", @"廿五", @"廿六", @"廿七", @"廿八", @"廿九", @"三十"];
    self.lineSpacing = 15;
    self.itemSpacing = 15;
    self.dayWidth = 35;
    self.weekendDayColor = [UIColor redColor];
    self.workingDayColor = [UIColor darkTextColor];
    self.titleFont = [UIFont systemFontOfSize:14];
    self.currentDay = [NSDate dateWithTimeIntervalSinceNow:timeInterval];
    self.currentDayFilledColor = [UIColor redColor];
    self.currentDayColor = [UIColor whiteColor];
    self.displayYear = [self.currentDay yearOfCurrentDate];
    self.displayMonth = [self.currentDay monthOfCurrentDate];
    self.showChineseDay = YES;
    self.dayFont = [UIFont systemFontOfSize:15];
    self.chineseDayFont = [UIFont systemFontOfSize:10];
    self.dateColor = [UIColor darkGrayColor];
    self.dateFont = [UIFont systemFontOfSize:15];
    self.btnHeight = 40;
    self.yearBtnColor = [UIColor redColor];
    self.monthBtnColor = [UIColor darkTextColor];
    self.dayCornerRadius = 5;
    self.daysToTitleSpacing = 10;
    self.dayBordarWidth = 1;
    self.dayFilled = YES;
    self.dayFilledColor = [UIColor whiteColor];
    self.markedDayFilled = YES;
    self.showBordar = YES;
    self.markedDayFilledColor = [UIColor colorWithRed:1.000 green:0.381 blue:0.275 alpha:1.000];
    self.markedDayColor = [UIColor whiteColor];
    self.selectedDayColor = [UIColor blueColor];
    self.selectedDayFilledColor = [UIColor lightGrayColor];
    self.selectMany = YES;
    self.currentDayFilled = YES;
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)]];
    [self resetValue];
}

- (void)resetValue {
    NSString *str = @"初九";
    CGFloat width = [str boundingRectWithSize:CGSizeMake(100, 100) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : self.chineseDayFont} context:nil].size.width;
    self.dayWidth = self.dayWidth > 1.5 * width ? self.dayWidth : 1.5 * width;
    self.dayCornerRadius = self.dayCornerRadius < self.dayWidth / 2 ? self.dayCornerRadius : self.dayWidth / 2;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self drawDateLabel];
    [self drawTitle];
    [self drawDaysWithYear:self.displayYear month:self.displayMonth];
}

- (void)drawDateLabel {
    CGFloat left = [self centerX:0];
    CGFloat right = [self centerX:6];
    // 画折线
    [self addCurveFrom:CGPointMake(left, self.btnHeight/2 - 4)
                  pass:CGPointMake(left - 8, self.btnHeight/2)
                    to:CGPointMake(left, self.btnHeight/2 + 4)
             withColor:self.yearBtnColor width:0.8];
    [self addCurveFrom:CGPointMake(left + 5, self.btnHeight/2 - 4)
                  pass:CGPointMake(left + 5 - 8, self.btnHeight/2)
                    to:CGPointMake(left + 5, self.btnHeight/2 + 4)
             withColor:self.yearBtnColor width:0.8];
    [self addCurveFrom:CGPointMake(right, self.btnHeight/2 - 4)
                  pass:CGPointMake(right + 8, self.btnHeight/2)
                    to:CGPointMake(right, self.btnHeight/2 + 4)
             withColor:self.yearBtnColor width:0.8];
    [self addCurveFrom:CGPointMake(right - 5, self.btnHeight/2 - 4)
                  pass:CGPointMake(right - 5 + 8, self.btnHeight/2)
                    to:CGPointMake(right - 5, self.btnHeight/2 + 4)
             withColor:self.yearBtnColor width:0.8];
    [self addCurveFrom:CGPointMake(left + 30, self.btnHeight/2 - 4)
                  pass:CGPointMake(left + 30 - 8, self.btnHeight/2)
                    to:CGPointMake(left + 30, self.btnHeight/2 + 4)
             withColor:self.monthBtnColor width:0.8];
    [self addCurveFrom:CGPointMake(right - 30, self.btnHeight/2 - 4)
                  pass:CGPointMake(right - 30 + 8, self.btnHeight/2)
                    to:CGPointMake(right - 30, self.btnHeight/2 + 4)
             withColor:self.monthBtnColor width:0.8];

    NSString *dateText = [NSString stringWithFormat:@"%ld年%ld月", self.displayYear + (self.displayMonth - 1) / 12, self.displayMonth % 12 == 0 ? 12 : self.displayMonth % 12];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentCenter;
    NSDictionary *dict = @{NSFontAttributeName : self.dateFont,
                           NSForegroundColorAttributeName : self.dateColor,
                           NSParagraphStyleAttributeName : style};
    CGFloat dateTextHeight = [dateText boundingRectWithSize:CGSizeMake(1000, 100) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size.height;
    [dateText drawInRect:CGRectMake(0, (self.btnHeight - dateTextHeight) / 2, self.width, dateTextHeight) withAttributes:dict];
    
}

- (void)addCurveFrom:(CGPoint)starPoint pass:(CGPoint)passPoint to:(CGPoint)endPoint withColor:(UIColor *)color width:(CGFloat)width {
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:starPoint];
    [bezierPath addLineToPoint:passPoint];
    [bezierPath addLineToPoint:endPoint];
    [color set];
    bezierPath.lineWidth = width;
    [bezierPath stroke];
}

- (void)drawTitle {
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetRGBFillColor(context, 1, 1, 1, 1);
    NSString *str = @"日";
    CGSize size = [str boundingRectWithSize:CGSizeMake(100, 100) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : self.titleFont} context:nil].size;
    CGFloat strWidth = size.width;
    self.letterHeight = size.height;

    NSString *text = @"日一二三四五六";
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle defaultParagraphStyle].mutableCopy;
    style.alignment = NSTextAlignmentCenter;
    NSDictionary *dict = @{NSFontAttributeName : self.titleFont,
                           NSKernAttributeName : @(self.dayWidth + self.itemSpacing - strWidth),
                           NSForegroundColorAttributeName : self.weekendDayColor,
                           NSParagraphStyleAttributeName : style};
    
    [string setAttributes:dict range:NSMakeRange(0, string.length)];
    [string addAttribute:NSForegroundColorAttributeName value:self.workingDayColor range:NSMakeRange(1, string.length - 2)];
    [string addAttribute:NSKernAttributeName value:@0 range:NSMakeRange(6, 1)];
    [string drawInRect:CGRectMake(0, self.btnHeight, self.width, 30)];
}

- (void)drawDaysWithYear:(NSInteger)year month:(NSInteger)month {
    NSDate *date = [self getFirshDayOfMonth:month year:year];
    NSInteger days = [date numberOfDaysInCurrentMonth];
    NSInteger firstWeekly = [[date firstDayOfCurrentMonth] weeklyOfCurrentDay];
    firstWeekly %= 7; //对首日是周日的情况进行特殊处理
    self.firstWeekly = firstWeekly;
    self.daysOfDisplayMonth = days;
    for (int i = 1; i <= days; i++) {
        NSInteger line = (i + firstWeekly - 1) / 7;
        NSInteger item = (i + firstWeekly - 1) % 7;
        [self drawDay:i withLine:line item:item];
    }
}

- (void)drawDay:(NSInteger)day withLine:(NSInteger)line item:(NSInteger)item {
    UIColor *color = item == 0 || item == 6 ? self.weekendDayColor : self.workingDayColor;
    UIColor *filledColor = self.dayFilledColor;
    BOOL filled = self.dayFilled;
    
    NSString *displayDay = [NSString stringWithFormat:@"%ld%02ld%02ld", self.displayYear, self.displayMonth, day];
    if ([self.markedDays containsObject:displayDay]) {
        color = self.markedDayColor;
        filledColor = self.markedDayFilledColor;
        filled = self.markedDayFilled;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString *currentDayText = [formatter stringFromDate:self.currentDay];
    if ([currentDayText isEqualToString:displayDay]) {
        color = self.currentDayColor;
        filledColor = self.currentDayFilledColor;
        filled = self.currentDayFilled;
    }
    if ([self.selectedDays containsObject:displayDay]) {
        color = self.selectedDayColor;
        filledColor = self.selectedDayFilledColor;
        filled = self.selectedDayFilled;
    }
    
    NSAttributedString *string = [self setAttributedSting:day color:color];
    // 获取 string的高度（用来垂直居中）
    CGFloat stringHeight = [string boundingRectWithSize:CGSizeMake(100, 100) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
    
    // 当前day origin
    CGFloat x = [self centerX:item] - self.dayWidth / 2;
    CGFloat y = line * (self.dayWidth + self.lineSpacing) + self.btnHeight + self.letterHeight + self.daysToTitleSpacing + self.lineSpacing / 2;
    
    // 绘制边框
    if (self.showBordar) {
        [self drawBordarWithX:x y:y color:color filled:filled filledColor:filledColor];
    }
    
    // 将string在边框中垂直居中
    [string drawInRect:CGRectMake(x, y + (self.dayWidth - stringHeight) / 2, self.dayWidth, stringHeight)];
}

- (void)drawBordarWithX:(CGFloat)x y:(CGFloat)y color:(UIColor *)color filled:(BOOL)filled filledColor:(UIColor *) filledColor {
    // 边框圆角，最大值为width/2
    CGFloat width = self.dayWidth;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, self.dayBordarWidth);
    CGContextSetFillColorWithColor(context, filledColor.CGColor);
    CGContextMoveToPoint(context, x + width / 2, y);
    CGContextAddArcToPoint(context, x + width, y, x + width, y + width/2, self.dayCornerRadius);
    CGContextAddArcToPoint(context, x + width, y + width, x + width / 2, y + width, self.dayCornerRadius);
    CGContextAddArcToPoint(context, x, y + width, x, y + width / 2, self.dayCornerRadius);
    CGContextAddArcToPoint(context, x, y, x + width / 2, y, self.dayCornerRadius);
    if (filled) {
        CGContextFillPath(context);
    } else {
        CGContextClosePath(context);
    }
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextDrawPath(context, kCGPathStroke);
}

- (NSAttributedString *)setAttributedSting:(NSInteger)day color:(UIColor *)color {
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle defaultParagraphStyle].mutableCopy;
    style.alignment = NSTextAlignmentCenter;
    
    NSMutableDictionary *attributes = @{NSFontAttributeName : self.dayFont,
                                        NSParagraphStyleAttributeName : style,
                                        NSForegroundColorAttributeName : color}.mutableCopy;
    NSString *text = [NSString stringWithFormat:@"%ld", day];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text];
    [string setAttributes:attributes range:NSMakeRange(0, string.length)];
    
    NSDate *date = [self getFirshDayOfMonth:self.displayMonth year:self.displayYear];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
    NSDateComponents *chineseComponets = [calendar components:NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[date dateByAddingTimeInterval:(day - 1) * 24 * 60 * 60]];
    if (self.showChineseDay) {
        NSString *subText = chineseComponets.day == 1 ? chineseMonths[chineseComponets.month - 1] : chineseDays[chineseComponets.day - 1];
        subText = [NSString stringWithFormat:@"\n%@", subText];
        NSMutableAttributedString *subString = [[NSMutableAttributedString alloc] initWithString:subText];
        [attributes setValue:self.chineseDayFont forKey:NSFontAttributeName];
        [subString setAttributes:attributes range:NSMakeRange(subString.length - 2, 2)];
        if (chineseComponets.month == 11 && chineseComponets.day == 1) {
            [subString setAttributes:attributes range:NSMakeRange(subString.length - 3, 3)];
        }
        [string appendAttributedString:subString];
    }
    return string;
}

- (CGFloat)centerX:(NSInteger)index {
    CGFloat leftSpacing = (self.width - self.dayWidth * 7 - self.itemSpacing * 6) / 2;
    CGFloat centerX = leftSpacing + index * (self.dayWidth + self.itemSpacing) + self.dayWidth / 2;
    return centerX;
}

- (void)reloadInterface {
    [self resetValue];
    [self setNeedsDisplay];
}

- (NSDate *)getFirshDayOfMonth:(NSInteger)month year:(NSInteger)year {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.year = year;
    components.month = month;
    //    components.timeZone = [NSTimeZone systemTimeZone];
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:components];
    date = [date dateByAddingTimeInterval:[[NSTimeZone systemTimeZone] secondsFromGMTForDate:date]];
    return date;
}

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    self.displayMonth++;
//    [self reloadInterface];
//}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:tap.view];
    CGFloat x = point.x;
    CGFloat y = point.y;
    if (y < self.btnHeight) {
        if (x > [self centerX:0] - 15 && x < [self centerX:0] + 15) {
            self.displayYear--;
        } else if (x > [self centerX:0] + 15 && x < [self centerX:0] + 40) {
            [self lastMonth];
        } else if (x < [self centerX:6] + 15 && x > [self centerX:6] - 15) {
            self.displayYear++;
        } else if (x < [self centerX:6] - 15 && x > [self centerX:6] - 40) {
            [self nextMonth];
        }
    } else if (y > self.btnHeight + self.letterHeight + self.daysToTitleSpacing &&
               x > [self centerX:0] - (self.dayWidth + self.itemSpacing) / 2) {
        
        CGPoint origin = CGPointMake([self centerX:0], self.btnHeight + self.letterHeight + self.daysToTitleSpacing);
        NSInteger item = (int)(x - origin.x + (self.dayWidth + self.itemSpacing) / 2) / (int)(self.dayWidth + self.itemSpacing);
        NSInteger line = (int)(y - origin.y) / (int)(self.lineSpacing + self.dayWidth);
        NSInteger day = line * 7 + item + 1 - self.firstWeekly;
        if (day <= self.daysOfDisplayMonth && day > 0) {
            [self clickDay:day];
        }
    }
    [self reloadInterface];
}

- (void)clickDay:(NSInteger)day {
    NSString *dayText = [NSString stringWithFormat:@"%ld%02ld%02ld", self.displayYear, self.displayMonth, day];
    if ([self.selectedDays containsObject:dayText]) {
        [self.selectedDays removeObject:dayText];
    } else {
        if (!self.selectMany) {
            [self.selectedDays removeAllObjects];
        }
        [self.selectedDays addObject:dayText];
    }
    [self reloadInterface];
}

- (void)lastMonth {
    if (self.displayMonth == 1) {
        self.displayMonth = 12;
        self.displayYear--;
    } else {
        self.displayMonth--;
    }
}

- (void)nextMonth {
    if (self.displayMonth == 12) {
        self.displayMonth = 1;
        self.displayYear++;
    } else {
        self.displayMonth++;
    }
}

@end
