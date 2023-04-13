import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:webtoon_second_try/models/webtoon_model.dart';

class ApiServer {
  String url =
      'https://www.11toon69.com/bbs/board.php?bo_table=toon_c&type=upd';

  Future<List> getToons() async {
    List<dynamic> toons = [];
    for (int page = 1; page < 21; page++) {
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

      // this thing prints <>genrename<><> something like this, so
      // needs to remove those other than the genrename in korean
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
        throw Error();
      }
    }
    return toons;
  }
}
