import 'dart:convert';

import 'package:http/http.dart';
import 'package:mineral/core.dart';
import 'package:mineral/core/api.dart';
import 'package:mineral/framework.dart';
import 'package:mineral/src/api/managers/cache_manager.dart';
import 'package:mineral/src/api/sticker.dart';
import 'package:mineral/src/helper.dart';
import 'package:mineral/src/internal/mixins/container.dart';

class StickerManager extends CacheManager<Sticker> with Container, Console {
  late final Guild guild;

  Future<Sticker?> create ({ required String name, required String description, required String tags, required String filename }) async {
    if (guild.features.contains(GuildFeature.verified) || guild.features.contains(GuildFeature.partnered)) {
      Response response = await container.use<HttpService>().post(url: "/guilds/${guild.id}/stickers", payload: {
        'name': name,
        'description': description,
        'tags': tags,
        'file': Helper.getPicture(filename)
      });

      dynamic payload = jsonDecode(response.body);

      Sticker sticker = Sticker.from(payload);
      sticker.manager = this;

      cache.putIfAbsent(sticker.id, () => sticker);

      return sticker;
    }

    console.warn('cancelled ${guild.name} guild does not have the ${GuildFeature.verified} or ${GuildFeature.partnered} feature.');
    return null;
  }

  Future<Map<Snowflake, Sticker>> sync () async {
    cache.clear();

    Response response = await container.use<HttpService>().get(url: "/guilds/${guild.id}/stickers");
    dynamic payload = jsonDecode(response.body);

    for(dynamic element in payload) {
      Sticker sticker = Sticker.from(element);

      cache.putIfAbsent(sticker.id, () => sticker);
    }

    return cache;
  }
}
