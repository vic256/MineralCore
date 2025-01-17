import 'package:mineral/core/api.dart';
import 'package:mineral/core/events.dart';
import 'package:mineral/framework.dart';
import 'package:mineral/src/internal/services/event_service.dart';
import 'package:mineral/src/internal/mixins/container.dart';
import 'package:mineral/src/internal/websockets/websocket_packet.dart';
import 'package:mineral/src/internal/websockets/websocket_response.dart';

class MemberJoinPacket with Container implements WebsocketPacket {
  @override
  Future<void> handle(WebsocketResponse websocketResponse) async {
    EventService eventService = container.use<EventService>();
    MineralClient client = container.use<MineralClient>();

    dynamic payload = websocketResponse.payload;

    Guild guild = client.guilds.cache.getOrFail(payload['guild_id']);

    User user = User.from(payload['user']);
    GuildMember member = GuildMember.from(
      user: user,
      roles: guild.roles,
      member: payload,
      guild: guild,
      voice: VoiceManager.empty(payload['deaf'], payload['mute'], user.id, guild.id)
    );

    guild.members.cache.putIfAbsent(member.user.id, () => member);
    eventService.controller.add(MemberJoinEvent(member));
  }
}
