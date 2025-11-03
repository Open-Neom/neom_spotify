import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:neom_core/app_config.dart';
import 'package:neom_core/app_properties.dart';
import 'package:spotify/spotify.dart' as spotify;
import 'package:spotify_sdk/spotify_sdk.dart';

import '../utils/constants/neom_spotify_constants.dart';

class SpotifyApiCalls {

  /// You can signup for spotify developer account and get your own clientID and clientSecret incase you don't want to use these


  String requestAuthorization() => 'https://accounts.spotify.com/authorize?client_id='
      '${AppProperties.getSpotifyClientId()}&response_type=code&redirect_uri=${NeomSpotifyConstants.redirectUrl}&'
      'scope=${NeomSpotifyConstants.scopes.join('%20')}';


  static Future<String> getSpotifyToken() async {
    AppConfig.logger.d('Getting access and Spotify Token');
    String spotifyToken = '';

    if(await SpotifySdk.connectToSpotifyRemote(
      clientId: AppProperties.getSpotifyClientId(),
      redirectUrl: NeomSpotifyConstants.redirectUrl,)
    ) {
      spotifyToken = await SpotifySdk.getAccessToken(
          clientId: AppProperties.getSpotifyClientId(),
          redirectUrl: NeomSpotifyConstants.redirectUrl,
          scope: NeomSpotifyConstants.scope,
      );
    }

    AppConfig.logger.i('Spotify Token Retrieved $spotifyToken');
    return spotifyToken;
  }


  static Future<spotify.User> getUserProfile({required String spotifyToken,}) async {

    final spotify.SpotifyApi spotifyApi = spotify.SpotifyApi.withAccessToken(spotifyToken);
    spotify.User spotifyUser = spotify.User();

    try {
      spotifyUser = await spotifyApi.me.get();
    } catch (e) {
      AppConfig.logger.e(e.toString());
    }

    AppConfig.logger.i('The spotify userName is ${spotifyUser.displayName}');
    return spotifyUser;
  }

  static Future<List<spotify.PlaylistSimple>> getUserPlaylistSimples({required String spotifyToken, required String userId}) async {

    final spotify.SpotifyApi spotifyApi = spotify.SpotifyApi.withAccessToken(spotifyToken);
    Iterable<spotify.PlaylistSimple> spotifyPlaylists = [];

    try {
      spotifyPlaylists = await spotifyApi.playlists.getUsersPlaylists(userId, 100).all();
      AppConfig.logger.i('${spotifyPlaylists.length} playlists where retrieved from Spotify');
    } catch (e) {
      AppConfig.logger.e(e.toString());
    }

    AppConfig.logger.i('${spotifyPlaylists.length} were retrieved for Spotify User Id $userId');
    return spotifyPlaylists.toList();
  }


  static Future<List<spotify.Playlist>> getUserPlaylists({required String spotifyToken, required String userId}) async {

    final spotify.SpotifyApi spotifyApi = spotify.SpotifyApi.withAccessToken(spotifyToken);
    Iterable<spotify.PlaylistSimple> spotifyPlaylists;
    final List<spotify.Playlist> playlists = [];

    try {
      spotifyPlaylists = await spotifyApi.playlists.getUsersPlaylists(userId, 100).all();
      AppConfig.logger.i('${spotifyPlaylists.length} playlists where retrieved from Spotify');

      for (var spotifyPlaylist in spotifyPlaylists.toList()) {
        if(spotifyPlaylist.id?.isNotEmpty ?? false) {
          AppConfig.logger.d('Getting full info for Playlist ${spotifyPlaylist.name} with id ${spotifyPlaylist.id}');
          playlists.add(await spotifyApi.playlists.get(spotifyPlaylist.id!));
        }
      }
    } catch (e) {
      AppConfig.logger.e(e.toString());
    }

    AppConfig.logger.i('${playlists.length} were retrieved for Spotify User Id $userId');
    return playlists;
  }

