import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widgets/widgets.dart';
import '../../select_contacts/controller/select_contact_controller.dart';

final selectedGroupContacts = StateProvider<List<Contact>>((ref) => []);

class SelectContactsGroup extends ConsumerStatefulWidget {
  const SelectContactsGroup({super.key});

  @override
  ConsumerState<SelectContactsGroup> createState() =>
      _SelectContactsGroupState();
}

class _SelectContactsGroupState extends ConsumerState<SelectContactsGroup> {
  List<int> selectedContactIndex = [];

  void selectContact(
    int index,
    Contact contact,
  ) {
    if (selectedContactIndex.contains(index)) {
      selectedContactIndex.removeAt(index);
    } else {
      selectedContactIndex.add(index);
    }
    setState(() {
      ref
          // ignore: deprecated_member_use
          .read(selectedGroupContacts.state)
          .update((state) => [...state, contact]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(getContactProvider).when(
          data: (contactList) => Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: contactList.length,
              itemBuilder: (context, index) {
                final contact = contactList[index];

                return InkWell(
                  onTap: () => selectContact(
                    index,
                    contact,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(
                        contact.displayName,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      leading: selectedContactIndex.contains(index)
                          ? IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.done),
                            )
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
          error: (err, trace) => ErrorScreen(
            error: err.toString(),
          ),
          loading: () => const Loader(),
        );
  }
}
