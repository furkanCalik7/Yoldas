import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  final List<String> items;
  final String? selectedValue;
  final Function(String) onChanged;
  final String hintText;

  const CustomDropdown({
    Key? key,
    required this.items,
    required this.onChanged,
    this.hintText = 'Seçiniz',
    this.selectedValue,
  }) : super(key: key);

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.selectedValue;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 10),
      ),
      value: selectedValue,
      hint: Text(widget.hintText),
      onChanged: (newValue) {
        setState(() {
          selectedValue = newValue!;
          widget.onChanged(newValue);
        });
      },
      items: widget.items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
  }
}