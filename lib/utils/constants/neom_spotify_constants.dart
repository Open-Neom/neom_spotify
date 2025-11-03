
import 'package:neom_core/app_properties.dart';
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

  static SpotifyApiCredentials getSpotifyCredentials({String accessToken = ""}) {
    return SpotifyApiCredentials(
        AppProperties.getSpotifyClientId(),
        AppProperties.getSpotifyClientSecret(),
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
