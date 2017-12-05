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

#import "KeyboardNumbersView.h"

#import "HolderButton.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum {
  kBoardStateUppercase,
  kBoardStateLowercase,
} BoardStateEnum;

static NSString *const kRowS = @"0123456789-/:;()$&@\"⇧.,?!'⌫";
static NSString *const kShiftS = @"[]{}#%^*+=_\\|~<>€£¥•⇧.,?!'⌫";

@interface KeyboardNumbersView()
@property(nonatomic) NSArray *keys;
@property(nonatomic) BoardStateEnum boardState;
@end

enum {
  kIndexShift = 20,
  kIndexBackspace = 26,
  kIndexLetters = 27,
  kIndexKeyboard = 28,
  kIndexSpace = 29,
  kIndexReturn = 30
};

@implementation KeyboardNumbersView

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    NSMutableArray *keys = [NSMutableArray array];
    for (int i = 0; i < 31; ++i) {
      HolderButton *button = [HolderButton buttonWithType:UIButtonTypeSystem];
      button.tag = i;
      if (i < [kRowS length]) {
        NSString *s = [kRowS substringWithRange:NSMakeRange(i, 1)];
        [button setTitle:s forState:UIControlStateNormal];
      }
      [button setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1]];
      [button setTitleColor:[UIColor colorWithWhite:0.2 alpha:1] forState:UIControlStateNormal];
      [button.titleLabel setFont:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]];
      [button.titleLabel setMinimumScaleFactor:0.8];
      [button.layer setCornerRadius:3];
      [button setClipsToBounds:NO];
      [button.layer setShadowColor:[UIColor blackColor].CGColor];
      [button.layer setShadowRadius:2];
      [button.layer setShadowOffset:CGSizeMake(0, 1)];
      [button.layer setShadowOpacity:0.5];
      switch (i) {
      case kIndexShift:
        [button setTitle:@"#+=" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(didShift:) forControlEvents:UIControlEventTouchUpInside];
        break;
      case kIndexBackspace:
        [button addTarget:self action:@selector(didBackspace:) forControlEvents:UIControlEventTouchUpInside];
        break;
      case kIndexLetters:
        [button setTitle:@"ABC" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(didLetters:) forControlEvents:UIControlEventTouchUpInside];
        break;
      case kIndexSpace:
        [button setTitle:@"" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(didSpace:) forControlEvents:UIControlEventTouchUpInside];
        break;
      case kIndexReturn:
        [button setTitle:_delegate.returnLabel forState:UIControlStateNormal];
        [button addTarget:self action:@selector(didReturn:) forControlEvents:UIControlEventTouchUpInside];
        break;
      case kIndexKeyboard:
        [button setTitle:@"🌐" forState:UIControlStateNormal];
        break;
      default:
        [button addTarget:self action:@selector(didTap:) forControlEvents:UIControlEventTouchUpInside];
        break;
      }
      [keys addObject:button];
      [self addSubview:button];
    }
    _keys = keys;
    [self updateKeyboardAppearance];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  if (self.superview) {
    static const CGFloat kXMargin = 2;
    static const CGFloat kYMargin = 4;
    CGRect bounds = self.bounds;

    CGFloat keyCellWidth = bounds.size.width / 10;
    CGFloat keyCellRow3Width = bounds.size.width / 8;
    CGFloat keyCellHeight = bounds.size.height / 4;
    int i = 0;
    UIEdgeInsets insets = UIEdgeInsetsMake(kYMargin, kXMargin, kYMargin, kXMargin);
    for (; i < 10; ++i) {
      CGRect cellFrame = CGRectMake(bounds.origin.x + i*keyCellWidth,
          bounds.origin.y + 0*keyCellHeight, keyCellWidth, keyCellHeight);
      CGRect keyFrame = UIEdgeInsetsInsetRect(cellFrame, insets);
      UIButton *button = _keys[i];
      button.frame = keyFrame;
    }
    for (int j = 0; j < 10; j++) {
      CGRect cellFrame = CGRectMake(bounds.origin.x + j*keyCellWidth,
          bounds.origin.y + 1*keyCellHeight, keyCellWidth, keyCellHeight);
      CGRect keyFrame = UIEdgeInsetsInsetRect(cellFrame, insets);
      UIButton *button = _keys[i++];
      button.frame = keyFrame;
    }

    // Shift key
    CGRect cellFrame = CGRectMake(bounds.origin.x + 0*keyCellRow3Width,
        bounds.origin.y + 2*keyCellHeight, keyCellRow3Width + keyCellRow3Width/2, keyCellHeight);
    CGRect keyFrame = UIEdgeInsetsInsetRect(cellFrame, insets);
    UIButton *button = _keys[i++];
    button.frame = keyFrame;

    for (int j = 1; j < 7; j++) {
      CGRect cellFrame = CGRectMake(bounds.origin.x + j*keyCellRow3Width + keyCellRow3Width/2,
          bounds.origin.y + 2*keyCellHeight, keyCellRow3Width, keyCellHeight);
      if (6 == j) {
        cellFrame.size.width *= 1.5;
      }
      CGRect keyFrame = UIEdgeInsetsInsetRect(cellFrame, insets);
      UIButton *button = _keys[i++];
      button.frame = keyFrame;
    }

   // Letters key
    CGRect cellFrame0 = CGRectMake(bounds.origin.x + 0*keyCellWidth,
        bounds.origin.y + 3*keyCellHeight, keyCellWidth * 1.5, keyCellHeight);
    CGRect keyFrame0 = UIEdgeInsetsInsetRect(cellFrame0, insets);
    UIButton *button0 = _keys[i++];
    button0.frame = keyFrame0;

    // Keyboard key
    CGRect cellFrame1 = CGRectMake(bounds.origin.x + 1*keyCellWidth + keyCellWidth/2,
        bounds.origin.y + 3*keyCellHeight, keyCellWidth, keyCellHeight);
    CGRect keyFrame1 = UIEdgeInsetsInsetRect(cellFrame1, insets);
    UIButton *button1 = _keys[i++];
    [button1 setTintColor:[UIColor colorWithWhite:0.2 alpha:1]];
    button1.frame = keyFrame1;

    CGRect cellFrame2 = CGRectMake(bounds.origin.x + 2*keyCellWidth + keyCellWidth/2,
        bounds.origin.y + 3*keyCellHeight, 5*keyCellWidth, keyCellHeight);
    CGRect keyFrame2 = UIEdgeInsetsInsetRect(cellFrame2, insets);
    UIButton *button2 = _keys[i++];
    button2.frame = keyFrame2;

    CGRect cellFrame3 = CGRectMake(bounds.origin.x + 7*keyCellWidth + keyCellWidth/2,
        bounds.origin.y + 3*keyCellHeight, 2.5*keyCellWidth, keyCellHeight);
    CGRect keyFrame3 = UIEdgeInsetsInsetRect(cellFrame3, insets);
    UIButton *button3 = _keys[i++];
    button3.frame = keyFrame3;

  }
}

