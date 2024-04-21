import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewPostActivity extends StatefulWidget {
  @override
  _NewPostActivityState createState() => _NewPostActivityState();
}

class _NewPostActivityState extends State<NewPostActivity> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  List<XFile>? _imageFiles = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  void _pickImages() async {
    final List<XFile>? selectedImages = await _picker.pickMultiImage();
    if (selectedImages != null && selectedImages.isNotEmpty) {
      setState(() {
        if (_imageFiles == null) {
          // If _imageFiles is null, initialize it with the selected images
          _imageFiles = selectedImages;
        } else {
          // If _imageFiles already contains images, append the selected images
          _imageFiles!.addAll(selectedImages);
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You can only add up to 4 images.')),
      );
    }
  }

  void _takePhoto() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        // Append the new photo to the existing list of selected images
        _imageFiles!.add(photo);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No photo captured.')),
      );
    }
  }

  Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];
    if (_imageFiles == null || _imageFiles!.isEmpty) {
      print("No images selected for upload.");
      return imageUrls;
    }
    for (var file in _imageFiles!) {
      File imageFile = File(file.path);
      String fileName = 'posts/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      FirebaseStorage storage = FirebaseStorage.instance;
      try {
        TaskSnapshot snapshot = await storage.ref(fileName).putFile(imageFile);
        String downloadUrl = await snapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
        print("Uploaded image URL: $downloadUrl");
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
    return imageUrls;
  }

  void _submitForm() async {
    List<String> imageUrls = [];
    if (!_formKey.currentState!.validate() || (_imageFiles != null && _imageFiles!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add some images and fill out all fields.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    imageUrls = await _uploadImages();

    if (imageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image upload failed, please try again.')),
      );
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('posts').add({
        'title': _titleController.text,
        'price': _priceController.text,
        'description': _descriptionController.text,
        'images': imageUrls,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('New post added successfully!')),
      );
      _titleController.clear();
      _priceController.clear();
      _descriptionController.clear();
      _imageFiles = [];
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add post: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  List<Widget> _buildImageWidgets() {
    List<Widget> widgets = [];

    if (_imageFiles != null) {
      for (int i = 0; i < _imageFiles!.length; i++) {
        widgets.add(Container(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Image.file(File(_imageFiles![i].path), width: 150, height: 150),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _imageFiles!.removeAt(i);
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(4),
                      color: Colors.red,
                      child: Icon(Icons.delete, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
      }
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("HyperGarageSale"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.photo_library),
            onPressed: _pickImages,
          ),
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: _takePhoto,
          ),
          IconButton(
            icon: Icon(Icons.post_add),
            onPressed: _isSubmitting ? null : _submitForm,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: <Widget>[
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
              validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
            ),
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) => value!.isEmpty ? 'Please enter a price' : null,
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 5,
              validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
            ),
            SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10.0,
              runSpacing: 10.0,
              children: _buildImageWidgets(),
            ),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitForm,
              child: Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}
