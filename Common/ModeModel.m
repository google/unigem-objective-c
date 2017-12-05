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
#import "ModeModel.h"

#import "Mode.h"
#import "NSString+UpsideDownAdditions.h"

NS_ASSUME_NONNULL_BEGIN

@interface ModeModel ()
@property(nonatomic) NSArray<Mode *> *modes;
@end

static ModeModel *sModeModel;

@implementation ModeModel

+ (instancetype)sharedInstance {
  if (nil == sModeModel) {
    sModeModel = [[self alloc] init];
  }
  return sModeModel;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    Mode *upsideDown = MakeNode(@"Upside Down", ^(NSString *s) { return [[s invert] reverse]; });
    upsideDown.shouldResetInsertionPoint = YES;
    Mode *backwards = MakeNode(@"Backwards", ^(NSString *s) { return [[s uppercaseString] backwards]; });
    backwards.shouldResetInsertionPoint = YES;
   _modes = @[
    MakeNode(@"Unchanged", ^(NSString *s) { return s; }),
    MakeNode(@"Ringed", ^(NSString *s) { return [s ringed]; }),
    MakeNode(@"Braille", ^(NSString *s) { return [s braille]; }),
    MakeNode(@"BlackBoxedCaps", ^(NSString *s) { return [s blackBoxedCaps]; }),
    MakeNode(@"BlackRingedCaps", ^(NSString *s) { return [s blackRingedCaps]; }),
    MakeNode(@"BoxedCaps", ^(NSString *s) { return [s boxedCaps]; }),
    // On iOS 10 and 11, this is national flags
//    MakeNode(@"DottedBoxedCaps", ^(NSString *s) { return [s dottedBoxedCaps]; }),
    MakeNode(@"Double", ^(NSString *s) { return [s mathDouble]; }),
    backwards,
    MakeNode(@"Germanic", ^(NSString *s) { return [s mathGermanic]; }),
    MakeNode(@"Germanic Bold", ^(NSString *s) { return [s mathGermanicBold]; }),
    MakeNode(@"Sans", ^(NSString *s) { return [s mathSans]; }),
    MakeNode(@"Sans Bold", ^(NSString *s) { return [s mathSansBold]; }),
    MakeNode(@"Mono", ^(NSString *s) { return [s mathMono]; }),
    MakeNode(@"Sans Italic", ^(NSString *s) { return [s mathSansItalic]; }),
    MakeNode(@"Sans Bold Italic", ^(NSString *s) { return [s mathSansBoldItalic]; }),
    MakeNode(@"Serif Bold", ^(NSString *s) { return [s mathSerifBold]; }),
    MakeNode(@"Serif Italic", ^(NSString *s) { return [s mathSerifItalic]; }),
    MakeNode(@"Serif Bold Italic", ^(NSString *s) { return [s mathSerifBoldItalic]; }),
    MakeNode(@"Script Italic", ^(NSString *s) { return [s mathScriptItalic]; }),
    MakeNode(@"Script Bold Italic", ^(NSString *s) { return [s mathScriptBoldItalic]; }),
//    MakeNode(@"Small Caps", ^(NSString *s) { return [s smallCaps]; }),
//    MakeNode(@"Very Small Caps", ^(NSString *s) { return [s verySmallCaps]; }),
    upsideDown,
    MakeNode(@"Yinglish", ^(NSString *s) { return [s yinglish]; }),
    MakeNode(@"Keycaps", ^(NSString *s) { return [s withCombining:@[@"\u20e3"]]; }),
    MakeNode(@"Square", ^(NSString *s) { return [s withCombining:@[@"\u20de"]]; }),
    MakeNode(@"Diamond", ^(NSString *s) { return [s withCombining:@[@"\u20df"]]; }),
    MakeNode(@"Bar", ^(NSString *s) { return [s withCombining:@[@"\u20d2"]]; }),
    MakeNode(@"Double Bar", ^(NSString *s) { return [s withCombining:@[@"\u20e6"]]; }),
    MakeNode(@"Slash", ^(NSString *s) { return [s withCombining:@[@"\u0337"]]; }),
    MakeNode(@"Double Slash", ^(NSString *s) { return [s withCombining:@[@"\u20eb"]]; }),
    MakeNode(@"Hyphen", ^(NSString *s) { return [s withCombining:@[@"\u0336"]]; }),
    MakeNode(@"Slashs", ^(NSString *s) { return [s withCombining:@[@"\u0337", @"\u20eb"]]; }),
    MakeNode(@"SlashHyphen", ^(NSString *s) { return [s withCombining:@[@"\u0337", @"\u0336", @"\u20eb", @"\u0336"]]; }),
   ];
  }
  return self;
}

- (NSUInteger)count {
  return [_modes count];
}

- (Mode *)modeAtIndex:(NSUInteger)index {
  return [_modes objectAtIndex:index];
}

- (nullable Mode *)modeForName:(NSString *)name {
  Mode *result = nil;
  for (Mode *mode in _modes) {
    if ([[mode name] isEqual:name]) {
      result = mode;
      break;
    }
  }
  return result;
}

- (NSUInteger)indexOfMode:(Mode *)mode {
  NSUInteger result = NSNotFound;
  NSUInteger count = [_modes count];
  for (NSUInteger i = 0; i < count; ++i) {
    Mode *modeA = _modes[i];
    if ([modeA.name isEqual:mode.name]) {
      result = i;
      break;
    }
  }
  return result;
}


@end

NS_ASSUME_NONNULL_END
