import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class SecureNote {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;

  SecureNote({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'tags': tags,
  };

  factory SecureNote.fromJson(Map<String, dynamic> json) => SecureNote(
    id: json['id'] as String,
    title: json['title'] as String,
    content: json['content'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
  );

  SecureNote copyWith({
    String? title,
    String? content,
    List<String>? tags,
  }) {
    return SecureNote(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      tags: tags ?? this.tags,
    );
  }
}

class SecureStorageService {
  final FlutterSecureStorage _storage;
  static const _keyPrefix = 'secure_note_';

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.unlocked_this_device,
              ),
            );

  Future<void> saveNote(SecureNote note) async {
    final key = '$_keyPrefix${note.id}';
    final value = jsonEncode(note.toJson());
    await _storage.write(key: key, value: value);
  }

  Future<SecureNote> createNote({
    required String title,
    required String content,
    List<String> tags = const [],
  }) async {
    final note = SecureNote(
      id: const Uuid().v4(),
      title: title,
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      tags: tags,
    );
    await saveNote(note);
    return note;
  }

  Future<List<SecureNote>> readAllNotes() async {
    final all = await _storage.readAll();
    final notes = <SecureNote>[];

    for (final entry in all.entries) {
      if (entry.key.startsWith(_keyPrefix)) {
        try {
          final json = jsonDecode(entry.value);
          notes.add(SecureNote.fromJson(json));
        } catch (e) {
          // Identify corrupted data or unrelated keys
          continue;
        }
      }
    }
    
    // Sort by updated descending
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  Future<void> deleteNote(String id) async {
    await _storage.delete(key: '$_keyPrefix$id');
  }

  Future<void> clearAllNotes() async {
     final all = await _storage.readAll();
     for (final key in all.keys) {
       if (key.startsWith(_keyPrefix)) {
         await _storage.delete(key: key);
       }
     }
  }
  
  // Wipe everything (Nuclear Option)
  Future<void> nuclearWipe() async {
    await _storage.deleteAll();
  }
}
