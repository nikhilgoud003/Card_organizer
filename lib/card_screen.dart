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
  bool _isCardLimitReached = false;
  bool _hasSufficientCards = false;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final data = await DatabaseHelper.instance.getCards(widget.folderId);
    setState(() {
      _cards = data;
      _isCardLimitReached = _cards.length >= 6;
      _hasSufficientCards = _cards.length >= 3;
    });
  }

  Future<void> _showErrorDialog(String message) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Warning"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _checkCardLimits() {
    if (!_hasSufficientCards) {
      _showErrorDialog("You need at least 3 cards in this folder.");
    }
  }

  Future<void> _addCard() async {
    if (_isCardLimitReached) {
      await _showErrorDialog("This folder can only hold 6 cards.");
      return;
    }

    TextEditingController nameController = TextEditingController();
    TextEditingController suitController = TextEditingController();
    TextEditingController imageUrlController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add New Card"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameController,
                  decoration: InputDecoration(hintText: "Enter card name")),
              TextField(
                  controller: suitController,
                  decoration: InputDecoration(hintText: "Enter card suit")),
              TextField(
                  controller: imageUrlController,
                  decoration: InputDecoration(hintText: "Enter image URL")),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    suitController.text.isNotEmpty) {
                  await DatabaseHelper.instance.addCard(
                    nameController.text,
                    suitController.text,
                    imageUrlController.text,
                    widget.folderId,
                  );
                  _loadCards();
                }
                Navigator.of(context).pop();
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateCard(int id, String currentName, String currentSuit,
      String currentImageUrl) async {
    TextEditingController nameController =
        TextEditingController(text: currentName);
    TextEditingController suitController =
        TextEditingController(text: currentSuit);
    TextEditingController imageUrlController =
        TextEditingController(text: currentImageUrl);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Update Card"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameController,
                  decoration: InputDecoration(hintText: "Enter card name")),
              TextField(
                  controller: suitController,
                  decoration: InputDecoration(hintText: "Enter card suit")),
              TextField(
                  controller: imageUrlController,
                  decoration: InputDecoration(hintText: "Enter image URL")),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await DatabaseHelper.instance.updateCard(
                  id,
                  nameController.text,
                  suitController.text,
                  imageUrlController.text,
                  widget.folderId,
                );
                _loadCards();
                Navigator.of(context).pop();
              },
              child: Text("Update"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCard(int id) async {
    if (_cards.length <= 3) {
      await _showErrorDialog("You need at least 3 cards in this folder.");
      return;
    }

    await DatabaseHelper.instance.deleteCard(id);
    _loadCards();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkCardLimits();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folderName),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                "${_cards.length}/6 cards",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _updateCard(
                      _cards[index]['id'],
                      _cards[index]['name'],
                      _cards[index]['suit'],
                      _cards[index]['image_url'] ?? '',
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteCard(_cards[index]['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCard,
        backgroundColor: _isCardLimitReached ? Colors.grey : null,
        child: Icon(Icons.add),
      ),
    );
  }
}
