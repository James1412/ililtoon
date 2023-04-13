import 'package:http/http.dart' as http;

class ApiService {
  final baseUrl = "https://webtoon-crawler.nomadcoders.workers.dev";
  final today = "today";

  void getTodaysToon() {
    final url = Uri.parse("$baseUrl/$today");
    http.get(url);
  }
}
