import 'package:sint/sint.dart';
import 'package:neom_core/utils/constants/app_route_constants.dart';
import 'package:neom_core/ui/deferred_loader.dart';

import 'ui/search/playlist_items_page.dart' deferred as playlistItems;
import 'ui/sync/spotify_playlist_page.dart' deferred as spotifyPlaylist;

class NeomSpotifyRoutes {

  static final List<SintPage<dynamic>> routes = [
    SintPage(
        name: AppRouteConstants.spotifyPlaylists,
        page: () => DeferredLoader(playlistItems.loadLibrary, () => playlistItems.PlaylistItemsPage()),
        transition: Transition.rightToLeft
    ),
    SintPage(
        name: AppRouteConstants.finishingSpotifySync,
        page: () => DeferredLoader(spotifyPlaylist.loadLibrary, () => spotifyPlaylist.SpotifyPlaylistsPage()),
        transition: Transition.zoom
    ),
  ];

}
