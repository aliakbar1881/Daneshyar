// lib/screens/pdf_viewer_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:research_assistant/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PdfViewerScreen extends ConsumerStatefulWidget {
  final String pdfUrl;
  final String paperTitle;
  final String paperAbstract;

  const PdfViewerScreen({
    Key? key,
    required this.pdfUrl,
    required this.paperTitle,
    required this.paperAbstract,
  }) : super(key: key);

  @override
  ConsumerState<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends ConsumerState<PdfViewerScreen> {
  late PdfViewerController _pdfController;
  bool _isLoading = true;
  String? _localPath;
  String? _lastSelectedText;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfViewerController();
    _downloadAndLoadPdf();
  }

  Future<void> _downloadAndLoadPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/temp_paper.pdf');
        await file.writeAsBytes(response.bodyBytes);
        setState(() {
          _localPath = file.path;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to download PDF');
      }
    } catch (e) {
      print('Error downloading PDF: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading PDF: $e')),
      );
    }
  }

  Future<void> _getAIComment(String text) async {
    if (text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No text to analyze')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(child: CircularProgressIndicator()),
    );

    try {
      final comment = await ref.read(apiServiceProvider).analyzeText(text);
      if (mounted) {
        Navigator.pop(context);
        _showCommentDialog(comment);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showCommentDialog(String comment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('AI Comment'),
        content: SingleChildScrollView(
          child: Text(comment, style: TextStyle(fontSize: 16)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.auto_awesome),
            onPressed: () {
              if (_lastSelectedText != null && _lastSelectedText!.isNotEmpty) {
                _getAIComment(_lastSelectedText!);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please select some text first')),
                );
              }
            },
            tooltip: 'AI Comment on selected text',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SfPdfViewer.file(
              File(_localPath!),
              controller: _pdfController,
              enableTextSelection: true,
              onTextSelectionChanged: (PdfTextSelectionChangedDetails? details) {
                if (details != null && details.selectedText != null && details.selectedText!.isNotEmpty) {
                  setState(() {
                    _lastSelectedText = details.selectedText;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Selected: ${details.selectedText}'),
                      action: SnackBarAction(
                        label: 'AI Comment',
                        onPressed: () => _getAIComment(details.selectedText!),
                      ),
                    ),
                  );
                }
              },
            ),
    );
  }
}