import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:neom_commons/utils/constants/app_page_id_constants.dart';
import 'package:neom_commons/utils/constants/translations/message_translation_constants.dart';
import 'package:neom_core/app_config.dart';
import 'package:neom_core/data/firestore/app_media_item_firestore.dart';
import 'package:neom_core/data/firestore/itemlist_firestore.dart';
import 'package:neom_core/data/firestore/profile_firestore.dart';
import 'package:neom_core/data/firestore/user_firestore.dart';
import 'package:neom_core/domain/model/app_media_item.dart';
import 'package:neom_core/domain/model/app_profile.dart';
import 'package:neom_core/domain/model/band.dart';
import 'package:neom_core/domain/model/item_list.dart';
import 'package:neom_core/domain/use_cases/user_service.dart';
import 'package:neom_core/utils/constants/app_route_constants.dart';
import 'package:neom_core/utils/enums/itemlist_type.dart';
import 'package:neom_core/utils/enums/owner_type.dart';
import 'package:spotify/spotify.dart' as spotify;

import '../data/spotify_api_calls_from_itemlists.dart';
import '../data/spotify_search.dart';
import '../domain/use_cases/neom_spotify_service.dart';
import '../utils/media_item_spotify_mapper.dart';
import 'sync/spotify_playlist_page.dart';

class NeomSpotifyController extends GetxController implements NeomSpotifyService  {

  final userServiceImpl = Get.find<UserService>();

  Itemlist currentItemlist = Itemlist();
  Itemlist spotifyItemlist = Itemlist();

  TextEditingController newItemlistNameController = TextEditingController();
  TextEditingController newItemlistDescController = TextEditingController();

  final RxMap<String, Itemlist> itemlists = <String, Itemlist>{}.obs;
  final RxList<Itemlist> addedItemlists = <Itemlist>[].obs;
  
  final RxMap<String, Itemlist> spotifyItemlists = <String, Itemlist>{}.obs;
  final RxList<spotify.Playlist> spotifyPlaylists = <spotify.Playlist>[].obs;
  final RxList<spotify.PlaylistSimple> spotifyPlaylistSimples = <spotify.PlaylistSimple>[].obs;

  AppProfile profile = AppProfile();
  Band band = Band();
  String ownerId = '';
  String ownerName = '';
  OwnerType ownerType = OwnerType.profile;
  ItemlistType itemlistType = ItemlistType.playlist;

  final RxBool isLoading = true.obs;
  final RxBool isButtonDisabled = false.obs;

  final RxBool isPublicNewItemlist = true.obs;
  final RxString errorMsg = "".obs;

  bool spotifyAvailable = true;

  RxString itemName = "".obs;
  RxInt itemNumber = 0.obs;
  int totalItemsToSync = 0;

  @override
  void onInit() {
    super.onInit();
    AppConfig.logger.t("onInit Itemlist Controller");

    try {
      userServiceImpl.itemlistOwnerType = OwnerType.profile;
      profile = userServiceImpl.profile;
      ownerId = profile.id;
      ownerName = profile.name;
      itemlistType = AppConfig.instance.defaultItemlistType;

      if(Get.arguments != null) {
        if(Get.arguments.isNotEmpty && Get.arguments[0] is Band) {
          if(Get.arguments[0] is Band) {
            band = Get.arguments[0];
            ownerId = band.id;
            ownerName = band.name;
            ownerType = OwnerType.band;

            userServiceImpl.band = band;
            userServiceImpl.itemlistOwnerType = OwnerType.band;
          } else if(Get.arguments[0] is ItemlistType) {
            itemlistType = Get.arguments[0];
          }
        }
      }

      AppConfig.logger.t('Itemlists being loaded from ${ownerType.name}');
      if(ownerType == OwnerType.profile) {
        itemlists.value = Map.from(profile.itemlists ?? {});
      } else if(ownerType == OwnerType.band){
        itemlists.value = Map.from(band.itemlists ?? {});
      }

    } catch (e) {
      AppConfig.logger.e(e.toString());
    }

  }