- (void)setDelegate:(nullable id<KeyboardNumbersDelegate>)delegate {
  if (_delegate != delegate) {
    _delegate = delegate;
    if (delegate) {
      UIButton *button = _keys[kIndexKeyboard];
      if ([delegate respondsToSelector:@selector(handleInputModeListFromView:withEvent:)]) {
        [button removeTarget:self action:nil forControlEvents:UIControlEventAllTouchEvents];
        [button addTarget:self action:@selector(handleInputModeListFromView:withEvent:) forControlEvents:UIControlEventAllTouchEvents];
      } else {
        [button removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(advanceToNextInputMode) forControlEvents:UIControlEventTouchUpInside];
      }
      [self updateReturn];
    }
  }
}

- (void)updateReturn {
  UIButton *button = _keys[kIndexReturn];
  [button setEnabled:_delegate.textDocumentProxy.hasText];
}

- (NSString *)transform:(NSString *)s {
  if (_delegate) {
    return [_delegate transform:s];
  } else {
    return s;
  }
}

- (void)didChangeReturnKeyName {
  UIButton *button = _keys[kIndexReturn];
  [button setTitle:_delegate.returnLabel forState:UIControlStateNormal];
}

- (void)didTap:(UIButton *)button {
  NSString *s = [[button titleLabel] text];
  s = [self transform:s];
  [_delegate.textDocumentProxy insertText:s];
  if (_delegate.shouldResetInsertionPoint) {
    [_delegate.textDocumentProxy adjustTextPositionByCharacterOffset: - [s length]];
  }
  [self updateReturn];
}

