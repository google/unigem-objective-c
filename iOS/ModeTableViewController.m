/*
  Copyright 2017 Google Inc.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      https://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

#import "ModeTableViewController.h"

#import "Mode.h"
#import "ModeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ModeTableViewController ()
@property(nonatomic) ModeModel *modeModel;
@end

@implementation ModeTableViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setTitle:@"Select Mode"];
  _modeModel = [ModeModel sharedInstance];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)setSelectedMode:(Mode *)selectedMode {
  if (_selectedMode != selectedMode) {
    _selectedMode = selectedMode;
    [self.tableView reloadData];
    [_modeDelegate tableViewControllerSelectedModeDidChange:self];
  }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [_modeModel count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
  if (nil == cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
  }
  Mode *mode = [_modeModel modeAtIndex:indexPath.row];
  cell.textLabel.text = [mode name];
  cell.detailTextLabel.text = [mode transform]([mode name]);
  [cell setAccessoryType: [mode isEqual:_selectedMode] ?
      UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone ];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  Mode *mode = [_modeModel modeAtIndex:indexPath.row];
  [self setSelectedMode:mode];
}

@end

NS_ASSUME_NONNULL_END
