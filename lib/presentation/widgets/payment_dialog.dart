import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rentra/presentation/blocs/rental_bloc.dart';
import 'package:rentra/domain/models/rental.dart';
import 'package:rentra/data/services/localization_service.dart';

class PaymentDialog extends StatefulWidget {
  final Rental rental;

  const PaymentDialog({super.key, required this.rental});

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _paymentAmountController = TextEditingController();
  final LocalizationService _localizationService = LocalizationService();
  double _paymentAmount = 0.0;

  @override
  void initState() {
    super.initState();
    // Set initial payment amount to remaining balance
    _paymentAmount = widget.rental.totalCost - widget.rental.amountPaid;
    _paymentAmountController.text = _paymentAmount.toString();
  }

  @override
  Widget build(BuildContext context) {
    final remainingBalance = widget.rental.totalCost - widget.rental.amountPaid;

    return ListenableBuilder(
      listenable: _localizationService,
      builder: (context, child) {
        return AlertDialog(
          title: Text(_localizationService.translate('payment.title'),
              style: TextStyle(fontSize: 18.sp)),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _localizationService
                              .translate('payment.rental_summary'),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                            '${_localizationService.translate('payment.total_cost')}: ${widget.rental.totalCost.toStringAsFixed(2)} DZD'),
                        Text(
                            '${_localizationService.translate('payment.amount_paid')}: ${widget.rental.amountPaid.toStringAsFixed(2)} DZD'),
                        Text(
                          '${_localizationService.translate('payment.remaining_balance')}: ${remainingBalance.toStringAsFixed(2)} DZD',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: remainingBalance > 0
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        const Divider(),
                        Text(
                          '${_localizationService.translate('payment.security_deposit')}: ${widget.rental.securityDeposit.toStringAsFixed(2)} DZD',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        Text(
                          _localizationService
                              .translate('payment.security_deposit_note'),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _paymentAmountController,
                  decoration: InputDecoration(
                    labelText:
                        '${_localizationService.translate('payment.payment_amount')} (DZD)',
                    border: const OutlineInputBorder(),
                    helperText: _localizationService
                        .translate('payment.payment_amount'),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _paymentAmount = double.tryParse(value) ?? 0.0;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return _localizationService
                          .translate('validation.required_field');
                    }
                    if (double.tryParse(value) == null) {
                      return _localizationService
                          .translate('validation.invalid_rate');
                    }
                    if (_paymentAmount <= 0) {
                      return _localizationService
                          .translate('validation.positive_number');
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                if (_paymentAmount > 0) ...[
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_localizationService.translate('payment.new_amount_paid')}:',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                              '${_localizationService.translate('payment.new_amount_paid')}: ${(widget.rental.amountPaid + _paymentAmount).toStringAsFixed(2)} DZD'),
                          Text(
                            '${_localizationService.translate('payment.new_balance')}: ${(remainingBalance - _paymentAmount).toStringAsFixed(2)} DZD',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: (remainingBalance - _paymentAmount) <= 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(_localizationService.translate('forms.cancel')),
            ),
            ElevatedButton(
              onPressed: _submitPayment,
              child: Text(_localizationService.translate('forms.payment')),
            ),
          ],
        );
      },
    );
  }

  void _submitPayment() {
    if (_formKey.currentState!.validate()) {
      context.read<RentalBloc>().add(
            UpdateRentalPayment(
              rentalId: widget.rental.id,
              paymentAmount: _paymentAmount,
            ),
          );
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${_localizationService.translate('payment.payment_successful')}: ${_paymentAmount.toStringAsFixed(2)} DZD'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _paymentAmountController.dispose();
    super.dispose();
  }
}