  @override
  void onReady() {
    super.onReady();
    ///NOT USEFUL RIGHT NOW - IS IT USEFUL TO GET SONGS FROM SPOTIFY???
    // try {
    //   if(AppFlavour.appInUse == AppInUse.g && !Platform.isIOS) {
    //     getSpotifyToken();
    //     if (userServiceImpl.user.spotifyToken.isNotEmpty
    //         && userServiceImpl.profile.lastSpotifySync < DateTime
    //             .now().subtract(const Duration(days: 30))
    //             .millisecondsSinceEpoch
    //     ) {
    //       AppConfig.logger.d("Spotify Last Sync was more than 30 days");
    //       outOfSync = true;
    //     } else {
    //       AppConfig.logger.i("Spotify Last Sync in scope");
    //     }
    //   }
    // } catch (e) {
    //   AppConfig.logger.e(e.toString());
    //   AppUtilities.showSnackBar(
    //     title: MessageTranslationConstants.spotifySynchronization.tr,
    //     message: e.toString(),
    //   );
    //   spotifyAvailable = false;
    // }
    isLoading.value = false;
    update([AppPageIdConstants.itemlist]);
  }

  @override
  Future<void> getSpotifyToken() async {
    AppConfig.logger.d("Getting SpotifyToken");
    AppConfig.logger.w("DEPRECATED - spotify_sdk was working for android and not allowing to build on ios");

    String spotifyToken = await SpotifyApiCalls.getSpotifyToken();
    // String spotifyToken = '';

    if(spotifyToken.isNotEmpty) {
      AppConfig.logger.t("Spotify access token is: $spotifyToken");
      userServiceImpl.user.spotifyToken = spotifyToken;
      await UserFirestore().updateSpotifyToken(userServiceImpl.user.id, spotifyToken);
    }
    update([AppPageIdConstants.itemlist]);
  }

  @override
  Future<void> gotoPlaylistSongs(Itemlist itemlist) async {

    spotify.Playlist spotifyPlaylist = spotify.Playlist();

    try {
      spotify.PlaylistSimple playlistSimple = spotifyPlaylistSimples.value.where((element) => element.href == itemlist.href).first;

      if(playlistSimple.id?.isNotEmpty ?? false) {
        spotifyPlaylist = await SpotifyApiCalls.getPlaylist(spotifyToken: userServiceImpl.user.spotifyToken, playlistId: playlistSimple.id!);
      }

      if(spotifyPlaylist.href?.isNotEmpty ?? false) {
        itemlist.appMediaItems = MediaItemSpotifyMapper.mapTracksToSongs(spotifyPlaylist.tracks!);
        AppConfig.logger.d("${itemlist.appMediaItems?.length ?? 0} songs were mapped from ${spotifyPlaylist.name}");
      }
    } catch (e) {
      AppConfig.logger.e(e.toString());
    }

    await Get.toNamed(AppRouteConstants.listItems, arguments: [itemlist, true]);
    update([AppPageIdConstants.itemlist, AppPageIdConstants.itemlistItem]);
  }

  @override
  void handlePlaylistList(Itemlist spotifyItemlist) {

    try {
      if (addedItemlists.contains(spotifyItemlist)) {
        AppConfig.logger.d("Removing gigList ${spotifyItemlist.name}");
        addedItemlists.remove(spotifyItemlist);
        totalItemsToSync -= spotifyPlaylistSimples.value.where((element) => element.id == spotifyItemlist.id).first.tracksLink?.total ?? 0;
      } else {
        AppConfig.logger.d("Adding giglist with name ${spotifyItemlist.name}");
        addedItemlists.add(spotifyItemlist);
        totalItemsToSync += spotifyPlaylistSimples.value.where((element) => element.id == spotifyItemlist.id).first.tracksLink?.total ?? 0;
      }
    } catch (e) {
      AppConfig.logger.e(e.toString());
    }

    update([AppPageIdConstants.playlistSong]);
  }

