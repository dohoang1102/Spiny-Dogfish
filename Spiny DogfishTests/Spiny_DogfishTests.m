//
//  Spiny_DogfishTests.m
//  Spiny DogfishTests
//
//  Created by Max Korenkov on 11/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Spiny_DogfishTests.h"
#import "Eng2RuHTMLParser.h"
#import "Eng2RuNotFoundException.h"

@implementation Spiny_DogfishTests
- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)test_translate_enru_random
{
    NSString* path = [[NSBundle mainBundle] pathForResource:@"word-random"
                                                     ofType:@"txt"];
    NSError *error;
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:&error];

    Eng2RuHTMLParser *parser = [[Eng2RuHTMLParser alloc] init];
    @try {
        NSMutableString *result = [parser parseHTMLString:content];
        NSString *expected = @"random LingvoUniversal (En-Ru) [";
        STAssertTrue( [result isEqualToString: expected], @"Not expected result: %@", result);
    } @catch (Eng2RuNotFoundException *e) {
        STFail(@"Parsing this word should not give errors.");
    }
}

- (void)test_translate_enru_test
{
    NSString* path = [[NSBundle mainBundle] pathForResource:@"word-test"
                                                     ofType:@"txt"];
    NSError *error;
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:&error];

    Eng2RuHTMLParser *parser = [[Eng2RuHTMLParser alloc] init];
    @try {
        NSMutableString *result = [parser parseHTMLString:content];
        NSString *expected = @"test LingvoUniversal (En-Ru) [ ] брит.                      амер.                      1. сущ. 1) проверка , испытание ; тест 2) а) проверочная , контрольная работа ; тест б) психол.  тест 3) мерило ; критерий 4) мед. ; хим.  исследование , анализ ; проверка 5) хим.  реактив 6) пробирная чашка для определения пробы  ( драгоценного металла ) 2. гл. 1) а) подвергать испытанию , проверке б) подвергаться испытанию , проходить тест в) амер.  показать в результате испытания , дать результат ; обнаруживать определённые свойства в результате испытаний 2) а) = test out тестировать ; проверять с помощью тестов б) экзаменовать 3) проверять , убеждаться 4) а) хим.  подвергать действию реактива ; брать пробу б) производить опыты в) определять пробу  ( драгоценного металла ) 3. прил. испытательный , пробный , контрольный , проверочный Розгорнути статтю &#187; &#171; Згорнути статтю ";
        STAssertTrue( [result isEqualToString: expected], @"Not expected result: %@", result);
    } @catch (Eng2RuNotFoundException *e) {
        STFail(@"Parsing this word should not give errors.");
    }
}

@end
