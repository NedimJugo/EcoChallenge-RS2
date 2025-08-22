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
  
  List<GalleryShowcaseResponse> _originalGalleryItems = []; // Store original items
  List<GalleryShowcaseResponse> _galleryItems = [];
  Map<int, GalleryReactionResponse?> _userReactions = {};
  Set<int> _processingReactions = {};
  bool _isLoading = true;
  String? _error;
  bool _showLikedOnly = false;
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _selectedFilter;

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
      
      var searchFilter = GalleryShowcaseSearchObject(
        isApproved: true,
        pageSize: 50,
      );

      SearchResult<GalleryShowcaseResponse> result = 
          await _galleryProvider.get(filter: searchFilter.toJson());
      
      _originalGalleryItems = result.items ?? [];
      _galleryItems = List.from(_originalGalleryItems);

      if (_authProvider.currentUserId != null) {
        await _loadUserReactions();
      }

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
      
      for (var item in _originalGalleryItems) {
        var reactionSearch = GalleryReactionSearchObject(
          userId: _authProvider.currentUserId,
          galleryShowcaseId: item.id,
          pageSize: 1,
        );

        var reactionResult = await _reactionProvider.get(filter: reactionSearch.toJson());
        
        if (reactionResult.items != null && reactionResult.items!.isNotEmpty) {
          _userReactions[item.id] = reactionResult.items!.first;
        } else {
          _userReactions[item.id] = null;
        }
      }
    } catch (e) {
      print('Error loading user reactions: $e');
    }
  }

  void _applyFilters() {
    List<GalleryShowcaseResponse> filteredItems = List.from(_originalGalleryItems);

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

    // Apply additional filters
    if (_selectedFilter == 'Featured') {
      filteredItems = filteredItems.where((item) => item.isFeatured).toList();
    } else if (_selectedFilter == 'Recent') {
      filteredItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    setState(() {
      _galleryItems = filteredItems;
    });
  }

  void _clearFilters() {
    setState(() {
      _showLikedOnly = false;
      _fromDate = null;
      _toDate = null;
      _selectedFilter = null;
      _galleryItems = List.from(_originalGalleryItems);
    });
  }

  Future<void> _handleReaction(GalleryShowcaseResponse item, ReactionType reactionType) async {
    if (_authProvider.currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please login to react to posts')),
      );
      return;
    }

    if (_processingReactions.contains(item.id)) {
      return;
    }

    var existingReaction = _userReactions[item.id];

    setState(() {
      _processingReactions.add(item.id);
    });

    try {
      if (existingReaction == null) {
        var insertRequest = GalleryReactionInsertRequest(
          galleryShowcaseId: item.id,
          userId: _authProvider.currentUserId!,
          reactionType: reactionType,
        );

        var newReaction = await _reactionProvider.addReaction(insertRequest);
        setState(() {
          _userReactions[item.id] = newReaction;
          _updateItemCounts(item.id, null, reactionType);
        });

      } else if (existingReaction.reactionType == reactionType) {
        bool deleteSuccess = await _reactionProvider.delete(existingReaction.id);
        if (deleteSuccess) {
          setState(() {
            _userReactions[item.id] = null;
            _updateItemCounts(item.id, reactionType, null);
          });
        }

      } else {
        var updateRequest = GalleryReactionUpdateRequest(
          id: existingReaction.id,
          reactionType: reactionType,
        );

        var updatedReaction = await _reactionProvider.updateReaction(updateRequest);
        setState(() {
          _userReactions[item.id] = updatedReaction;
          _updateItemCounts(item.id, existingReaction.reactionType, reactionType);
        });
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _processingReactions.remove(item.id);
      });
    }
  }

  void _updateItemCounts(int itemId, ReactionType? oldType, ReactionType? newType) {
    int itemIndex = _originalGalleryItems.indexWhere((g) => g.id == itemId);
    if (itemIndex == -1) return;

    var currentItem = _originalGalleryItems[itemIndex];
    int newLikesCount = currentItem.likesCount;
    int newDislikesCount = currentItem.dislikesCount;

    // Remove old reaction count
    if (oldType == ReactionType.like) {
      newLikesCount = (newLikesCount > 0) ? newLikesCount - 1 : 0;
    } else if (oldType == ReactionType.dislike) {
      newDislikesCount = (newDislikesCount > 0) ? newDislikesCount - 1 : 0;
    }

    // Add new reaction count
    if (newType == ReactionType.like) {
      newLikesCount++;
    } else if (newType == ReactionType.dislike) {
      newDislikesCount++;
    }

    // Update original item
    _originalGalleryItems[itemIndex] = GalleryShowcaseResponse(
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

    // Apply filters again to update displayed items
    _applyFilters();
  }

  void _showImageDialog(GalleryShowcaseResponse item) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.all(16),
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                    Expanded(
                      child: PageView(
                        children: [
                          _buildImageWithLabel(item.beforeImageUrl, 'BEFORE'),
                          _buildImageWithLabel(item.afterImageUrl, 'AFTER'),
                        ],
                      ),
                    ),
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

  Widget _buildImageWithLabel(String imageUrl, String label) {
    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            child: Text(
              label,
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
                imageUrl,
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
        currentIndex: 1,
      ),
    );
  }

  Widget _buildFilterSection() {
    bool hasActiveFilters = _showLikedOnly || _fromDate != null || _toDate != null || _selectedFilter != null;
    
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter by',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (hasActiveFilters)
                TextButton(
                  onPressed: _clearFilters,
                  child: Text(
                    'Clear Filters',
                    style: TextStyle(
                      color: Color(0xFFD4A574),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedFilter,
                  decoration: InputDecoration(
                    labelText: 'Filter',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: ['All', 'Featured', 'Recent'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value == 'All' ? null : value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value;
                    });
                    _applyFilters();
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _fromDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _fromDate = date;
                      });
                      _applyFilters();
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'From',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _fromDate != null 
                            ? '${_fromDate!.day}/${_fromDate!.month}/${_fromDate!.year}'
                            : 'Select date',
                          style: TextStyle(fontSize: 14),
                        ),
                        Icon(Icons.calendar_today, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _toDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _toDate = date;
                      });
                      _applyFilters();
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'To',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _toDate != null 
                            ? '${_toDate!.day}/${_toDate!.month}/${_toDate!.year}'
                            : 'Select date',
                          style: TextStyle(fontSize: 14),
                        ),
                        Icon(Icons.calendar_today, size: 20),
                      ],
                    ),
                  ),
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
              Text('Show liked only'),
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
                foregroundColor: Colors.white,
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
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _clearFilters,
              child: Text('Clear Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD4A574),
                foregroundColor: Colors.white,
              ),
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
                        onTap: isProcessing ? null : () => _handleReaction(item, ReactionType.like),
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
                        onTap: isProcessing ? null : () => _handleReaction(item, ReactionType.dislike),
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