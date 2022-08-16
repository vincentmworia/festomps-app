import 'package:flutter/material.dart';

class AdminSearch extends StatefulWidget {
  const AdminSearch({Key? key}) : super(key: key);

  @override
  State<AdminSearch> createState() => _AdminSearchState();
}

class _AdminSearchState extends State<AdminSearch> {

  late TextEditingController _searchController;
  @override
  void initState() {
    super.initState();
    _searchController=TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return    Padding(
      padding: const EdgeInsets.all(20.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: const BorderSide(
              width: 0.8,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(
              width: 0.8,
              color: Theme.of(context).primaryColor,
            ),
          ),
          hintText: 'Search Food or Restaurant',
          prefixIcon: GestureDetector(
            child: const Icon(Icons.search, size: 30.0),
            onTap: () {
              //todo search
            },
          ),
          suffixIcon: GestureDetector(
            child: const Icon(Icons.clear, size: 30.0),
            onTap: () {
              _searchController.clear();
            },
          ),
        ),
      ),
    );
  }
}
