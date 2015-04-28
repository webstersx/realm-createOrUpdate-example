//
//  Person.h
//  realm-createOrUpdate-example
//
//  Created by Shawn Webster on 28/04/2015.
//  Copyright (c) 2015 Shawn Webster. All rights reserved.
//

#import <Realm/Realm.h>

@class BankAccount;

@interface Person : RLMObject
@property NSInteger _id;
@property NSString *pin;
@property NSString *first_name;
@property NSString *last_name;
@property BankAccount *bank_account;
@end

RLM_ARRAY_TYPE(Person)