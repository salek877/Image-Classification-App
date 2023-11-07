import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const CoffeeLandClassifierApp());
}

class CoffeeLandClassifierApp extends StatelessWidget {
  const CoffeeLandClassifierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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

  final uri = Uri.parse('https://salek877-fastapi-for-classifier.hf.space/predict/'); //API endpoint
  final request = http.MultipartRequest('POST', uri);

  request.files.add(
    await http.MultipartFile.fromPath(
      'upload_file',
      _imageFile!.path,
    ),
  );

  try {
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final result = jsonDecode(responseBody);
      print('res ${result}');
      final predictionResult = '${result}'; 
      setState(() {
        _predictionResult = predictionResult;
      });
    } else {
      print('Server responded with status code: ${response.statusCode}');
      print('Response body: $responseBody');
      setState(() {
        _predictionResult = 'Error: Server responded with status code: ${response.statusCode}';
      });
    }
  } catch (e) {
    print('Error: $e');
    setState(() {
      _predictionResult = 'Error: $e';
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coffee Land Classifier'),
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
              const Text('No image selected'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectImage,
              child: const Text('Select Image'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _predictImage,
              child: const Text('Predict'),
            ),
            const SizedBox(height: 20),
            Text('Prediction Result: $_predictionResult'),
          ],
        ),
      ),
    );
  }
}
