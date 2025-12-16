import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ApiStatusWidget extends StatefulWidget {
  const ApiStatusWidget({Key? key}) : super(key: key);

  @override
  State<ApiStatusWidget> createState() => _ApiStatusWidgetState();
}

class _ApiStatusWidgetState extends State<ApiStatusWidget> {
  bool? _isConnected;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    setState(() => _isChecking = true);
    
    try {
      final isConnected = await ApiService.testConnection();
      setState(() {
        _isConnected = isConnected;
        _isChecking = false;
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor().withOpacity(0.3)),
      ),
      child: Row(
        children: [
          _isChecking
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(_getStatusColor()),
                  ),
                )
              : Icon(
                  _getStatusIcon(),
                  color: _getStatusColor(),
                  size: 16,
                ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getStatusText(),
              style: TextStyle(
                color: _getStatusColor(),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: _isChecking ? null : _checkConnection,
            child: Text(
              'Refresh',
              style: TextStyle(
                color: _getStatusColor(),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (_isChecking) return Colors.orange;
    if (_isConnected == true) return Colors.green;
    return Colors.red;
  }

  IconData _getStatusIcon() {
    if (_isConnected == true) return Icons.check_circle;
    return Icons.error;
  }

  String _getStatusText() {
    if (_isChecking) return 'Mengecek koneksi API...';
    if (_isConnected == true) return 'API Flask terhubung';
    return 'API Flask tidak terhubung - Cek konfigurasi';
  }
}