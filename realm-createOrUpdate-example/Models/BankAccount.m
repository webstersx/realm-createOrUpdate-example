//
//  BankAccount.m
//  realm-createOrUpdate-example
//
//  Created by Shawn Webster on 28/04/2015.
//  Copyright (c) 2015 Shawn Webster. All rights reserved.
//

#import "BankAccount.h"

@implementation BankAccount

+ (NSDictionary*) defaultPropertyValues {
    return @{@"_id":@(0),
             @"balance":@(0),
             @"cr_interest_rate":@(0.02),
             @"dr_interest_rate":@(0.25)};
}

+ (NSString*) primaryKey {
    return @"_id";
}

@end
