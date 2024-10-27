//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<flutter_mongodb_realm/FlutterMongoStitchPlugin.h>)
#import <flutter_mongodb_realm/FlutterMongoStitchPlugin.h>
#else
@import flutter_mongodb_realm;
#endif

#if __has_include(<path_provider_foundation/PathProviderPlugin.h>)
#import <path_provider_foundation/PathProviderPlugin.h>
#else
@import path_provider_foundation;
#endif

#if __has_include(<realm/RealmPlugin.h>)
#import <realm/RealmPlugin.h>
#else
@import realm;
#endif

#if __has_include(<shared_preferences_foundation/SharedPreferencesPlugin.h>)
#import <shared_preferences_foundation/SharedPreferencesPlugin.h>
#else
@import shared_preferences_foundation;
#endif

#if __has_include(<streams_channel3/StreamsChannelPlugin.h>)
#import <streams_channel3/StreamsChannelPlugin.h>
#else
@import streams_channel3;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [FlutterMongoStitchPlugin registerWithRegistrar:[registry registrarForPlugin:@"FlutterMongoStitchPlugin"]];
  [PathProviderPlugin registerWithRegistrar:[registry registrarForPlugin:@"PathProviderPlugin"]];
  [RealmPlugin registerWithRegistrar:[registry registrarForPlugin:@"RealmPlugin"]];
  [SharedPreferencesPlugin registerWithRegistrar:[registry registrarForPlugin:@"SharedPreferencesPlugin"]];
  [StreamsChannelPlugin registerWithRegistrar:[registry registrarForPlugin:@"StreamsChannelPlugin"]];
}

@end
