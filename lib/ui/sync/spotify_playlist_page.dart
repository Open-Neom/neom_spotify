import 'package:flutter/material.dart';
import 'package:sint/sint.dart';
import 'package:neom_commons/ui/theme/app_color.dart';
import 'package:neom_commons/ui/theme/app_theme.dart';
import 'package:neom_commons/ui/widgets/appbar_child.dart';
import 'package:neom_commons/utils/constants/app_page_id_constants.dart';
import 'package:neom_commons/utils/constants/translations/app_translation_constants.dart';
import 'package:percent_indicator/flutter_percent_indicator.dart';

import '../neom_spotify_controller.dart';
import '../widgets/neom_spotify_widgets.dart';

class SpotifyPlaylistsPage extends StatelessWidget {
  const SpotifyPlaylistsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SintBuilder<NeomSpotifyController>(
      id: AppPageIdConstants.playlistSong,
      builder: (controller) => Scaffold(
        appBar: AppBarChild(title: "${controller.spotifyPlaylistSimples.value.length} Playlists ${AppTranslationConstants.found.tr}"),
        body: Container(
            decoration: AppTheme.appBoxDecoration,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: controller.addedItemlists.isNotEmpty
                      ? controller.itemNumber > 0 ? AppTheme.fullHeight(context) * 0.7 : AppTheme.fullHeight(context) * 0.8
                      : AppTheme.fullHeight(context) * 0.9,
                  child: Obx(()=> buildSyncPlaylistList(context, controller)),
                ),
                controller.addedItemlists.isNotEmpty ? Obx(()=> controller.itemNumber > 0 ?
                Center(
                    child: LinearPercentIndicator(
                      width: AppTheme.fullWidth(context),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      lineHeight: 25.0,
                      percent: controller.itemNumber/controller.totalItemsToSync,
                      center: Text("${AppTranslationConstants.adding.tr} "
                          "${controller.itemNumber} ${AppTranslationConstants.outOf.tr} "
                          "${controller.totalItemsToSync}"
                      ),
                      progressColor: AppColor.bondiBlue,
                    )
                  ): buildSyncPlaylistsButton(context, controller)
                ) : const SizedBox.shrink(),
                Obx(()=> controller.itemName.isNotEmpty
                    ? Text(controller.currentItemlist.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ) : const SizedBox.shrink()),
                Obx(()=> controller.itemName.isNotEmpty
                    ? Text(controller.itemName.value,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ) : const SizedBox.shrink()),
              ],
            )
        ),
      ),
    );
  }
}
