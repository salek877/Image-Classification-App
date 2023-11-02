import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(CoffeeLandClassifierApp());
}

class CoffeeLandClassifierApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _imageFile;
  String _predictionResult = '';

  Future<void> _selectImage() async {
    final pickedImage = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _imageFile = pickedImage;
        _predictionResult = '';
      });
    }
  }

  Future<void> _predictImage() async {
    if (_imageFile == null) return;

    final uri = Uri.parse('API endpoint'); //API endpoint

    final request = http.MultipartRequest('POST', uri);
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        _imageFile!.path,
      ),
    );

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final result = jsonDecode(responseBody);
        setState(() {
          _predictionResult = result['class'];
        });
      } else {
        setState(() {
          _predictionResult = 'Error';
        });
      }
    } catch (e) {
      setState(() {
        _predictionResult = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coffee Land Classifier'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (_imageFile != null)
              Image.file(
                File(_imageFile!.path),
                height: 200,
              )
            else
              Text('No image selected'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectImage,
              child: Text('Select Image'),
            ),
            ElevatedButton(
              onPressed: _predictImage,
              child: Text('Predict'),
            ),
            SizedBox(height: 20),
            Text('Prediction Result: $_predictionResult'),
          ],
        ),
      ),
    );
  }
}
