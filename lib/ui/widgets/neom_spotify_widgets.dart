import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neom_commons/ui/theme/app_color.dart';
import 'package:neom_commons/ui/theme/app_theme.dart';
import 'package:neom_commons/ui/widgets/images/handled_cached_network_image.dart';
import 'package:neom_commons/utils/constants/app_constants.dart';
import 'package:neom_core/app_properties.dart';
import 'package:neom_core/domain/model/item_list.dart';

import '../../utils/constants/spotify_translation_constants.dart';
import '../neom_spotify_controller.dart';

Widget buildSyncPlaylistsButton(BuildContext context, NeomSpotifyController controller) {
  return Center(
    child: SizedBox(
      width: AppTheme.fullWidth(context) * 0.5,
      height: AppTheme.fullHeight(context) * 0.06,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: AppColor.bondiBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        ),
        onPressed: () async {
          if(!controller.isButtonDisabled.value) await controller.synchronizeItemlists();
        },
        child: Obx(()=>controller.isLoading.value ? const Center(child: CircularProgressIndicator())
            : Text(SpotifyTranslationConstants.synchronizePlaylists.tr,
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15
          ),
        ),
        ),
      ),
    ),
  );
}

Widget buildSyncPlaylistList(BuildContext context, NeomSpotifyController controller) {
  return ListView.separated(
    separatorBuilder: (context, index) => const Divider(),
    itemCount: controller.spotifyItemlists.length,
    itemBuilder: (context, index) {
      Itemlist spotifyItemlist = controller.spotifyItemlists.values.elementAt(index);
      return ListTile(
        leading: HandledCachedNetworkImage(
          spotifyItemlist.imgUrl.isNotEmpty ? spotifyItemlist.imgUrl : AppProperties.getAppLogoUrl(),
        ),
        title: Text((spotifyItemlist.name.isEmpty) ? ""
            : spotifyItemlist.name.length > AppConstants.maxAppItemNameLength
            ? "${spotifyItemlist.name.substring(0,AppConstants.maxAppItemNameLength)}..."
            : spotifyItemlist.name),
        subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text((spotifyItemlist.description.isEmpty) ? ""
                    : spotifyItemlist.description.length > AppConstants.maxArtistNameLength
                    ? "${spotifyItemlist.description.substring(0,AppConstants.maxArtistNameLength)}..."
                    : spotifyItemlist.description),
              ),
              AppTheme.widthSpace5,
            ]),
        trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Chip(
                backgroundColor: AppColor.main50,
                avatar: CircleAvatar(
                  backgroundColor: AppColor.white80,
                  child: Obx(()=>controller.isLoading.value && controller.currentItemlist.href == spotifyItemlist.href
                      ? const Center(child: CircularProgressIndicator())
                      : Text(("${(spotifyItemlist.appMediaItems?.isEmpty ?? true)
                      ? controller.spotifyPlaylistSimples.value.where((element) => element.id == spotifyItemlist.id).first.tracksLink?.total
                      : spotifyItemlist.appMediaItems?.length ?? 0
                  }")
                  ),
                  ),
                ),
                label: Icon(Icons.music_note, color: AppColor.white80),
                labelPadding: const EdgeInsets.all(5),
              ),
            ]
        ),
        tileColor: controller.addedItemlists.contains(spotifyItemlist) ? AppColor.getMain() : Colors.transparent,
        onTap: () => {
          controller.handlePlaylistList(spotifyItemlist),
        },
        onLongPress: () => {
          controller.gotoPlaylistSongs(spotifyItemlist)
        },
      );
    },
  );
}
