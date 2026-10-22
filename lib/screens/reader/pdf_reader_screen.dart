import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/book_model.dart';
import '../../providers/book_provider.dart';

class PdfReaderScreen extends StatefulWidget {
  final Book book;

  const PdfReaderScreen({Key? key, required this.book}) : super(key: key);

  @override
  State<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen> {
  final PdfViewerController _pdfController = PdfViewerController();
  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController _pageController = TextEditingController();

  int _currentPage = 1;
  int _totalPages = 0;
  double _sliderValue = 1.0;
  bool _isReading = false;
  bool _showControls = true;
  String? _selectedText;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.book.currentPage > 0 ? widget.book.currentPage : 1;
    _sliderValue = _currentPage.toDouble();
    _initTts();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (widget.book.currentPage > 0 && mounted) {
        _pdfController.jumpToPage(widget.book.currentPage);
      }
    });
  }

  void _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isReading = false);
    });
  }

  int _getReadingPercentage() {
    if (_totalPages <= 0) return 0;
    return ((_currentPage / _totalPages) * 100).round();
  }

  // ---------------- READ PAGE ----------------
  Future<void> _readFullPage() async {
    setState(() => _isReading = true);
    try {
      final bytes = File(widget.book.filePath).readAsBytesSync();
      final PdfDocument pdfDoc = PdfDocument(inputBytes: bytes);
      final text = PdfTextExtractor(pdfDoc).extractText(
        startPageIndex: _currentPage - 1,
        endPageIndex: _currentPage - 1,
      );
      pdfDoc.dispose();

      await _flutterTts.speak(
        text.trim().isEmpty ? "This page is empty." : text,
      );
    } catch (_) {
      setState(() => _isReading = false);
    }
  }

  void _stopReading() async {
    await _flutterTts.stop();
    setState(() => _isReading = false);
  }

  // ---------------- GOOGLE SEARCH ----------------
  Future<void> _searchOnGoogle(String text) async {
    final word = text
        .trim()
        .split(RegExp(r'\s+'))
        .first
        .replaceAll(RegExp(r'[^a-zA-Z]'), '');

    if (word.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a word')),
      );
      return;
    }

    final url = Uri.parse("https://www.google.com/search?q=define+$word");
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  // ---------------- TEXT SELECTION ----------------
  void _handleSelectionChanged(PdfTextSelectionChangedDetails details) {
    if (details.selectedText == null || details.selectedText!.trim().isEmpty) {
      setState(() => _selectedText = null);
      return;
    }
    setState(() => _selectedText = details.selectedText!.trim());
  }

  // ---------------- GO TO PAGE ----------------
  void _showGoToPageDialog() {
    _pageController.clear();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Go to Page'),
        content: TextField(
          controller: _pageController,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(hintText: '1 - $_totalPages'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final page = int.tryParse(_pageController.text);
              if (page != null && page >= 1 && page <= _totalPages) {
                _pdfController.jumpToPage(page);
                setState(() {
                  _currentPage = page;
                  _sliderValue = page.toDouble();
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Go'),
          ),
        ],
      ),
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _showControls
          ? AppBar(
              backgroundColor: Colors.black,
              title: Text(
                widget.book.title,
                style: const TextStyle(fontSize: 15),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.filter_1),
                  onPressed: _showGoToPageDialog,
                ),
              ],
            )
          : null,
      body: Stack(
        children: [
          SfPdfViewer.file(
            File(widget.book.filePath),
            controller: _pdfController,
            enableTextSelection: true,
            onTextSelectionChanged: _handleSelectionChanged,
            onPageChanged: (details) {
              setState(() {
                _currentPage = details.newPageNumber;
                _sliderValue = _currentPage.toDouble();
              });
              Provider.of<BookProvider>(context, listen: false)
                  .updateBookProgress(
                      widget.book.id, _currentPage, _totalPages);
            },
            onDocumentLoaded: (details) {
              setState(() {
                _totalPages = details.document.pages.count;
                _sliderValue = _currentPage.toDouble();
              });
              if (_currentPage > 1) {
                Future.delayed(const Duration(milliseconds: 300), () {
                  _pdfController.jumpToPage(_currentPage);
                });
              }
            },
          ),

          // 🔊 TTS
          Positioned(
            bottom: 110,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: const Color(0xFF8B6F47),
              heroTag: 'tts',
              child: Icon(_isReading ? Icons.stop : Icons.record_voice_over),
              onPressed: _isReading ? _stopReading : _readFullPage,
            ),
          ),

          // 📖 DICTIONARY → GOOGLE
          Positioned(
            bottom: 110,
            right: 90,
            child: FloatingActionButton(
              backgroundColor: Colors.blue,
              heroTag: 'dictionary',
              child: const Icon(Icons.book),
              onPressed: () {
                if (_selectedText != null) {
                  _searchOnGoogle(_selectedText!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Select a word first')),
                  );
                }
              },
            ),
          ),

          // 📄 PAGE SLIDER
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _totalPages > 0
                        ? "Page $_currentPage / $_totalPages (${_getReadingPercentage()}%)"
                        : "Loading...",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  if (_totalPages > 0)
                    Slider(
                      value: _sliderValue.clamp(1.0, _totalPages.toDouble()),
                      min: 1,
                      max: _totalPages.toDouble(),
                      onChanged: (v) {
                        setState(() => _sliderValue = v);
                        _pdfController.jumpToPage(v.toInt());
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _pageController.dispose();
    super.dispose();
  }
}




