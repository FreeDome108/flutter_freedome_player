#include "include/flutter_freedome_player/flutter_freedome_player_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flutter_freedome_player_plugin.h"

void FlutterFreedomePlayerPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flutter_freedome_player::FlutterFreedomePlayerPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
