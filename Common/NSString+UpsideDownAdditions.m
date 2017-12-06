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

#import "NSString+UpsideDownAdditions.h"
#import "ToYinglish.h"

static NSString *kLowMem = @"Out of Memory";

NS_ASSUME_NONNULL_BEGIN

// 'buffer' in all of these, is a place to construct the output, at least 5 chars long.
static const unsigned char *CharToUTF8(uint64_t c, unsigned char *buffer, NSUInteger bufferLen) {
  NSCAssert(5 <= bufferLen, @"Buffer must be at least 5 long");
  if (c <= 0x7F) {
    buffer[0] = c;
    buffer[1] = '\0';
  } else if (c <= 0x7FF) {
    buffer[0] = 0xA0 | (0x1F & (c >> 6));
    buffer[1] = 0x80 | (0x3F & c);
    buffer[2] = '\0';
  } else if (c <= 0xFFFF) {
    buffer[0] = 0xE0 | (0xF & (c >> 12));
    buffer[1] = 0x80 | (0x3F & (c >> 6));
    buffer[2] = 0x80 | (0x3F & c);
    buffer[3] = '\0';
  } else {
    buffer[0] = 0xF0 | (0x7 & (c >> 18));
    buffer[1] = 0x80 | (0x3F & (c >>12));
    buffer[2] = 0x80 | (0x3F & (c >> 6));
    buffer[3] = 0x80 | (0x3F & c);
    buffer[4] = '\0';
  }
  return buffer;
}

static const unsigned char *  MathSerifBoldChar(uint64_t c, unsigned char *buffer, NSUInteger bufferLen) {
  if ('A' <= c && c <= 'Z') {
    c += 0x1D400 - 'A';
  } else if ('a' <= c && c <= 'z') {
    c += 0x1D41a - 'a';
  }
  return CharToUTF8(c, buffer, bufferLen);
}

// 𝑀𝑎𝑡ℎ𝑆𝑒𝑟𝑖𝑓𝐼𝑡𝑎𝑙𝑖𝑐𝐶ℎ𝑎𝑟 𝐿𝑜𝑜𝑘𝑠 𝑙𝑖𝑘𝑒 𝑡ℎ𝑖𝑠
// http://www.unicode.org/charts/PDF/U1D400.pdf tells where the exceptions are.
static const unsigned char *  MathSerifItalicChar(uint64_t c, unsigned char *buffer, NSUInteger bufferLen) {
  if ('A' <= c && c <= 'Z') {
    c += 0x1D434 - 'A';
  } else if ('h' == c) {
    c = 0x210E;
  } else if ('a' <= c && c <= 'z') {
    c += 0x1D44E - 'a';
  }
  return CharToUTF8(c, buffer, bufferLen);
}

// 𝓜𝓪𝓽𝓱𝓢𝓬𝓻𝓲𝓹𝓽𝓑𝓸𝓵𝓭𝓘𝓽𝓪𝓵𝓲𝓬𝓒𝓱𝓪𝓻 𝓛𝓸𝓸𝓴𝓼 𝓵𝓲𝓴𝓮 𝓽𝓱𝓲𝓼
static const unsigned char *  MathSerifBoldItalicChar(uint64_t c, unsigned char *buffer, NSUInteger bufferLen) {
  if ('A' <= c && c <= 'Z') {
    c += 0x1D468 - 'A';
  } else if ('a' <= c && c <= 'z') {
    c += 0x1D482 - 'a';
  }
  return CharToUTF8(c, buffer, bufferLen);
}

static const unsigned char *  MathScriptItalicChar(uint64_t c, unsigned char *buffer, NSUInteger bufferLen) {
  if ('B' == c) {
    c = 0x212C;
  } else if ('E' == c) {
    c = 0x2130;
  } else if ('F' == c) {
    c = 0x2131;
  } else if ('H' == c) {
    c = 0x210B;
  } else if ('I' == c) {
    c = 0x2110;
  } else if ('L' == c) {
    c = 0x2112;
  } else if ('M' == c) {
    c = 0x2133;
  } else if ('R' == c) {
    c = 0x211B;
  } else if ('e' == c) {
    c = 0x212F;
  } else if ('g' == c) {
    c = 0x210A;
  } else if ('o' == c) {
    c = 0x2134;
  } else if ('A' <= c && c <= 'Z') {
    c += 0x1D49C - 'A';
  } else if ('a' <= c && c <= 'z') {
    c += 0x1D4B6 - 'a';
  }
  return CharToUTF8(c, buffer, bufferLen);
}

