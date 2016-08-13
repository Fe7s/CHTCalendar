//
//  ViewController.m
//  CHTCalendar
//
//  Created by risenb_mac on 16/8/9.
//  Copyright © 2016年 risenb_mac. All rights reserved.
//

#import "ViewController.h"
#import "CHTCalendarView.h"

@interface ViewController ()<UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) CHTCalendarView *calendar;

@property (strong, nonatomic) IBOutlet UILabel *lineSpacingLabel;
@property (strong, nonatomic) IBOutlet UIStepper *lineSpacingStepper;
@property (strong, nonatomic) IBOutlet UIStepper *itemSpacingStepper;
@property (strong, nonatomic) IBOutlet UILabel *itemSpacingLabel;
@property (strong, nonatomic) IBOutlet UILabel *dayWidthLabel;
@property (strong, nonatomic) IBOutlet UIStepper *dayWidthStepper;
@property (strong, nonatomic) IBOutlet UILabel *dayRadiusLabel;
@property (strong, nonatomic) IBOutlet UIStepper *dayRadiusStepper;

@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) IBOutlet UILabel *colorRLabel;
@property (strong, nonatomic) IBOutlet UILabel *colorGLabel;
@property (strong, nonatomic) IBOutlet UILabel *colorBLabel;
@property (strong, nonatomic) IBOutlet UILabel *colorAlphaLabel;
@property (strong, nonatomic) IBOutlet UISlider *colorRSlider;
@property (strong, nonatomic) IBOutlet UISlider *colorGSlider;
@property (strong, nonatomic) IBOutlet UISlider *colorBSlider;
@property (strong, nonatomic) IBOutlet UISlider *colorAlphaSlider;

@property (nonatomic, strong) NSArray *colorTitlesArray;
@property (nonatomic, copy) NSString *currentColorTitle;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CHTCalendarView *calendarView = [[CHTCalendarView alloc] initWithFrame:CGRectMake(0, 20, self.view.width, self.view.width)];
    [self.view addSubview:calendarView];
    self.calendar = calendarView;
    [self setupViews];
    calendarView.markedDays = @[@"20160804", @"20160808", @"20160821"];
    [calendarView reloadInterface];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)setupViews {
    self.lineSpacingLabel.text = [NSString stringWithFormat:@"%.f", self.calendar.lineSpacing];
    self.lineSpacingStepper.value = self.calendar.lineSpacing;
    self.itemSpacingLabel.text = [NSString stringWithFormat:@"%.f", self.calendar.itemSpacing];
    self.itemSpacingStepper.value = self.calendar.itemSpacing;
    self.dayWidthLabel.text = [NSString stringWithFormat:@"%.f", self.calendar.dayWidth];
    self.dayWidthStepper.value = self.calendar.dayWidth;
    self.dayRadiusLabel.text = [NSString stringWithFormat:@"%.1f", self.calendar.dayCornerRadius];
    self.dayRadiusStepper.value = self.calendar.dayCornerRadius;
    self.colorTitlesArray = @[@"weekendDayColor", @"workingDayColor", @"currentDayColor", @"currentDayFilledColor", @"dayFilledColor", @"selectedDayFilledColor", @"selectedDayColor", @"markedDayFilledColor", @"markedDayColor", @"dateColor", @"yearBtnColor", @"monthBtnColor"];
    [self pickerView:self.pickerView didSelectRow:0 inComponent:0];
}

- (IBAction)switchChanged:(UISwitch *)sender {
    switch (sender.tag - 100) {
        case 1:
            self.calendar.showChineseDay = sender.on;
            break;
        case 2:
            self.calendar.dayFilled = sender.on;
            break;
        case 3:
            self.calendar.currentDayFilled = sender.on;
            break;
        case 4:
            self.calendar.selectedDayFilled = sender.on;
            break;
        case 5:
            self.calendar.markedDayFilled = sender.on;
            break;
        case 6:
            self.calendar.selectMany = sender.on;
            break;
        case 7:
            self.calendar.showBordar = sender.on;
            break;
        default:
            break;
    }
    [self.calendar reloadInterface];
}

