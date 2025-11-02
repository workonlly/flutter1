import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:hex/hex.dart';
import 'package:bip39/bip39.dart' as bip39;

class AptosService {
  static const String aptosDevnetUrl = 'https://fullnode.devnet.aptoslabs.com/v1';
  static const String aptosFaucetUrl = 'https://faucet.devnet.aptoslabs.com';
  
  // Contract configuration
  static const String moduleAddress = '0x1'; // Using core framework for simplicity
  static const String moduleName = 'user_messages';
  
  static String? _privateKey;
  static String? _publicKey;
  static String? _address;

  // Generate a new wallet
  static Map<String, String> generateWallet() {
    // Generate mnemonic
    final mnemonic = bip39.generateMnemonic();
    
    // Derive seed from mnemonic
    final seed = bip39.mnemonicToSeed(mnemonic);
    
    // Generate simplified key pair (for demo purposes)
    final seedHash = sha256.convert(seed);
    final privateKeyBytes = seedHash.bytes.take(32).toList();
    
    _privateKey = HEX.encode(privateKeyBytes);
    
    // Generate public key (simplified approach)
    final publicKeyHash = sha256.convert(privateKeyBytes);
    final publicKeyBytes = publicKeyHash.bytes.take(32).toList();
    _publicKey = HEX.encode(publicKeyBytes);
    
    // Generate address from public key
    _address = _generateAddressFromPublicKey(_publicKey!);
    
    return {
      'mnemonic': mnemonic,
      'privateKey': _privateKey!,
      'publicKey': _publicKey!,
      'address': _address!,
    };
  }

  static String _generateAddressFromPublicKey(String publicKey) {
    // Simplified address generation for demo
    final pubKeyBytes = HEX.decode(publicKey);
    final addressBytes = sha3_256(pubKeyBytes + [0x00]); // Single signature scheme
    return '0x${HEX.encode(addressBytes).substring(0, 64)}';
  }

  static List<int> sha3_256(List<int> input) {
    final digest = sha256.convert(input);
    return digest.bytes;
  }

  // Fund account from faucet (devnet only)
  static Future<Map<String, dynamic>> fundAccount(String address) async {
    try {
      final response = await http.post(
        Uri.parse('$aptosFaucetUrl/mint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'address': address,
          'amount': 100000000, // 1 APT = 100,000,000 octas
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to fund account: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // Get account balance
  static Future<Map<String, dynamic>> getAccountBalance(String address) async {
    try {
      final response = await http.get(
        Uri.parse('$aptosDevnetUrl/accounts/$address/resource/0x1::coin::CoinStore<0x1::aptos_coin::AptosCoin>'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final balance = int.parse(data['data']['coin']['value']);
        return {
          'success': true,
          'balance': balance,
          'balanceInApt': balance / 100000000, // Convert octas to APT
        };
      } else {
        return {
          'success': false,
          'error': 'Account not found or insufficient funds',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // Get account sequence number
  static Future<int> getAccountSequenceNumber(String address) async {
    try {
      final response = await http.get(
        Uri.parse('$aptosDevnetUrl/accounts/$address'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return int.parse(data['sequence_number']);
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  // Submit a message transaction (simplified version)
  static Future<Map<String, dynamic>> submitMessageTransaction({
    required String message,
    required String userEmail,
    required DateTime timestamp,
  }) async {
    if (_address == null || _privateKey == null) {
      return {
        'success': false,
        'error': 'Wallet not connected',
      };
    }

    try {
      // Get account sequence number
      final sequenceNumber = await getAccountSequenceNumber(_address!);
      
      // Create transaction payload (simplified)
      final transactionPayload = {
        'type': 'entry_function_payload',
        'function': '0x1::aptos_account::transfer',
        'type_arguments': [],
        'arguments': [
          _address, // Send to self as a way to store data
          '1', // 1 octa
        ],
      };

      // Create raw transaction
      final rawTransaction = {
        'sender': _address,
        'sequence_number': sequenceNumber.toString(),
        'max_gas_amount': '2000',
        'gas_unit_price': '100',
        'expiration_timestamp_secs': (DateTime.now().millisecondsSinceEpoch ~/ 1000 + 600).toString(),
        'payload': transactionPayload,
      };

      // Submit transaction (simplified - in real implementation you'd need to sign)
      final response = await http.post(
        Uri.parse('$aptosDevnetUrl/transactions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(rawTransaction),
      );

      if (response.statusCode == 202) {
        final txData = jsonDecode(response.body);
        
        // Store message data locally (in real implementation, this would be in the transaction)
        final messageData = {
          'hash': txData['hash'],
          'message': message,
          'user_email': userEmail,
          'timestamp': timestamp.toIso8601String(),
          'sender': _address,
        };

        return {
          'success': true,
          'transaction_hash': txData['hash'],
          'message_data': messageData,
        };
      } else {
        return {
          'success': false,
          'error': 'Transaction failed: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Transaction error: $e',
      };
    }
  }

  // Get transaction details
  static Future<Map<String, dynamic>> getTransaction(String transactionHash) async {
    try {
      final response = await http.get(
        Uri.parse('$aptosDevnetUrl/transactions/by_hash/$transactionHash'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'transaction': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': 'Transaction not found',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // Check if wallet is connected
  static bool isWalletConnected() {
    return _address != null && _privateKey != null;
  }

  // Get current wallet info
  static Map<String, String?> getWalletInfo() {
    return {
      'address': _address,
      'publicKey': _publicKey,
    };
  }

  // Disconnect wallet
  static void disconnectWallet() {
    _privateKey = null;
    _publicKey = null;
    _address = null;
  }

  // Get network status
  static Future<Map<String, dynamic>> getNetworkStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$aptosDevnetUrl/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'network': 'Aptos Devnet',
          'status': 'Connected',
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': 'Network unavailable',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }
}