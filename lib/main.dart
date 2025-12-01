import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img_lib;

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Ошибка инициализации камеры: $e');
  }

  runApp(const CameraApp());
}

class CameraApp extends StatelessWidget {
  const CameraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera Demo',
      theme: ThemeData(useMaterial3: true),
      home: cameras.isEmpty
          ? const CameraErrorPage()
          : const CameraPage(),
    );
  }
}

class CameraErrorPage extends StatelessWidget {
  const CameraErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ошибка')),
      body: const Center(
        child: Text('Камеры не найдены или недоступны'),
      ),
    );
  }
}

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  File? _capturedImage;
  File? _capturedVideo;
  bool _isCameraReady = false;
  bool _isCapturing = false;
  bool _isRecording = false;
  bool _isFlashOn = false;
  CameraMode _currentMode = CameraMode.photo;
  FilterType _currentFilter = FilterType.none;
  VideoPlayerController? _videoController;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    if (cameras.isEmpty) return;

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: true,
    );

    _controller!.initialize().then((_) {
      if (!mounted) return;
      setState(() => _isCameraReady = true);
    }).catchError((e) {
      print('Ошибка инициализации камеры: $e');
    });
  }

  Future<void> _takePicture() async {
    if (!_isCameraReady || _controller == null || !_controller!.value.isInitialized) {
      return;
    }

    if (_isCapturing) return;

    setState(() => _isCapturing = true);

    try {
      final XFile picture = await _controller!.takePicture();
      File originalImage = File(picture.path);

      if (_currentFilter != FilterType.none) {
        final processedImage = await _applyFilter(originalImage, _currentFilter);
        setState(() => _capturedImage = processedImage);
      } else {
        setState(() => _capturedImage = originalImage);
      }
    } on CameraException catch (e) {
      print('Ошибка при съемке: $e');
      _showSnackBar('Ошибка при съемке: ${e.description}');
    } finally {
      setState(() => _isCapturing = false);
    }
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File originalImage = File(image.path);

      if (_currentFilter != FilterType.none) {
        final processedImage = await _applyFilter(originalImage, _currentFilter);
        setState(() => _capturedImage = processedImage);
      } else {
        setState(() => _capturedImage = originalImage);
      }
    }
  }

  Future<void> _startRecording() async {
    if (!_isCameraReady || _controller == null || !_controller!.value.isInitialized) {
      return;
    }

    if (_isRecording) return;

    try {
      await _controller!.startVideoRecording();
      setState(() => _isRecording = true);

      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _recordingDuration += const Duration(seconds: 1);
          });
        }
      });
    } on CameraException catch (e) {
      print('Ошибка при начале записи: $e');
      _showSnackBar('Ошибка при записи: ${e.description}');
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording || _controller == null) return;

    try {
      final XFile videoFile = await _controller!.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _capturedVideo = File(videoFile.path);
        _recordingDuration = Duration.zero;
      });

      _recordingTimer?.cancel();
      _recordingTimer = null;

      _videoController = VideoPlayerController.file(_capturedVideo!);
      await _videoController!.initialize();
      setState(() {});

    } on CameraException catch (e) {
      print('Ошибка при остановке записи: $e');
      _showSnackBar('Ошибка при остановке записи: ${e.description}');
    }
  }

  Future<File> _applyFilter(File originalImage, FilterType filter) async {
    try {
      final bytes = await originalImage.readAsBytes();
      img_lib.Image image = img_lib.decodeImage(bytes)!;
      switch (filter) {
        case FilterType.grayscale:
          image = img_lib.grayscale(image);
          break;
        case FilterType.sepia:
          image = img_lib.sepia(image);
          break;
        case FilterType.blur:
          image = img_lib.gaussianBlur(image, 5); // Радиус размытия
          break;
        case FilterType.invert:
          image = img_lib.invert(image);
          break;
        case FilterType.brightness:
          image = img_lib.adjustColor(image, brightness: 50);
          break;
        case FilterType.contrast:
          image = img_lib.adjustColor(image, contrast: 50);
          break;
        case FilterType.none:
          return originalImage;
      }
      //Кодируем обработанное изображение в JPEG
      final filteredBytes = img_lib.encodeJpg(image);

      //Сохраняем во временный файл
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filteredPath = '${tempDir.path}/filtered_${filter.name}_$timestamp.jpg';

      return File(filteredPath)..writeAsBytesSync(filteredBytes);
    } catch (e) {
      print('Ошибка при применении фильтра: $e');
      return originalImage;
    }
  }

  Future<void> _saveImage() async {
    if (_capturedImage == null) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filterName = _currentFilter != FilterType.none ? _currentFilter.name : 'original';
      final newPath = '${directory.path}/photo_${filterName}_$timestamp.jpg';
      final savedFile = await _capturedImage!.copy(newPath);

      _showSnackBar('Фото сохранено: ${savedFile.path}');
    } catch (e) {
      print('Ошибка сохранения: $e');
      _showSnackBar('Ошибка сохранения фото');
    }
  }

  Future<void> _saveVideo() async {
    if (_capturedVideo == null) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newPath = '${directory.path}/video_$timestamp.mp4';
      final savedFile = await _capturedVideo!.copy(newPath);

      _showSnackBar('Видео сохранено: ${savedFile.path}');
    } catch (e) {
      print('Ошибка сохранения: $e');
      _showSnackBar('Ошибка сохранения видео');
    }
  }

  void _toggleFlash() {
    if (_controller == null || !_isCameraReady) return;

    setState(() {
      _isFlashOn = !_isFlashOn;
      _controller!.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
    });
  }

  void _switchCamera() {
    if (!_isCameraReady || _controller == null) return;

    final lensDirection = _controller!.description.lensDirection;
    CameraDescription newCamera;

    if (lensDirection == CameraLensDirection.back) {
      newCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
    } else {
      newCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
    }

    if (newCamera == _controller!.description) return;

    _controller!.dispose();
    setState(() => _isCameraReady = false);

    _controller = CameraController(newCamera, ResolutionPreset.medium, enableAudio: true);
    _controller!.initialize().then((_) {
      if (!mounted) return;
      setState(() => _isCameraReady = true);
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _retakeMedia() {
    setState(() {
      _capturedImage = null;
      _capturedVideo = null;
      _videoController?.dispose();
      _videoController = null;
    });
  }

  void _toggleVideoPlayback() {
    if (_videoController != null) {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
      setState(() {});
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    _controller?.dispose();
    _videoController?.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Камера'),
        actions: _buildAppBarActions(),
      ),
      body: _buildBody(),
      floatingActionButton: _buildCameraControls(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  List<Widget> _buildAppBarActions() {
    if (_capturedImage != null || _capturedVideo != null) return [];

    return [
      if (_isCameraReady && cameras.length > 1)
        IconButton(
          icon: const Icon(Icons.cameraswitch),
          onPressed: _switchCamera,
        ),
      if (_isCameraReady)
        IconButton(
          icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
          onPressed: _toggleFlash,
        ),
      IconButton(
        icon: const Icon(Icons.photo_library),
        onPressed: _pickImageFromGallery,
      ),
    ];
  }

  Widget _buildBody() {
    if (_capturedImage != null) {
      return _buildMediaPreview();
    }

    if (_capturedVideo != null) {
      return _buildVideoPreview();
    }

    return _buildCameraPreview();
  }

  Widget _buildCameraPreview() {
    if (!_isCameraReady || _controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        CameraPreview(_controller!),
        if (_isRecording)
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.red.withOpacity(0.7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDuration(_recordingDuration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (_isCapturing)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
        //фильтры только в режиме фото
        if (_currentMode == CameraMode.photo && !_isRecording)
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: _buildFilterSelector(),
          ),
      ],
    );
  }

  Widget _buildFilterSelector() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: FilterType.values.map((filter) {
          return GestureDetector(
            onTap: () => setState(() => _currentFilter = filter),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _currentFilter == filter ? Colors.blue : Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_getFilterIcon(filter), color: Colors.white),
                  Text(
                    _getFilterName(filter),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMediaPreview() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: const Text(
            'Предпросмотр фото',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(color: Colors.black),
            child: _capturedImage != null
                ? Image.file(_capturedImage!, fit: BoxFit.contain)
                : const Center(child: Text('Ошибка загрузки')),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          child: Text(
            'Применён фильтр: ${_getFilterName(_currentFilter)}',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
        const Expanded(flex: 1, child: SizedBox()),
      ],
    );
  }

  Widget _buildVideoPreview() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: const Text(
            'Предпросмотр видео',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 3,
          child: _videoController != null && _videoController!.value.isInitialized
              ? Stack(
            children: [
              AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
              Positioned.fill(
                child: IconButton(
                  icon: Icon(
                    _videoController!.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                    size: 50,
                  ),
                  onPressed: _toggleVideoPlayback,
                ),
              ),
            ],
          )
              : const Center(child: CircularProgressIndicator()),
        ),
        const Expanded(flex: 1, child: SizedBox()),
      ],
    );
  }

  Widget _buildCameraControls() {
    if (_capturedImage != null || _capturedVideo != null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton(
              heroTag: 'retake',
              onPressed: _retakeMedia,
              child: const Icon(Icons.camera_alt),
            ),
            FloatingActionButton(
              heroTag: 'save',
              onPressed: _capturedImage != null ? _saveImage : _saveVideo,
              child: const Icon(Icons.save),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Переключение режима фото/видео
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildModeButton('Фото', CameraMode.photo, Icons.photo_camera),
                _buildModeButton('Видео', CameraMode.video, Icons.videocam),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Основная кнопка съемки/записи
          _isRecording
              ? FloatingActionButton(
            heroTag: 'stop',
            onPressed: _stopRecording,
            backgroundColor: Colors.red,
            child: const Icon(Icons.stop),
          )
              : FloatingActionButton(
            heroTag: 'capture',
            onPressed: _currentMode == CameraMode.photo
                ? (_isCameraReady && !_isCapturing ? _takePicture : null)
                : (_isCameraReady ? _startRecording : null),
            child: _isCapturing
                ? const CircularProgressIndicator(color: Colors.white)
                : Icon(_currentMode == CameraMode.photo ? Icons.camera : Icons.videocam),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(String text, CameraMode mode, IconData icon) {
    final isSelected = _currentMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentMode = mode;
          // Сбрасываем фильтр при видео
          if (mode == CameraMode.video) {
            _currentFilter = FilterType.none;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(text, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  IconData _getFilterIcon(FilterType filter) {
    switch (filter) {
      case FilterType.grayscale:
        return Icons.filter_b_and_w;
      case FilterType.sepia:
        return Icons.filter;
      case FilterType.blur:
        return Icons.blur_on;
      case FilterType.invert:
        return Icons.invert_colors;
      case FilterType.brightness:
        return Icons.brightness_6;
      case FilterType.contrast:
        return Icons.contrast;
      case FilterType.none:
        return Icons.filter_none;
    }
  }

  String _getFilterName(FilterType filter) {
    switch (filter) {
      case FilterType.grayscale:
        return 'Черно-белый';
      case FilterType.sepia:
        return 'Сепия';
      case FilterType.blur:
        return 'Размытие';
      case FilterType.invert:
        return 'Инвертировать';
      case FilterType.brightness:
        return 'Яркость';
      case FilterType.contrast:
        return 'Контраст';
      case FilterType.none:
        return 'Без фильтра';
    }
  }
}

enum CameraMode { photo, video }

enum FilterType { none, grayscale, sepia, blur, invert, brightness, contrast }