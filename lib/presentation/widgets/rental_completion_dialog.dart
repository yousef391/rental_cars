import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_rent_car/presentation/blocs/rental_bloc.dart';
import 'package:offline_rent_car/domain/models/rental.dart';
import 'package:offline_rent_car/data/services/localization_service.dart';

class RentalCompletionDialog extends StatefulWidget {
  final Rental rental;

  const RentalCompletionDialog({super.key, required this.rental});

  @override
  State<RentalCompletionDialog> createState() => _RentalCompletionDialogState();
}

class _RentalCompletionDialogState extends State<RentalCompletionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _endMileageController = TextEditingController();
  final _finalCostController = TextEditingController();
  final LocalizationService _localizationService = LocalizationService();
  int? _endMileage;
  double? _finalCost;
  bool _hasAdditionalCharges = false;

  @override
  void initState() {
    super.initState();
    _finalCostController.text = widget.rental.totalCost.toString();
  }

  @override
  Widget build(BuildContext context) {
    final distanceTraveled =
        _endMileage != null && widget.rental.startMileage != null
            ? _endMileage! - widget.rental.startMileage!
            : null;

    return ListenableBuilder(
      listenable: _localizationService,
      builder: (context, child) {
        return AlertDialog(
          title: Text(_localizationService.translate('completion.title'),
              style: TextStyle(fontSize: 18.sp)),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
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
                                .translate('completion.rental_summary'),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                              '${_localizationService.translate('completion.start_mileage')}: ${widget.rental.startMileage ?? _localizationService.translate('messages.no_data')} km'),
                          Text(
                              '${_localizationService.translate('rentals.total_cost')}: ${widget.rental.totalCost.toStringAsFixed(2)} DZD'),
                          Text(
                              '${_localizationService.translate('rentals.amount_paid')}: ${widget.rental.amountPaid.toStringAsFixed(2)} DZD'),
                          Text(
                            '${_localizationService.translate('rentals.payment_status')}: ${_getPaymentStatusText(widget.rental.paymentStatus)}',
                            style: TextStyle(
                              color: _getPaymentStatusColor(
                                  widget.rental.paymentStatus),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          const Divider(),
                          Text(
                            '${_localizationService.translate('rentals.security_deposit')}: ${widget.rental.securityDeposit.toStringAsFixed(2)} DZD',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          Text(
                            _localizationService.translate(
                                'completion.security_deposit_return'),
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
                    controller: _endMileageController,
                    decoration: InputDecoration(
                      labelText: _localizationService
                          .translate('completion.end_mileage'),
                      border: const OutlineInputBorder(),
                      helperText: _localizationService
                          .translate('completion.end_mileage'),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _endMileage = int.tryParse(value);
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return _localizationService
                            .translate('validation.required_field');
                      }
                      if (int.tryParse(value) == null) {
                        return _localizationService
                            .translate('validation.invalid_mileage');
                      }
                      if (widget.rental.startMileage != null &&
                          _endMileage != null) {
                        if (_endMileage! < widget.rental.startMileage!) {
                          return _localizationService
                              .translate('completion.mileage_less_than_start');
                        }
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  if (distanceTraveled != null) ...[
                    Card(
                      color: Colors.green.shade50,
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_localizationService.translate('completion.distance_traveled')}:',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text('$distanceTraveled km'),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],
                  CheckboxListTile(
                    title: Text(
                      _localizationService
                          .translate('completion.additional_charges'),
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    subtitle: Text(
                      _localizationService
                          .translate('completion.additional_charges_note'),
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    ),
                    value: _hasAdditionalCharges,
                    onChanged: (value) {
                      setState(() {
                        _hasAdditionalCharges = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  if (_hasAdditionalCharges) ...[
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _finalCostController,
                      decoration: InputDecoration(
                        labelText:
                            '${_localizationService.translate('completion.final_cost')} (DZD)',
                        border: const OutlineInputBorder(),
                        helperText: _localizationService
                            .translate('completion.final_cost_note'),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _finalCost = double.tryParse(value);
                        });
                      },
                      validator: (value) {
                        if (_hasAdditionalCharges) {
                          if (value == null || value.isEmpty) {
                            return _localizationService
                                .translate('validation.required_field');
                          }
                          if (double.tryParse(value) == null) {
                            return _localizationService
                                .translate('validation.invalid_rate');
                          }
                          if (_finalCost != null &&
                              _finalCost! < widget.rental.totalCost) {
                            return _localizationService
                                .translate('completion.final_cost_note');
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(_localizationService.translate('forms.cancel')),
            ),
            ElevatedButton(
              onPressed: _completeRental,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text(_localizationService.translate('completion.title')),
            ),
          ],
        );
      },
    );
  }

  String _getPaymentStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return _localizationService.translate('rentals.pending');
      case PaymentStatus.paid:
        return _localizationService.translate('rentals.paid_status');
    }
  }

  Color _getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.paid:
        return Colors.green;
    }
  }

  void _completeRental() {
    if (_formKey.currentState!.validate()) {
      if (_endMileage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                _localizationService.translate('completion.invalid_mileage')),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
              _localizationService.translate('completion.confirm_completion')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  '${_localizationService.translate('completion.end_mileage')}: $_endMileage km'),
              if (distanceTraveled != null)
                Text(
                    '${_localizationService.translate('completion.distance_traveled')}: $distanceTraveled km'),
              Text(
                  '${_localizationService.translate('completion.final_cost')}: ${(_finalCost ?? widget.rental.totalCost).toStringAsFixed(2)} DZD'),
              Text(
                '✅ ${_localizationService.translate('payment.payment_successful')}',
                style: const TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold),
              ),
              Builder(
                builder: (context) {
                  final finalCost = _hasAdditionalCharges
                      ? (_finalCost ?? widget.rental.totalCost)
                      : widget.rental.totalCost;
                  final remainingAmount =
                      finalCost - (widget.rental.amountPaid ?? 0.0);
                  if (remainingAmount > 0) {
                    return Text(
                      '💰 ${_localizationService.translate('payment.remaining_balance')}: ${remainingAmount.toStringAsFixed(2)} DZD',
                      style: const TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💰 ${_localizationService.translate('completion.security_deposit_return')}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    Text(
                        '${_localizationService.translate('rentals.security_deposit')}: ${widget.rental.securityDeposit.toStringAsFixed(2)} DZD'),
                    Text(
                      _localizationService
                          .translate('completion.security_deposit_return'),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(_localizationService
                  .translate('completion.completion_message')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(_localizationService.translate('forms.cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close confirmation dialog
                Navigator.of(context).pop(); // Close completion dialog

                // Always mark as paid when completing rental
                final finalCost = _hasAdditionalCharges
                    ? (_finalCost ?? widget.rental.totalCost)
                    : widget.rental.totalCost;
                final remainingAmount =
                    finalCost - (widget.rental.amountPaid ?? 0.0);

                // Complete the rental with updated payment status
                context.read<RentalBloc>().add(
                      CompleteRentalWithMileage(
                        rentalId: widget.rental.id,
                        endMileage: _endMileage!,
                        finalCost: finalCost,
                      ),
                    );

                // Show success message
                final remainingMessage = remainingAmount > 0
                    ? '\n${_localizationService.translate('payment.remaining_balance')}: ${remainingAmount.toStringAsFixed(2)} DZD'
                    : '';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${_localizationService.translate('completion.completion_successful')}!\n'
                      '${_localizationService.translate('completion.end_mileage')}: $_endMileage km\n'
                      '${_localizationService.translate('payment.payment_successful')}$remainingMessage\n'
                      '${_localizationService.translate('rentals.security_deposit')}: ${widget.rental.securityDeposit.toStringAsFixed(2)} DZD',
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 5),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text(_localizationService.translate('forms.complete')),
            ),
          ],
        ),
      );
    }
  }

  int? get distanceTraveled {
    if (_endMileage != null && widget.rental.startMileage != null) {
      return _endMileage! - widget.rental.startMileage!;
    }
    return null;
  }

  @override
  void dispose() {
    _endMileageController.dispose();
    _finalCostController.dispose();
    super.dispose();
  }
}
