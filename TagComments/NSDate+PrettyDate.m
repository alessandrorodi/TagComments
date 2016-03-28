//
//  NSDate+PrettyDate.m
//  gymEver
//
//  Created by Alessandro on 2014-12-23.
//  Copyright (c) 2014 alegiallo. All rights reserved.
//

#import "NSDate+PrettyDate.h"

@implementation NSDate (PrettyDate)

- (NSString *)prettyDate
{
    NSString * prettyTimestamp;
    
    float delta = [self timeIntervalSinceNow] * -1;
    
    if (delta < 5) {
         prettyTimestamp = @"just now";
    } else if (delta < 60) {
        prettyTimestamp = [NSString stringWithFormat:@"%d%@", (int) floor(delta),NSLocalizedString(@"secondsPrettyDate", nil) ];
    } else if (delta < 120) {
        prettyTimestamp = @"1m";
    } else if (delta < 3600) {
        prettyTimestamp = [NSString stringWithFormat:@"%dm", (int) floor(delta/60.0) ];
    } else if (delta < 7200) {
        prettyTimestamp = @"1h";
    } else if (delta < 86400) {
        prettyTimestamp = [NSString stringWithFormat:@"%dh", (int) floor(delta/3600.0) ];
    } else if (delta < ( 86400 * 2 ) ) {//1 day
        prettyTimestamp = [NSString stringWithFormat:@"1%@",NSLocalizedString(@"daysPrettyDate", nil)];
    } else if (delta < ( 86400 * 7 ) ) {
        prettyTimestamp = [NSString stringWithFormat:@"%d%@", (int) floor(delta/86400.0),NSLocalizedString(@"daysPrettyDate", nil) ];
    } else if (delta < ( 604800 * 2 ) ) {
        prettyTimestamp = [NSString stringWithFormat:@"1%@",NSLocalizedString(@"weeksPrettyDate", nil)];
    } else {
        prettyTimestamp = [NSString stringWithFormat:@"%d%@", (int) floor(delta/604800.0),NSLocalizedString(@"weeksPrettyDate", nil) ];
        
    } /*else {
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        
        prettyTimestamp = [NSString stringWithFormat:@"on %@", [formatter stringFromDate:self]];
    }*/
    
    //    } else if (delta < ( 604800 * 4 ) ) {

    
    return prettyTimestamp;
}
- (NSString *)prettyDateMinified
{
    NSString * prettyTimestamp;
    
    float delta = [self timeIntervalSinceNow] * -1;
    
    if (delta < 5) {
        prettyTimestamp = @"1s";
    } else if (delta < 60) {
        prettyTimestamp = [NSString stringWithFormat:@"%d%@", (int) floor(delta),NSLocalizedString(@"secondsPrettyDate", nil) ];
    } else if (delta < 120) {
        prettyTimestamp = @"1m";
    } else if (delta < 3600) {
        prettyTimestamp = [NSString stringWithFormat:@"%dm", (int) floor(delta/60.0) ];
    } else if (delta < 7200) {
        prettyTimestamp = @"1h";
    } else if (delta < 86400) {
        prettyTimestamp = [NSString stringWithFormat:@"%dh", (int) floor(delta/3600.0) ];
    } else if (delta < ( 86400 * 2 ) ) {//1 day
        prettyTimestamp = [NSString stringWithFormat:@"1%@",NSLocalizedString(@"daysPrettyDate", nil)];
    } else if (delta < ( 86400 * 7 ) ) {
        prettyTimestamp = [NSString stringWithFormat:@"%d%@", (int) floor(delta/86400.0),NSLocalizedString(@"daysPrettyDate", nil) ];
    } else if (delta < ( 604800 * 2 ) ) {
        prettyTimestamp = [NSString stringWithFormat:@"1%@",NSLocalizedString(@"weeksPrettyDate", nil)];
    } else {
        prettyTimestamp = [NSString stringWithFormat:@"%d%@", (int) floor(delta/604800.0),NSLocalizedString(@"weeksPrettyDate", nil) ];
        
    } /*else {
       NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
       [formatter setDateStyle:NSDateFormatterMediumStyle];
       
       prettyTimestamp = [NSString stringWithFormat:@"on %@", [formatter stringFromDate:self]];
       }*/
    
    //    } else if (delta < ( 604800 * 4 ) ) {
    
    
    return prettyTimestamp;
}

@end
