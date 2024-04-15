import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/colors.dart';

class CustomListView extends StatefulWidget {
  final List<String> list;
  final Function(int) onDelete;

  const CustomListView({
    Key? key,
    required this.list,
    required this.onDelete,
  }) : super(key: key);

  @override
  _CustomListViewState createState() => _CustomListViewState();
}

class _CustomListViewState extends State<CustomListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.list.length,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: ListTile(
            title: Text(
              widget.list[index],
              style: TextStyle(color: textColorLight),
            ),
            trailing: IconButton(
              icon: Icon(Icons.cancel, color: Colors.white),
              onPressed: () {
                setState(() {
                  widget.onDelete(index);
                });
              },
            ),
          ),
        );
      },
    );
  }
}
