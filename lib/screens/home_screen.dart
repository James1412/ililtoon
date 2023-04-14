import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webtoon_second_try/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int endPage = 1;
  late String selectedGenre = "전체";
  late SharedPreferences prefs;

  Future<List> toons = ApiServer.getToons(
    startPage: 1,
    endPage: 1,
  );

  Future<void> onNextPage() async {
    setState(() {
      endPage += 1;
      toons = ApiServer.getToons(startPage: 1, endPage: endPage);
    });
  }

  Future<void> onRefresh() async {
    setState(() {
      toons = ApiServer.getToons(startPage: 1, endPage: endPage);
    });
  }

  List<String> favorites = [];

  void toggleFavorite(String title) async {
    setState(() {
      if (favorites.contains(title)) {
        favorites.remove(title);
      } else {
        favorites.add(title);
      }
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', favorites);
  }

  void onImageTap(var url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrlString(uri.toString());
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        favorites = prefs.getStringList('favorites') ?? [];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          color: Colors.green,
          iconSize: 35,
          icon: const Icon(Icons.arrow_downward_rounded),
          onPressed: onNextPage,
        ),
        title: Text(
          "최신 만화",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          DropdownButton<String>(
            iconEnabledColor: Colors.green,
            alignment: Alignment.center,
            value: selectedGenre,
            items: [
              const DropdownMenuItem(
                alignment: Alignment.center,
                value: "전체",
                child: Text("전체"),
              ),
              const DropdownMenuItem(
                alignment: Alignment.center,
                value: "액션",
                child: Text("액션"),
              ),
              const DropdownMenuItem(
                alignment: Alignment.center,
                value: "코미디",
                child: Text("코미디"),
              ),
              const DropdownMenuItem(
                alignment: Alignment.center,
                value: "드라마",
                child: Text("드라마"),
              ),
              const DropdownMenuItem(
                alignment: Alignment.center,
                value: "판타지",
                child: Text("판타지"),
              ),
              const DropdownMenuItem(
                alignment: Alignment.center,
                value: "학원",
                child: Text("학원"),
              ),
              const DropdownMenuItem(
                alignment: Alignment.center,
                value: "스릴러",
                child: Text("스릴러"),
              ),
              const DropdownMenuItem(
                alignment: Alignment.center,
                value: "먹방",
                child: Text("먹방"),
              ),
              const DropdownMenuItem(
                alignment: Alignment.center,
                value: "스포츠",
                child: Text("스포츠"),
              ),
              const DropdownMenuItem(
                alignment: Alignment.center,
                value: "인기",
                child: Text("인기"),
              ),
              const DropdownMenuItem(
                alignment: Alignment.center,
                value: "러브코미디",
                child: Text("러브코미디"),
              ),
              if (favorites.isNotEmpty)
                const DropdownMenuItem(
                  alignment: Alignment.center,
                  value: "즐겨찾기",
                  child: Text("즐겨찾기"),
                ),
            ],
            onChanged: (value) {
              setState(() {
                selectedGenre = value!;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: FutureBuilder(
            future: toons,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var toons = snapshot.data!;
                if (selectedGenre != "전체" && selectedGenre != "즐겨찾기") {
                  toons = toons
                      .where((toon) => toon.genre.contains(selectedGenre))
                      .toList();
                }
                var filteredToons = (selectedGenre == "즐겨찾기")
                    ? toons
                        .where((toon) => favorites.contains(toon.title))
                        .toList()
                    : toons;
                return ListView.separated(
                  separatorBuilder: (context, index) => const SizedBox(
                    height: 70,
                  ),
                  scrollDirection: Axis.vertical,
                  itemCount: filteredToons.length,
                  itemBuilder: (context, index) {
                    var toon = filteredToons[index];
                    bool isFavorite = favorites.contains(toon.title);
                    return Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => onImageTap(toon.url),
                            child: SizedBox(
                              width: 250,
                              height: 350,
                              child: Image.network(
                                toon.thumb,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  toon.title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              IconButton(
                                icon: isFavorite
                                    ? const Icon(Icons.favorite)
                                    : const Icon(Icons.favorite_border),
                                color: Colors.green,
                                onPressed: () => toggleFavorite(toon.title),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(toon.genre.toString()),
                        ],
                      ),
                    );
                  },
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
      ),
    );
  }
}
