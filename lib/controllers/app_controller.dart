import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import '../data/data_service.dart';
import '../models/report.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';

class AppController extends GetxController {
  final Rxn<User> currentUser = Rxn<User>();
  final reports = <Report>[].obs;
  final myReportsList = <Report>[].obs;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  final hasLoadedMyReports = false.obs;
  final selectedCity = 'Bogotá'.obs;
  final searchText = ''.obs;
  final selectedCategory = 'Vialidad'.obs;
  final selectedImagePath = RxnString();
  final selectedImageBytes = Rxn<Uint8List>();
  final profileImagePath = RxnString();
  final profileImageBytes = Rxn<Uint8List>();
  final currentPosition = Rxn<Position>();
  final isDarkMode = false.obs;

  List<String> get cities =>
      ['Bogotá', 'Medellín', 'Cali', 'Barranquilla', 'Cartagena'];
  List<String> get categories =>
      ['Vialidad', 'Seguridad', 'Alumbrado', 'Limpieza'];

  List<Report> get filteredReports {
    final lowerSearch = searchText.value.toLowerCase();
    return reports.where((report) {
      final matchesSearch = lowerSearch.isEmpty ||
          report.descripcion.toLowerCase().contains(lowerSearch) ||
          report.titulo.toLowerCase().contains(lowerSearch) ||
          report.direccion.toLowerCase().contains(lowerSearch) ||
          report.categoria.toLowerCase().contains(lowerSearch);
      return matchesSearch;
    }).toList();
  }

  List<Report> get myReports {
    if (hasLoadedMyReports.value) {
      return myReportsList;
    }
    return reports
        .where((report) => report.user == currentUser.value?.email)
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadAppState();
  }

  Future<void> loadAppState() async {
    isDarkMode.value = StorageService.getThemeMode();
    selectedCity.value = StorageService.getCity() ?? selectedCity.value;

    if (DataService.reports.isEmpty) {
      await DataService.loadData();
    }

    reports.assignAll(DataService.reports.map((json) => Report.fromJson(json)));

    final savedUserJson = StorageService.getCurrentUserData();
    if (savedUserJson != null) {
      try {
        final userMap = json.decode(savedUserJson);
        if (userMap is Map<String, dynamic>) {
          currentUser.value = User.fromJson(userMap);
        }
      } catch (_) {
        // Ignore invalid saved user data.
      }
    } else {
      final savedEmail = StorageService.getCurrentUserEmail();
      if (savedEmail != null) {
        final userMap = DataService.users.firstWhere(
          (user) => user['email'] == savedEmail,
          orElse: () => {},
        );
        if (userMap.isNotEmpty) {
          currentUser.value = User.fromJson(userMap);
        }
      }
    }

    // Fetch remote reports in background to avoid blocking UI startup.
    ApiService.fetchReports().then((fetchedReports) {
      if (fetchedReports.isNotEmpty) {
        reports.assignAll(fetchedReports);
      }
    }).catchError((_) {
      // Ignore fetch errors; local data remains available.
    });

    if (currentUser.value != null) {
      await refreshMyReports();
    }
  }

  Future<bool> login(String email, String password) async {
    final apiUser = await ApiService.login(email, password);
    if (apiUser != null) {
      currentUser.value = apiUser;
      await StorageService.setCurrentUserEmail(email);
      await _saveCurrentUserToStorage();
      await refreshMyReports();
      return true;
    }

    final userMap = DataService.users.firstWhere(
      (user) => user['email'] == email && user['password'] == password,
      orElse: () => {},
    );

    if (userMap.isEmpty) {
      return false;
    }

    currentUser.value = User.fromJson(userMap);
    await StorageService.setCurrentUserEmail(email);
    await _saveCurrentUserToStorage();
    return true;
  }

