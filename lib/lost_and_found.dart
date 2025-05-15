import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart'; // Add this package in pubspec.yaml

class LostAndFoundPage extends StatefulWidget {
  const LostAndFoundPage({super.key});

  @override
  _LostAndFoundPageState createState() => _LostAndFoundPageState();
}

class _LostAndFoundPageState extends State<LostAndFoundPage> {
  List<Map<String, dynamic>> items = [
    {
      'title': 'Black Wallet',
      'description': 'Black wallet with ID card',
      'date': DateTime(2025, 4, 27),
      'image': 'images/wallet.jpg',
      'contact': {'name': 'John Doe', 'phone': '123-456-7890', 'email': 'johndoe@example.com'},
      'type': 'lost',
      'isAsset': true,
    },
    {
      'title': 'Vehicle Key',
      'description': 'A splendor bike key',
      'date': DateTime(2025, 4, 29),
      'image': 'images/key.webp',
      'contact': {'name': 'Jane Smith', 'phone': '987-654-3210', 'email': 'janesmith@example.com'},
      'type': 'lost',
      'isAsset': true,
    },
    {
      'title': 'Headphones',
      'description': 'A Sony Headphone (black)',
      'date': DateTime(2025, 4, 31),
      'image': 'images/headphones.webp',
      'contact': {'name': 'Bob Lee', 'phone': '555-123-4567', 'email': 'boblee@example.com'},
      'type': 'lost',
      'isAsset': true,
    },
  ];

  String filterType = 'lost'; // Default filter for "Lost Items"
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredItems = items
        .where((item) =>
    item['type'] == filterType &&
        (searchController.text.isEmpty ||
            item['title']
                .toLowerCase()
                .contains(searchController.text.toLowerCase())))
        .toList()
      ..sort((a, b) => b['date'].compareTo(a['date'])); // Sort by most recent

    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          color: Colors.blue,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Lost and Found'),
          backgroundColor: Colors.blue,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'Search item...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7.0),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      filterType = 'lost';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: filterType == 'lost' ? Colors.purple : Colors.black,
                  ),
                  child: Text('Lost Items'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      filterType = 'found';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: filterType == 'found' ? Colors.purple : Colors.black,
                  ),
                  child: Text('Found Items'),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return Card(
                    color: Colors.grey[900],
                    margin: EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'],
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white),
                          ),
                          SizedBox(height: 5),
                          Text(item['description'],
                              style: TextStyle(color: Colors.white70)),
                          SizedBox(height: 5),
                          Text(
                            '${item['date'].toLocal()}'.split(' ')[0],
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  _viewImage(context, item['image'], item['isAsset'] ?? false);
                                },
                                icon: Icon(Icons.image),
                                label: Text('View Image'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  _viewContact(context, item['contact']);
                                },
                                icon: Icon(Icons.contact_page),
                                label: Text('Contact'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddItemDialog(context),
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  void _viewImage(BuildContext context, String imagePath, bool isAsset) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: isAsset
              ? Image.asset(imagePath)
              : Image.file(
            // ignore: prefer_relative_imports
            File(imagePath),
            errorBuilder: (ctx, error, stack) => Text("Image not found"),
          ),
        );
      },
    );
  }

  void _viewContact(BuildContext context, Map<String, String> contact) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Contact Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Name: ${contact['name']}'),
              Text('Phone: ${contact['phone']}'),
              Text('Email: ${contact['email']}'),
            ],
          ),
        );
      },
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final contactNameController = TextEditingController();
    final contactPhoneController = TextEditingController();
    final contactEmailController = TextEditingController();
    String type = 'lost';
    String? selectedImagePath;
    bool isAsset = false;

    setState(() {}); // To trigger rebuild if needed

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text('Add Item'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: type,
                    items: [
                      DropdownMenuItem(value: 'lost', child: Text('Lost')),
                      DropdownMenuItem(value: 'found', child: Text('Found')),
                    ],
                    onChanged: (val) {
                      setStateDialog(() {
                        type = val ?? 'lost';
                      });
                    },
                    decoration: InputDecoration(labelText: 'Category'),
                  ),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(labelText: 'Title'),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                  ),
                  TextField(
                    controller: contactNameController,
                    decoration: InputDecoration(labelText: 'Contact Name'),
                  ),
                  TextField(
                    controller: contactPhoneController,
                    decoration: InputDecoration(labelText: 'Contact Phone'),
                  ),
                  TextField(
                    controller: contactEmailController,
                    decoration: InputDecoration(labelText: 'Contact Email'),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final typeGroup = XTypeGroup(
                            label: 'images',
                            extensions: ['jpg', 'jpeg', 'png', 'webp'],
                          );
                          final picked = await openFile(acceptedTypeGroups: [typeGroup]);
                          if (picked != null) {
                            setStateDialog(() {
                              selectedImagePath = picked.path;
                              isAsset = false;
                            });
                          }
                        },
                        icon: Icon(Icons.image),
                        label: Text('Upload Image'),
                      ),
                      SizedBox(width: 8),
                      selectedImagePath != null
                          ? Flexible(
                        child: Text(
                          selectedImagePath!.split('/').last,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12),
                        ),
                      )
                          : SizedBox(),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.isEmpty ||
                      descriptionController.text.isEmpty ||
                      contactNameController.text.isEmpty ||
                      contactPhoneController.text.isEmpty ||
                      contactEmailController.text.isEmpty ||
                      selectedImagePath == null) {
                    _showWarningDialog(context, 'All fields and an image are mandatory!');
                    return;
                  }

                  setState(() {
                    items.add({
                      'title': titleController.text,
                      'description': descriptionController.text,
                      'date': DateTime.now(),
                      'image': selectedImagePath,
                      'contact': {
                        'name': contactNameController.text,
                        'phone': contactPhoneController.text,
                        'email': contactEmailController.text,
                      },
                      'type': type,
                      'isAsset': isAsset,
                    });
                  });

                  Navigator.of(context).pop();
                  _showConfirmationDialog(context, 'Lost/Found request sent successfully!');
                },
                child: Text('Submit'),
              ),
            ],
          );
        });
      },
    );
  }

  void _showWarningDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Warning'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}