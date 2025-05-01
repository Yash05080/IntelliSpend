import 'dart:convert';
import 'dart:io';
import 'package:finance_manager_app/pages/add%20expense/batch_result.dart';
import 'package:finance_manager_app/pages/add%20expense/veiws/mlconnect.dart';
import 'package:finance_manager_app/services/transaction_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRCapturePage extends StatefulWidget {
  @override
  _OCRCapturePageState createState() => _OCRCapturePageState();
}

class _OCRCapturePageState extends State<OCRCapturePage> {
  File? _capturedImage;
  bool _isProcessing = false;

  String _status = '';
  final ImagePicker _picker = ImagePicker();
  final _gemini = GeminiService();
  final _txService = TransactionService();

  Future<void> _captureAndSaveAll() async {
    if (_isProcessing) return; // ⇐ guard
    setState(() => _isProcessing = true);

    try {
      setState(() => _status = 'Taking photo...');
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);

      if (image == null) {
        // User cancelled camera
        return;
      }

      setState(() => _status = 'Extracting text...');
      final input = InputImage.fromFilePath(image.path);
      final recognized =
          await TextRecognizer(script: TextRecognitionScript.latin)
              .processImage(input);
      final rawText = recognized.text;

      setState(() => _status = 'Parsing transactions...');
      final jsonString = await _gemini.extractAllTransactionsJson(rawText);

      setState(() => _status = 'Saving transactions...');
      final batch = await _txService.saveAllFromGemini(jsonString);

      if (batch.isNotEmpty) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BatchResultPage(newTransactions: batch),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No transactions found.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
        _status = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan & Save'),
      backgroundColor: Theme.of(context).colorScheme.background,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: _isProcessing ? null : _captureAndSaveAll,
              child: Text(_isProcessing ? 'Processing...' : 'Scan & Save'),
            ),
            if (_status.isNotEmpty) ...[
              SizedBox(height: 16),
              Text(_status),
            ],
          ],
        ),
      ),
    );
  }
}
