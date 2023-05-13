import 'package:chatapp_uc/common/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';

import '../../../models/models.dart';

class StatusScreen extends StatefulWidget {
  static const String routeName = '/statusScreen';
  final Status status;
  const StatusScreen({
    super.key,
    required this.status,
  });

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  StoryController controller = StoryController();
  List<StoryItem> storyItem = [];

  @override
  void initState() {
    initStoryPageItems();
    super.initState();
  }

  void initStoryPageItems() {
    for (var i = 0; i < widget.status.photoUrl.length; i++) {
      storyItem.add(
        StoryItem.pageImage(
          url: widget.status.photoUrl[i],
          controller: controller,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: storyItem.isEmpty
          ? const Loader()
          : StoryView(
              onComplete: () {
                Navigator.pop(context);
              },
              storyItems: storyItem,
              controller: controller,
              onVerticalSwipeComplete: (p0) {
                if (p0 == Direction.down) {
                  Navigator.pop(context);
                }
              },
            ),
    );
  }
}
