import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:finance_manager_app/pages/add%20expense/veiws/mlconnect.dart';
import 'package:finance_manager_app/services/transaction_service.dart';
import 'package:flutter/material.dart';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'batch_result.dart';

import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class DocumentPickerPage extends StatefulWidget {
  @override
  _DocumentPickerPageState createState() => _DocumentPickerPageState();
}

class _DocumentPickerPageState extends State<DocumentPickerPage> {
  File? _file;
  PDFDocument? _pdfDoc;
  String _status = '';
  bool _isProcessing = false;

  final _gemini = GeminiService();
  final _txService = TransactionService();

  Future<void> _pickFile() async {
    // Define allowed types with both extensions and UTIs
    final groups = <XTypeGroup>[
      XTypeGroup(
        label: 'PDF',
        extensions: ['pdf'],
        // UTI for PDF documents
        uniformTypeIdentifiers: ['com.adobe.pdf'],
      ),
      XTypeGroup(
        label: 'Images',
        extensions: ['jpg', 'jpeg', 'png'],
        // UTI for common image types
        uniformTypeIdentifiers: ['public.jpeg', 'public.png', 'public.image'],
      ),
    ];

    final XFile? picked = await openFile(acceptedTypeGroups: groups);
    if (picked == null) return; // user canceled

    final file = File(picked.path);
    setState(() {
      _file = file;
      _pdfDoc = null;
    });

    if (picked.path.toLowerCase().endsWith('.pdf')) {
      setState(() => _status = 'Loading PDF preview…');
      _pdfDoc = await PDFDocument.fromFile(file);
      setState(() => _status = '');
    }
  }

  /// 2️⃣ Extract text (OCR for image, or text-extract for PDF)
  Future<String> _extractText() async {
    if (_file == null) return '';

    final path = _file!.path.toLowerCase();
    if (path.endsWith('.pdf')) {
      // LOAD PDF bytes
      final bytes = await _file!.readAsBytes();
      // OPEN with Syncfusion PDF
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      StringBuffer fullText = StringBuffer();

      // EXTRACT text from each page
      for (int i = 0; i < document.pages.count; i++) {
        final page = document.pages[i];
        final extractor = PdfTextExtractor(document);
        final pageText =
            extractor.extractText(startPageIndex: i, endPageIndex: i);
        fullText.writeln(pageText);
      }
      document.dispose();
      return fullText.toString();
    } else {
      // IMAGE OCR
      final input = InputImage.fromFile(_file!);
      final rec = TextRecognizer(script: TextRecognitionScript.latin);
      final result = await rec.processImage(input);
      return result.text;
    }
  }

  /// 3️⃣ Process & Save
  Future<void> _processDocument() async {
    if (_isProcessing || _file == null) return;
    setState(() {
      _isProcessing = true;
      _status = 'Extracting text…';
    });

    try {
      final text = await _extractText();

      setState(() {
        _status = 'Parsing transactions…';
      });
      final jsonString = await _gemini.extractAllTransactionsJson(text);

      setState(() {
        _status = 'Saving transactions…';
      });
      final batch = await _txService.saveAllFromGemini(jsonString);

      if (batch.isNotEmpty) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => BatchResultPage(newTransactions: batch),
        ));
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
    final fileName = _file?.path.split('/').last ?? 'No file selected';
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text('Select Document'),
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: Icon(Icons.attach_file),
              label: Text('Pick PDF / Image'),
            ),
            SizedBox(height: 12),
            Text(fileName, style: TextStyle(fontSize: 16)),
            SizedBox(height: 12),
            if (_pdfDoc != null) Expanded(child: PDFViewer(document: _pdfDoc!)),
            Spacer(),
            if (_status.isNotEmpty) ...[
              Text(_status),
              SizedBox(height: 8),
            ],
            ElevatedButton(
              onPressed:
                  (_file == null || _isProcessing) ? null : _processDocument,
              child: Text(_isProcessing ? 'Processing…' : 'Process Document'),
            ),
          ],
        ),
      ),
    );
  }
}
