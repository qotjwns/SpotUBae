// lib/screens/photo_diary_screen.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/photo_service.dart';
import '../models/photo.dart';
import 'full_screen_photo_gallery.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class PhotoDiaryScreen extends StatefulWidget {
  const PhotoDiaryScreen({super.key});

  @override
  PhotoDiaryScreenState createState() => PhotoDiaryScreenState();
}

class PhotoDiaryScreenState extends State<PhotoDiaryScreen> {
  final ImagePicker _picker = ImagePicker();
  late PhotoService _photoService;
  final List<Photo> _photos = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }


  Future<void> _savePhoto(String path) async {
    final newPhoto = Photo(
      path: path,
      date: DateTime.now(),
    );
    await _photoService.addPhoto(newPhoto);
    setState(() {
      _photos.insert(0, newPhoto);
    });
  }

  Future<void> _deletePhoto(int index) async {
    await _photoService.deletePhoto(index);
    setState(() {
      _photos.removeAt(index);
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80, // 이미지 품질 조정 (옵션)
    );
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
        title: const Text('Save Photo'),
        content: const Text('Would you like to save this photo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
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
        title: const Text('Photo Diary'),
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: GestureDetector(
              onTap: _pickImage,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: 350,
                  height: 50,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, color: Colors.black, size: 25),
                        Text("Add a Photo!")
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                        title: const Text('Delete Photo'),
                        content: const Text('Are you sure you want to delete this photo?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('No'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Yes'),
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
                          File(photo.path),
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          DateFormat('yyyy-MM-dd').format(photo.date),
                          style: const TextStyle(fontSize: 12),
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