//
//  ModuleRoot.m
//  AwesomeProject
//
//  Created by Marimuthu on 15/03/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "ModuleRoot.h"
#import <AVFoundation/AVFoundation.h>
#import "AudioController.h"
//#import "SpeechRecognitionService.h"
//#import "google/cloud/speech/v1beta1/CloudSpeech.pbrpc.h"

#define SAMPLE_RATE 16000.0f

//typedef enum : NSInteger {
//  InitializationError = 5000,
//  RecorderRUnningError,
//
//
//} ModuleErroCode;


typedef enum {
  InitializationError = 10000,
  RecorderAlreadyRunningError,
  RecorderUnableToRecordError,
  RecorderAlreadyStoppedError,
  RecorderUnableToStopError,
}ModuleErroCode;


@interface ModuleRoot ()<AudioControllerDelegate>
@property (nonatomic, strong) NSMutableData *audioData;


@end

@implementation ModuleRoot

- (instancetype)init
{
  self = [super init];
  if (self) {
  }
  return self;
}

RCT_EXPORT_MODULE();

- (NSArray<NSString *> *)supportedEvents {
  return @[@"onTranslatedSpeechEvent",@"onTranslatedSpeechError",@"onTranslatedSpeechCompleted"];
}



RCT_REMAP_METHOD(initSpeechProcessor,
                 initSpeechProcessor_resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
  @try {

    // initialize audio recorder and also speech service
    // intialize data object to receive the recording data

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];

    _audioData = [[NSMutableData alloc] init];


    [AudioController sharedInstance].delegate = self;
    [[AudioController sharedInstance] prepareWithSampleRate:SAMPLE_RATE];
   // [[SpeechRecognitionService sharedInstance] setSampleRate:SAMPLE_RATE];

    NSLog(@"SAMPLING RATE: %f", SAMPLE_RATE);

    NSDictionary *response = [NSDictionary dictionaryWithObjectsAndKeys:@"RECORDER INITIALIZED",@"status", nil];
    resolve(response);

  } @catch (NSException *exception) {
    NSError *error = [NSError errorWithDomain:@"INIT FAILED"
                                         code:InitializationError
                                     userInfo:nil];
    reject(@"INIT FAILED",exception.reason, error);
  }
}


RCT_REMAP_METHOD(startRecording,
                 startRecording_resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {

  // check for existing recorder run

  if ([AudioController sharedInstance].isRecording ==  YES) {
    NSError *error = [NSError errorWithDomain:@"ERROR STARTING"
                                         code:RecorderAlreadyRunningError
                                     userInfo:nil];
    reject(@"ERROR STARTING",@"ALREADY RUNNING", error);
    return;
  }

  // start the recorder

  if ([[AudioController sharedInstance] start] == kAudioServicesNoError ) {

#pragma mark Todo Actual file path to be sent

    NSString *filePathString = @"Test String";
    NSDictionary *response = [NSDictionary dictionaryWithObjectsAndKeys:@"RECORDING STARTED",@"status",
                              filePathString,@"filePath",
                              nil];
    resolve(response);

  } else {
    NSError *error = [NSError errorWithDomain:@"ERROR_RECORDING"
                                         code:RecorderUnableToRecordError
                                     userInfo:nil];
    reject(@"ERROR_RECORDING",@"", error);

  }
}

RCT_REMAP_METHOD(stopRecording,
                 stopRecording_resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {

  // check for existing run
  if ([AudioController sharedInstance].isRecording ==  NO) {
    NSError *error = [NSError errorWithDomain:@"ERROR STOPPING"
                                         code:RecorderAlreadyStoppedError
                                     userInfo:nil];
    reject(@"ERROR STOPPING",@"RECORDER ALREADY STOPPED", error);
    return;
  }

  // stop the recorder and speech service
  if ([[AudioController sharedInstance] stop] == kAudioServicesNoError ) {
   // [[SpeechRecognitionService sharedInstance] stopStreaming];
    NSDictionary *response = [NSDictionary dictionaryWithObjectsAndKeys:@"RECORDING STOPPED",@"status", nil];
    //response.putString("filePath", fileName);
    resolve(response);
  } else {
    NSError *error = [NSError errorWithDomain:@"ERROR_STOPPING_RECORD"
                                         code:RecorderUnableToStopError
                                     userInfo:nil];
    reject(@"ERROR_STOPPING_RECORD",@"", error);
  }
}


#pragma mark Audio controller delegate

- (void) processSampleData:(NSData *)data {
}


@end