static const unsigned char *  MathScriptBoldItalicChar(uint64_t c, unsigned char *buffer, NSUInteger bufferLen) {
  if ('A' <= c && c <= 'Z') {
    c += 0x1D4D0 - 'A';
  } else if ('a' <= c && c <= 'z') {
    c += 0x1D4EA - 'a';
  }
  return CharToUTF8(c, buffer, bufferLen);
}

// 𝔐𝔞𝔱𝔥𝔊𝔢𝔯𝔪𝔞𝔫𝔦𝔠ℭ𝔥𝔞𝔯 𝔏𝔬𝔬𝔨𝔰 𝔩𝔦𝔨𝔢 𝔱𝔥𝔦𝔰
static const unsigned char *  MathGermanicChar(uint64_t c, unsigned char *buffer, NSUInteger bufferLen) {
  if ('C' == c) {
    c = 0x212D;
  } else if ('H' == c) {
    c = 0x210C;
  } else if ('I' == c) {
    c = 0x2111;
  } else if ('R' == c) {
    c = 0x211C;
  } else if ('Z' == c) {
    c = 0x2128;
  } else if ('A' <= c && c <= 'Z') {
    c += 0x1D504 - 'A';
  } else if ('a' <= c && c <= 'z') {
    c += 0x1D51E - 'a';
  }
  return CharToUTF8(c, buffer, bufferLen);
}

// 𝕄𝕒𝕥𝕙𝔻𝕠𝕦𝕓𝕝𝕖ℂ𝕙𝕒𝕣 𝕃𝕠𝕠𝕜𝕤 𝕝𝕚𝕜𝕖 𝕥𝕙𝕚𝕤
static const unsigned char *  MathDoubleChar(uint64_t c, unsigned char *buffer, NSUInteger bufferLen) {
  if ('C' == c) {
    c = 0x2102;
  } else if ('H' == c) {
    c = 0x210D;
  } else if ('N' == c) {
    c = 0x2115;
  } else if ('P' == c) {
    c = 0x2119;
  } else if ('Q' == c) {
    c = 0x211A;
  } else if ('R' == c) {
    c = 0x211D;
  } else if ('Z' == c) {
    c = 0x2124;
  } else if ('A' <= c && c <= 'Y') {
    c += 0x1D538 - 'A';
  } else if ('a' <= c && c <= 'z') {
    c += 0x1D552 - 'a';
  }
  return CharToUTF8(c, buffer, bufferLen);
}

static const unsigned char *  MathGermanicBoldChar(uint64_t c, unsigned char *buffer, NSUInteger bufferLen) {
  if ('A' <= c && c <= 'Z') {
    c += 0x1D56C - 'A';
  } else if ('a' <= c && c <= 'z') {
    c += 0x1D586 - 'a';
  }
  return CharToUTF8(c, buffer, bufferLen);
}

static const unsigned char *  MathSansChar(uint64_t c, unsigned char *buffer, NSUInteger bufferLen) {
  if ('A' <= c && c <= 'Z') {
    c += 0x1D5A0 - 'A';
  } else if ('a' <= c && c <= 'z') {
    c += 0x1D5BA - 'a';
  }
  return CharToUTF8(c, buffer, bufferLen);
}

static const unsigned char *  MathSansBoldChar(uint64_t c, unsigned char *buffer, NSUInteger bufferLen) {
  if ('A' <= c && c <= 'Z') {
    c += 0x1D5D4 - 'A';
  } else if ('a' <= c && c <= 'z') {
    c += 0x1D5EE - 'a';
  }
  return CharToUTF8(c, buffer, bufferLen);
}

static const unsigned char *  MathSansItalicChar(uint64_t c, unsigned char *buffer, NSUInteger bufferLen) {
  if ('A' <= c && c <= 'Z') {
    c += 0x1D608 - 'A';
  } else if ('a' <= c && c <= 'z') {
    c += 0x1D622 - 'a';
  }
  return CharToUTF8(c, buffer, bufferLen);
}

