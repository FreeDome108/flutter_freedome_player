library flutter_freedome_player;

// Core player functionality
export 'src/freedome_player.dart';
export 'src/freedome_player_controller.dart';

// Media format support
export 'src/formats/comics_player.dart';
export 'src/formats/boranko_player.dart';
export 'src/formats/model_3d_player.dart';
export 'src/formats/collada_player.dart';

// Services
export 'src/services/media_loader_service.dart';
export 'src/services/format_detector_service.dart';
export 'src/services/dome_projection_service.dart';

// Models and data structures
export 'src/models/media_content.dart';
export 'src/models/player_config.dart';
export 'src/models/dome_config.dart';

// Widgets
export 'src/widgets/freedome_player_widget.dart';
export 'src/widgets/media_controls.dart';

// Platform interface
export 'src/flutter_freedome_player_platform_interface.dart';
export 'src/flutter_freedome_player_method_channel.dart';
