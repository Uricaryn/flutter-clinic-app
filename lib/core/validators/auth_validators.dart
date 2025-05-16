import 'package:flutter/material.dart';

class AuthValidators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-posta adresi boş olamaz';
    }

    // E-posta formatı kontrolü
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Geçerli bir e-posta adresi giriniz';
    }

    // Türkçe karakter kontrolü
    if (value.contains(RegExp(r'[ğüşıöçĞÜŞİÖÇ]'))) {
      return 'E-posta adresi Türkçe karakter içeremez';
    }

    // Boşluk kontrolü
    if (value.contains(' ')) {
      return 'E-posta adresi boşluk içeremez';
    }

    // Uzunluk kontrolü
    if (value.length > 100) {
      return 'E-posta adresi çok uzun';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre boş olamaz';
    }

    // Minimum uzunluk kontrolü
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalıdır';
    }

    // Maksimum uzunluk kontrolü
    if (value.length > 50) {
      return 'Şifre çok uzun';
    }

    // Büyük harf kontrolü
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Şifre en az bir büyük harf içermelidir';
    }

    // Küçük harf kontrolü
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Şifre en az bir küçük harf içermelidir';
    }

    // Rakam kontrolü
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Şifre en az bir rakam içermelidir';
    }

    // Özel karakter kontrolü
    if (!value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
      return 'Şifre en az bir özel karakter içermelidir';
    }

    // Boşluk kontrolü
    if (value.contains(' ')) {
      return 'Şifre boşluk içeremez';
    }

    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ad Soyad boş olamaz';
    }

    // Minimum uzunluk kontrolü
    if (value.length < 2) {
      return 'Ad Soyad en az 2 karakter olmalıdır';
    }

    // Maksimum uzunluk kontrolü
    if (value.length > 50) {
      return 'Ad Soyad çok uzun';
    }

    // Sadece harf ve boşluk kontrolü
    if (!RegExp(r'^[a-zA-ZğüşıöçĞÜŞİÖÇ\s]+$').hasMatch(value)) {
      return 'Ad Soyad sadece harf ve boşluk içerebilir';
    }

    // Ardışık boşluk kontrolü
    if (value.contains('  ')) {
      return 'Ad Soyad ardışık boşluk içeremez';
    }

    // Başta ve sonda boşluk kontrolü
    if (value.startsWith(' ') || value.endsWith(' ')) {
      return 'Ad Soyad başında veya sonunda boşluk olamaz';
    }

    return null;
  }

  static String? validatePasswordConfirmation(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Şifre tekrarı boş olamaz';
    }

    if (value != password) {
      return 'Şifreler eşleşmiyor';
    }

    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefon numarası boş olamaz';
    }

    // Sadece rakam ve + kontrolü
    if (!RegExp(r'^\+?[0-9]+$').hasMatch(value)) {
      return 'Geçerli bir telefon numarası giriniz';
    }

    // Minimum uzunluk kontrolü (ülke kodu + numara)
    if (value.length < 10) {
      return 'Telefon numarası çok kısa';
    }

    // Maksimum uzunluk kontrolü
    if (value.length > 15) {
      return 'Telefon numarası çok uzun';
    }

    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Adres boş olamaz';
    }

    // Minimum uzunluk kontrolü
    if (value.length < 10) {
      return 'Adres çok kısa';
    }

    // Maksimum uzunluk kontrolü
    if (value.length > 200) {
      return 'Adres çok uzun';
    }

    return null;
  }
}
