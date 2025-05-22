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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                borderRadius: BorderRadius.circular(12),
                value: selectedItem,
                selectedItemBuilder: (BuildContext context) {
                  return selectionList.map<Widget>((String item) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    );
                  }).toList();
                },
                items: selectionList.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (index < selectionList.length - 1)
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: Colors.grey[300],
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? value) => setSelectedItem(label, value),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
