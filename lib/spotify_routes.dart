import 'package:sint/sint.dart';
import 'package:neom_core/utils/constants/app_route_constants.dart';

import 'ui/search/playlist_items_page.dart';
import 'ui/sync/spotify_playlist_page.dart';

class NeomSpotifyRoutes {

  static final List<SintPage<dynamic>> routes = [
    SintPage(
        name: AppRouteConstants.spotifyPlaylists,
        page: () => const PlaylistItemsPage(),
        transition: Transition.rightToLeft
    ),
    SintPage(
        name: AppRouteConstants.finishingSpotifySync,
        page: () => const SpotifyPlaylistsPage(),
        transition: Transition.zoom
    ),
  ];

}
