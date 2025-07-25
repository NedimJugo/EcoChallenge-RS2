import 'package:flutter/material.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int pageSize;
  final Function(int) onPageChanged;
  final Function(int) onPageSizeChanged;

  const PaginationWidget({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.pageSize,
    required this.onPageChanged,
    required this.onPageSizeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Text(
            '${(currentPage * pageSize) + 1}-${((currentPage + 1) * pageSize).clamp(0, totalItems)} of $totalItems',
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(width: 16),
          Text('Rows per page:', style: TextStyle(color: Colors.grey[600])),
          SizedBox(width: 8),
          DropdownButton<int>(
            value: pageSize,
            items: [10, 20, 50, 100].map((size) => DropdownMenuItem(
              value: size,
              child: Text(size.toString()),
            )).toList(),
            onChanged: (value) {
              if (value != null) {
                onPageSizeChanged(value);
              }
            },
          ),
          Spacer(),
          IconButton(
            onPressed: currentPage > 0 ? () => onPageChanged(0) : null,
            icon: Icon(Icons.first_page),
          ),
          IconButton(
            onPressed: currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
            icon: Icon(Icons.chevron_left),
          ),
          Text('${currentPage + 1} of $totalPages'),
          IconButton(
            onPressed: currentPage < totalPages - 1 ? () => onPageChanged(currentPage + 1) : null,
            icon: Icon(Icons.chevron_right),
          ),
          IconButton(
            onPressed: currentPage < totalPages - 1 ? () => onPageChanged(totalPages - 1) : null,
            icon: Icon(Icons.last_page),
          ),
        ],
      ),
    );
  }
}
