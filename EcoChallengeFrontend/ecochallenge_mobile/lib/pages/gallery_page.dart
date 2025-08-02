import 'package:ecochallenge_mobile/widgets/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecochallenge_mobile/models/gallery_showcase.dart';
import 'package:ecochallenge_mobile/models/gallery_reaction.dart';
import 'package:ecochallenge_mobile/providers/gallery_showcase_provider.dart';
import 'package:ecochallenge_mobile/providers/gallery_reaction_provider.dart';
import 'package:ecochallenge_mobile/providers/auth_provider.dart';
import 'package:ecochallenge_mobile/pages/search_result.dart';

class GalleryPage extends StatefulWidget {
  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  late GalleryShowcaseProvider _galleryProvider;
  late GalleryReactionProvider _reactionProvider;
  late AuthProvider _authProvider;
  
  List<GalleryShowcaseResponse> _galleryItems = [];
  Map<int, GalleryReactionResponse?> _userReactions = {};
  Set<int> _processingReactions = {}; // Track which items are being processed
  bool _isLoading = true;
  String? _error;
  bool _showLikedOnly = false;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _galleryProvider = GalleryShowcaseProvider();
    _reactionProvider = GalleryReactionProvider();
    _loadGalleryData();
  }

  Future<void> _loadGalleryData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Create search filter
      var searchFilter = GalleryShowcaseSearchObject(
        isApproved: true,
        pageSize: 50,
      );

      // Load gallery items
      SearchResult<GalleryShowcaseResponse> result = 
          await _galleryProvider.get(filter: searchFilter.toJson());
      
      _galleryItems = result.items ?? [];

      // Load user reactions for each gallery item
      if (_authProvider.currentUserId != null) {
        await _loadUserReactions();
      }

      // Apply filters
      _applyFilters();

    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserReactions() async {
  if (_authProvider.currentUserId == null) return;

  try {
    _userReactions.clear();
    
    for (var item in _galleryItems) {
      print('Loading reaction for item ${item.id}');
      var reactionSearch = GalleryReactionSearchObject(
        userId: _authProvider.currentUserId,
        galleryShowcaseId: item.id,
        pageSize: 1,
      );

      var reactionResult = await _reactionProvider.get(filter: reactionSearch.toJson());
      
      if (reactionResult.items != null && reactionResult.items!.isNotEmpty) {
        print('Found reaction: ${reactionResult.items!.first.reactionType}');
        _userReactions[item.id] = reactionResult.items!.first;
      } else {
        print('No reaction found');
        _userReactions[item.id] = null;
      }
    }
  } catch (e) {
    print('Error loading user reactions: $e');
  }
}

  void _applyFilters() {
    List<GalleryShowcaseResponse> filteredItems = List.from(_galleryItems);

    // Filter by liked items
    if (_showLikedOnly && _authProvider.currentUserId != null) {
      filteredItems = filteredItems.where((item) {
        var reaction = _userReactions[item.id];
        return reaction != null && reaction.reactionType == ReactionType.like;
      }).toList();
    }

    // Filter by date range
    if (_fromDate != null) {
      filteredItems = filteredItems.where((item) => 
          item.createdAt.isAfter(_fromDate!) || 
          item.createdAt.isAtSameMomentAs(_fromDate!)).toList();
    }

    if (_toDate != null) {
      filteredItems = filteredItems.where((item) => 
          item.createdAt.isBefore(_toDate!.add(Duration(days: 1)))).toList();
    }

    setState(() {
      _galleryItems = filteredItems;
    });
  }

