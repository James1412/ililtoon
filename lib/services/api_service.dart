import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:webtoon_second_try/models/webtoon_model.dart';

class ApiServer {
  static int ililcode = 68;
  static String url =
      'https://www.11toon$ililcode.com/bbs/board.php?bo_table=toon_c&type=upd&tablename=최신만화';
  static int pageNumber = 1;

  static Future<List> getToons({required startPage, required endPage}) async {
    List<dynamic> toons = [];
    for (int page = startPage; page <= endPage; page++) {
      // ililcode changes every few weeks or months
      // avoid changed ililcode
      int maxAttempts = 50;
      int attempts = 0;
      bool isWebsiteWorking = false;
      while (!isWebsiteWorking && attempts < maxAttempts) {
        try {
          final uri = Uri.parse('$url&page=$page');
          final response = await http.get(uri);
          dom.Document html = dom.Document.html(response.body);
          // 작동은 함
          final titles = html
              .querySelectorAll(' a > div.homelist-title > span')
              .map((e) => e.innerHtml.trim())
              .toList();
          if (titles.isEmpty) {
            // 근데 내가 원하던 사이트가 아님
            ililcode++;
            throw Exception('Titles list is empty');
          } else {
            // 내가 원하던 사이트임
            isWebsiteWorking = true;
          }
        } catch (e) {
          // 아예 접속이 안됨
          ililcode++;
          attempts++;
          url = url;
        }
      }
      final uri = Uri.parse('$url&page=$page');
      final response = await http.get(uri);
      dom.Document html = dom.Document.html(response.body);

      final titles = html
          .querySelectorAll(' a > div.homelist-title > span')
          .map((e) => e.innerHtml.trim())
          .toList();

      final thumbs = html
          .querySelectorAll('a > div.homelist-thumb')
          .map((thumb) => thumb.attributes['style']!)
          .map((style) => RegExp(r'url\((.*?)\)').firstMatch(style))
          .where((match) => match != null)
          .map((match) => "https:${match!.group(1)!}")
          .map((url) => url.replaceAll("'", ""))
          .toList();

      final urls = html
          .querySelectorAll('.homelist.is-cover>li>a')
          .map((e) => "https://www.11toon69.com/${e.attributes['href']}")
          .toList();

      final roughGenre = html
          .querySelectorAll('a > div.homelist-genre')
          .map((e) => e.innerHtml.trim())
          .toList();
      var genres = [];
      for (final element in roughGenre) {
        var eachElement = [];
        final regex = RegExp(r'[\u3131-\u3163\uAC00-\uD7A3]+');
        final matches = regex.allMatches(element);
        for (final match in matches) {
          eachElement.add(match.group(0)!);
        }
        genres.add(eachElement);
      }

      if (response.statusCode == 200) {
        for (var it in titles) {
          toons.add(
            ToonModel.fromJson(
              genre: genres[titles.indexOf(it)],
              title: titles[titles.indexOf(it)],
              thumb: thumbs[titles.indexOf(it)],
              url: urls[titles.indexOf(it)],
            ),
          );
        }
      } else {
        ililcode += 1;
        throw Error();
      }
    }

    return toons;
  }
}
