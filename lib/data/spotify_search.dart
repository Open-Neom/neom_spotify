import 'dart:async';

import 'package:neom_core/app_config.dart';
import 'package:neom_core/domain/model/app_media_item.dart';
import 'package:neom_core/domain/model/item_list.dart';
import 'package:spotify/spotify.dart';

import '../../utils/constants/neom_spotify_constants.dart';
import '../../utils/media_item_spotify_mapper.dart';

class SpotifySearch {

  static SpotifyApi spotify = SpotifyApi(NeomSpotifyConstants.getSpotifyCredentials());
  static Map<String, AppMediaItem> songs = {};
  static Map<String, Itemlist> giglists = {};

  static Future<Map<String, AppMediaItem>> searchSongs(String searchParam) async {
    AppConfig.logger.t("Searching for songs by param: $searchParam}");

    try {
      var searchData = await spotify.search
          .get(searchParam.toLowerCase(),
            types: [SearchType.track])
          .first(20)
          .catchError((err) {
            AppConfig.logger.e(err.toString());
            return err;
          });

      await loadSongsFromSpotify(searchData);

    } catch (e) {
      AppConfig.logger.e(e.toString());
    }

    return songs;
  }

  static Future<void> loadSongsFromSpotify(List<Page<dynamic>> searchData) async {
    AppConfig.logger.t("Retrieving songs from Spotify");
    songs.clear();
    try {
      for (var page in searchData) {
        for (var item in page.items!) {
          if (item is Track) {
            AppMediaItem song = MediaItemSpotifyMapper.mapTrackToSong(item);
            if(song.url.isNotEmpty) {
              songs[song.id] = song;
            } else {
              AppConfig.logger.t("Media ${song.name} was found with no url so it was no added to songs list");
            }

          }
        }
      }
    } catch (e) {
      AppConfig.logger.e(e.toString());
    }

  }


  Future<Map<String, Itemlist>> searchPlaylists(String searchParam) async {
    AppConfig.logger.d("Searching for playlists");

    try {
      var searchData = await spotify.search
          .get(searchParam.toLowerCase(),
            types: [SearchType.playlist])
          .first(50);

      AppConfig.logger.i("Retrieving playlists from Spotify");
      loadPlaylistsFromSpotify(searchData);

    } catch (e) {
      AppConfig.logger.e(e.toString());
    }

    return giglists;
  }

  void loadPlaylistsFromSpotify(List<Page<dynamic>> searchData) async {

    try {
      for (var page in searchData) {
        for (var item in page.items!) {
          if (item is Playlist) {
            Itemlist giglist = MediaItemSpotifyMapper.mapPlaylistToItemlist(item);
            giglists[giglist.id] = giglist;
          } else if (item is PlaylistSimple) {
            Itemlist giglist = MediaItemSpotifyMapper.mapPlaylistSimpleToItemlist(item);
            giglists[giglist.id] = giglist;
          }
        }
      }
    } catch (e) {
      AppConfig.logger.e(e.toString());
    }

    AppConfig.logger.d("${giglists.length} playlists retrieved");
  }

  Future<Artist> loadArtistDetails(String artistId) async {
    AppConfig.logger.d("Retrieving Details for artistId $artistId");
    Artist artist = Artist();

    try {
      artist = await spotify.artists.get(artistId);
    } catch (e) {
      AppConfig.logger.e(e.toString());
    }

    return artist;
  }

  Future<List<AppMediaItem>> loadSongsFromPlaylist(String playlistId) async {
    AppConfig.logger.d("Loading songs from playlist $playlistId");
    List<AppMediaItem> playlistSongs = [];
    Playlist playlist = Playlist();

    try {
      playlist = await spotify.playlists.get(playlistId);

      if(playlist.tracks != null) {
        playlistSongs = MediaItemSpotifyMapper.mapTracksToSongs(playlist.tracks!);
      }
    } catch (e) {
      AppConfig.logger.e(e.toString());
    }

    return playlistSongs;
  }

}
