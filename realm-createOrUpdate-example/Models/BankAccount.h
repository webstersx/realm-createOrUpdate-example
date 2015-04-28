//
//  BankAccount.h
//  realm-createOrUpdate-example
//
//  Created by Shawn Webster on 28/04/2015.
//  Copyright (c) 2015 Shawn Webster. All rights reserved.
//

#import <Realm/Realm.h>

@interface BankAccount : RLMObject
@property NSInteger _id;
@property float balance;
@property float cr_interest_rate;
@property float dr_interest_rate;
@end

RLM_ARRAY_TYPE(BankAccount)