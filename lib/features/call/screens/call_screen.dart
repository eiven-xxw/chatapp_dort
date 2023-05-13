import 'package:agora_uikit/agora_uikit.dart';
import 'package:chatapp_uc/config/agora/agora_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/call_model.dart';

class CallScreen extends ConsumerStatefulWidget {
  final String channelId;
  final CallModel call;
  final bool isGroupChat;

  const CallScreen({
    super.key,
    required this.channelId,
    required this.call,
    required this.isGroupChat,
  });

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  AgoraClient? client;

  @override
  void initState() {
    
    super.initState();

    client =AgoraConnectionData(appId: AgoraConfig.appId, channelName: widget.channelId,)
  }
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
