import 'package:get/get.dart';
import 'package:young_care/app/common/controller/user_controller.dart';
import 'package:young_care/app/data/models/pedometer_result.dart';
import 'package:young_care/app/data/models/resource.dart';
import 'package:young_care/app/data/models/daily_step_entry.dart';
import 'package:young_care/app/data/repositories/daily_steps_repository.dart';
import 'package:young_care/app/data/repositories/pedometer_repository.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class HomeController extends GetxController {
  HomeController({
    PedometerRepository? pedometerRepository,
    DailyStepsRepository? dailyStepsRepository,
  })  : _pedometerRepository =
            pedometerRepository ?? Get.find<PedometerRepository>(),
        _dailyStepsRepository =
            dailyStepsRepository ?? DailyStepsRepository();

  final UserController userController = Get.find<UserController>();
  final PedometerRepository _pedometerRepository;
  final DailyStepsRepository _dailyStepsRepository;

  final Rx<Resource<PedometerResult>> todayPedometer =
      const Resource<PedometerResult>.initial().obs;
  final Rx<Resource<int>> todaySteps =
      const Resource<int>.initial().obs;

@override
  void onInit() {
    super.onInit();
    ever(userController.user, (_) {
      fetchTodayPedometer();
      fetchTodaySteps();
      fetchArticles(); // Panggil fetchArticles di sini
    });
  }

  @override
  void onReady() {
    super.onReady();
    fetchTodayPedometer();
    fetchTodaySteps();
    fetchArticles(); // Panggil fetchArticles di sini
  }

  Future<void> refreshAll() async {
    await Future.wait<void>([
      fetchTodayPedometer(),
      fetchTodaySteps(),
      fetchArticles(), // Panggil fetchArticles saat refresh
    ]);
  }

// === Tambahan: API Artikel Kesehatan Islami ===
var articles = [].obs;
var isLoadingArticles = false.obs;

// Data dummy untuk fallback
  final List<Map<String, dynamic>> _dummyArticles = [
    {
      'title': 'Pentingnya Tidur Malam dalam Islam dan Kesehatan',
      'description': 'Tidur yang cukup adalah Sunnah dan esensial bagi pemulihan fisik dan mental. Pelajari waktu tidur yang dianjurkan.',
      'image_url': null, // Biarkan null untuk menguji placeholder di ArticleTile
    },
    {
      'title': 'Manfaat Wudhu untuk Kebersihan dan Kesehatan Kulit',
      'description': 'Wudhu tidak hanya membersihkan secara spiritual, tetapi juga menjaga kebersihan kulit wajah, tangan, dan kaki dari kuman sehari-hari.',
      'image_url': 'https://images.unsplash.com/photo-1627964132338-3482a20b925b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=150&q=80',
    },
    {
      'title': 'Gaya Hidup Sehat Ala Rasulullah: Makan dan Minum',
      'description': 'Petunjuk Rasulullah tentang porsi makan yang tidak berlebihan (sepertiga makanan, sepertiga air, sepertiga udara) adalah kunci kesehatan pencernaan.',
      'image_url': 'https://images.unsplash.com/photo-1634591410214-411a0e8d35f4?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=150&q=80',
    },
  ];

// Fungsi ambil artikel islami dari API publik yang baru
Future<void> fetchArticles() async {
  isLoadingArticles(true);
  
  // Ganti API Key dan URL dengan NewsAPI.org (Perlu ganti YOUR_NEWSAPI_KEY)
  // Perhatian: Ganti 'YOUR_NEWSAPI_KEY' dengan kunci API NewsAPI.org Anda yang valid
  const String apiKey = 'YOUR_NEWSAPI_KEY'; 
  
  // Menggunakan API NewsAPI.org: mencari berita tentang 'kesehatan' dalam bahasa Indonesia
  final url = Uri.parse(
    'https://newsapi.org/v2/everything?q=kesehatan%20dan%20islam&language=id&sortBy=publishedAt&apiKey=$apiKey'
  );

  try {
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final fetchedArticles = data['articles'] ?? [];
      
      // Mengubah format NewsAPI.org agar sesuai dengan ArticleTile yang sudah dibuat
      final formattedArticles = fetchedArticles.map((item) {
        return {
          'title': item['title'],
          'description': item['description'] ?? item['content'],
          'image_url': item['urlToImage'],
        };
      }).toList();
      
      // Jika API mengembalikan hasil (status OK), gunakan hasil API
      if (formattedArticles.isNotEmpty) {
        articles.value = formattedArticles;
      } else {
        // Jika API kosong, gunakan data dummy
        articles.value = _dummyArticles;
      }
    } else {
      print("Gagal mengambil artikel dari NewsAPI: ${res.statusCode}. Menggunakan data dummy.");
      articles.value = _dummyArticles; // Gunakan data dummy saat status code bukan 200
    }
  } catch (e) {
    print("Error saat fetch artikel dari NewsAPI: $e. Menggunakan data dummy.");
    articles.value = _dummyArticles; // Gunakan data dummy saat terjadi error
  } finally {
    isLoadingArticles(false);
  }
}



  Future<void> fetchTodayPedometer() async {
    final String? userId = userController.userId;
    if (userId == null) {
      todayPedometer.value = const Resource<PedometerResult>.empty();
      return;
    }

    todayPedometer.value =
        Resource<PedometerResult>.loading(todayPedometer.value.data);

    try {
      final result =
          await _pedometerRepository.fetchLatestToday(userId: userId);

      if (result == null) {
        todayPedometer.value = const Resource<PedometerResult>.empty();
      } else {
        final computed = _withComputedCalories(result);
        todayPedometer.value = Resource<PedometerResult>.success(computed);
      }
    } catch (error, stackTrace) {
      todayPedometer.value = Resource<PedometerResult>.error(
        'Failed to load pedometer data',
        todayPedometer.value.data,
      );
      Get.log('Failed to fetch pedometer data: $error', isError: true);
      Get.log(stackTrace.toString(), isError: true);
    }
  }

  Future<void> fetchTodaySteps() async {
    final String? userId = userController.userId;
    if (userId == null) {
      todaySteps.value = const Resource<int>.empty();
      return;
    }

    todaySteps.value = Resource<int>.loading(todaySteps.value.data);

    try {
      final DateTime now = DateTime.now();
      final DateTime startOfDay = DateTime(now.year, now.month, now.day);
      final DateTime endOfDay = startOfDay.add(const Duration(days: 1));

      final List<DailyStepEntry> entries =
          await _dailyStepsRepository.fetchEntries(
        userId: userId,
        start: startOfDay,
        end: endOfDay,
        ascending: true,
      );

      final int totalSteps =
          _dailyStepsRepository.calculateCumulativeSteps(entries);

      todaySteps.value = Resource<int>.success(totalSteps);
    } catch (error, stackTrace) {
      todaySteps.value = Resource<int>.error(
        'Failed to load steps',
        todaySteps.value.data,
      );
      Get.log('Failed to fetch daily steps: $error', isError: true);
      Get.log(stackTrace.toString(), isError: true);
    }
  }

  PedometerResult _withComputedCalories(PedometerResult result) {
    final user = userController.user.value;
    if (user == null) return result;
    final calculated = result.calculateBurnCalories(user);
    if (calculated == null) return result;
    return result.copyWith(burnCalories: calculated);
  }
}
