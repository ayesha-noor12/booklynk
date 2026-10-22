import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/book_model.dart';
import '../utils/database_helper.dart';

class BookProvider extends ChangeNotifier {
  List<Book> _books = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Book> get books => _books;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  BookProvider() {
    loadBooks();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Load all books from database
  Future<void> loadBooks() async {
    try {
      _setLoading(true);
      _books = await DatabaseHelper.instance.getAllBooks();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load books: $e');
      _setLoading(false);
    }
  }

  // Upload/Add a new PDF book with full file system access
  Future<bool> addBook() async {
    try {
      _setLoading(true);
      _setError(null);

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
        dialogTitle: 'Select PDF Book',
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;
        
        // Get app directory
        final appDir = await getApplicationDocumentsDirectory();
        final booksDir = Directory('${appDir.path}/books');
        
        if (!await booksDir.exists()) {
          await booksDir.create(recursive: true);
        }

        // Copy file to app directory
        final newPath = '${booksDir.path}/${const Uuid().v4()}.pdf';
        await file.copy(newPath);

        // Create book object
        final book = Book(
          id: const Uuid().v4(),
          title: fileName.replaceAll('.pdf', ''),
          filePath: newPath,
          lastOpened: DateTime.now(),
          dateAdded: DateTime.now(),
          fileSize: await file.length(),
        );

        // Save to database
        await DatabaseHelper.instance.insertBook(book);
        
        // Reload books
        await loadBooks();
        
        _setLoading(false);
        return true;
      }

      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to add book: $e');
      _setLoading(false);
      return false;
    }
  }

  // Update book progress
  Future<void> updateBookProgress(
    String bookId,
    int currentPage,
    int totalPages,
  ) async {
    try {
      final bookIndex = _books.indexWhere((b) => b.id == bookId);
      if (bookIndex != -1) {
        final updatedBook = _books[bookIndex].copyWith(
          currentPage: currentPage,
          totalPages: totalPages,
          lastOpened: DateTime.now(),
        );

        await DatabaseHelper.instance.updateBook(updatedBook);
        _books[bookIndex] = updatedBook;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update book progress: $e');
    }
  }

  // Delete a book
  Future<bool> deleteBook(String bookId) async {
    try {
      _setLoading(true);
      
      final book = _books.firstWhere((b) => b.id == bookId);
      
      // Delete file
      final file = File(book.filePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Delete from database
      await DatabaseHelper.instance.deleteBook(bookId);
      
      // Reload books
      await loadBooks();
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to delete book: $e');
      _setLoading(false);
      return false;
    }
  }

 Future<bool> renameBook(Book updatedBook) async {
  try {
    await DatabaseHelper.instance.updateBook(updatedBook);
    final index = _books.indexWhere((b) => b.id == updatedBook.id);
    if (index != -1) {
      _books[index] = updatedBook;
      notifyListeners();
    }
    return true;
  } catch (e) {
    _setError('Failed to rename book: $e');
    return false;
  }
}

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}