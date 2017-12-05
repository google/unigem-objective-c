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

#import "KeyboardViewController.h"

#import "KeyboardLettersView.h"
#import "KeyboardNumbersView.h"
#import "Mode.h"
#import "ModeSelector.h"


NS_ASSUME_NONNULL_BEGIN

@interface KeyboardViewController ()<KeyboardLettersDelegate, KeyboardNumbersDelegate>
@property(nonatomic) KeyboardLettersView *lettersView;
@property(nonatomic) KeyboardNumbersView *numbersView;
@property(nonatomic) ModeSelector *modeSelector;
@property(nonatomic, readonly) UICollectionView *modeCollectionView;
@property(nonatomic, readwrite) NSString *returnLabel;
@property(nonatomic) CGSize previousCollectionSize;
@property(nonatomic) UIReturnKeyType returnKeyType;
@end



@implementation KeyboardViewController

- (void)viewInitalLayout {
  _modeSelector = [[ModeSelector alloc] init];
  _returnLabel = @"ret";
  CGRect frame = [self.view bounds];
  _lettersView = [[KeyboardLettersView alloc] initWithFrame:frame];
  _lettersView.delegate = self;
  [_lettersView setAutoresizingMask:0x3F];
  [self.view addSubview:_lettersView];

  _numbersView = [[KeyboardNumbersView alloc] initWithFrame:frame];
  _numbersView.delegate = self;
  [_numbersView setAutoresizingMask:0x3F];
  [_numbersView setHidden:YES];
  [self.view addSubview:_numbersView];

  UICollectionView *modeCollectionView = [self modeCollectionView];
  [self.view addSubview:modeCollectionView];
  [modeCollectionView reloadData];
}

- (void)everyTimeLayout {
  CGRect bounds = self.view.bounds;
  CGRect screenBounds = [[UIScreen mainScreen] bounds];
  CGRect controlsRect, keyRect;
  UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.modeCollectionView.collectionViewLayout;
  if (screenBounds.size.width < screenBounds.size.height) {
    CGRectDivide(bounds, &controlsRect, &keyRect, 44, CGRectMinYEdge);
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [layout setItemSize:CGSizeMake(130, 44)];
  } else {
    CGRectDivide(bounds, &controlsRect, &keyRect, 200, CGRectMinXEdge);
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [layout setItemSize:CGSizeMake(100, 40)];
  }
  [_lettersView setFrame:keyRect];
  [_numbersView setFrame:keyRect];
  [self.modeCollectionView setFrame:controlsRect];
  if (CGSizeEqualToSize(controlsRect.size, _previousCollectionSize)) {
    [_modeSelector restoreInitialMode];
    _previousCollectionSize = controlsRect.size;
  }
}

- (void)viewWillLayoutSubviews {
  [super viewWillLayoutSubviews];
  if (self.view.superview ) {
    if (nil == _lettersView) {
      [self viewInitalLayout];
    }
    [self everyTimeLayout];
  }
}

- (void)didNumbers:(UIButton *)button {
  [_lettersView setHidden:YES];
  [_numbersView setHidden:NO];
}

- (void)didLetters:(UIButton *)button {
  [_lettersView setHidden:NO];
  [_numbersView setHidden:YES];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)setReturnLabel:(NSString *)returnLabel {
  if ( ! [_returnLabel isEqual:returnLabel]) {
    _returnLabel = returnLabel;
    [_lettersView didChangeReturnKeyName];
    [_numbersView didChangeReturnKeyName];
  }
}

- (UICollectionView *)modeCollectionView {
  return [_modeSelector collectionView];
}

- (NSString *)transform:(NSString *)s {
  return [_modeSelector.selectedMode transform:s];
}

- (BOOL)shouldResetInsertionPoint {
  return _modeSelector.selectedMode.shouldResetInsertionPoint;
}

- (void)setReturnKeyType:(UIReturnKeyType)returnKeyType {
  if (_returnKeyType != returnKeyType) {
    _returnKeyType = returnKeyType;
    switch (_returnKeyType) {
      default:
      case UIReturnKeyDefault: self.returnLabel = @"Return"; break;
      case UIReturnKeyGo: self.returnLabel = @"Go"; break;
      case UIReturnKeyGoogle: self.returnLabel = @"Google"; break;
      case UIReturnKeyJoin: self.returnLabel = @"Join"; break;
      case UIReturnKeyNext: self.returnLabel = @"Next"; break;
      case UIReturnKeyRoute: self.returnLabel = @"Route"; break;
      case UIReturnKeySearch: self.returnLabel = @"Search"; break;
      case UIReturnKeySend: self.returnLabel = @"Send"; break;
      case UIReturnKeyYahoo: self.returnLabel = @"Yahoo"; break;
      case UIReturnKeyDone: self.returnLabel = @"Done"; break;
      case UIReturnKeyEmergencyCall: self.returnLabel = @"Call"; break;
      case UIReturnKeyContinue: self.returnLabel = @"Continue"; break;
    }
  }
}

- (void)textWillChange:(nullable id<UITextInput>)textInput {
  // The app is about to change the document's contents. Perform any preparation here.
}

- (void)textDidChange:(nullable id<UITextInput>)textInput {
  [self setReturnKeyType:self.textDocumentProxy.returnKeyType];
  // The app has just changed the document's contents, the document context has been updated.
  [_lettersView setKeyboardAppearance:self.textDocumentProxy.keyboardAppearance];
  [_numbersView setKeyboardAppearance:self.textDocumentProxy.keyboardAppearance];
  [_modeSelector setKeyboardAppearance:self.textDocumentProxy.keyboardAppearance];
}

@end

NS_ASSUME_NONNULL_END

