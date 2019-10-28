/*
 * Copyright 2019 VMware
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


#import "CRUserflowsViewController.h"
#import <Crittercism/Crittercism.h>

@interface CRUserflowsViewController ()

@property (nonatomic) NSArray *userflowNames;

@end

@implementation CRUserflowsViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.userflowNames = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"userflowNames"];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return self.userflowNames.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SimpleCell" forIndexPath:indexPath];
  NSString *txText = [NSString stringWithFormat:@"Userflow \"%@\"", self.userflowNames[(NSUInteger)indexPath.section]];
  if (indexPath.row == 0) {
    cell.textLabel.text = [NSString stringWithFormat:@"%@: Begin ", txText];
  } else if (indexPath.row == 1) {
    cell.textLabel.text = [NSString stringWithFormat:@"%@: End  ", txText];
  } else if (indexPath.row == 2) {
    cell.textLabel.text = [NSString stringWithFormat:@"%@: Fail ", txText];
  } else if (indexPath.row == 3) {
    cell.textLabel.text = [NSString stringWithFormat:@"%@: Cancel ", txText];
  } else if (indexPath.row == 4) {
    cell.textLabel.text = [NSString stringWithFormat:@"%@: Add 1 ", txText];
  } else if (indexPath.row == 5) {
    cell.textLabel.text = [NSString stringWithFormat:@"%@: Get Value", txText];
  } else {
    assert(NO);
  }
  return cell;
}

- (void)executeCommand:(UIButton *)sender {
  NSLog(@"%@", sender.titleLabel.text);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 44;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return [NSString stringWithFormat:@"Userflow \"%@\":", self.userflowNames[section]];
}

- (void)performCommand:(NSString *)what forUserflow:(NSString *)txName {
  NSLog(@"%@ %@", what, txName);
  if ([what isEqualToString:@"Begin"]) {
    [Crittercism beginUserflow:txName];
  } else if ([what isEqualToString:@"End"]) {
    [Crittercism endUserflow:txName];
  } else if ([what isEqualToString:@"Fail"]) {
    [Crittercism failUserflow:txName];
  } else if ([what isEqualToString:@"Cancel"]) {
    [Crittercism cancelUserflow:txName];
  } else if ([what isEqualToString:@"Add"]) {
    if ([Crittercism valueForUserflow:txName] < 0)
      [Crittercism setValue:1 forUserflow:txName];
    else
      [Crittercism setValue:[Crittercism valueForUserflow:txName] + 1 forUserflow:txName];
  } else if ([what isEqualToString:@"Get"]) {
      UIAlertController* alert =[UIAlertController alertControllerWithTitle:txName
      message:[NSString stringWithFormat:@"Userflow value = %i", [Crittercism valueForUserflow:txName]]
      preferredStyle:UIAlertControllerStyleAlert];
    
      UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
         handler:^(UIAlertAction * action) {}];
       
      [alert addAction:defaultAction];
      [self presentViewController:alert animated:YES completion:nil];
      
  } else {
    NSString *msg = [NSString stringWithFormat:@"%@ %@", what, txName];
    UIAlertController* alert =[UIAlertController alertControllerWithTitle:msg
    message:@"" preferredStyle:UIAlertControllerStyleAlert];
  
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
       handler:^(UIAlertAction * action) {}];
     
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];

  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *what;
  switch (indexPath.row) {
  case 0:
    what = @"Begin";
    break;
  case 1:
    what = @"End";
    break;
  case 2:
    what = @"Fail";
    break;
  case 3:
    what = @"Cancel";
    break;
  case 4:
    what = @"Add";
    break;
  case 5:
    what = @"Get";
    break;
  default:
    assert(NO);
  }
  NSString *userflowName = self.userflowNames[indexPath.section];
  [self performCommand:what forUserflow:userflowName];
  [self performSelector:@selector(fadeSelection:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.3];
}

- (void)fadeSelection:(BOOL)animated {
  NSIndexPath *selection = [self.tView indexPathForSelectedRow];
  if (selection) {
    [self.tView deselectRowAtIndexPath:selection animated:animated];
  }
}

@end
