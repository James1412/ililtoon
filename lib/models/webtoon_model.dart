class ToonModel {
  final String title, thumb, url;
  final List<dynamic> genre;
  ToonModel.fromJson(
      {required var this.title,
      required var this.thumb,
      required var this.url,
      required var this.genre});
}
