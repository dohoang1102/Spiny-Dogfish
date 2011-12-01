//
//  Created by lynx on 12/1/11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "Eng2RuPostProcessor.h"


@implementation Eng2RuPostProcessor
NSMutableString *word;
NSMutableString *dictionary;
NSMutableString *transcriptionURL;
NSMutableString *translation;

-(NSString *) getWord{
    return word;
}
-(NSString *) getDictionary{
    return dictionary;
}
-(NSString *) getTranscriptionUrl{
    return transcriptionURL;
}
-(NSString *) getTranslation {
    return translation;
}

-(void) process: (NSMutableString *) translationSrc {
    int endOfInput = translationSrc.length-1;
    
    //trim last six words
    int whitespaceCounter = 0;
    const int WHITESPACES_FOR_SIX_WORDS = 7;
    for (NSUInteger i = translationSrc.length-1; i >= 0; i--) {
        NSString *m = [translationSrc substringWithRange:NSMakeRange(i, 1)];
        if ([m isEqualToString:@" "]) {
            whitespaceCounter++;
        }
        if (whitespaceCounter == WHITESPACES_FOR_SIX_WORDS) {
            if (i > 0) {
                endOfInput = i;
            }
            break;
        }
    }

    word = [[NSMutableString alloc] initWithString:@""];
    dictionary = [[NSMutableString alloc] initWithString:@""];
    transcriptionURL = [[NSMutableString alloc] initWithString:@""];
    translation = [[NSMutableString alloc] initWithString:@""];
    whitespaceCounter = 0;
    bool transcriptionModeWriting = false;
    NSString * transcriptionModeTrigger = @"";
    int phase = 0;
    int phase3WordCount = 0;
    const int PHASE3_EXPECTED_WORD_COUNT = 2;
    NSString *phase3PrevChar = @"";
    bool phase4Writing = false;
    for (NSUInteger i = 0; i < endOfInput; i++) {
        NSString *m = [translationSrc substringWithRange:NSMakeRange(i, 1)];
        bool isWhitespace = [m isEqualToString:@" "];
        if (isWhitespace) {
            whitespaceCounter++;
        }
        if (phase == 0 && whitespaceCounter == 0) {
            [word appendString:m];
        }
        if (whitespaceCounter == 1 || whitespaceCounter == 2) {
            if (phase == 0){
                phase = 1;
                continue;
            }
            if (phase == 1) {
                [dictionary appendString:m];
            }
        }
        //phase 2 - transcription url
        if ([m isEqualToString:@"["]) {
            if (phase == 1) {
                phase = 2;
                continue;
            }
        }
        if ([m isEqualToString:@"]"]) {
            if (phase == 2) {
                phase = 3;
                continue;
            }
        }
        if (phase == 2) {
            if (!transcriptionModeWriting &&
                    ([m isEqualToString: @"'"] || [m isEqualToString: @"\""])) {
                transcriptionModeWriting = true;
                transcriptionModeTrigger = m;
                continue;
            }
            if (transcriptionModeWriting &&
                    [m isEqualToString: transcriptionModeTrigger]) {
                transcriptionModeWriting = false;
                continue;
            }
            if (transcriptionModeWriting)
            {
                [transcriptionURL appendString: m];
                continue;
            }
        }
        // skip 2 words in phase#3
        if (phase == 3) {
            if(isWhitespace &&
                    ![phase3PrevChar isEqualToString:@""] &&
                    ![phase3PrevChar isEqualToString: @" "]){
                phase3WordCount++;
            }
            if (phase3WordCount == PHASE3_EXPECTED_WORD_COUNT) {
                phase = 4;
            }
            phase3PrevChar = m;
        }
        // in phase#4 - all the rest except whitespaces
        if (phase == 4) {
            if (isWhitespace) {
                if (!phase4Writing) {
                    continue;
                }
            } else {
                if (!phase4Writing) {
                    phase4Writing = true;
                }
            }
            if (phase4Writing) {
                [translation appendString:m];
            }
        }
    }
}
@end