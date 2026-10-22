import 'package:flutter/material.dart';
import '../models/dictionary_models.dart';
import '../services/dictionary_service.dart';

class DictionaryBottomSheet extends StatefulWidget {
  final String word;
  final DictionaryService dictionaryService;

  const DictionaryBottomSheet({
    super.key,
    required this.word,
    required this.dictionaryService,
  });

  @override
  State<DictionaryBottomSheet> createState() => _DictionaryBottomSheetState();
}

class _DictionaryBottomSheetState extends State<DictionaryBottomSheet> {
  DictionaryResponse? _definition;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDefinition();
  }

  Future<void> _fetchDefinition() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await widget.dictionaryService.getDefinition(widget.word);
      if (mounted) {
        setState(() {
          _definition = result;
          _isLoading = false;
          if (result == null) {
            _error = 'No definition found for "${widget.word}"';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load definition';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildHeader(),
                  const SizedBox(height: 24),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator(color: Color(0xFF8B6F47)))
                  else if (_error != null)
                    _buildErrorState()
                  else if (_definition != null)
                    _buildContent(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.word.toLowerCase(),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF8B6F47)),
              ),
              if (_definition?.phonetic != null)
                Text(_definition!.phonetic!, style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
            ],
          ),
        ),
        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.search_off, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(_error!, textAlign: TextAlign.center),
          TextButton(onPressed: _fetchDefinition, child: const Text("Retry")),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Definition", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8B6F47))),
        const SizedBox(height: 8),
        Text(_definition!.definition),
        if (_definition!.synonyms.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text("Synonyms", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8B6F47))),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _definition!.synonyms.take(10).map((s) => Chip(
              label: Text(s, style: const TextStyle(fontSize: 12)),
              backgroundColor: const Color(0xFF8B6F47).withOpacity(0.1),
            )).toList(),
          ),
        ],
      ],
    );
  }
}