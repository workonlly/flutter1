import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'summary_service.dart';
import 'globals.dart' as globals;
import 'aptos_view.dart';

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SummaryViewPage();
  }
}

class SummaryViewPage extends StatefulWidget {
  const SummaryViewPage({super.key});

  @override
  State<SummaryViewPage> createState() => _SummaryViewPageState();
}

class _SummaryViewPageState extends State<SummaryViewPage> {
  bool _isLoading = false;
  Map<String, dynamic> _summaryData = {};
  final String _selectedDateRange = 'today';
  DateTime _selectedDate = DateTime.now();
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadTodaySummaries();
  }

  Future<void> _loadTodaySummaries() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await SummaryService.getTodaySummaries();
      setState(() {
        _summaryData = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error loading summaries: $e');
    }
  }

  Future<void> _loadSummariesForDate(DateTime date) async {
    setState(() {
      _isLoading = true;
    });

    try {
      String dateStr = SummaryService.formatDateForApi(date);
      final result = await SummaryService.getSummariesForDate(dateStr);
      setState(() {
        _summaryData = result;
        _selectedDate = date;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error loading summaries: $e');
    }
  }

  Future<void> _loadSummariesForDateRange() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String startDateStr = SummaryService.formatDateForApi(_startDate);
      String endDateStr = SummaryService.formatDateForApi(_endDate);
      final result = await SummaryService.getSummariesForDateRange(
        startDateStr,
        endDateStr,
      );
      setState(() {
        _summaryData = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error loading summaries: $e');
    }
  }

  Future<void> _loadRecentSummaries() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await SummaryService.getRecentSummaries();
      setState(() {
        _summaryData = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error loading summaries: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      await _loadSummariesForDate(picked);
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      await _loadSummariesForDateRange();
    }
  }

  void _showAptosPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.account_balance_wallet, color: Colors.green[600]),
              const SizedBox(width: 8),
              Text(
                'Aptos Smart Contract',
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create a smart contract on Aptos blockchain with your summary data.',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contract Details:',
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Email: ${globals.globalEmail}',
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      'Date: ${SummaryService.formatDate(DateTime.now().toString())}',
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AptosViewPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Create Contract'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Summary Reports",
          style: GoogleFonts.roboto(
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.normal,
              letterSpacing: 1.3,
              fontSize: 24,
              color: Colors.blue[400],
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Date filter controls
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter by Date',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _loadTodaySummaries,
                        icon: const Icon(Icons.today, size: 18),
                        label: const Text('Today'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedDateRange == 'today'
                              ? Colors.blue
                              : Colors.grey[300],
                          foregroundColor: _selectedDateRange == 'today'
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _selectDate,
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: const Text('Pick Date'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _loadRecentSummaries,
                        icon: const Icon(Icons.date_range, size: 18),
                        label: const Text('Last 7 Days'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _selectDateRange,
                        icon: const Icon(Icons.date_range, size: 18),
                        label: const Text('Date Range'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[600],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Loading indicator or summary content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading summaries...'),
                      ],
                    ),
                  )
                : _buildSummaryContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAptosPopup,
        icon: const Icon(Icons.account_balance_wallet),
        label: const Text('Smart Contract'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildSummaryContent() {
    if (_summaryData.isEmpty || _summaryData['success'] != true) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _summaryData['error'] ?? 'No summaries found',
              style: GoogleFonts.roboto(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadTodaySummaries,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    List<dynamic> summaries = _summaryData['summaries'] ?? [];

    if (summaries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.summarize_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No summaries available for the selected date(s)',
              style: GoogleFonts.roboto(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: summaries.length,
      itemBuilder: (context, index) {
        final summary = summaries[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Colors.blue[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      SummaryService.formatDate(summary['date'] ?? ''),
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${summary['notification_count']} notifications',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  summary['summary'] ?? 'No summary available',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Created: ${SummaryService.formatDate(summary['created_at'] ?? '')}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
