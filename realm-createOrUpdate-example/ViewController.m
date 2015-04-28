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

@interface ViewController () {
    BOOL loadedBankAccounts;
    BOOL updatedPerson1;

}
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
    
    loadedBankAccounts = NO;
    updatedPerson1 = NO;
    
    [self updateDisplay];
}

- (IBAction) loadPeople:(id)sender {
    NSArray *people = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"people"
                                                                                                                             ofType:@"json"]]
                                                      options:0
                                                        error:nil];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    
    for (NSDictionary *person in people) {
        [Person createOrUpdateInDefaultRealmWithObject:person];
    }
    
    [realm commitWriteTransaction];
    
    updatedPerson1 = NO;
    
    [self updateDisplay];
}

- (IBAction) loadBankAccounts:(id)sender {
    NSArray *accounts = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"bank_accounts"
                                                                                                                               ofType:@"json"]]
                                                        options:0
                                                          error:nil];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    
    for (NSDictionary *account in accounts) {
        [BankAccount createOrUpdateInDefaultRealmWithObject:account];
    }
    
    [realm commitWriteTransaction];
    
    loadedBankAccounts = YES;
    
    [self updateDisplay];
}

- (IBAction)updatePerson1:(id)sender {
    NSDictionary *person1 = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"update_person_1"
                                                                                                                             ofType:@"json"]]
                                                      options:0
                                                        error:nil];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [Person createOrUpdateInDefaultRealmWithObject:person1];
    [realm commitWriteTransaction];
    
    updatedPerson1 = YES;
    
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
    
    NSInteger np = [[Person allObjects] count];
    NSInteger nba = [[BankAccount allObjects] count];
    Person *shawn = [Person objectForPrimaryKey:@(1)];
    Person *tim = [Person objectForPrimaryKey:@(2)];
    BankAccount *shawnsBankAccount = shawn.bank_account;
    BankAccount *timsBankAccount = tim.bank_account;
    float timsBalance = timsBankAccount.balance;
    float shawnsBalance = shawnsBankAccount.balance;
    
    if (np == 0 && nba == 0) {
        message = @"The database is empty";
    } else if (np == 1 && nba == 1) {
        message = @"Shawn Webster has been added as a person, and his bank account has default values";
    } else if (np == 2 && nba == 2) {
        
            
        if (loadedBankAccounts) {
            if (updatedPerson1) {
                if (shawnsBalance == 0) {
                    message = @"Tim's money went missing, then we updated Shawn's name (and cleared his debt) -- bad!";
                } else {
                    message = @"Loaded People, updated Shawn's name, then loaded Bank Accounts. This is also good.";
                }
            } else {
                
                if (timsBalance == 0) {
                    message = @"Bank Accounts *then* People were loaded. Tim is going to be really angry when he finds out his $10,000 is missing.";
                } else {
                    message = @"People *then* Bank Accounts were loaded. Everything is as it should be.";
                }
            }
        } else {
            
            if (updatedPerson1) {
                message = @"You loaded People then updated Shawn's name. Bank Accounts have default values";
            } else {
                message = @"You've just loaded People. Their Bank Accounts have default values.";
            }
        }
    } else if (nba == 2) {
        
        if (updatedPerson1) {
            message = @"You just updated Shawn's name... oh, and you cleared his debts! Yay for him, but this is really bad.";
            
        } else {
            message = @"You've just loaded Bank Accounts, they're not owned by any people yet but their balances are correct.";
        }
    }
    
    self.lblDescription.text = message;
}

@end
