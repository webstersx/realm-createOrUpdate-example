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
    
    [self updateDisplay];
}

- (void) updateDisplay {
    
    self.tvPeople.text = [[Person allObjects] description];
    self.tvBankAccounts.text = [[BankAccount allObjects] description];
}

@end