  static Future<http.Response?> getUserTopItems({required String spotifyToken, String itemType = 'tracks'}) async {

    http.Response? response;

    try {
      final Uri uri = Uri.parse('https://api.spotify.com/v1/me/top/$itemType');
      response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $spotifyToken',
        },
      );
    } catch (e) {
      AppConfig.logger.e(e.toString());
    }


    AppConfig.logger.i(response?.body ?? '');
    return response;
  }

  static Future<spotify.Playlist> getPlaylist({required String spotifyToken, required String playlistId}) async {

    final spotify.SpotifyApi spotifyApi = spotify.SpotifyApi.withAccessToken(spotifyToken);
    spotify.Playlist playlist = spotify.Playlist();

    try {
      playlist = await spotifyApi.playlists.get(playlistId);
      AppConfig.logger.i('Playlist ${playlist.name} were retrieved from Spotify');

    } catch (e) {
      AppConfig.logger.e(e.toString());
    }

    return playlist;
  }

  Future<List<String>> getAccessToken({
    String? code,
    String? refreshToken,
  }) async {
    final String clientID = AppProperties.getSpotifyClientId();
    final String clientSecret = AppProperties.getSpotifyClientSecret();

    final Map<String, String> headers = {
      'Authorization': "Basic ${base64.encode(utf8.encode("$clientID:$clientSecret"))}",
    };

    Map<String, String>? body;
    if (code != null) {
      body = {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': NeomSpotifyConstants.redirectUrl,
      };
    } else if (refreshToken != null) {
      body = {
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
      };
    }

    if (body == null) {
      return [];
    }

    try {
      final Uri path = Uri.parse(NeomSpotifyConstants.requestToken);
      final response = await post(path, headers: headers, body: body);

      if (response.statusCode == 200) {
        final Map result = jsonDecode(response.body) as Map;
        return <String>[
          result['access_token'].toString(),
          result['refresh_token'].toString(),
          result['expires_in'].toString(),
        ];
      } else {
        AppConfig.logger.e(
          'Error in getAccessToken, called: $path, returned: ${response.statusCode}',
        );
      }
    } catch (e) {
      AppConfig.logger.e('Error in getting spotify access token: $e');
    }
    return [];
  }

  Future<List> getAllTracksOfPlaylist(
      String accessToken,
      String playlistId,
      ) async {
    final List tracks = [];
    int totalTracks = 100;

    final Map data = await SpotifyApiCalls().getHundredTracksOfPlaylist(
      accessToken,
      playlistId,
      0,
    );
    totalTracks = data['total'] as int;
    tracks.addAll(data['tracks'] as List);

    if (totalTracks > 100) {
      for (int i = 1; i * 100 <= totalTracks; i++) {
        final Map data = await SpotifyApiCalls().getHundredTracksOfPlaylist(
          accessToken,
          playlistId,
          i * 100,
        );
        tracks.addAll(data['tracks'] as List);
      }
    }
    return tracks;
  }

  Future<Map> getHundredTracksOfPlaylist(
      String accessToken,
      String playlistId,
      int offset,
      ) async {
    try {
      final Uri path = Uri.parse(
        '${NeomSpotifyConstants.spotifyApiBaseUrl}${NeomSpotifyConstants.spotifyPlaylistTrackEndpoint}/$playlistId/tracks?limit=100&offset=$offset',
      );
      final response = await get(
        path,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final result = await jsonDecode(response.body);
        final List tracks = result['items'] as List;
        final int total = result['total'] as int;
        return {'tracks': tracks, 'total': total};
      } else {
        AppConfig.logger.e(
          'Error in getHundredTracksOfPlaylist, called: $path, returned: ${response.statusCode}',);
      }
    } catch (e) {
      AppConfig.logger.e('Error in getting spotify playlist tracks: $e');
    }
    return {};
  }

  Future<Map> searchTrack({
    required String accessToken,
    required String query,
    int limit = 10,
    String type = 'track',
  }) async {
    final Uri path = Uri.parse(
      '${NeomSpotifyConstants.spotifyApiBaseUrl}/search?q=$query&type=$type&limit=$limit',
    );

    final response = await get(
      path,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body) as Map;
      return result;
    } else {
      AppConfig.logger.e(
        'Error in searchTrack, called: $path, returned: ${response.statusCode}',
      );
    }
    return {};
  }

  Future<Map> getTrackDetails(String accessToken, String trackId) async {
    final Uri path = Uri.parse(
      '${NeomSpotifyConstants.spotifyApiBaseUrl}/tracks/$trackId',
    );
    final response = await get(
      path,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body) as Map;
      return result;
    } else {
      AppConfig.logger.e(
        'Error in getTrackDetails, called: $path, returned: ${response.statusCode}',
      );
    }
    return {};
  }

  static Future<spotify.Track> getTrackById(String trackId) async {
    final spotifyApi = spotify.SpotifyApi(
        spotify.SpotifyApiCredentials(
          AppProperties.getSpotifyClientId(),
          AppProperties.getSpotifyClientSecret(),
        )
    );

    spotify.Track track = await spotifyApi.tracks.get(trackId);
    return track;
  }

}