  @override
  Future<void> loadSongsForPlaylist(spotify.PlaylistSimple playlist) async {
    itemlists.forEach((playlistId, giglist) async {
      giglist.appMediaItems = await SpotifySearch().loadSongsFromPlaylist(playlistId);
      AppConfig.logger.i("Adding ${giglist.appMediaItems?.length} song to Giglist ${giglist.name}");
      itemlists[playlistId] = giglist;
    });
  }

  @override
  Future<void> synchronizeItemlists() async {
    AppConfig.logger.i("Synchronizing ${addedItemlists.length} Itemlists from Spotify Playlists");

    Map<Itemlist, bool> wereSynchronized = {};
    isLoading.value = true;
    isButtonDisabled.value = true;
    update([AppPageIdConstants.itemlist]);

    try {
      spotify.Playlist playlistToSync = spotify.Playlist();
      for (var addedItemlist in addedItemlists) {
        spotify.PlaylistSimple playlistSimple = spotifyPlaylistSimples.value.where((element) => element.href == addedItemlist.href).first;

        if(playlistSimple.id?.isNotEmpty ?? false) {
          playlistToSync = await SpotifyApiCalls.getPlaylist(spotifyToken: userServiceImpl.user.spotifyToken, playlistId: playlistSimple.id!);
        }

        if(playlistToSync.href?.isNotEmpty ?? false) {
          addedItemlist.appMediaItems = MediaItemSpotifyMapper.mapTracksToSongs(playlistToSync.tracks!);
          AppConfig.logger.i("${addedItemlist.appMediaItems?.length ?? 0} songs were mapped from ${playlistToSync.name}");
          wereSynchronized[addedItemlist] = await synchronizeItemlist(addedItemlist);
        }

      }

      if(wereSynchronized.values.firstWhere((element) => true)) {
        ProfileFirestore().updateLastSpotifySync(userServiceImpl.profile.id);
        Get.toNamed(AppRouteConstants.finishingSpotifySync, arguments: [AppRouteConstants.finishingSpotifySync]);
      } else {
        AppConfig.logger.i("No giglist was updated. Each one is up to date");
      }
    } catch(e) {
      AppConfig.logger.e(e.toString());
    }


    wereSynchronized.forEach((giglist, wasSync) {
      if(!wasSync) {
        AppConfig.logger.d("Removing added Giglist ${giglist.name} as it's up to date");
        addedItemlists.remove(giglist);
      }
    });

    isLoading.value = false;
    isButtonDisabled.value = false;
    update();
  }

