import 'dart:io';

abstract class KycRepository {
  Future<Map<String, dynamic>?> submitKyc({
    required Map<String, dynamic> data,
    File? idFront,
    File? idBack,
    File? selfie,
    File? profileImage,
  });
}
