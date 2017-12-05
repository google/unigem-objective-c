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

#import "ModeSelector.h"

#import "Mode.h"
#import "ModeModel.h"
#import "NSString+UpsideDownAdditions.h"
#import "SelectorCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ModeSelector () <UICollectionViewDataSource,  UICollectionViewDelegate>
@property(nonatomic, readwrite) UICollectionView *collectionView;
@property(nonatomic) ModeModel *modeModel;
@end

@implementation ModeSelector

- (instancetype)init {
  self = [super init];
  if (self) {
    _modeModel = [ModeModel sharedInstance];
    _selectedMode = [Mode identity];
  }
  return self;
}

- (UICollectionView *)collectionView {
  if (nil == _collectionView) {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setMinimumLineSpacing:0];
    [layout setMinimumInteritemSpacing:0];
    [layout setSectionInset:UIEdgeInsetsZero];
    [layout setItemSize:CGSizeMake(100, 20)];
    // Initial rect is a non-zero placeholder.
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 300, 44) collectionViewLayout:layout];
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    [_collectionView registerClass:[SelectorCell class] forCellWithReuseIdentifier:@"cell"];
    [_collectionView setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:1]];
  }
  return _collectionView;
}

- (void)setSelectedMode:(Mode *)selectedMode {
  if (_selectedMode != selectedMode) {
    _selectedMode = selectedMode;
    [self.collectionView reloadData];
    NSString *name = selectedMode.name;
    if (name) {
      NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
      [defaults setObject:name forKey:@"mode"];
      [defaults synchronize];
    }
  }
}

- (UIColor *)backgroundColor {
  if (_keyboardAppearance == UIKeyboardAppearanceDark) {
    return [UIColor blackColor];
  } else {
    return [UIColor colorWithWhite:0.9 alpha:1];
  }
}

- (UIColor *)textColor {
  if (_keyboardAppearance == UIKeyboardAppearanceDark) {
    return [UIColor colorWithWhite:0.9 alpha:1];
  } else {
    return [UIColor colorWithWhite:0.1 alpha:1];
  }
}

- (void)setKeyboardAppearance:(UIKeyboardAppearance)keyboardAppearance {
  if (_keyboardAppearance != keyboardAppearance) {
    _keyboardAppearance = keyboardAppearance;
    [_collectionView setBackgroundColor:[self backgroundColor]];
    [_collectionView reloadData];
  }
}

- (void)restoreInitialMode {
  NSString *modeName = [[NSUserDefaults standardUserDefaults] stringForKey:@"mode"];
  Mode *mode = [_modeModel modeForName:modeName];
  if (mode) {
    [self setSelectedMode:mode];
    NSUInteger i = [_modeModel indexOfMode:mode];
    if (NSNotFound != i) {
      NSIndexPath *path = [NSIndexPath indexPathForItem:i inSection:0];
      UICollectionViewScrollPosition pos = UICollectionViewScrollPositionCenteredVertically |UICollectionViewScrollPositionCenteredHorizontally;
      [_collectionView scrollToItemAtIndexPath:path atScrollPosition:pos animated:NO];
    }
  }
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return [_modeModel count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  SelectorCell *cell = (SelectorCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
  Mode *mode = [_modeModel modeAtIndex:indexPath.row];
  [cell.textLabel setText:[mode name]];
  [cell.detailLabel setText:[mode transform]([mode name])];
  if ([mode isEqual:_selectedMode]) {
    UIColor *backColor = [UIColor blueColor];
    UIColor *textColor = [UIColor colorWithWhite:0.9 alpha:1];
    [cell.contentView setBackgroundColor:backColor];
    [cell.textLabel setTextColor:textColor];
    [cell.detailLabel setTextColor:textColor];
  } else {
    UIColor *backColor = [self backgroundColor];
    UIColor *textColor = [self textColor];
    [cell.contentView setBackgroundColor:backColor];
    [cell.textLabel setTextColor:textColor];
    [cell.detailLabel setTextColor:textColor];
  }
  return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  Mode *mode = [_modeModel modeAtIndex:indexPath.row];
  [self setSelectedMode:mode];
}

@end

NS_ASSUME_NONNULL_END
