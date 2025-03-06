import 'package:flutter/material.dart';
import 'db_helper.dart';

class CardScreen extends StatefulWidget {
  final int folderId;
  final String folderName;

  const CardScreen(
      {super.key, required this.folderId, required this.folderName});

  @override
  _CardScreenState createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  List<Map<String, dynamic>> _cards = [];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final data = await DatabaseHelper.instance.getCards(widget.folderId);
    setState(() {
      _cards = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.folderName)),
      body: ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: _cards.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: _cards[index]['image_url'] != null &&
                      _cards[index]['image_url'].isNotEmpty
                  ? Image.network(_cards[index]['image_url'])
                  : Icon(Icons.image_not_supported),
              title: Text(_cards[index]['name']),
              subtitle: Text(_cards[index]['suit']),
            ),
          );
        },
      ),
    );
  }
}
