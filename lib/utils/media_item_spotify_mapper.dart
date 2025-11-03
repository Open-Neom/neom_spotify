import 'package:neom_commons/utils/mappers/app_media_item_mapper.dart';
import 'package:neom_core/app_config.dart';
import 'package:neom_core/domain/model/app_media_item.dart';
import 'package:neom_core/domain/model/genre.dart';
import 'package:neom_core/domain/model/item_list.dart';
import 'package:neom_core/utils/enums/app_media_source.dart';
import 'package:neom_core/utils/enums/itemlist_type.dart';
import 'package:neom_core/utils/enums/media_item_type.dart';
import 'package:neom_core/utils/enums/owner_type.dart';
import 'package:spotify/spotify.dart';

class MediaItemSpotifyMapper {

  static List<AppMediaItem> listFromMap(Map<String, List<dynamic>> map) {
    List<AppMediaItem> items = [];
    try {

    } catch (e) {
      throw Exception('Error parsing song item: $e');
    }

    return items;
  }

  static List<AppMediaItem> listFromList(List<dynamic>? list) {
    List<AppMediaItem> items = [];
    try {

    } catch (e) {
      throw Exception('Error parsing song item: $e');
    }

    return items;
  }



  static List<AppMediaItem> mapItemsFromItemlist(Itemlist itemlist) {

    List<AppMediaItem> appMediaItems = [];

    if(itemlist.appMediaItems != null) {
      appMediaItems.addAll(itemlist.appMediaItems!);
    }

    if(itemlist.appReleaseItems != null) {
      for (var element in itemlist.appReleaseItems!) {
        appMediaItems.add(AppMediaItemMapper.fromAppReleaseItem(element));
      }
    }

    // if(itemlist.chamberPresets != null) {
    //   itemlist.chamberPresets!.forEach((element) {
    //     appMediaItems.add(AppMediaItem.fromAppItem(element));
    //   });
    // }

    AppConfig.logger.t("Retrieving ${appMediaItems.length} total AppMediaItems.");
    return appMediaItems;
  }

  static AppMediaItem mapTrackToSong(Track track) {
    AppMediaItem song = AppMediaItem();
    String artistName = "";
    String albumImgUrl = "";

    try {
      if (track.artists!.length > 1) {
        for (var artists in track.artists!) {
          artistName.isEmpty ? artistName = (artists.name ?? "")
              : artistName = "$artistName, ${artists.name ?? ""}";
        }
      } else {
        artistName = track.artists?.first.name ?? "";
        albumImgUrl = track.album?.images?.first.url ?? "";
      }

      song = AppMediaItem(
          id: track.id ?? "",
          state: 1,
          name: track.name ?? "",
          ownerName: artistName,
          ownerId: track.artists?.first.id ?? "",
          album: track.album?.name ?? "",
          duration: ((track.durationMs ?? 0) / 1000).ceil(),
          imgUrl: albumImgUrl,
          url: track.previewUrl ?? "",
          categories: Genre.listFromJSON(track.artists?.first.genres ?? []).map((e) => e.name).toList(),
          mediaSource: AppMediaSource.external,
          type: MediaItemType.song,
          permaUrl: track.externalUrls?.spotify ?? ''
      );

    } catch (e) {
      AppConfig.logger.e(e.toString());
    }

    return song;
  }

  static List<AppMediaItem> mapTracksToSongs(Paging<Track> tracks) {

    List<AppMediaItem> songs = [];

    ///DEPRECATED
    // String artistName = "";
    // String albumImgUrl = "";

    try {
      for (var playlistTrack in tracks.itemsNative!) {
        Track track = Track.fromJson(playlistTrack["track"]);
        songs.add(mapTrackToSong(track));
      }
    } catch (e) {
      AppConfig.logger.e(e.toString());
    }

    return songs;
  }

  static Itemlist mapPlaylistToItemlist(Playlist playlist) {
    AppConfig.logger.i("Mapping Spotify Playlist ${playlist.name} to Itemlist");
    List<AppMediaItem> appMediaItems = [];

    try {
      if (playlist.tracks != null && (playlist.tracks?.total ?? 0) > 1) {
        appMediaItems = mapTracksToSongs(playlist.tracks!);
      }
    } catch (e) {
      AppConfig.logger.e(e.toString());
    }

    return Itemlist(
        id: playlist.id ?? "",
        name: playlist.name ?? "",
        description: playlist.description ?? "",
        href: playlist.href ?? "",
        imgUrl: playlist.images?.first.url ?? "",
        public: playlist.public ?? true,
        uri: playlist.uri ?? "",
        appMediaItems: appMediaItems
    );
  }

  static Itemlist mapPlaylistSimpleToItemlist(PlaylistSimple playlist) {
    AppConfig.logger.i("Mapping Spotify PlaylistSimple ${playlist.name} to Itemlist");

    return Itemlist(
      id: playlist.id ?? "",
      name: playlist.name ?? "",
      description: playlist.description ?? "",
      href: playlist.href ?? "",
      imgUrl: (playlist.images?.isNotEmpty ?? false) ? playlist.images?.first.url ?? "" : "",
      public: playlist.public ?? true,
      uri: playlist.uri ?? "",
      appMediaItems: [], // No detailed tracks available in PlaylistSimple
      isModifiable: true,
      ownerId: '',
      ownerName: '',
      type: ItemlistType.playlist,
      ownerType: OwnerType.profile,
    );
  }

}