- (IBAction)stepClick:(UIStepper *)sender {
    switch (sender.tag - 200) {
        
        case 1:
            self.lineSpacingLabel.text = [NSString stringWithFormat:@"%.f", sender.value];
            self.calendar.lineSpacing = sender.value;
            break;
        case 2:
            self.itemSpacingLabel.text = [NSString stringWithFormat:@"%.f", sender.value];
            self.calendar.itemSpacing = sender.value;
            break;
        case 3:
            self.dayWidthLabel.text = [NSString stringWithFormat:@"%.f", sender.value];
            self.calendar.dayWidth = sender.value;
            break;
        case 4:
            self.dayRadiusLabel.text = [NSString stringWithFormat:@"%.1f", sender.value];
            self.calendar.dayCornerRadius = sender.value;
            break;
        default:
            break;
    }
    [self.calendar reloadInterface];
    switch (sender.tag - 200) {
        case 3:
            self.dayWidthStepper.value = self.calendar.dayWidth;
            self.dayWidthLabel.text = [NSString stringWithFormat:@"%.f", self.calendar.dayWidth];
            break;
        case 4:
            self.dayRadiusStepper.value = self.calendar.dayCornerRadius;
            self.dayRadiusLabel.text = [NSString stringWithFormat:@"%.1f", self.calendar.dayCornerRadius];
            break;
            
        default:
            break;
    }
}

- (IBAction)sliderChanged:(UISlider *)sender {
    self.colorRLabel.text = [NSString stringWithFormat:@"%.2f", self.colorRSlider.value];
    self.colorGLabel.text = [NSString stringWithFormat:@"%.2f", self.colorGSlider.value];
    self.colorBLabel.text = [NSString stringWithFormat:@"%.2f", self.colorBSlider.value];
    self.colorAlphaLabel.text = [NSString stringWithFormat:@"%.2f", self.colorAlphaSlider.value];
    UIColor *color = [UIColor colorWithRed:self.colorRSlider.value green:self.colorGSlider.value blue:self.colorBSlider.value alpha:self.colorAlphaSlider.value];
    [self.calendar setValue:color forKey:self.currentColorTitle];
    [self.calendar reloadInterface];
}

- (void)setSliderWithColor:(UIColor *)color {
    self.colorRSlider.value = CGColorGetComponents(color.CGColor)[0];
    self.colorGSlider.value = CGColorGetComponents(color.CGColor)[1];
    self.colorBSlider.value = CGColorGetComponents(color.CGColor)[2];
    if (CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) == kCGColorSpaceModelMonochrome) {
        self.colorGSlider.value = CGColorGetComponents(color.CGColor)[0];
        self.colorBSlider.value = CGColorGetComponents(color.CGColor)[0];
    }
    self.colorAlphaSlider.value = CGColorGetComponents(color.CGColor)[CGColorGetNumberOfComponents(color.CGColor) - 1];
    self.colorRLabel.text = [NSString stringWithFormat:@"%.2f", self.colorRSlider.value];
    self.colorGLabel.text = [NSString stringWithFormat:@"%.2f", self.colorGSlider.value];
    self.colorBLabel.text = [NSString stringWithFormat:@"%.2f", self.colorBSlider.value];
    self.colorAlphaLabel.text = [NSString stringWithFormat:@"%.2f", self.colorAlphaSlider.value];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.colorTitlesArray.count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
    label.text = self.colorTitlesArray[row];
    label.font = [UIFont systemFontOfSize:12];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.currentColorTitle = self.colorTitlesArray[row];
    UIColor *color = [self.calendar valueForKey:self.currentColorTitle];
    [self setSliderWithColor:color];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
