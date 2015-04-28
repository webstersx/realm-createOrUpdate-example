//
//  Person.m
//  realm-createOrUpdate-example
//
//  Created by Shawn Webster on 28/04/2015.
//  Copyright (c) 2015 Shawn Webster. All rights reserved.
//

#import "Person.h"

@implementation Person

+ (NSDictionary*) defaultPropertyValues {
    return @{@"_id":@(0),
             @"first_name":@""};
}

+ (NSString*) primaryKey {
    return @"_id";
}

@end