static const unsigned char *  MathSansBoldItalicChar(uint64_t c, unsigned char *buffer, NSUInteger bufferLen) {
  if ('A' <= c && c <= 'Z') {
    c += 0x1D63C - 'A';
  } else if ('a' <= c && c <= 'z') {
    c += 0x1D656 - 'a';
  }
  return CharToUTF8(c, buffer, bufferLen);
}

static const unsigned char * MathMonoChar(uint64_t c, unsigned char *buffer, NSUInteger bufferLen) {
  if ('A' <= c && c <= 'Z') {
    c += 0x1D670 - 'A';
  } else if ('a' <= c && c <= 'z') {
    c += 0x1D68A - 'a';
  }
  return CharToUTF8(c, buffer, bufferLen);
}

static const unsigned char * BoxCapsChar(uint64_t c, unsigned char *buffer, NSUInteger bufferLen) {
  if ('A' <= c && c <= 'Z') {
    c += 0x1F130 - 'A';
  } else if ('a' <= c && c <= 'z') {
    c += 0x1F130 - 'a';
  }
  return CharToUTF8(c, buffer, bufferLen);
}

static const unsigned char * BlackBoxCapsChar(uint64_t c, unsigned char *buffer, NSUInteger bufferLen) {
  if ('A' <= c && c <= 'Z') {
    c += 0x1F170 - 'A';
  } else if ('a' <= c && c <= 'z') {
    c += 0x1F170 - 'a';
  }
  return CharToUTF8(c, buffer, bufferLen);
}

static const unsigned char * BlackRingedCapsChar(uint64_t c, unsigned char *buffer, NSUInteger bufferLen) {
  if ('1' <= c && c <= '9') {
    c += 0x278A - '1';
  } else if ('A' <= c && c <= 'Z') {
    c += 0x1F150 - 'A';
  } else if ('a' <= c && c <= 'z') {
    c += 0x1F150 - 'a';
  }
  return CharToUTF8(c, buffer, bufferLen);
}

static const unsigned char * DottedBoxCapsChar(uint64_t c, unsigned char *buffer, NSUInteger bufferLen) {
  if ('A' <= c && c <= 'Z') {
    c += 0x1F1E6 - 'A';
  } else if ('a' <= c && c <= 'z') {
    c += 0x1F1E6 - 'a';
  }
  return CharToUTF8(c, buffer, bufferLen);
}

static unichar BackwardsChar(unichar c) {
  static NSString *upper = nil;
  if (nil == upper) {
    upper = NSLocalizedString(@"backwardsUpperCase", @"");
  }
  int index;
  if ('A' <= c && c <= 'Z') {
    return [upper characterAtIndex:c - 'A'];
  } else if(-1 != (index = [upper indexOfCharacter:c])){
    return 'A' + index;
  }
  return c;
}


static unichar InvertUnichar(unichar c) {
  static NSString *lower = nil;
  static NSString *upper = nil;
  static NSString *punctSource = nil;
  static NSString *punctDest = nil;
  int index;
  if (nil == lower) {
    lower = NSLocalizedString(@"lowerCase", @"");
    upper = NSLocalizedString(@"upperCase", @"");
    punctSource = NSLocalizedString(@"punctSource", @"");
    punctDest = NSLocalizedString(@"punctDest", @"");
  }
  if ('a' <= c && c <= 'z') {
    return [lower characterAtIndex: 'z' - c];
  } else if ('A' <= c && c <= 'Z') {
    return [upper characterAtIndex: 'Z' - c];
  } else if(-1 != (index = [lower indexOfCharacter:c])){
    return 'z' - index;
  } else if(-1 != (index = [upper indexOfCharacter:c])){
    return 'Z' - index;
  } else if(-1 != (index = [punctSource indexOfCharacter:c])){
    return [punctDest characterAtIndex: index];
  } else if(-1 != (index = [punctDest indexOfCharacter:c])){
    return [punctSource characterAtIndex: index];
  }
  return c;
}