- (void)didShift:(UIButton *)button {
  if (kBoardStateLowercase == _boardState) {
    [self setBoardState:kBoardStateUppercase];
  } else if (kBoardStateUppercase == _boardState) {
    [self setBoardState:kBoardStateLowercase];
  }
}

- (void)didBackspace:(UIButton *)button {
  if (_delegate.shouldResetInsertionPoint) {
    [_delegate.textDocumentProxy adjustTextPositionByCharacterOffset: 1];
  }
  [_delegate.textDocumentProxy deleteBackward];
  [self updateReturn];
}

- (void)didLetters:(UIButton *)button {
  [_delegate didLetters:button];
}

- (void)advanceToNextInputMode {
  [_delegate advanceToNextInputMode];
}

- (void)handleInputModeListFromView:(UIView *)view  withEvent:(UIEvent *)event {
  [_delegate handleInputModeListFromView:view withEvent:event];
}

- (void)didSpace:(UIButton *)button {
  [_delegate.textDocumentProxy insertText:@" "];
  if (_delegate.shouldResetInsertionPoint) {
    [_delegate.textDocumentProxy adjustTextPositionByCharacterOffset: -1];
  }
  [self updateReturn];
}

- (void)didReturn:(UIButton *)button {
  [_delegate.textDocumentProxy insertText:@"\n"];
}

- (void)setKeyboardAppearance:(UIKeyboardAppearance)keyboardAppearance {
  if (_keyboardAppearance != keyboardAppearance) {
    _keyboardAppearance = keyboardAppearance;
    [self updateKeyboardAppearance];
  }
}

- (void)updateKeyboardAppearance {
  UIColor *textColor = nil;
  UIColor *keyBackgroundColor = nil;
  UIColor *textDisabledColor = [UIColor colorWithWhite:0.4 alpha:1];
  if (_keyboardAppearance == UIKeyboardAppearanceDark) {
    textColor = [UIColor colorWithWhite:0.9 alpha:1];
    keyBackgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
  } else {
    textColor = [UIColor colorWithWhite:0.2 alpha:1];
    keyBackgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
  }
  for (UIButton *button in _keys) {
    [button setTitleColor:textColor forState:UIControlStateNormal];
    [button setTitleColor:textDisabledColor forState:UIControlStateDisabled];
    [button setBackgroundColor:keyBackgroundColor];
  }
}


- (void)setBoardState:(BoardStateEnum)boardState  {
  if (_boardState != boardState) {
    _boardState = boardState;
    NSString *s = kBoardStateUppercase == _boardState ? kRowS : kShiftS;
    NSUInteger count = MIN([_keys count], [s length]);
    for (NSUInteger i = 0; i < count; ++i) {
      UIButton *button = _keys[i];
      if (kIndexShift == button.tag) {
        NSString *title = kBoardStateUppercase == _boardState ? @"#+=" : @"123";
        [button setTitle:title forState:UIControlStateNormal];
      } else {
        [button setTitle:[s substringWithRange:NSMakeRange(i, 1)] forState:UIControlStateNormal];
      }
    }
  }
}

@end

NS_ASSUME_NONNULL_END
