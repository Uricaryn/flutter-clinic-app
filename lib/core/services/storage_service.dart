import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload file and return download URL
  Future<String> uploadFile(File file, String folder) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';
      final ref = _storage.ref().child('$folder/$fileName');

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw 'Failed to upload file: $e';
    }
  }

  // Delete file by URL
  Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      throw 'Failed to delete file: $e';
    }
  }

  // Get file metadata
  Future<FullMetadata> getFileMetadata(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      return await ref.getMetadata();
    } catch (e) {
      throw 'Failed to get file metadata: $e';
    }
  }

  // List files in a folder
  Future<List<Reference>> listFiles(String folder) async {
    try {
      final ref = _storage.ref().child(folder);
      final result = await ref.listAll();
      return result.items;
    } catch (e) {
      throw 'Failed to list files: $e';
    }
  }
}