Future<void> _handleReaction(GalleryShowcaseResponse item, ReactionType reactionType) async {
  print('=== REACTION DEBUG START ===');
  print('Item ID: ${item.id}');
  print('Requested reaction type: $reactionType');
  
  if (_authProvider.currentUserId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please login to react to posts')),
    );
    return;
  }

  if (_processingReactions.contains(item.id)) {
    print('Reaction already in progress for item ${item.id}');
    return;
  }

  // Get current reaction state
  var existingReaction = _userReactions[item.id];
  print('Current existing reaction: ${existingReaction?.reactionType}');
  print('Current like count: ${item.likesCount}');
  print('Current dislike count: ${item.dislikesCount}');

  setState(() {
    _processingReactions.add(item.id);
  });

  try {
    if (existingReaction == null) {
      // Case 1: No existing reaction - create new one
      print('Creating new reaction: $reactionType');
      
      var insertRequest = GalleryReactionInsertRequest(
        galleryShowcaseId: item.id,
        userId: _authProvider.currentUserId!,
        reactionType: reactionType,
      );

      var newReaction = await _reactionProvider.addReaction(insertRequest);
      print('New reaction created successfully: ${newReaction.reactionType}');

      // Update local state
      setState(() {
        _userReactions[item.id] = newReaction;
        _updateItemCounts(item.id, null, reactionType);
      });

    } else if (existingReaction.reactionType == reactionType) {
      // Case 2: Clicking same reaction type - remove it (toggle off)
      print('Removing existing $reactionType reaction (toggle off)');
      
      bool deleteSuccess = await _reactionProvider.delete(existingReaction.id);
      if (deleteSuccess) {
        print('Reaction deleted successfully');
        
        // Update local state
        setState(() {
          _userReactions[item.id] = null;
          _updateItemCounts(item.id, reactionType, null);
        });
      }

    } else {
      // Case 3: Different reaction type - update existing reaction
      print('Updating reaction from ${existingReaction.reactionType} to $reactionType');
      
      var updateRequest = GalleryReactionUpdateRequest(
        id: existingReaction.id,
        reactionType: reactionType,
      );

      var updatedReaction = await _reactionProvider.updateReaction(updateRequest);
      print('Reaction updated successfully: ${updatedReaction.reactionType}');

      // Update local state
      setState(() {
        _userReactions[item.id] = updatedReaction;
        _updateItemCounts(item.id, existingReaction.reactionType, reactionType);
      });
    }

  } catch (e) {
    print('ERROR in handleReaction: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  } finally {
    setState(() {
      _processingReactions.remove(item.id);
    });
    print('=== REACTION DEBUG END ===');
  }
}

