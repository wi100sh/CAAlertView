//
//  CAAlertView.m
//  CAAlertView
//
//  Created by Chandan on 16/05/16.
//

#import "CAAlertView.h"
#import "CAPickerViewController.h"
#import "CAPopOverViewController.h"
#import "CACustomAlertObject.h"

#define isiPhone5 YES
#define DATE_FORMATTER  @"MM-dd-yyyy HH:mm"


@interface CAAlertView()<CAPopOverViewControllerDelegate, UIPopoverPresentationControllerDelegate>

@property (nonatomic, assign) CAAlertViewType myType; // default is CAAlertViewTypeDatePicker

@property (nonatomic, strong) NSArray *objectArray;
@property (nonatomic, strong) CAPopOverViewController *tablePopOver;
@property (nonatomic, strong) CAPickerViewController *datePickerPopOver;

- (void) configureAlertView;

NSString *kformatDateToString(NSDate *date);
NSString *kformatDateAndTimeToString(NSDate *date);
@end

#pragma mark
#pragma mark setter getter
@implementation CAAlertView

#pragma mark
#pragma mark Class constructor
- (id) initWithType:(CAAlertViewType) type andData:(NSArray *) array {
    if (self = [super init]) {
        _myType = type;
        if (_myType == CAAlertViewTypeTable) {
            _objectArray = [[NSArray alloc] initWithArray:(array && array.count > 0 ? array : [NSArray arrayWithObject:@"No Data To Display"])];
        }
        _isDatePickerTypeDOB = YES;
        _isDateAndTimeBoth = NO;
        _isMultipleSelectionAllowed = NO;
    }
    return self;
}

#pragma mark
#pragma mark Configuring Alert
- (void) configureAlertView {
    if (_myType == CAAlertViewTypeDatePicker) {
        _datePickerPopOver = [self datePickerPopOver];
    }else {
        _tablePopOver = [self tablepopOver];
    }
}

- (void) showAlertView:(id) sender { // sender should be a UIView Object
    [self configureAlertView];
    
    UIViewController *controller = (UIViewController *) _delegate;
    
    if (_myType == CAAlertViewTypeDatePicker) {
        
        UIView *v = (UIView *) sender;
        UIPopoverPresentationController *ppc = _datePickerPopOver.popoverPresentationController;
        [ppc setDelegate:self];
        
        _datePickerPopOver.popoverPresentationController.sourceView = v;
        _datePickerPopOver.popoverPresentationController.sourceRect = v.bounds;
        [controller presentViewController:_datePickerPopOver animated:YES completion:^{
            
        }];
    }
    else {
        
        UIView *v = (UIView *) sender;
        UIPopoverPresentationController *ppc = _tablePopOver.popoverPresentationController;
        [ppc setDelegate:self];
        
        _tablePopOver.popoverPresentationController.sourceView = v;
        _tablePopOver.popoverPresentationController.sourceRect = v.bounds;
        [controller presentViewController:_tablePopOver animated:YES completion:^{
            
        }];
    }
}

- (CAPopOverViewController *) tablepopOver {
    
    if (!_tablePopOver) {
        _tablePopOver = [[CAPopOverViewController alloc] initWithDataSource:_objectArray];
        [_tablePopOver setDelegate:self];
    }else {
        [_tablePopOver modifyDataSource:_objectArray];
    }
    _tablePopOver.isMultipleSelectionAllowed = _isMultipleSelectionAllowed;
    
    _tablePopOver.preferredContentSize = CGSizeMake(200.0f, 300.0f);
    _tablePopOver.modalPresentationStyle = UIModalPresentationPopover;
    return _tablePopOver;
}

- (CAPickerViewController *) datePickerPopOver {
    
    if (!_datePickerPopOver) {
        _datePickerPopOver = [[CAPickerViewController alloc] init];
    }
    
    [_datePickerPopOver.myDatePicker setDatePickerMode: _isDateAndTimeBoth ? UIDatePickerModeDateAndTime : UIDatePickerModeDate];
    
    if (_isDatePickerTypeDOB) {
        [_datePickerPopOver.myDatePicker setMaximumDate:[NSDate date]];
    }
    else{
        [_datePickerPopOver.myDatePicker setMinimumDate:[NSDate date]];
    }
    _datePickerPopOver.preferredContentSize = CGSizeMake(300.0f, 150.0f);
    _datePickerPopOver.modalPresentationStyle = UIModalPresentationPopover;
    
    return _datePickerPopOver;
}

- (void) CAPopover:(CAPopOverViewController *) obj selectedData:(id) data {
    if ([_delegate respondsToSelector:@selector(CAAlertView:completedWithData:)]) {
        if (_myType == CAAlertViewTypeTable) {
            [_delegate CAAlertView:self completedWithData:@[data]];
        }
    }
}


- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller{
    
    return UIModalPresentationNone;
}

- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    
    if (_myType == CAAlertViewTypeDatePicker) {
        if ([_delegate respondsToSelector:@selector(CAAlertView:completedWithData:)]) {
            
            NSString *d = nil;
            if (_isDateAndTimeBoth) {
                d = kformatDateAndTimeToString(_datePickerPopOver.myDatePicker.date);
            }
            else {
                d = kformatDateToString(_datePickerPopOver.myDatePicker.date);
            }
            if (d) {
                CACustomAlertObject *obj = [[CACustomAlertObject alloc] initWithObjectName:d AndID:1];
                [_delegate CAAlertView:self completedWithData:[NSArray arrayWithObject:obj]];
            }
        }
    }
    else {
        if (_isMultipleSelectionAllowed) {
            if ([_delegate respondsToSelector:@selector(CAAlertView:completedWithData:)]) {
                [_delegate CAAlertView:self completedWithData:_tablePopOver.selectedObjects.allObjects];
            }
        }
    }
}

NSString *kformatDateToString(NSDate *date) {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd-yyyy"];
    NSString *dateString = [formatter stringFromDate:date];
    
    return dateString;
}


NSString *kformatDateAndTimeToString(NSDate *date) {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:DATE_FORMATTER];
    NSString *dateString = [formatter stringFromDate:date];
    
    return dateString;
}

#pragma mark
#pragma mark releasing object
- (void) dealloc {
    
    if (_tablePopOver) {
        [_tablePopOver dismissViewControllerAnimated:NO completion:nil];
        _tablePopOver = nil;
    }
    
    if (_datePickerPopOver) {
        [_datePickerPopOver dismissViewControllerAnimated:NO completion:nil];
        _datePickerPopOver = nil;
    }
    _objectArray = nil;
}

@end