import 'package:flutter/material.dart';

class UserDropDownField extends StatelessWidget {
  final String label;
  final List<String> selectionList;
  final String selectedItem;
  final Function setSelectedItem;

  const UserDropDownField(
      {super.key,
      required this.label,
      required this.selectedItem,
      required this.selectionList,
      required this.setSelectedItem});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
            ),
            DropdownButton<String>(
              borderRadius: BorderRadius.circular(5.5),
              value: selectedItem,
              items: selectionList
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 20),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (String? value) => setSelectedItem(label, value),
            ),
          ],
        ),
      ),
    );
  }
}
