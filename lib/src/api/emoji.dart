import 'package:http/http.dart';
import 'package:mineral/api.dart';
import 'package:mineral/core.dart';
import 'package:mineral/src/api/managers/emoji_manager.dart';
import 'package:mineral/src/api/managers/member_manager.dart';
import 'package:mineral/src/api/managers/role_manager.dart';

class Emoji {
  Snowflake id;
  String label;
  List<Role> roles;
  GuildMember? creator;
  bool requireColons;
  bool managed;
  bool animated;
  bool available;
  EmojiManager manager;

  Emoji({
    required this.id,
    required this.label,
    required this.roles,
    required this.creator,
    required this.requireColons,
    required this.managed,
    required this.animated,
    required this.available,
    required this.manager,
  });

  /// Modifies the [label] of this.
  /// ```dart
  /// final Emoji? emoji = guild.emojis.cache.get('240561194958716924');
  /// if (emoji != null) {
  ///   await emoji.setLabel('New label');
  /// }
  /// ```
  Future<void> setLabel (String label) async {
    Http http = ioc.singleton(ioc.services.http);
    Response response = await http.patch(url: "/guilds/${manager.guildId}/emojis/$id", payload: { 'name': label });

    if (response.statusCode == 200) {
      this.label = label;
    }
  }

  /// Modifies the [roles] of this.
  /// ```dart
  /// final Emoji? emoji = guild.emojis.cache.get('240561194958716924');
  /// final Role? role = guild.roles.cache.get('240561194958716924');
  ///
  /// if (role != null && emoji != null) {
  ///   await emoji.setRoles([role.id]);
  /// }
  /// ```
  Future<void> setRoles (List<Snowflake> roles) async {
    Http http = ioc.singleton(ioc.services.http);
    Response response = await http.patch(url: "/guilds/${manager.guildId}/emojis/$id", payload: { 'roles': roles });

    if (response.statusCode == 200) {
      List<Role> _roles = [];
      for (Snowflake id in roles) {
        Role? role = manager.guild?.roles.cache.get(id);
        if (role != null) {
          _roles.add(role);
        }
      }

      this.roles = _roles;
    }
  }

  /// Removes the current this from the [EmojiManager]'s cache
  /// ```dart
  /// final Emoji? emoji = guild.emojis.cache.get('240561194958716924');
  /// if (emoji != null) {
  ///   await emoji.delete();
  /// }
  /// ```
  /// You can specify a reason for this action
  /// ```dart
  /// await emoji.delete(reason: 'I will destroy this..');
  /// ```
  Future<void> delete () async {
    Http http = ioc.singleton(ioc.services.http);
    Response response = await http.destroy(url: "/guilds/${manager.guildId}/emojis/$id");

    if (response.statusCode == 200) {
      manager.cache.remove(id);
    }
  }

  factory Emoji.from({ required MemberManager memberManager, required RoleManager roleManager, required EmojiManager emojiManager, required dynamic payload }) {
    List<Role> roles = [];
    for (dynamic id in payload['roles']) {
      Role? role = roleManager.cache.get(id);
      if (role != null) {
        roles.add(role);
      }
    }

    return Emoji(
      id: payload['id'],
      label: payload['name'],
      roles: roles,
      creator: payload['user'] != null ? memberManager.cache.get(payload['user']['id']) : null,
      requireColons: payload['require_colons'] ?? false,
      managed: payload['managed'] ?? false,
      animated: payload['animated'] ?? false,
      available: payload['available'] ?? false,
      manager: emojiManager
    );
  }
}
