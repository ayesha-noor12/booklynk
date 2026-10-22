import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/book_model.dart';
import '../models/dictionary_models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('booklynk.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';

    // Books table
    await db.execute('''
      CREATE TABLE books (
        id $idType,
        title $textType,
        filePath $textType,
        coverPath TEXT,
        currentPage $intType,
        totalPages $intType,
        lastOpened $textType,
        dateAdded $textType,
        fileSize $intType
      )
    ''');

    // Dictionary cache table
    await db.execute('''
      CREATE TABLE dictionary_cache (
        word $idType,
        definition $textType,
        synonyms TEXT,
        phonetic TEXT,
        cachedAt $textType
      )
    ''');
  }

  // Books CRUD
  Future<int> insertBook(Book book) async {
    final db = await database;
    return await db.insert('books', book.toMap());
  }

  Future<List<Book>> getAllBooks() async {
    final db = await database;
    final result = await db.query(
      'books',
      orderBy: 'lastOpened DESC',
    );
    return result.map((json) => Book.fromMap(json)).toList();
  }

  Future<int> updateBook(Book book) async {
    final db = await database;
    return await db.update(
      'books',
      book.toMap(),
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  Future<int> deleteBook(String id) async {
    final db = await database;
    return await db.delete(
      'books',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Dictionary Cache CRUD
  Future<int> cacheDictionaryEntry(DictionaryCacheModel entry) async {
    final db = await database;
    return await db.insert(
      'dictionary_cache',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<DictionaryCacheModel?> getDictionaryEntry(String word) async {
    final db = await database;
    final result = await db.query(
      'dictionary_cache',
      where: 'word = ?',
      whereArgs: [word.toLowerCase()],
    );
    
    if (result.isNotEmpty) {
      return DictionaryCacheModel.fromMap(result.first);
    }
    return null;
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}