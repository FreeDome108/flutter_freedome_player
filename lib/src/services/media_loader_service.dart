import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';
import 'package:path/path.dart' as path;
import 'package:archive/archive.dart';

import '../models/media_content.dart';
import 'format_detector_service.dart';

/// Сервис для загрузки различных типов медиа контента
class MediaLoaderService {
  static final MediaLoaderService _instance = MediaLoaderService._internal();
  factory MediaLoaderService() => _instance;
  MediaLoaderService._internal();

  final FormatDetectorService _formatDetector = FormatDetectorService();

  /// Загрузить медиа контент из файла
  Future<MediaContent?> loadMediaContent(String filePath) async {
    try {
      debugPrint('🔵 [MEDIA_LOADER] Starting media load: $filePath');
      final startTime = DateTime.now();

      // Определяем формат файла
      final format = _formatDetector.detectFormat(filePath);
      if (format == MediaFormat.unknown) {
        debugPrint('🔴 [MEDIA_LOADER] Unknown format for file: $filePath');
        return null;
      }

      // Создаем базовый MediaContent
      final mediaContent = MediaContent(
        id: _generateId(),
        name: path.basenameWithoutExtension(filePath),
        filePath: filePath,
        format: format,
        createdAt: DateTime.now(),
      );

      // Загружаем метаданные в зависимости от формата
      MediaContent? enrichedContent;
      switch (format) {
        case MediaFormat.comics:
          enrichedContent = await _loadComicsMetadata(mediaContent);
          break;
        case MediaFormat.boranko:
          enrichedContent = await _loadBorankoMetadata(mediaContent);
          break;
        case MediaFormat.collada:
          enrichedContent = await _loadColladaMetadata(mediaContent);
          break;
        case MediaFormat.obj:
          enrichedContent = await _loadObjMetadata(mediaContent);
          break;
        case MediaFormat.gltf:
        case MediaFormat.glb:
          enrichedContent = await _loadGltfMetadata(mediaContent);
          break;
        case MediaFormat.unknown:
          enrichedContent = mediaContent;
          break;
      }

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime).inMilliseconds;

      if (enrichedContent != null) {
        debugPrint(
            '🟢 [MEDIA_LOADER] Media loaded successfully in ${duration}ms');
        debugPrint('  - Name: ${enrichedContent.name}');
        debugPrint('  - Format: ${enrichedContent.format}');
        debugPrint('  - Metadata: ${enrichedContent.metadata?.keys}');
      } else {
        debugPrint('🔴 [MEDIA_LOADER] Failed to load media in ${duration}ms');
      }

      return enrichedContent;
    } catch (e) {
      debugPrint('🔴 [MEDIA_LOADER] Error loading media: $e');
      debugPrint('🔴 [MEDIA_LOADER] Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  /// Загрузить метаданные комикса
  Future<MediaContent?> _loadComicsMetadata(MediaContent content) async {
    try {
      debugPrint(
          '🔵 [MEDIA_LOADER] Loading comics metadata: ${content.filePath}');

      Map<String, dynamic>? metadata;
      List<String> pages = [];

      // Читаем файл как байты из assets
      if (content.filePath.startsWith('assets/')) {
        final ByteData data = await rootBundle.load(content.filePath);
        final Uint8List bytes = data.buffer.asUint8List();

        // Распаковываем ZIP архив
        final Archive archive = ZipDecoder().decodeBytes(bytes);

        // Ищем файл metadata.json или info.json
        ArchiveFile? metadataFile;
        for (final file in archive) {
          if (file.name == 'metadata.json' || file.name == 'info.json') {
            metadataFile = file;
            break;
          }
        }

        if (metadataFile != null) {
          final String jsonContent = String.fromCharCodes(metadataFile.content);
          metadata = json.decode(jsonContent);
        }

        // Получаем список страниц
        for (final file in archive) {
          if (file.isFile && _isImageFile(file.name)) {
            pages.add(file.name);
          }
        }
        pages.sort();
      }

      // Создаем метаданные по умолчанию если не найдены
      metadata ??= _createDefaultComicsMetadata(content.name);
      metadata['pages'] = pages;
      metadata['totalPages'] = pages.length;

      return content.copyWith(
        metadata: metadata,
        description: metadata['description'],
        author: metadata['author'],
        duration: metadata['duration'] != null
            ? Duration(seconds: metadata['duration'])
            : null,
      );
    } catch (e) {
      debugPrint('🔴 [MEDIA_LOADER] Error loading comics metadata: $e');
      return content;
    }
  }

  /// Загрузить метаданные Boranko файла
  Future<MediaContent?> _loadBorankoMetadata(MediaContent content) async {
    try {
      debugPrint(
          '🔵 [MEDIA_LOADER] Loading boranko metadata: ${content.filePath}');

      String jsonContent;
      if (content.filePath.startsWith('assets/')) {
        jsonContent = await rootBundle.loadString(content.filePath);
      } else {
        final file = File(content.filePath);
        if (!await file.exists()) return content;
        jsonContent = await file.readAsString();
      }

      final Map<String, dynamic> borankoData = json.decode(jsonContent);

      return content.copyWith(
        metadata: borankoData,
        description: borankoData['metadata']?['description'],
        author: borankoData['metadata']?['author'],
        duration: borankoData['metadata']?['duration'] != null
            ? Duration(seconds: borankoData['metadata']['duration'])
            : null,
        playbackMode: PlaybackMode.dome,
      );
    } catch (e) {
      debugPrint('🔴 [MEDIA_LOADER] Error loading boranko metadata: $e');
      return content;
    }
  }

  /// Загрузить метаданные COLLADA файла
  Future<MediaContent?> _loadColladaMetadata(MediaContent content) async {
    try {
      debugPrint(
          '🔵 [MEDIA_LOADER] Loading COLLADA metadata: ${content.filePath}');

      String xmlContent;
      if (content.filePath.startsWith('assets/')) {
        xmlContent = await rootBundle.loadString(content.filePath);
      } else {
        final file = File(content.filePath);
        if (!await file.exists()) return content;
        xmlContent = await file.readAsString();
      }

      final document = XmlDocument.parse(xmlContent);
      final metadata = _extractColladaMetadata(document);

      return content.copyWith(
        metadata: metadata,
        description: metadata['description'],
        author: metadata['authoring_tool'],
      );
    } catch (e) {
      debugPrint('🔴 [MEDIA_LOADER] Error loading COLLADA metadata: $e');
      return content;
    }
  }

  /// Загрузить метаданные OBJ файла
  Future<MediaContent?> _loadObjMetadata(MediaContent content) async {
    try {
      debugPrint('🔵 [MEDIA_LOADER] Loading OBJ metadata: ${content.filePath}');

      String objContent;
      if (content.filePath.startsWith('assets/')) {
        objContent = await rootBundle.loadString(content.filePath);
      } else {
        final file = File(content.filePath);
        if (!await file.exists()) return content;
        objContent = await file.readAsString();
      }

      final metadata = _extractObjMetadata(objContent);

      return content.copyWith(
        metadata: metadata,
      );
    } catch (e) {
      debugPrint('🔴 [MEDIA_LOADER] Error loading OBJ metadata: $e');
      return content;
    }
  }

  /// Загрузить метаданные glTF файла
  Future<MediaContent?> _loadGltfMetadata(MediaContent content) async {
    try {
      debugPrint(
          '🔵 [MEDIA_LOADER] Loading glTF metadata: ${content.filePath}');

      String jsonContent;
      if (content.filePath.startsWith('assets/')) {
        jsonContent = await rootBundle.loadString(content.filePath);
      } else {
        final file = File(content.filePath);
        if (!await file.exists()) return content;
        jsonContent = await file.readAsString();
      }

      final Map<String, dynamic> gltfData = json.decode(jsonContent);
      final metadata = _extractGltfMetadata(gltfData);

      return content.copyWith(
        metadata: metadata,
        description: gltfData['asset']?['copyright'],
        author: gltfData['asset']?['generator'],
      );
    } catch (e) {
      debugPrint('🔴 [MEDIA_LOADER] Error loading glTF metadata: $e');
      return content;
    }
  }

  /// Извлечь метаданные из COLLADA
  Map<String, dynamic> _extractColladaMetadata(XmlDocument document) {
    final metadata = <String, dynamic>{};

    try {
      final asset = document.findAllElements('asset').firstOrNull;
      if (asset != null) {
        final created = asset.findElements('created').firstOrNull;
        final modified = asset.findElements('modified').firstOrNull;
        final authoringTool = asset.findElements('authoring_tool').firstOrNull;

        if (created != null) metadata['created'] = created.innerText;
        if (modified != null) metadata['modified'] = modified.innerText;
        if (authoringTool != null)
          metadata['authoring_tool'] = authoringTool.innerText;
      }

      // Подсчитываем геометрию
      final geometries =
          document.findAllElements('library_geometries').firstOrNull;
      if (geometries != null) {
        int vertices = 0;
        int triangles = 0;

        final positions = geometries.findAllElements('float_array');
        for (final pos in positions) {
          final count = int.tryParse(pos.getAttribute('count') ?? '0') ?? 0;
          vertices += count ~/ 3;
        }

        final trianglesElements = geometries.findAllElements('triangles');
        for (final tri in trianglesElements) {
          final count = int.tryParse(tri.getAttribute('count') ?? '0') ?? 0;
          triangles += count;
        }

        metadata['vertices'] = vertices;
        metadata['triangles'] = triangles;
      }

      // Подсчитываем материалы
      final materials = document.findAllElements('library_materials');
      metadata['materials_count'] = materials.length;

      // Подсчитываем текстуры
      final images = document.findAllElements('library_images');
      metadata['textures_count'] = images.length;

      // Проверяем наличие анимаций
      final animations = document.findAllElements('library_animations');
      metadata['has_animations'] = animations.isNotEmpty;
    } catch (e) {
      debugPrint('Error extracting COLLADA metadata: $e');
    }

    return metadata;
  }

  /// Извлечь метаданные из OBJ
  Map<String, dynamic> _extractObjMetadata(String content) {
    final lines = content.split('\n');
    int vertices = 0;
    int normals = 0;
    int textures = 0;
    int faces = 0;

    for (final line in lines) {
      if (line.startsWith('v ')) {
        vertices++;
      } else if (line.startsWith('vn ')) {
        normals++;
      } else if (line.startsWith('vt ')) {
        textures++;
      } else if (line.startsWith('f ')) {
        faces++;
      }
    }

    return {
      'vertices': vertices,
      'normals': normals,
      'textures': textures,
      'faces': faces,
      'format': 'obj',
    };
  }

  /// Извлечь метаданные из glTF
  Map<String, dynamic> _extractGltfMetadata(Map<String, dynamic> gltfData) {
    final metadata = <String, dynamic>{};

    // Основная информация
    final asset = gltfData['asset'];
    if (asset != null) {
      metadata['version'] = asset['version'];
      metadata['generator'] = asset['generator'];
      metadata['copyright'] = asset['copyright'];
    }

    // Подсчитываем геометрию
    final meshes = gltfData['meshes'] as List<dynamic>? ?? [];
    int totalVertices = 0;
    int totalTriangles = 0;

    for (final mesh in meshes) {
      final primitives = mesh['primitives'] as List<dynamic>? ?? [];
      for (final primitive in primitives) {
        final indices = primitive['indices'] as int?;
        final positions = primitive['attributes']?['POSITION'] as int?;

        if (positions != null) {
          final accessors = gltfData['accessors'] as List<dynamic>? ?? [];
          if (positions < accessors.length) {
            final accessor = accessors[positions];
            totalVertices += accessor['count'] as int? ?? 0;
          }
        }

        if (indices != null) {
          final accessors = gltfData['accessors'] as List<dynamic>? ?? [];
          if (indices < accessors.length) {
            final accessor = accessors[indices];
            totalTriangles += (accessor['count'] as int? ?? 0) ~/ 3;
          }
        }
      }
    }

    metadata['vertices'] = totalVertices;
    metadata['triangles'] = totalTriangles;
    metadata['meshes_count'] = meshes.length;
    metadata['has_animations'] =
        (gltfData['animations'] as List?)?.isNotEmpty ?? false;

    return metadata;
  }

  /// Создать метаданные комикса по умолчанию
  Map<String, dynamic> _createDefaultComicsMetadata(String name) {
    return {
      'title': name,
      'author': 'Unknown Author',
      'description': 'Comics file',
      'duration': 300,
      'audioFile': null,
      'pages': [],
      'metadata': {
        'version': 1,
        'created': DateTime.now().toIso8601String(),
        'language': 'en',
        'format': 'comics'
      }
    };
  }

  /// Проверить, является ли файл изображением
  bool _isImageFile(String fileName) {
    final String extension = fileName.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }

  /// Сгенерировать уникальный ID
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
