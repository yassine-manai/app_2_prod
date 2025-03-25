import 'package:flutter/material.dart';
import '../controllers/profile_controller.dart';

class BalanceScreen extends StatefulWidget {
  const BalanceScreen({super.key});

  @override
  _BalanceScreenState createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  final ProfileController _controller = ProfileController();
  final _topUpFormKey = GlobalKey<FormState>();
  
  final TextEditingController _topUpAmountController = TextEditingController();
  
  bool _isLoading = false;
  bool _isTopUpLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _topUpAmountController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    
    try {
      await _controller.getProfile();
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showTopUpDialog() {
    _topUpAmountController.text = '';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Top-up Balance'),
        content: Form(
          key: _topUpFormKey,
          child: TextFormField(
            controller: _topUpAmountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.attach_money),
              suffix: Text('TND'),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              final amount = int.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'Please enter a valid amount';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isTopUpLoading ? null : () => _showPaymentMethodsDialog(context),
            child: _isTopUpLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showPaymentMethodsDialog(BuildContext context) {
    if (!_topUpFormKey.currentState!.validate()) return;
    
    // First close the amount dialog
    Navigator.of(context).pop();
    
    // Then show payment methods dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Payment Method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.credit_card, color: Colors.white),
              ),
              title: const Text('Stripe'),
              subtitle: const Text('Visa, Mastercard, etc.'),
              onTap: () {
                Navigator.of(context).pop();
                _processStripeTopUp();
              },
            ),
            const Divider(),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.orange,
                child: Icon(Icons.account_balance, color: Colors.white),
              ),
              title: const Text('Bank Transfer'),
              subtitle: const Text('Direct bank deposit'),
              onTap: () {
                Navigator.of(context).pop();
                _processTopUp(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _processStripeTopUp() async {
    setState(() => _isTopUpLoading = true);
    
    try {
      // Parse the amount from the text field
      final amount = int.parse(_topUpAmountController.text);
      
      // Process the Stripe top-up (calling a different API endpoint)
      final success = await _controller.topUpStripe(amount);
      
      if (success) {
        _showSuccessSnackBar('Payment processing with Stripe');
        // Refresh balance data
        _loadProfileData();
      } else {
        _showErrorSnackBar(_controller.error);
      }
    } catch (e) {
      _showErrorSnackBar('Error processing Stripe payment: ${e.toString()}');
    } finally {
      setState(() => _isTopUpLoading = false);
    }
  }

  Future<void> _processTopUp(BuildContext context) async {
    setState(() => _isTopUpLoading = true);
    
    try {
      // Parse the amount from the text field
      final amount = int.parse(_topUpAmountController.text);
      
      // Process the bank transfer top-up (using the existing method)
      final success = await _controller.topUpBalance(amount);
      
      if (success) {
        _showSuccessSnackBar('Balance topped up successfully via bank transfer');
        // Refresh balance data
        _loadProfileData();
      } else {
        _showErrorSnackBar(_controller.error);
      }
    } catch (e) {
      _showErrorSnackBar('Error processing bank transfer: ${e.toString()}');
    } finally {
      setState(() => _isTopUpLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Balance'),
        centerTitle: false,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.indigo.withOpacity(0.1), Colors.white],
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Balance Card
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [Colors.indigo, Colors.indigo.shade800],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Available Balance',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                     
                                      const SizedBox(width: 4),
                                      Text(
                                        '${_controller.profileData['balance'] ?? 0}',
                                        style: const TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Padding(
                                        padding: EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          'TND',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.yellow,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  const Divider(color: Colors.white30),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Last update: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.account_balance_wallet,
                                        color: Colors.white70,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Top-up Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _showTopUpDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Top-up Balance'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Transaction History Section
                        Text(
                          'Transaction History',
                          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Example transaction history items
                        // In a real app, you would fetch these from your API
                        _buildTransactionItem(
                          date: 'Mar 8, 2025',
                          title: 'Top-up',
                          amount: '+50.00',
                          isCredit: true,
                        ),
                        _buildTransactionItem(
                          date: 'Mar 5, 2025',
                          title: 'Event Ticket Purchase',
                          amount: '-35.00',
                          isCredit: false,
                        ),
                        _buildTransactionItem(
                          date: 'Mar 2, 2025',
                          title: 'Top-up',
                          amount: '+100.00',
                          isCredit: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTransactionItem({
    required String date,
    required String title,
    required String amount,
    required bool isCredit,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isCredit ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isCredit ? Icons.add_circle : Icons.remove_circle,
                color: isCredit ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    date,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isCredit ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}