static unichar RingedChar(unichar c) {
  static unichar RingedA = 0x24B6;
  static unichar Ringeda = 0x24D0;
  static unichar Ringed1 = 0x2460;
  static unichar Ringed0 = 0x29BE;
  if ('1' <= c && c <= '9') {
    return 0x2460 + c - '1';
  } else if ('0' == c) {
    return 0x24EA;
  } else if ('a' <= c && c <= 'z') {
    return Ringeda + c - 'a';
  } else if ('A' <= c && c <= 'Z') {
    return RingedA + c - 'A';
  } else if ('1' <= c && c <= '9') {
    return Ringed1 + c - '1';
  } else if ('0' == c) {
    return Ringed0;
  } else if (RingedA <= c && c < RingedA+26) {
    return 'A' + c - RingedA;
  } else if (Ringeda <= c && c < Ringeda+26) {
    return 'a' + c - Ringeda;
  } else if (Ringed1 <= c && c < Ringeda+9) {
    return '1' + c - Ringed1;
  } else if (Ringed0 == c) {
    return '0';
  }
  return c;
}

static unichar BrailleChar(unichar c) {
  static unichar BrailleBlank = 0x2800;
  static unichar BrailleHigh = 0x283F;
  static NSString *brailleString = nil;
  if (nil == brailleString) {
    brailleString = NSLocalizedString(@"braille", @"");
  }
  if (' ' <= c && c <= '_') {
    return [brailleString characterAtIndex: (c - ' ')];
  }
  if ('a' <= c && c <= 'z') {
    return [brailleString characterAtIndex: (c - ' ' - 'a' + 'A')];
  }
  if (BrailleBlank <= c && c <= BrailleHigh) {
    int i = [brailleString indexOfCharacter:c];
    if (0 <= i) {
      return ' ' + i;
    }
  }
  return c;
}


typedef unichar (*UnicharFunc)(unichar);

@implementation NSString(UpsideDownAdditions)

- (NSString *)translateWithFunc:(UnicharFunc)func {
  NSUInteger i, length = [self length];
  unichar *s = (unichar*) malloc(length * sizeof(unichar));
  if(nil == s) {
    [[NSException exceptionWithName:NSMallocException  reason:kLowMem userInfo:nil] raise];
    return nil;
  }
  [self getCharacters:s];
  for(i = 0;i < length; ++i){
    s[i] = (*func)(s[i]);
  }
  NSString *val = [NSString stringWithCharacters:s length:length];
  free(s);
  return val;
}

typedef const unsigned char * (*StringFunc)(uint64_t, unsigned char *buffer, NSUInteger bufferLen);
- (NSString *)translateWithFunc32:(StringFunc)func {
  unsigned char *s = (unsigned char*) malloc([self length] * 6);
  unsigned char *p = (unsigned char *)[self UTF8String];
  unsigned char *dest = s;
  unsigned char buffer[6];
  while (*p) {
    const unsigned char *sPart = func(*p, buffer, sizeof buffer);
    strcat((char *)dest, (const char *)sPart);
    dest += strlen((char *)sPart);
    p++;
  }
  NSString *val = [NSString stringWithUTF8String:(char *)s];
  free(s);
  return val;
}


- (NSString *)braille {
  return [self translateWithFunc:BrailleChar];
}

- (NSString *)ringed {
  return [self translateWithFunc:RingedChar];
}

- (NSString *)backwards {
  return [[self reverse] translateWithFunc:BackwardsChar];
}

- (NSString *)yinglish {
  return ToYinglishS(self);
}

- (NSString *)mathSerifBold {
  return [self translateWithFunc32:MathSerifBoldChar];
}

- (NSString *)mathSerifItalic {
  return [self translateWithFunc32:MathSerifItalicChar];
}

- (NSString *)mathSerifBoldItalic {
  return [self translateWithFunc32:MathSerifBoldItalicChar];
}

- (NSString *)mathScriptItalic {
  return [self translateWithFunc32:MathScriptItalicChar];
}

- (NSString *)mathScriptBoldItalic {
  return [self translateWithFunc32:MathScriptBoldItalicChar];
}

- (NSString *)mathGermanic {
  return [self translateWithFunc32:MathGermanicChar];
}

- (NSString *)mathDouble {
  return [self translateWithFunc32:MathDoubleChar];
}

- (NSString *)mathGermanicBold {
  return [self translateWithFunc32:MathGermanicBoldChar];
}

- (NSString *)mathSans {
  return [self translateWithFunc32:MathSansChar];
}

