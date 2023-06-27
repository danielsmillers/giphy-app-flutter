import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';

import 'giphy_service.dart';

void main() => runApp(const GiphyApp());

class GiphyApp extends StatefulWidget {
  const GiphyApp({Key? key}) : super(key: key);

  @override
  State<GiphyApp> createState() => _GiphyAppState();
}

class _GiphyAppState extends State<GiphyApp> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _fetchedGifs = [];
  int _offset = 0;
  int _limit = 20;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _searchGifs(String query) {
    // Clear the existing fetched GIFs list and reset the offset
    setState(() {
      _fetchedGifs = [];
      _offset = 0;
    });
    _loadMoreGifs(query);
  }

  Future<void> _loadMoreGifs(String query) async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
      try {
        // Fetch additional GIFs from the API call
        final gifs = await GiphyService.searchGifs(query,
            offset: _offset, limit: _limit);
        setState(() {
          // Add the fetched GIFs to the list and update the offset
          _fetchedGifs.addAll(gifs);
          _offset += _limit;
          _isLoading = false;
        });
      } catch (e) {
        // Error handler for GIF fetching
        print('Error: $e');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _scrollListener() {
    // Check if the scroll position has reached the bottom
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Load more GIFs when reaching the bottom
      _loadMoreGifs(_searchController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: TextField(
            controller: _searchController,
            onChanged: _searchGifs,
            decoration: const InputDecoration(
              hintText: 'Search GIFs',
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            color: Colors.white,
            child: GridView.builder(
              // Create a grid to show GIFs in two columns
              controller: _scrollController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: _fetchedGifs.length + 1,
              itemBuilder: (context, index) {
                if (index == _fetchedGifs.length) {
                  return _buildLoadingIndicator();
                } else {
                  // Adding some reshaping for the corresponding GIF
                  return _buildGifItem(_fetchedGifs[index]);
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGifItem(String gifUrl) {
    // Resizes GIF item and adds a rounded border
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: CachedNetworkImage(
        imageUrl: gifUrl,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    // Show a loading indicator widget if more GIFs are being loaded
    return _isLoading
        ? const Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          )
        : Container();
  }
}
