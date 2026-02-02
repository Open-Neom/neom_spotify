import 'package:flutter/material.dart';
import 'package:sint/sint.dart';
import 'package:neom_commons/ui/theme/app_color.dart';
import 'package:neom_commons/ui/theme/app_theme.dart';
import 'package:neom_commons/ui/widgets/appbar_child.dart';
import 'package:neom_commons/utils/constants/app_constants.dart';
import 'package:neom_commons/utils/constants/app_page_id_constants.dart';
import 'package:neom_commons/utils/constants/translations/common_translation_constants.dart';
import 'package:neom_core/utils/constants/app_route_constants.dart';
import 'package:neom_core/utils/enums/media_search_type.dart';

import '../neom_spotify_controller.dart';
import '../widgets/neom_spotify_widgets.dart';

class PlaylistItemsPage extends StatelessWidget {

  const PlaylistItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SintBuilder<NeomSpotifyController>(
      id: AppPageIdConstants.playlistSong,
      builder: (controller) => Scaffold(
        appBar: AppBarChild(title: controller.spotifyItemlist.name.length > AppConstants.maxItemlistNameLength
            ? "${controller.spotifyItemlist.name.substring(0, AppConstants.maxItemlistNameLength)}..."
            : controller.spotifyItemlist.name),
        backgroundColor: AppColor.main50,
        body: Container(
          decoration: AppTheme.appBoxDecoration,
          child: buildSyncPlaylistList(context, controller)
        ),
        floatingActionButton: controller.spotifyItemlist.appMediaItems?.isEmpty ?? true ?
          FloatingActionButton(
          tooltip: CommonTranslationConstants.addItem.tr,
          onPressed: ()=>{
            Sint.toNamed(AppRouteConstants.spotifyPlaylists,
                arguments: [MediaSearchType.song, controller.spotifyItemlist])
          },
          child: const Icon(Icons.navigate_next),
        ) : SizedBox.shrink(),
      ),
    );
  }
}
