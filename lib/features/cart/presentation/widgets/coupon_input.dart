/// Coupon Input Widget
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CouponInput extends StatefulWidget {
  final Future<bool> Function(String code) onApply;
  final VoidCallback? onRemove;
  final String? appliedCoupon;
  final double? discountAmount;
  final bool isLoading;

  const CouponInput({
    super.key,
    required this.onApply,
    this.onRemove,
    this.appliedCoupon,
    this.discountAmount,
    this.isLoading = false,
  });

  @override
  State<CouponInput> createState() => _CouponInputState();
}

class _CouponInputState extends State<CouponInput> {
  final _controller = TextEditingController();
  bool _isApplying = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _applyCoupon() async {
    final code = _controller.text.trim();
    if (code.isEmpty) {
      setState(() => _errorMessage = 'Masukkan kode kupon');
      return;
    }

    setState(() {
      _isApplying = true;
      _errorMessage = null;
    });

    final success = await widget.onApply(code);

    if (mounted) {
      setState(() {
        _isApplying = false;
        if (success) {
          _controller.clear();
        } else {
          _errorMessage = 'Kupon tidak valid atau sudah kadaluarsa';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Show applied coupon
    if (widget.appliedCoupon != null) {
      return _buildAppliedCoupon(theme);
    }

    // Show input field
    return _buildInputField(theme);
  }

  Widget _buildAppliedCoupon(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_offer, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kupon ${widget.appliedCoupon} diterapkan',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
                if (widget.discountAmount != null && widget.discountAmount! > 0)
                  Text(
                    'Hemat Rp ${widget.discountAmount!.toStringAsFixed(0)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.green.shade600,
                    ),
                  ),
              ],
            ),
          ),
          if (widget.onRemove != null)
            IconButton(
              onPressed: widget.onRemove,
              icon: const Icon(Icons.close, size: 18),
              style: IconButton.styleFrom(
                foregroundColor: Colors.green.shade700,
                padding: EdgeInsets.zero,
                minimumSize: const Size(32, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => context.push('/pemesanan/kupon'),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(
                  Icons.discount_outlined,
                  size: 20,
                  color: const Color(0xFFf49d2a),
                ),
                const SizedBox(width: 8),
                Text(
                  'Lihat Kupon Tersedia',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: const Color(0xFFf49d2a),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Color(0xFFf49d2a),
                ),
              ],
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: !_isApplying && !widget.isLoading,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'Kode Kupon',
                  prefixIcon: const Icon(Icons.local_offer_outlined, size: 20),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.dividerColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFf49d2a)),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
                onSubmitted: (_) => _applyCoupon(),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isApplying || widget.isLoading
                    ? null
                    : _applyCoupon,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFf49d2a),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                child: _isApplying
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Pakai'),
              ),
            ),
          ],
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.red),
          ),
        ],
      ],
    );
  }
}