- (NSString *)mathSansBold {
  return [self translateWithFunc32:MathSansBoldChar];
}

- (NSString *)mathSansItalic {
  return [self translateWithFunc32:MathSansItalicChar];
}

- (NSString *)mathSansBoldItalic {
  return [self translateWithFunc32:MathSansBoldItalicChar];
}

- (NSString *)mathMono {
  return [self translateWithFunc32:MathMonoChar];
}

- (NSString *)boxedCaps {
  return [self translateWithFunc32:BoxCapsChar];
}

- (NSString *)blackBoxedCaps {
  return [self translateWithFunc32:BlackBoxCapsChar];
}

- (NSString *)blackRingedCaps {
  return [self translateWithFunc32:BlackRingedCapsChar];
}

// Probably useless: shows as incomplete national flags on iOS 10.
- (NSString *)dottedBoxedCaps {
  return [self translateWithFunc32:DottedBoxCapsChar];
}


- (NSString *)lowerCaseReplacedByPattern:(NSString *)pattern {
  NSMutableString *result = [NSMutableString string];
  NSUInteger count = [self length];
  for (NSUInteger i = 0; i < count; ++i) {
    unichar c = [self characterAtIndex:i];
    if ('a' <= c && c <= 'z') {
      c = [pattern characterAtIndex:c - 'a'];
    }
    [result appendFormat:@"%C", c];
  }
  return result;
}

- (NSString *)smallCaps {
  return [self lowerCaseReplacedByPattern:NSLocalizedString(@"smallcaps", 0)];
}

- (NSString *)verySmallCaps {
  return [self lowerCaseReplacedByPattern:NSLocalizedString(@"verysmallcaps", 0)];
}


// keycaps \u20e3
// square \u20de
// diamond \u20df
// verticalBar \u20d2
// doubleverticalBar \u20e6

// triangle \u20e4

// smallcircle \u20d8
// circle \u20dd
// backslash \u20e5
// circledoubleslash \u20eb
// circlebackslash \u20e0 = works

// dash \u0336 
// slash \u0337 

- (NSString *)withCombining:(NSArray *)arrayOfCombiners {
  NSMutableString *result = [NSMutableString string];
  NSUInteger count = [self length];
  NSUInteger j = 0;
  NSUInteger arrayCount = [arrayOfCombiners count];
  for (NSUInteger i = 0; i < count; ++i) {
    unichar c = [self characterAtIndex:i];
    if (c == ' ') {
      [result appendFormat:@"%C", c];
    } else {
      unichar combining = [arrayOfCombiners[j] characterAtIndex:0];
      [result appendFormat:@"%C%C", c, combining];
      if (arrayCount <= ++j) {
        j = 0;
      }
    }
  }
  return result;
}

- (NSString *)reverse {
  NSUInteger length = [self length];
  unichar *s = (unichar*) malloc(length * sizeof(unichar));
  if(nil == s) {
    [[NSException exceptionWithName:NSMallocException  reason:kLowMem userInfo:nil] raise];
    return nil;
  }
  [self getCharacters:s];
  int i = 0;
  NSInteger j = ((NSInteger)length) - 1;
  while(i < j) {
    unichar c = s[i];
    s[i] = s[j];
    s[j] = c;
    i++;
    j--;
  }
  NSString *val = [NSString stringWithCharacters:s length:length];
  free(s);
  return val;
}

- (NSString *)invert {
  NSUInteger i, length = [self length];
  unichar *s = (unichar*) malloc(length * sizeof(unichar));
  if(nil == s) {
    [[NSException exceptionWithName:NSMallocException reason:kLowMem userInfo:nil] raise];
    return nil;
  }
  [self getCharacters:s];
  for(i = 0;i < length; ++i){
    s[i] = InvertUnichar(s[i]);
  }
  NSString *val = [NSString stringWithCharacters:s length:length];
  free(s);
  return val;
}

- (int)indexOfCharacter:(unichar)c {
  unichar buffer[1];
  buffer[0] = c;
  NSString *s = [NSString stringWithCharacters:buffer length:1];
  NSRange range = [self rangeOfString: s];
  if (NSNotFound == range.location) {
    return -1;
  }
  return (int)range.location;
}

@end

NS_ASSUME_NONNULL_END
