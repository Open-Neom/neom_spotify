import 'package:neom_core/domain/model/item_list.dart';
import 'package:spotify/spotify.dart';


abstract class NeomSpotifyService {

  Future<void> getSpotifyToken();
  Future<void> gotoPlaylistSongs(Itemlist itemlist);
  void handlePlaylistList(Itemlist spotifyItemlist);
  Future<void> loadSongsForPlaylist(PlaylistSimple playlist);
  Future<void> synchronizeItemlists();
  Future<bool> synchronizeItemlist(Itemlist itemlist);
  Future<Map<String, Itemlist>> searchPlaylists(String searchParam);
  Future<void> synchronizeSpotifyPlaylists();

}
