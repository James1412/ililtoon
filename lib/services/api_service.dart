import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;

class ApiServer {
  final url = 'https://www.11toon69.com/bbs/board.php?bo_table=toon_c&type=upd';

  void getToons() async {
    final uri = Uri.parse(url);
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

    final roughIds = html.querySelectorAll('a > div.homelist-thumb');
    var ids = [];
    for (final id in roughIds) {
      final style = id.attributes['style']!;
      final match = RegExp(r'url\((.*?)\)').firstMatch(style);
      if (match != null) {
        final url = match.group(1)!.substring(34).replaceAll("'", "");
        ids.add(url);
      }
    }

    final urls = html
        .querySelectorAll('.homelist.is-cover>li>a')
        .map((e) => "https://www.11toon69.com/${e.attributes['href']}")
        .toList();

    if (response.statusCode == 200) {
      print(urls);
      return;
    }
    throw Error();
  }
}
