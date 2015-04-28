//
//  ViewController.m
//  realm-createOrUpdate-example
//
//  Created by Shawn Webster on 28/04/2015.
//  Copyright (c) 2015 Shawn Webster. All rights reserved.
//

#import "ViewController.h"
#import <Realm/Realm.h>

#import "Person.h"
#import "BankAccount.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextView *tvPeople;
@property (weak, nonatomic) IBOutlet UITextView *tvBankAccounts;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self clearMockData:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) clearMockData:(id)sender {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm deleteAllObjects];
    [realm commitWriteTransaction];
    
    [self updateDisplay];
}

- (id) loadJSON:(NSString*)filename {
    //strip .json in case I made a mistake
    if ([filename hasSuffix:@".json"]) {
        filename = [filename stringByReplacingOccurrencesOfString:@".json" withString:@""];
    }
    
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@"json"]];
    
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
}

- (IBAction) loadPeople:(id)sender {
    NSArray *people = [self loadJSON:@"people"];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    
    for (NSDictionary *person in people) {
        [Person createOrUpdateInDefaultRealmWithObject:person];
    }
    
    [realm commitWriteTransaction];
    
    [self updateDisplay];
}

- (IBAction) loadBankAccounts:(id)sender {
    NSArray *accounts = [self loadJSON:@"bank_accounts"];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    
    for (NSDictionary *account in accounts) {
        [BankAccount createOrUpdateInDefaultRealmWithObject:account];
    }
    
    [realm commitWriteTransaction];
    
    [self updateDisplay];
}

- (IBAction)updatePerson1:(id)sender {
    NSDictionary *person1 = [self loadJSON:@"update_person_1"];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [Person createOrUpdateInDefaultRealmWithObject:person1];
    [realm commitWriteTransaction];
    
    [self updateDisplay];
    
}

- (void) updateDisplay {
    
    self.tvPeople.text = [[Person allObjects] description];
    self.tvBankAccounts.text = [[BankAccount allObjects] description];
    
    [self explain];
}

- (void) explain {
    //Note: these explanations are very specific to the example logic provided
    
    NSString *message = @"This state hasn't been defined yet.";
    
    NSInteger numAccounts = [[BankAccount allObjects] count];
    Person *shawn = [Person objectForPrimaryKey:@(1)];
    Person *tim = [Person objectForPrimaryKey:@(2)];
    BankAccount *shawnsBankAccount = shawn.bank_account;
    BankAccount *timsBankAccount = tim.bank_account;
    float timsBalance = timsBankAccount.balance;
    float shawnsBalance = shawnsBankAccount.balance;
    BOOL shawnUpdated = [shawn.first_name isEqualToString:@"Shawn Webster"];
    
    if (!shawn && !tim) {
        //both are loaded
        if (numAccounts == 2) {
            message = @"Accounts are correct but not linked to.";
        } else {
            message = @"Database is empty";
        }
    } else if (shawn && !tim) {
        if (numAccounts == 1) {
            message = @"Updated person 1, name is correct but account has default values";
        } else {
            if (shawnsBalance == 0) {
                message = @"Loaded accounts, then updated person 1. Person 1's balance just got wiped out.";
            } else {
                message = @"Updated person 1, then loaded accounts. Person 1 is correct but the person who owns account 1002 hasn't been loaded.";
            }
        }
    } else {
        //shawn and tim
        if (shawnsBalance == 0 && timsBalance == 0) {
            if (shawnUpdated) {
                message = @"People loaded then persion 1 updated. Accounts have default values.";
            } else {
                message = @"People loaded. If accounts were previously loaded they just got reset.";
            }
        } else if (timsBalance == 10000) {
            if (shawnsBalance == -10000) {
                if (shawnUpdated) {
                    message = @"People, person 1, then bank accounts in that order. This is a valid state.";
                } else {
                    message = @"People, then bank accounts in that order. This is a valid state.";
                }
            } else {
                message = @"People, bank accounts, then person 1. Person 1's balance just got reset.";
            }
        }
    }
    
    
    self.lblDescription.text = message;
}

@end
