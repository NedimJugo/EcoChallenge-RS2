import 'package:ecochallenge_desktop/layouts/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/request.dart';
import '../models/request_participation.dart';
import '../providers/request_provider.dart';
import '../providers/request_participation_provider.dart';
import '../widgets/request_details_widget.dart';
import '../widgets/payment_approval_widget.dart';

class AdminRequestManagementPage extends StatefulWidget {
  final VoidCallback? onBalanceChanged; 
   const AdminRequestManagementPage({
    Key? key,
    this.onBalanceChanged,
  }) : super(key: key);
  
  @override
  _AdminRequestManagementPageState createState() => _AdminRequestManagementPageState();
}

class _AdminRequestManagementPageState extends State<AdminRequestManagementPage> {
  int _currentView = 0; // 0 = dashboard, 1 = request details, 2 = payment approval
  RequestResponse? _selectedRequest;
  RequestParticipationResponse? _selectedPayment;
  
  int _requestPage = 0;
  int _paymentPage = 0;
  final int _pageSize = 5;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final requestProvider = Provider.of<RequestProvider>(context, listen: false);
    final participationProvider = Provider.of<RequestParticipationProvider>(context, listen: false);
    
    final requestSearchObject = RequestSearchObject(
      page: _requestPage,
      pageSize: _pageSize,
      status: 1,
    );
    requestProvider.get(filter: requestSearchObject.toJson());
    
    final participationSearchObject = RequestParticipationSearchObject(
      page: _paymentPage,
      pageSize: _pageSize,
      status: ParticipationStatus.pending,
    );
    participationProvider.get(filter: participationSearchObject.toJson());
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height - 140;
    
    switch (_currentView) {
      case 1:
        return RequestDetailsWidget(
          request: _selectedRequest!,
          onBack: () {
            setState(() => _currentView = 0);
            _loadData();
          },
          availableHeight: screenHeight,
           onBalanceChanged: widget.onBalanceChanged,
        );
      case 2:
        return PaymentApprovalWidget(
          payment: _selectedPayment!,
          onBack: () {
            setState(() => _currentView = 0);
            _loadData();
          },
          availableHeight: screenHeight,
        );
      default:
        return _buildDashboardView(screenHeight);
    }
  }

  Widget _buildDashboardView(double availableHeight) {
    return Container(
      height: availableHeight,
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          // Requests Section
          Expanded(
            child: Container(
              margin: EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: forestGreen[50],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: forestGreen,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.assignment, color: Colors.white, size: 20),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Approve Or Deny Request',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: forestGreen[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Consumer<RequestProvider>(
                      builder: (context, provider, child) {
                        final requestSearchObject = RequestSearchObject(
                          page: _requestPage,
                          pageSize: _pageSize,
                          status: 1,
                        );
                        
                        return FutureBuilder(
                          future: provider.get(filter: requestSearchObject.toJson()),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(color: Colors.blue[600]),
                                    SizedBox(height: 16),
                                    Text('Loading requests...', style: TextStyle(color: Colors.grey[600])),
                                  ],
                                ),
                              );
                            }
                            
                            final result = snapshot.data;
                            if (result == null || result.items?.isEmpty == true) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                                    SizedBox(height: 16),
                                    Text(
                                      'No pending requests',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'All requests have been processed',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            
                            return Column(
                              children: [
                                Expanded(child: _buildRequestTable(result.items ?? [])),
                                if ((result.totalCount ?? 0) > _pageSize)
                                  _buildPagination(result.totalCount ?? 0, _requestPage, true),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Payments Section
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green[600],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.payment, color: Colors.white, size: 20),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Approve Or Deny Payment',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.green[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Consumer<RequestParticipationProvider>(
                      builder: (context, provider, child) {
                        final participationSearchObject = RequestParticipationSearchObject(
                          page: _paymentPage,
                          pageSize: _pageSize,
                          status: ParticipationStatus.pending,
                        );
                        
                        return FutureBuilder(
                          future: provider.get(filter: participationSearchObject.toJson()),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(color: Colors.green[600]),
                                    SizedBox(height: 16),
                                    Text('Loading payments...', style: TextStyle(color: Colors.grey[600])),
                                  ],
                                ),
                              );
                            }
                            
                            final result = snapshot.data;
                            if (result == null || result.items?.isEmpty == true) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey[400]),
                                    SizedBox(height: 16),
                                    Text(
                                      'No pending payments',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'All payments have been processed',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            
                            return Column(
                              children: [
                                Expanded(child: _buildPaymentTable(result.items ?? [])),
                                if ((result.totalCount ?? 0) > _pageSize)
                                  _buildPagination(result.totalCount ?? 0, _paymentPage, false),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestTable(List<RequestResponse> requests) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[100]!),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.05),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: () => _openRequestDetails(request),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: forestGreen[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.assignment, color: forestGreen[600], size: 24),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.title ?? 'Untitled Request',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.person_outline, size: 14, color: Colors.grey[600]),
                            SizedBox(width: 4),
                            Text(
                              'User ${request.userId}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            SizedBox(width: 12),
                            Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[600]),
                            SizedBox(width: 4),
                            Text(
                              _formatDate(request.createdAt),
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Pending Review',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange[800],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentTable(List<RequestParticipationResponse> payments) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green[100]!),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.05),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: () => _openPaymentApproval(payment),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.payment, color: Colors.green[600], size: 24),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment #${payment.id}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.person_outline, size: 14, color: Colors.grey[600]),
                            SizedBox(width: 4),
                            Text(
                              'User ${payment.userId}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            SizedBox(width: 12),
                            Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[600]),
                            SizedBox(width: 4),
                            Text(
                              _formatDate(payment.submittedAt),
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Pending Approval',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange[800],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPagination(int totalCount, int currentPage, bool isRequest) {
    final totalPages = (totalCount / _pageSize).ceil();
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < totalPages && i < 5; i++)
            GestureDetector(
              onTap: () {
                setState(() {
                  if (isRequest) {
                    _requestPage = i;
                  } else {
                    _paymentPage = i;
                  }
                });
                _loadData();
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: currentPage == i 
                      ? (isRequest ? forestGreen[600] : Colors.green[600])
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: currentPage == i 
                      ? null 
                      : Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    color: currentPage == i ? Colors.white : Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openRequestDetails(RequestResponse request) {
    setState(() {
      _selectedRequest = request;
      _currentView = 1;
    });
  }

  void _openPaymentApproval(RequestParticipationResponse payment) {
    setState(() {
      _selectedPayment = payment;
      _currentView = 2;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}
