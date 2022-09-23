import 'dart:convert';
import 'package:flutter/foundation.dart' show immutable;

List<ArtistsData> artistsDataFromJson(String str) => List<ArtistsData>.from(
    json.decode(str).map((x) => ArtistsData.fromJson(x)));

String artistsDataToJson(List<ArtistsData> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@immutable
class ArtistsData {
  const ArtistsData({
    required this.name,
    required this.link,
    required this.about,
  });

  final String? name;
  final String? link;
  final String? about;

  ArtistsData.fromJson(Map<String, dynamic> json) :
        name = json["name"] as String?,
        link = json["link"],
        about = json["about"];

  Map<String, dynamic> toJson() => {
        "name": name,
        "link": link,
        "about": about,
      };
}

/*
class ArtistsData {
  String? name;
  String? link;
  String? about;
  ArtistsData(this.name, this.link, this.about);
  ArtistsData.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    link = json['link'];
    about = json['about'];
  }
}
*/