  @override
  Future<bool> synchronizeItemlist(Itemlist itemlist) async {
    AppConfig.logger.i("Synchronizing Itemlist ${itemlist.name}");
    isButtonDisabled.value = true;
    isLoading.value = true;
    bool wasSync = false;
    try {

      String itemlistId = "";
      Itemlist? existingItemlist;
      List<Itemlist>? existingItemlists;
      if(ownerType == OwnerType.profile) {
        existingItemlists = userServiceImpl.profile.itemlists?.values
            .where((element) => element.name == itemlist.name).toList();
      } else {
        existingItemlists = userServiceImpl.band.itemlists?.values
            .where((element) => element.name == itemlist.name).toList();
      }

      if(existingItemlists?.isNotEmpty ?? false) {
        existingItemlist = existingItemlists?.first;
      }

      if(existingItemlist?.id.isNotEmpty ?? false) {

        List<AppMediaItem> currentItems = [];
        itemlistId = existingItemlist?.id ?? "";

        itemlist.appMediaItems?.forEach((appItem) {
          List<AppMediaItem>? itemlistItems = existingItemlist?.appMediaItems?.where((element) => element.id == appItem.id).toList();
          if(itemlistItems?.isNotEmpty ?? false) {
            currentItems.add(appItem);
          }
        });

        for (AppMediaItem currentItem in currentItems) {
          itemlist.appMediaItems?.removeWhere((appItem) => appItem.id == currentItem.id);
          AppConfig.logger.d("Removing item ${currentItem.name} from being synchronized");
        }

        totalItemsToSync -= currentItems.length;
      }

      if(itemlistId.isEmpty) {
        itemlist.ownerId = ownerId;
        itemlist.ownerType = ownerType;
        itemlist.ownerName = ownerName;

        itemlistId = await ItemlistFirestore().insert(itemlist);
        AppConfig.logger.i("Itemlist inserted with id $itemlistId");
      }

      if(itemlistId.isNotEmpty && (itemlist.appMediaItems?.isNotEmpty ?? false)) {
        itemlist.id = itemlistId;

        if(ownerType == OwnerType.profile) {
          userServiceImpl.profile.itemlists![itemlist.id] = itemlist;
          currentItemlist = itemlist;

          List<String> appMediaItemsIds = itemlist.appMediaItems!.map((e) => e.id).toList();
          if(await ProfileFirestore().addFavoriteItems(profile.id, appMediaItemsIds)) {

          }
          for (AppMediaItem appItem in itemlist.appMediaItems ?? []) {
            itemName.value = appItem.name;
            itemNumber++;
            update([AppPageIdConstants.itemlist, AppPageIdConstants.playlistSong]);
            if (userServiceImpl.profile.itemlists!.isNotEmpty) {
              AppConfig.logger.d("Adding item to global itemlist from userServiceImpl");
              userServiceImpl.profile.favoriteItems!.add(appItem.id);
            }
            AppMediaItemFirestore().existsOrInsert(appItem);
          }
        } else if(ownerType == OwnerType.band) {
          userServiceImpl.band.itemlists![itemlist.id] = itemlist;
          for (var appItem in itemlist.appMediaItems ?? []) {
            AppMediaItemFirestore().existsOrInsert(appItem);
            //TODO Add sync for band itemlist
          }
        }
        AppConfig.logger.d("Items added successfully from Itemlist");
        wasSync = true;
      } else {
        Get.snackbar(
            MessageTranslationConstants.spotifySynchronization.tr,
            "Playlist ${itemlist.name} ${MessageTranslationConstants.upToDate.tr}",
            snackPosition: SnackPosition.bottom,
            duration: const Duration(seconds: 1)
        );
      }
      isButtonDisabled.value = false;
    } catch (e) {
      AppConfig.logger.e(e.toString());
    }

    update();
    return wasSync;
  }

  @override
  Future<Map<String, Itemlist>> searchPlaylists(String searchParam) async {
    itemlists.value = await SpotifySearch().searchPlaylists(searchParam);

    itemlists.value.forEach((playlistId, itemlist) async {
      itemlist.appMediaItems = await SpotifySearch().loadSongsFromPlaylist(playlistId);
      itemlists[playlistId] = itemlist;
    });

    return itemlists;
  }


  @override
  Future<void> synchronizeSpotifyPlaylists() async {
    AppConfig.logger.i("Getting Spotify Information with token: ${userServiceImpl.user.spotifyToken}");

    isLoading.value = true;
    update([AppPageIdConstants.itemlist]);

    spotify.User spotifyUser = await SpotifyApiCalls.getUserProfile(spotifyToken: userServiceImpl.user.spotifyToken);

    try {
      if(spotifyUser.id?.isNotEmpty ?? false) {
        spotifyPlaylistSimples.value =  await SpotifyApiCalls.getUserPlaylistSimples(spotifyToken: userServiceImpl.user.spotifyToken, userId: spotifyUser.id!);

        for (var playlist in spotifyPlaylistSimples.value) {
          if(playlist.id?.isNotEmpty ?? false) {
            spotifyItemlists[playlist.id!] = MediaItemSpotifyMapper.mapPlaylistSimpleToItemlist(playlist);
          }
        }

        Get.to(() => const SpotifyPlaylistsPage(), transition: Transition.rightToLeft);
        ///DEPRECATED
        // Get.toNamed(AppRouteConstants.spotifyPlaylists);
      }
    } catch(e) {
      AppConfig.logger.e(e.toString());
    }

    isLoading.value = false;
    update([AppPageIdConstants.itemlist]);
  }

}
