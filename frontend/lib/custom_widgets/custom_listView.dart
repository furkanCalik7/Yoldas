import 'package:flutter/material.dart';

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
          margin: EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            title: Text(widget.list[index]),
            trailing: IconButton(
              icon: Icon(Icons.delete),
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
