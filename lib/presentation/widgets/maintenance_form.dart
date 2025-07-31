import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offline_rent_car/presentation/blocs/vehicle_bloc.dart';
import 'package:offline_rent_car/data/services/localization_service.dart';

class MaintenanceForm extends StatefulWidget {
  final String vehicleId;

  const MaintenanceForm({super.key, required this.vehicleId});

  @override
  State<MaintenanceForm> createState() => _MaintenanceFormState();
}

class _MaintenanceFormState extends State<MaintenanceForm> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _notesController = TextEditingController();
  final LocalizationService _localizationService = LocalizationService();
  DateTime _dateOfService = DateTime.now();
  DateTime? _nextDueDate;

  @override
  void dispose() {
    _typeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _localizationService,
      builder: (context, child) {
        return AlertDialog(
          title: Text(_localizationService.translate('maintenance.title')),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _typeController,
                    decoration: InputDecoration(
                      labelText:
                          _localizationService.translate('maintenance.type'),
                      border: const OutlineInputBorder(),
                      hintText: _localizationService.translate(
                          'maintenance.maintenance_types.oil_change'),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return _localizationService
                            .translate('validation.required_field');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text(_localizationService
                        .translate('maintenance.date_of_service')),
                    subtitle: Text(
                      '${_dateOfService.day}/${_dateOfService.month}/${_dateOfService.year}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _dateOfService,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _dateOfService = date;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text(_localizationService
                        .translate('maintenance.next_due_date')),
                    subtitle: Text(
                      _nextDueDate != null
                          ? '${_nextDueDate!.day}/${_nextDueDate!.month}/${_nextDueDate!.year}'
                          : _localizationService.translate('messages.no_data'),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_nextDueDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _nextDueDate = null;
                              });
                            },
                          ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _nextDueDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365 * 2)),
                      );
                      if (date != null) {
                        setState(() {
                          _nextDueDate = date;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText:
                          _localizationService.translate('maintenance.notes'),
                      border: const OutlineInputBorder(),
                      hintText:
                          _localizationService.translate('maintenance.notes'),
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
              child: Text(_localizationService.translate('forms.add')),
            ),
          ],
        );
      },
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final type = _typeController.text;
      final notes = _notesController.text;

      context.read<VehicleBloc>().add(
            AddMaintenanceRecord(
              vehicleId: widget.vehicleId,
              type: type,
              dateOfService: _dateOfService,
              nextDueDate: _nextDueDate,
              notes: notes,
            ),
          );

      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(_localizationService.translate('maintenance.record_added')),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
