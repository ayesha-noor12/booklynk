class Book {
  final String id;
  final String title;
  final String filePath;
  final String? coverPath;
  final int currentPage;
  final int totalPages;
  final DateTime lastOpened;
  final DateTime dateAdded;
  final int fileSize;

  Book({
    required this.id,
    required this.title,
    required this.filePath,
    this.coverPath,
    this.currentPage = 0,
    this.totalPages = 0,
    required this.lastOpened,
    required this.dateAdded,
    required this.fileSize,
  });

  Book copyWith({
    String? id,
    String? title,
    String? filePath,
    String? coverPath,
    int? currentPage,
    int? totalPages,
    DateTime? lastOpened,
    DateTime? dateAdded,
    int? fileSize,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      coverPath: coverPath ?? this.coverPath,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      lastOpened: lastOpened ?? this.lastOpened,
      dateAdded: dateAdded ?? this.dateAdded,
      fileSize: fileSize ?? this.fileSize,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'filePath': filePath,
      'coverPath': coverPath,
      'currentPage': currentPage,
      'totalPages': totalPages,
      'lastOpened': lastOpened.toIso8601String(),
      'dateAdded': dateAdded.toIso8601String(),
      'fileSize': fileSize,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as String,
      title: map['title'] as String,
      filePath: map['filePath'] as String,
      coverPath: map['coverPath'] as String?,
      currentPage: map['currentPage'] as int,
      totalPages: map['totalPages'] as int,
      lastOpened: DateTime.parse(map['lastOpened'] as String),
      dateAdded: DateTime.parse(map['dateAdded'] as String),
      fileSize: map['fileSize'] as int,
    );
  }

  String get formattedFileSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  int get readingProgress {
    if (totalPages == 0) return 0;
    return ((currentPage / totalPages) * 100).round();
  }
}