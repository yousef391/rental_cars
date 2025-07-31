import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_rent_car/presentation/blocs/expense_bloc.dart';
import 'package:offline_rent_car/domain/models/expense.dart';
import 'package:offline_rent_car/data/services/localization_service.dart';

class ExpenseForm extends StatefulWidget {
  final Expense? expense;

  const ExpenseForm({super.key, this.expense});

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final LocalizationService _localizationService = LocalizationService();

  ExpenseCategory _selectedCategory = ExpenseCategory.maintenance;
  DateTime _selectedDate = DateTime.now();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _isEditing = true;
      _titleController.text = widget.expense!.title;
      _descriptionController.text = widget.expense!.description;
      _amountController.text = widget.expense!.amount.toString();
      _selectedCategory = widget.expense!.category;
      _selectedDate = widget.expense!.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _localizationService,
      builder: (context, child) {
        return AlertDialog(
          title: Text(
            _isEditing
                ? '${_localizationService.translate('forms.edit')} ${_localizationService.translate('statistics.expenses')}'
                : '${_localizationService.translate('forms.add')} ${_localizationService.translate('statistics.expenses')}',
            style: TextStyle(fontSize: 18.sp),
          ),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: _localizationService.translate('forms.title'),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return _localizationService
                            .translate('validation.required_field');
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText:
                          _localizationService.translate('forms.description'),
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return _localizationService
                            .translate('validation.required_field');
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: _localizationService.translate('forms.amount'),
                      border: const OutlineInputBorder(),
                      prefixText: 'DZD ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return _localizationService
                            .translate('validation.required_field');
                      }
                      if (double.tryParse(value) == null) {
                        return _localizationService
                            .translate('validation.invalid_rate');
                      }
                      if (double.parse(value) <= 0) {
                        return _localizationService
                            .translate('validation.positive_number');
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  DropdownButtonFormField<ExpenseCategory>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText:
                          _localizationService.translate('forms.category'),
                      border: const OutlineInputBorder(),
                    ),
                    items: ExpenseCategory.values.map((category) {
                      return DropdownMenuItem<ExpenseCategory>(
                        value: category,
                        child: Text(_getCategoryText(category)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 16.h),
                  ListTile(
                    title: Text(_localizationService.translate('forms.date')),
                    subtitle: Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _selectedDate = date;
                        });
                      }
                    },
                  ),
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
              onPressed: _submitForm,
              child: Text(_isEditing
                  ? _localizationService.translate('forms.update')
                  : _localizationService.translate('forms.add')),
            ),
          ],
        );
      },
    );
  }

  String _getCategoryText(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.maintenance:
        return _localizationService.translate('maintenance.title');
      case ExpenseCategory.fuel:
        return 'Fuel';
      case ExpenseCategory.insurance:
        return 'Insurance';
      case ExpenseCategory.registration:
        return 'Registration';
      case ExpenseCategory.utilities:
        return 'Utilities';
      case ExpenseCategory.office:
        return 'Office';
      case ExpenseCategory.marketing:
        return 'Marketing';
      case ExpenseCategory.other:
        return _localizationService
            .translate('maintenance.maintenance_types.other');
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text;
      final description = _descriptionController.text;
      final amount = double.parse(_amountController.text);

      if (_isEditing && widget.expense != null) {
        final updatedExpense = widget.expense!.copyWith(
          title: title,
          description: description,
          amount: amount,
          category: _selectedCategory,
          date: _selectedDate,
        );
        context.read<ExpenseBloc>().add(UpdateExpense(updatedExpense));
      } else {
        context.read<ExpenseBloc>().add(AddExpense(
              title: title,
              description: description,
              amount: amount,
              category: _selectedCategory,
              date: _selectedDate,
            ));
      }

      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_localizationService.translate('messages.data_saved')),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