// Helper method to update counts in gallery items
void _updateItemCounts(int itemId, ReactionType? oldType, ReactionType? newType) {
  print('Updating counts for item $itemId: $oldType -> $newType');
  
  int itemIndex = _galleryItems.indexWhere((g) => g.id == itemId);
  if (itemIndex == -1) {
    print('ERROR: Item not found in gallery list');
    return;
  }

  var currentItem = _galleryItems[itemIndex];
  int newLikesCount = currentItem.likesCount;
  int newDislikesCount = currentItem.dislikesCount;

  print('Current counts - Likes: $newLikesCount, Dislikes: $newDislikesCount');

  // Remove old reaction count
  if (oldType == ReactionType.like) {
    newLikesCount = (newLikesCount > 0) ? newLikesCount - 1 : 0;
    print('Removed like, new count: $newLikesCount');
  } else if (oldType == ReactionType.dislike) {
    newDislikesCount = (newDislikesCount > 0) ? newDislikesCount - 1 : 0;
    print('Removed dislike, new count: $newDislikesCount');
  }

  // Add new reaction count
  if (newType == ReactionType.like) {
    newLikesCount++;
    print('Added like, new count: $newLikesCount');
  } else if (newType == ReactionType.dislike) {
    newDislikesCount++;
    print('Added dislike, new count: $newDislikesCount');
  }

  // Create updated item with new counts
  _galleryItems[itemIndex] = GalleryShowcaseResponse(
    id: currentItem.id,
    requestId: currentItem.requestId,
    eventId: currentItem.eventId,
    locationId: currentItem.locationId,
    createdByAdminId: currentItem.createdByAdminId,
    beforeImageUrl: currentItem.beforeImageUrl,
    afterImageUrl: currentItem.afterImageUrl,
    title: currentItem.title,
    description: currentItem.description,
    likesCount: newLikesCount,
    dislikesCount: newDislikesCount,
    isFeatured: currentItem.isFeatured,
    isApproved: currentItem.isApproved,
    isReported: currentItem.isReported,
    reportCount: currentItem.reportCount,
    createdAt: currentItem.createdAt,
  );

  print('Final counts - Likes: $newLikesCount, Dislikes: $newDislikesCount');
}

  // Image viewer dialog
  void _showImageDialog(GalleryShowcaseResponse item) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black,
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Stack(
              children: [
                // Image content
                Column(
                  children: [
                    // Title
                    if (item.title != null)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        child: Text(
                          item.title!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    // Images
                    Expanded(
                      child: PageView(
                        children: [
                          // Before image
                          Container(
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    'BEFORE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InteractiveViewer(
                                    child: Image.network(
                                      item.beforeImageUrl,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[800],
                                          child: Icon(
                                            Icons.image_not_supported,
                                            color: Colors.white,
                                            size: 64,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // After image
                          Container(
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    'AFTER',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InteractiveViewer(
                                    child: Image.network(
                                      item.afterImageUrl,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[800],
                                          child: Icon(
                                            Icons.image_not_supported,
                                            color: Colors.white,
                                            size: 64,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Swipe indicator
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Swipe to see before/after',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                // Close button
                Positioned(
                  top: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Gallery',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFFD4A574),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: _buildGalleryContent(),
          ),
        ],
      ),
      bottomNavigationBar: SharedBottomNavigation(
        currentIndex: 1, // Gallery is at index 1
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'All',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: ['All', 'Featured', 'Recent'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    // Implement filter logic
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'From',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _fromDate = date;
                      });
                      _loadGalleryData();
                    }
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'To',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _toDate = date;
                      });
                      _loadGalleryData();
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Checkbox(
                value: _showLikedOnly,
                onChanged: (value) {
                  setState(() {
                    _showLikedOnly = value ?? false;
                  });
                  _applyFilters();
                },
              ),
              Text('Liked'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryContent() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Color(0xFFD4A574),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Error loading gallery',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadGalleryData,
              child: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD4A574),
              ),
            ),
          ],
        ),
      );
    }

    if (_galleryItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No gallery items found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGalleryData,
      color: Color(0xFFD4A574),
      child: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemCount: _galleryItems.length,
        itemBuilder: (context, index) {
          return _buildGalleryItem(_galleryItems[index]);
        },
      ),
    );
  }

  Widget _buildGalleryItem(GalleryShowcaseResponse item) {
  var userReaction = _userReactions[item.id];
  bool hasLiked = userReaction?.reactionType == ReactionType.like;
  bool hasDisliked = userReaction?.reactionType == ReactionType.dislike;
  bool isProcessing = _processingReactions.contains(item.id);

  // Debug print for UI state
  print('UI DEBUG - Item ${item.id}:');
  print('  User reaction: ${userReaction?.reactionType}');
  print('  Has liked: $hasLiked');
  print('  Has disliked: $hasDisliked');
  print('  Like count: ${item.likesCount}');
  print('  Dislike count: ${item.dislikesCount}');

  return GestureDetector(
    onTap: () => _showImageDialog(item),
    child: Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Stack(
                children: [
                  // Before/After images side by side
                  Row(
                    children: [
                      Expanded(
                        child: Image.network(
                          item.beforeImageUrl,
                          fit: BoxFit.cover,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: Icon(Icons.image_not_supported),
                            );
                          },
                        ),
                      ),
                      Container(width: 1, color: Colors.white),
                      Expanded(
                        child: Image.network(
                          item.afterImageUrl,
                          fit: BoxFit.cover,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: Icon(Icons.image_not_supported),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  // Before/After labels
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Before',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'After',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  // Tap to view indicator
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        Icons.zoom_in,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.title != null)
                  Text(
                    item.title!,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Like button
                    GestureDetector(
                      onTap: isProcessing ? null : () {
                        print('LIKE BUTTON CLICKED for item ${item.id}');
                        _handleReaction(item, ReactionType.like);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: hasLiked ? Colors.green.withOpacity(0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: hasLiked ? Colors.green : Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: Opacity(
                          opacity: isProcessing ? 0.5 : 1.0,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                hasLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                                size: 16,
                                color: hasLiked ? Colors.green : Colors.grey[600],
                              ),
                              SizedBox(width: 4),
                              Text(
                                '${item.likesCount}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: hasLiked ? FontWeight.bold : FontWeight.normal,
                                  color: hasLiked ? Colors.green : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    // Dislike button
                    GestureDetector(
                      onTap: isProcessing ? null : () {
                        print('DISLIKE BUTTON CLICKED for item ${item.id}');
                        _handleReaction(item, ReactionType.dislike);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: hasDisliked ? Colors.red.withOpacity(0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: hasDisliked ? Colors.red : Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: Opacity(
                          opacity: isProcessing ? 0.5 : 1.0,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                hasDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
                                size: 16,
                                color: hasDisliked ? Colors.red : Colors.grey[600],
                              ),
                              SizedBox(width: 4),
                              Text(
                                '${item.dislikesCount}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: hasDisliked ? FontWeight.bold : FontWeight.normal,
                                  color: hasDisliked ? Colors.red : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

}