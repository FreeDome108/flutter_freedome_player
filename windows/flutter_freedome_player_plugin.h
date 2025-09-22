#ifndef FLUTTER_PLUGIN_FLUTTER_FREEDOME_PLAYER_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_FREEDOME_PLAYER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace flutter_freedome_player {

class FlutterFreedomePlayerPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FlutterFreedomePlayerPlugin();

  virtual ~FlutterFreedomePlayerPlugin();

  // Disallow copy and assign.
  FlutterFreedomePlayerPlugin(const FlutterFreedomePlayerPlugin&) = delete;
  FlutterFreedomePlayerPlugin& operator=(const FlutterFreedomePlayerPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace flutter_freedome_player

#endif  // FLUTTER_PLUGIN_FLUTTER_FREEDOME_PLAYER_PLUGIN_H_
