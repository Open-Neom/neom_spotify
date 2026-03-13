
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:neom_core/cloud_properties.dart';
import 'package:spotify/spotify.dart';

class NeomSpotifyConstants {

  static const String scope = "app-remote-control,user-modify-playback-state,"
      " user-library-read,user-top-read, playlist-read-collaborative,"
      " playlist-read-private";

  static const List<String> scopes = [
    "app-remote-control", "user-modify-playback-state",
    "user-library-read", "user-top-read",
    "playlist-read-collaborative", "playlist-read-private"];

  static const String meUrl = 'https://api.spotify.com/v1/me';

  /// Returns Spotify API credentials.
  /// On web, Spotify SDK is not available — returns empty credentials.
  static SpotifyApiCredentials getSpotifyCredentials({String accessToken = ""}) {
    if (kIsWeb) {
      return SpotifyApiCredentials('', '', accessToken: accessToken, scopes: scopes);
    }
    return SpotifyApiCredentials(
        CloudProperties.getSpotifyClientId(),
        CloudProperties.getSpotifyClientSecret(),
        accessToken: accessToken,
        scopes: scopes,
    );
  }

  static const String redirectUrl = 'https://{appWebsite}/spotify_auth.html';
  static const String spotifyApiUrl = 'https://accounts.spotify.com/api';
  static const String spotifyApiBaseUrl = 'https://api.spotify.com/v1';
  static const String spotifyUserPlaylistEndpoint = '/me/playlists';
  static const String spotifyPlaylistTrackEndpoint = '/playlists';
  static const String spotifyRegionalChartsEndpoint = '/views/charts-regional';
  static const String spotifyFeaturedPlaylistsEndpoint = '/browse/featured-playlists';
  static const String spotifyBaseUrl = 'https://accounts.spotify.com';
  static const String requestToken = 'https://accounts.spotify.com/api/token';

}
