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
#import <Foundation/Foundation.h>

#import "ToYinglish.h"

NS_ASSUME_NONNULL_BEGIN

const unichar ltrPrefixChar = 0x200e;
const unichar rtlPrefixChar = 0x200f;

NSString * const ltrPrefixS = @"\\u200e";
NSString * const rtlPrefixS = @"\\u200f";


static const unichar toYinglishMap[] = {
  0xfb2f,  /* A - א */
  0x05d1,  /* B - ב */
  0x05db,  /* C - כ */
  0x05d3,  /* D - ד */
  0x05d0,  /* E - א */
  0x05e4,  /* F - פ */
  0x05d2,  /* G - ג */
  0x05d4,  /* H - ה */
  0x05e2,  /* I - ע */
  0xfb39,  /* J - יּ */
  0x05e7,  /* K - ק */
  0x05dc,  /* L - ל */
  0x05de,  /* M - מ */
  0x05e0,  /* N - נ */
  0xfb4b,  /* O - וֹ */
  0xfb44,  /* P - פּ */
  0x05e7,  /* Q - ק */
  0x05e8,  /* R - ר */
  0x05e9,  /* S - ש */
  0x05ea,  /* T - ת */
  0xfb35,  /* U - וּ */
  0x05d5,  /* V - ו */
  0x05f0,  /* W - װ */
  0x05e6,  /* X - צ */
  0x05d9,  /* Y - י */
  0x05d6,  /* Z - ז */
};

static const unichar toYinglishMapFinal[] = {
  0xfb2f,  /* A - א */
  0x05d1,  /* B - ב */
  0x05da,  /* C - ך */
  0x05d3,  /* D - ד */
  0x05d0,  /* E - א */
  0x05e3,  /* F - ף */
  0x05d2,  /* G - ג */
  0x05d4,  /* H - ה */
  0x05e2,  /* I - ע */
  0xfb39,  /* J - יּ */
  0x05e7,  /* K - ק */
  0x05dc,  /* L - ל */
  0x05de,  /* M - מ */
  0x05df,  /* N - ן */
  0xfb4b,  /* O - וֹ */
  0xfb43,  /* P - ףּ */
  0x05e7,  /* Q - ק */
  0x05e8,  /* R - ר */
  0x05e9,  /* S - ש */
  0x05ea,  /* T - ת */
  0xfb35,  /* U - וּ */
  0x05d5,  /* V - ו */
  0x05f0,  /* W - װ */
  0x05e5,  /* X - ץ */
  0x05d9,  /* Y - י */
  0x05d6,  /* Z - ז */
};


unichar ToYinglishC(unichar c, unichar cNext) {
  if ('a' <= c && c <= 'z') {
    c += 'A' - 'a';
  }
  if ('a' <= cNext && cNext <= 'z') {
    cNext += 'A' - 'a';
  }
  if ('A' <= c && c <= 'Z') {
    if ('A' <= cNext && cNext <= 'Z') {
      c = toYinglishMap[c - 'A'];
    } else {
      c = toYinglishMapFinal[c - 'A'];
    }
  }
  return c;
}


const char *ToYinglish(const char *inCString) {
  NSString *inString = [NSString stringWithUTF8String:inCString];
  return [ToYinglishS(inString) UTF8String];
}

NSString *ToYinglishS(NSString *inString) {
  NSUInteger length = [inString length];
  NSMutableString *s = [NSMutableString stringWithCapacity:length];
//  BOOL didModify = NO;
  for (NSUInteger i = 0; i < length ; ++i) {
    unichar c = [inString characterAtIndex:i];
    unichar cNext = EOF;
    if (i < length - 1) {
      cNext = [inString characterAtIndex:i+1];
    }
    if (c == '\\') {
      [s appendFormat:@"\\%C", cNext];
      i += 1;
    } else {
      unichar resultC = ToYinglishC(c, cNext);
      if (resultC != c) {
//        didModify = YES;
      }
      [s appendFormat:@"%C", resultC];
    }
  }
  NSString *result = s;
//  if (didModify) {
//    result = [NSString stringWithFormat:@"%@%@%@", rtlPrefixS, s, ltrPrefixS];
//  }
  return result;
}

NS_ASSUME_NONNULL_END

