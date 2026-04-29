import 'package:flutter/material.dart';

class LogTripPage extends StatefulWidget {
  final String? initialSpotName;
  final String? initialDateTime;
  final String? initialCondition;
  final Future<void> Function(Map<String, String>) onSaveTrip;
  final bool closeOnSave;

  const LogTripPage({
    super.key,
    this.initialSpotName,
    this.initialDateTime,
    this.initialCondition,
    required this.onSaveTrip,
    this.closeOnSave = false,
  });

  @override
  State<LogTripPage> createState() => _LogTripPageState();
}

class _LogTripPageState extends State<LogTripPage> {
  late TextEditingController _spotController;
  late TextEditingController _dateTimeController;
  late TextEditingController _conditionController;
  final TextEditingController _notesController = TextEditingController();

  String? catchResult;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    _spotController = TextEditingController(
      text: widget.initialSpotName ?? '',
    );

    _dateTimeController = TextEditingController(
      text: widget.initialDateTime ?? '',
    );

    _conditionController = TextEditingController(
      text: widget.initialCondition ?? '',
    );
  }

  @override
  void dispose() {
    _spotController.dispose();
    _dateTimeController.dispose();
    _conditionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void selectCatchResult(String result) {
    setState(() {
      catchResult = result;
    });
  }

  Future<void> saveTrip() async {
    final spot = _spotController.text.trim();
    final dateTime = _dateTimeController.text.trim();
    final condition = _conditionController.text.trim();
    final notes = _notesController.text.trim();

    if (spot.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a spot name')),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    final trip = <String, String>{
      'spot': spot,
      'dateTime': dateTime.isEmpty ? 'No date entered' : dateTime,
      'condition': condition.isEmpty ? 'No condition entered' : condition,
      'result': catchResult ?? 'No result selected',
      'notes': notes,
    };

    try {
      await widget.onSaveTrip(trip);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip saved')),
      );

      if (widget.closeOnSave && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save trip: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Widget buildPanel({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }

  Widget buildCatchCard({
    required String result,
    required IconData icon,
    required Color selectedColor,
  }) {
    final bool isSelected = catchResult == result;

    return Expanded(
      child: GestureDetector(
        onTap: () => selectCatchResult(result),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor.withValues(alpha: 0.18) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected ? selectedColor : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 34,
                color: isSelected ? selectedColor : Colors.black54,
              ),
              const SizedBox(height: 8),
              Text(
                result,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? selectedColor : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        buildPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.edit_note, color: Color(0xFF0277BD)),
                  SizedBox(width: 8),
                  Text(
                    'Log a Fishing Trip',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D2B3E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Record where you fished, the conditions, and the result.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 20),
              buildTextField(
                controller: _spotController,
                label: 'Spot name',
                icon: Icons.place_outlined,
              ),
              const SizedBox(height: 14),
              buildTextField(
                controller: _dateTimeController,
                label: 'Date & time',
                icon: Icons.schedule,
              ),
              const SizedBox(height: 14),
              buildTextField(
                controller: _conditionController,
                label: 'Local condition',
                icon: Icons.cloud_outlined,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        buildPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Catch Result',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D2B3E),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  buildCatchCard(
                    result: 'Caught',
                    icon: Icons.sentiment_satisfied_alt,
                    selectedColor: Colors.green,
                  ),
                  const SizedBox(width: 12),
                  buildCatchCard(
                    result: 'No catch',
                    icon: Icons.sentiment_dissatisfied,
                    selectedColor: Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Selected: ${catchResult ?? '--'}',
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        buildPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Trip Notes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D2B3E),
                ),
              ),
              const SizedBox(height: 12),
              buildTextField(
                controller: _notesController,
                label: 'Notes',
                icon: Icons.notes,
                maxLines: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: isSaving ? null : saveTrip,
          icon: const Icon(Icons.save_outlined),
          label: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(isSaving ? 'Saving...' : 'Save Trip'),
          ),
        ),
      ],
    );
  }
}