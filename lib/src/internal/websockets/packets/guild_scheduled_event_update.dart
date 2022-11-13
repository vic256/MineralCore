import 'package:mineral/api.dart';
import 'package:mineral/core.dart';
import 'package:mineral/event.dart';
import 'package:mineral/src/internal/managers/event_manager.dart';
import 'package:mineral/src/internal/websockets/websocket_packet.dart';
import 'package:mineral/src/internal/websockets/websocket_response.dart';

class GuildScheduledEventUpdate implements WebsocketPacket {
  @override
  Future<void> handle(WebsocketResponse websocketResponse) async {
    EventManager eventManager = ioc.singleton(Service.event);
    MineralClient client = ioc.singleton(Service.client);

    dynamic payload = websocketResponse.payload;

    Guild? guild = client.guilds.cache.get(payload['guild_id']);
    if (guild != null) {
      GuildScheduledEvent? before = guild.scheduledEvents.cache.get(payload['id']);
      GuildScheduledEvent after = GuildScheduledEvent.from(channelManager: guild.channels, memberManager: guild.members, payload: payload);
      guild.scheduledEvents.cache.set(after.id, after);

      eventManager.controller.add(GuildScheduledEventUpdateEvent(before, after));
    }
  }
}