  Future<bool> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        return false;
      }

      final displayName = account.displayName ?? '';
      final nameParts = displayName.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final user = User(
        name: firstName.isNotEmpty ? firstName : account.email.split('@').first,
        lastname: lastName,
        email: account.email,
        password: '',
        profileImage: account.photoUrl,
      );

      currentUser.value = user;
      await StorageService.setCurrentUserEmail(user.email);
      await _saveCurrentUserToStorage();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> register(User user) async {
    final apiSuccess = await ApiService.register(user);
    if (apiSuccess) {
      currentUser.value = user;
      await StorageService.setCurrentUserEmail(user.email);
      await _saveCurrentUserToStorage();
      await refreshMyReports();
      return true;
    }

    final exists = DataService.users.any((item) => item['email'] == user.email);
    if (exists) {
      return false;
    }

    DataService.users.add(user.toJson());
    currentUser.value = user;
    await StorageService.setCurrentUserEmail(user.email);
    await _saveCurrentUserToStorage();
    return true;
  }

  Future<bool> updateCurrentUser(User user) async {
    currentUser.value = user;
    await StorageService.setCurrentUserEmail(user.email);
    await _saveCurrentUserToStorage();
    return true;
  }

  Future<void> _saveCurrentUserToStorage() async {
    if (currentUser.value != null) {
      await StorageService.setCurrentUserData(
          json.encode(currentUser.value!.toJson()));
    }
  }

  Future<void> refreshMyReports() async {
    if (currentUser.value == null) return;
    final fetchedReports = await ApiService.fetchMyReports();
    myReportsList.assignAll(fetchedReports);
    hasLoadedMyReports.value = true;
  }

  Future<void> refreshReports() async {
    final fetchedReports = await ApiService.fetchReports();
    if (fetchedReports.isNotEmpty) {
      reports.assignAll(fetchedReports);
    }
  }

  Future<void> refreshAllReports() async {
    await refreshReports();
    if (currentUser.value != null) {
      await refreshMyReports();
    }
  }

  Future<void> pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
    );

    if (pickedFile == null) return;

    if (kIsWeb) {
      final bytes = await pickedFile.readAsBytes();
      profileImageBytes.value = bytes;
      profileImagePath.value = null; // solo UI
    } else {
      profileImagePath.value = pickedFile.path;
    }
  }

  void logout() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Ignore Google sign-out failures.
    }
    currentUser.value = null;
    profileImagePath.value = null;
    profileImageBytes.value = null;
    myReportsList.clear();
    hasLoadedMyReports.value = false;
    await StorageService.clearUser();
  }

  void selectCity(String city) {
    selectedCity.value = city;
    StorageService.setCity(city);
  }

  Future<bool> loadCurrentLocation() async {
    final location = await LocationService.getCurrentPosition();
    if (location == null) {
      return false;
    }
    currentPosition.value = location;
    return true;
  }

  Future<void> pickImage([ImageSource source = ImageSource.gallery]) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1200,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        selectedImageBytes.value = bytes;
        selectedImagePath.value =
            'data:image/png;base64,${base64Encode(bytes)}';
      } else {
        selectedImagePath.value = pickedFile.path;
      }
    }
  }

  void changeTheme(bool darkMode) {
    isDarkMode.value = darkMode;
    StorageService.setThemeMode(darkMode);
    Get.changeThemeMode(darkMode ? ThemeMode.dark : ThemeMode.light);
  }

  Future<String?> addReport({
    required String titulo,
    required String descripcion,
    required String direccion,
  }) async {
    if (currentUser.value == null) return 'No autenticado';

    final report = Report(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: titulo,
      descripcion: descripcion,
      direccion: direccion,
      estado: 'Pendiente',
      fecha: DateTime.now(),
      user: currentUser.value!.email,
      userName: currentUser.value!.name,
      userLastname: currentUser.value!.lastname,
      ciudad: selectedCity.value,
      categoria: selectedCategory.value,
      imagePath: selectedImagePath.value,
      latitude: currentPosition.value?.latitude,
      longitude: currentPosition.value?.longitude,
    );

    // Ensure ApiService has latest token from storage (in case login used local fallback)
    await ApiService.init();
    final result = await ApiService.createReport(report);

    if (result == null || result['success'] != true) {
      // Propagate error message to UI when available
      final message = result != null && result['message'] != null
          ? result['message'].toString()
          : 'Error al enviar reporte';
      return message;
    }

    final remoteData = result['data'];
    final serverReport = remoteData is Map<String, dynamic>
        ? Report.fromJson({...report.toJson(), ...remoteData})
        : report;

    reports.insert(0, serverReport);
    myReportsList.insert(0, serverReport);
    hasLoadedMyReports.value = true;
    DataService.reports.add(serverReport.toJson());

    selectedImagePath.value = null;
    selectedImageBytes.value = null;

    return null;
  }

  Future<String?> deleteReport(String id) async {
    if (currentUser.value == null) {
      return 'No autenticado';
    }

    await ApiService.init();
    final result = await ApiService.deleteReport(id);
    if (result['success'] != true) {
      final message = result['message']?.toString() ??
          'No se pudo eliminar el reporte. Intenta de nuevo.';
      return message;
    }

    reports.removeWhere((report) => report.id == id);
    myReportsList.removeWhere((report) => report.id == id);
    return null;
  }
}
