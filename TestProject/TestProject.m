//
//  TestProject.m
//  TestProject
//
//  Created by Marimuthu on 25/03/17.
//  Copyright © 2017 Marimuthu. All rights reserved.
//

#import "TestProject.h"

@implementation TestProject
RCT_EXPORT_MODULE();


RCT_EXPORT_METHOD(addEvent:(NSString *)name location:(NSString *)location) {
    NSLog(@"Pretending to create an event %@ at %@", name, location);
}
@end
