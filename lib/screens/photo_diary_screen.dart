import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PhotoDiaryScreen extends StatefulWidget {
  @override
  _PhotoDiaryScreenState createState() => _PhotoDiaryScreenState();
}

class _PhotoDiaryScreenState extends State<PhotoDiaryScreen> {
  final List<Map<String, dynamic>> _photos = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPhotos = prefs.getStringList('photos') ?? [];
    setState(() {
      // JSON 문자열을 Map으로 변환하여 리스트에 추가
      _photos.addAll(savedPhotos.map((photo) => jsonDecode(photo) as Map<String, dynamic>));
      // 최신 날짜 순으로 정렬 (가장 최근 사진이 가장 앞에 오도록)
      _photos.sort((a, b) => b['date'].compareTo(a['date']));
    });
  }

  Future<void> _savePhoto(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final newPhoto = {
      'path': path,
      'date': DateTime.now().toIso8601String(),
    };
    // 새로운 사진을 리스트의 시작 부분에 추가
    _photos.insert(0, newPhoto);

    // SharedPreferences에 저장하기 위해 JSON 문자열로 변환
    final photosJson = _photos.map((photo) => jsonEncode(photo)).toList();
    await prefs.setStringList('photos', photosJson);
    setState(() {});
  }

  Future<void> _deletePhoto(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _photos.removeAt(index);
    });
    final photosJson = _photos.map((photo) => jsonEncode(photo)).toList();
    await prefs.setStringList('photos', photosJson);
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final shouldSave = await _showSaveDialog();
      if (shouldSave) {
        await _savePhoto(pickedFile.path);
      }
    }
  }

  Future<bool> _showSaveDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Save Photo'),
        content: Text('Would you like to save this photo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes'),
          ),
        ],
      ),
    ) ??
        false;
  }

  void _showFullScreenImage(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenPhotoGallery(
          photos: _photos,
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Diary'),
        leading: BackButton(),
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: GestureDetector(
              onTap: _pickImage,
              child: Center(
                child:
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: 350,
                  height:50,
                  child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined,color:Colors.black,size: 25,),
                          Text("Add a Photo!")
                        ],
                      )
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                childAspectRatio: 0.75, // 날짜를 표시할 공간을 위해 비율 조정
              ),
              itemCount: _photos.length,
              itemBuilder: (context, index) {
                final photo = _photos[index];
                return GestureDetector(
                  onTap: () => _showFullScreenImage(index),
                  onLongPress: () async {
                    final shouldDelete = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Delete Photo'),
                        content: Text('Are you sure you want to delete this photo?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text('No'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text('Yes'),
                          ),
                        ],
                      ),
                    );
                    if (shouldDelete == true) {
                      await _deletePhoto(index);
                    }
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.file(
                          File(photo['path']),
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          DateFormat('yyyy-MM-dd').format(DateTime.parse(photo['date'])),
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
class FullScreenPhotoGallery extends StatefulWidget {
  final List<Map<String, dynamic>> photos;
  final int initialIndex;

  FullScreenPhotoGallery({required this.photos, required this.initialIndex});

  @override
  _FullScreenPhotoGalleryState createState() => _FullScreenPhotoGalleryState();
}

class _FullScreenPhotoGalleryState extends State<FullScreenPhotoGallery> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: FileImage(File(widget.photos[index]['path'])),
                initialScale: PhotoViewComputedScale.contained,
                heroAttributes: PhotoViewHeroAttributes(tag: widget.photos[index]['path']),
              );
            },
            itemCount: widget.photos.length,
            loadingBuilder: (context, event) => Center(
              child: CircularProgressIndicator(),
            ),
            pageController: _pageController,
            onPageChanged: (index) {
              // 여기에 페이지 변경 시 수행할 작업을 추가할 수 있습니다.
            },
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
