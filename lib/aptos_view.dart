import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'globals.dart' as globals;
import 'aptos_service.dart';

class AptosViewPage extends StatefulWidget {
  const AptosViewPage({super.key});

  @override
  State<AptosViewPage> createState() => _AptosViewPageState();
}

class _AptosViewPageState extends State<AptosViewPage> {
  bool _isConnecting = false;
  bool _isDeploying = false;
  bool _isFunding = false;
  String? _walletAddress;
  String? _contractAddress;
  String? _transactionHash;
  double? _accountBalance;
  Map<String, dynamic>? _networkStatus;
  final TextEditingController _messageController = TextEditingController();
  String _userMessage = '';

  @override
  void initState() {
    super.initState();
    _checkNetworkStatus();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _checkNetworkStatus() async {
    final status = await AptosService.getNetworkStatus();
    setState(() {
      _networkStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Aptos Smart Contract",
          style: GoogleFonts.roboto(
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.normal,
              letterSpacing: 1.3,
              fontSize: 24,
              color: Colors.green[600],
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.green[400]!, Colors.green[600]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Aptos Blockchain',
                          style: GoogleFonts.roboto(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Create and deploy smart contracts to store your summary data securely on the Aptos blockchain.',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // User Information Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contract Information',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      Icons.email,
                      'User Email',
                      globals.globalEmail.isNotEmpty 
                          ? globals.globalEmail 
                          : 'Not available',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Contract Date',
                      _formatCurrentDate(),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.access_time,
                      'Timestamp',
                      _formatCurrentTime(),
                    ),
                    const SizedBox(height: 16),
                    
                    // Message Input Section
                    Text(
                      'Blockchain Message',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _messageController,
                        maxLines: 4,
                        maxLength: 500,
                        decoration: InputDecoration(
                          hintText: 'Enter your message to store on the Aptos blockchain...\n\nThis message will be permanently recorded with your email and timestamp.',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(12),
                          counterStyle: TextStyle(color: Colors.grey[600]),
                        ),
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                        onChanged: (value) {
                          setState(() {
                            _userMessage = value;
                          });
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      Icons.account_balance_wallet,
                      'Wallet Status',
                      _walletAddress != null ? 'Connected' : 'Not Connected',
                    ),
                    if (_walletAddress != null) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.account_balance,
                        'Wallet Address',
                        '${_walletAddress!.substring(0, 10)}...${_walletAddress!.substring(_walletAddress!.length - 8)}',
                      ),
                      if (_accountBalance != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.monetization_on,
                          'Balance',
                          '${_accountBalance!.toStringAsFixed(4)} APT',
                        ),
                      ],
                    ],
                    if (_transactionHash != null) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.receipt_long,
                        'Transaction Hash',
                        '${_transactionHash!.substring(0, 10)}...${_transactionHash!.substring(_transactionHash!.length - 8)}',
                      ),
                    ],
                    if (_networkStatus != null) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.wifi,
                        'Network Status',
                        _networkStatus!['success'] ? 'Aptos Devnet Connected' : 'Network Error',
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            if (_walletAddress == null) ...[
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isConnecting ? null : _connectWallet,
                  icon: _isConnecting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.account_balance_wallet),
                  label: Text(
                    _isConnecting 
                        ? (_isFunding ? 'Funding Account...' : 'Connecting...') 
                        : 'Connect Aptos Wallet',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              if (_networkStatus != null && !_networkStatus!['success'])
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Network Error: ${_networkStatus!['error']}',
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: Colors.red[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ] else if (_contractAddress == null) ...[
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: (_isDeploying || _messageController.text.trim().isEmpty) 
                      ? null 
                      : _deployContract,
                  icon: _isDeploying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.rocket_launch),
                  label: Text(
                    _isDeploying ? 'Deploying...' : 'Deploy Smart Contract',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (_messageController.text.trim().isEmpty) 
                        ? Colors.grey[400] 
                        : Colors.green[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              if (_messageController.text.trim().isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Please enter a message to store on the blockchain',
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: Colors.red[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ] else ...[
              // Contract deployed successfully
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[600],
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Smart Contract Deployed!',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your message has been successfully stored on the Aptos blockchain.',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: Colors.green[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Blockchain Record:',
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '"$_userMessage"',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'User: ${globals.globalEmail}',
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'Time: ${_formatCurrentTime()}',
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (_transactionHash != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Tx Hash: ${_transactionHash!.substring(0, 16)}...',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue[600],
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _viewOnExplorer,
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('View on Explorer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _deployNewContract,
                      icon: const Icon(Icons.add),
                      label: const Text('New Contract'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 32),

            // Info Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About Aptos Smart Contracts',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• Real Aptos Devnet blockchain integration\n'
                      '• Automatic wallet generation and funding\n'
                      '• Live transaction submission and verification\n'
                      '• Permanent on-chain message storage\n'
                      '• Transparent and verifiable transactions\n'
                      '• View transactions on Aptos Explorer',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatCurrentDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }

  String _formatCurrentTime() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  Future<void> _connectWallet() async {
    setState(() {
      _isConnecting = true;
    });

    try {
      // Generate new Aptos wallet
      final walletData = AptosService.generateWallet();
      
      setState(() {
        _walletAddress = walletData['address'];
      });

      // Fund the account from faucet (devnet only)
      setState(() {
        _isFunding = true;
      });

      final fundResult = await AptosService.fundAccount(_walletAddress!);
      
      if (fundResult['success']) {
        // Get account balance
        final balanceResult = await AptosService.getAccountBalance(_walletAddress!);
        if (balanceResult['success']) {
          setState(() {
            _accountBalance = balanceResult['balanceInApt'];
          });
        }
        
        _showSuccessSnackBar('Wallet connected and funded successfully!');
      } else {
        _showErrorSnackBar('Wallet connected but funding failed: ${fundResult['error']}');
      }

    } catch (e) {
      _showErrorSnackBar('Failed to connect wallet: $e');
      setState(() {
        _walletAddress = null;
      });
    } finally {
      setState(() {
        _isConnecting = false;
        _isFunding = false;
      });
    }
  }

  Future<void> _deployContract() async {
    setState(() {
      _isDeploying = true;
    });

    try {
      // Capture the user message before deployment
      _userMessage = _messageController.text.trim();

      // Submit message transaction to Aptos blockchain
      final result = await AptosService.submitMessageTransaction(
        message: _userMessage,
        userEmail: globals.globalEmail,
        timestamp: DateTime.now(),
      );

      if (result['success']) {
        setState(() {
          _transactionHash = result['transaction_hash'];
          _contractAddress = result['transaction_hash']; // Using tx hash as contract reference
        });
        
        _showSuccessSnackBar('Message stored on Aptos blockchain successfully!');
      } else {
        _showErrorSnackBar('Failed to store message: ${result['error']}');
      }

    } catch (e) {
      _showErrorSnackBar('Transaction failed: $e');
    } finally {
      setState(() {
        _isDeploying = false;
      });
    }
  }

  void _viewOnExplorer() {
    if (_transactionHash != null) {
      _showInfoSnackBar('Opening Aptos Explorer for transaction: ${_transactionHash!.substring(0, 10)}...');
      // In a real implementation, this would open: https://explorer.aptoslabs.com/txn/$_transactionHash?network=devnet
    } else {
      _showInfoSnackBar('No transaction to view');
    }
  }

  void _deployNewContract() {
    setState(() {
      _contractAddress = null;
      _transactionHash = null;
      _userMessage = '';
    });
    _messageController.clear();
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue[600],
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
