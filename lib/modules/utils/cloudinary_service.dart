import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'cloudinary_config.dart';

class CloudinaryService {
  static final cloudinary = Cloudinary.full(
    apiKey: CloudinaryConfig.apiKey,
    apiSecret: CloudinaryConfig.apiSecret,
    cloudName: CloudinaryConfig.cloudName,
  );

  static Future<void> uploadImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma imagem selecionada')),
      );
      return;
    }

    final imageFile = File(pickedFile.path);

    try {
      final response = await cloudinary.uploadResource(
        CloudinaryUploadResource(
          filePath: imageFile.path,
          resourceType: CloudinaryResourceType.image,
        ),
      );

      if (response.isSuccessful) {
        final imageUrl = response.secureUrl;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Imagem enviada com sucesso!')),
        );
        debugPrint('URL da imagem: $imageUrl');
      } else {
        final error = response.error ?? 'Erro desconhecido';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar a imagem: $error')),
        );
        debugPrint('Erro Cloudinary: $error');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erro ao enviar a imagem')));
      debugPrint('Exceção ao enviar a imagem: $e');
    }
  }
}
