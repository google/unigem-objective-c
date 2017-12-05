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
#import "ModeCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ModeSelector()<NSCollectionViewDataSource, NSCollectionViewDelegate>
@property(nonatomic, weak) IBOutlet NSCollectionView *selectionView;
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

- (void)setDelegate:(id<ModeSelectorDelegate>)delegate {
  if (_delegate != delegate) {
    _delegate = delegate;
    [_delegate modeSelectorDidChange:self];
  }
}

- (void)setSelectionView:(nullable NSCollectionView *)selectionView {
  if (_selectionView != selectionView) {
    _selectionView = selectionView;
    [_selectionView registerClass:[ModeCell class] forItemWithIdentifier:@"ModeCell"];
    [_selectionView reloadData];
  }
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return [_modeModel count];
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
  ModeCell *cell = [collectionView makeItemWithIdentifier:@"ModeCell" forIndexPath:indexPath];

  Mode *mode = [_modeModel modeAtIndex:indexPath.item];
  if (mode) {
    [cell.textField setStringValue:[mode name] ?: @""];
    [cell.detailLabel setStringValue:[mode transform]([mode name]) ?: @""];
    if ([mode isEqual:_selectedMode]) {
      NSColor *backColor = [NSColor blueColor];
      NSColor *textColor = [NSColor colorWithWhite:0.9 alpha:1];
      [cell.textField setBackgroundColor:backColor];
      [cell.detailLabel setBackgroundColor:backColor];
      [cell.textField setTextColor:textColor];
      [cell.detailLabel setTextColor:textColor];
    } else {
      NSColor *backColor = [NSColor colorWithWhite:0.9 alpha:1];
      NSColor *textColor = [NSColor colorWithWhite:0.1 alpha:1];
      [cell.textField setBackgroundColor:backColor];
      [cell.detailLabel setBackgroundColor:backColor];
      [cell.textField setTextColor:textColor];
      [cell.detailLabel setTextColor:textColor];
    }
  }
  return cell;
}

- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths {
  NSIndexPath *indexPath = indexPaths.anyObject;
  Mode *mode = [_modeModel modeAtIndex:indexPath.item];
  if (_selectedMode != mode) {
    _selectedMode = mode;
    [_selectionView reloadData];
    [_delegate modeSelectorDidChange:self];
  }
}

@end

NS_ASSUME_NONNULL_END
