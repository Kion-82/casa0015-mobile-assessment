import 'package:flutter/material.dart';

class LogTripPage extends StatefulWidget {
  final String? initialSpotName;
  final void Function(Map<String, String>) onSaveTrip;

  const LogTripPage({
    super.key,
    this.initialSpotName,
    required this.onSaveTrip,
  });

  @override
  State<LogTripPage> createState() => _LogTripPageState();
}

class _LogTripPageState extends State<LogTripPage> {
  late TextEditingController _spotController;
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? catchResult;

  @override
  void initState() {
    super.initState();
    _spotController = TextEditingController(
      text: widget.initialSpotName ?? '',
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

  void saveTrip() {
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

    final trip = <String, String>{
      'spot': spot,
      'dateTime': dateTime.isEmpty ? 'No date entered' : dateTime,
      'condition': condition.isEmpty ? 'No condition entered' : condition,
      'result': catchResult ?? 'No result selected',
      'notes': notes,
    };

    widget.onSaveTrip(trip);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Trip saved')),
    );

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _spotController,
          decoration: const InputDecoration(
            labelText: 'Spot name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _dateTimeController,
          decoration: const InputDecoration(
            labelText: 'Date & time',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _conditionController,
          decoration: const InputDecoration(
            labelText: 'Auto-filled local condition',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Catch result',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => selectCatchResult('Caught'),
                child: Card(
                  color: catchResult == 'Caught'
                      ? Colors.green.shade100
                      : null,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        Icon(Icons.sentiment_satisfied_alt, size: 32),
                        SizedBox(height: 8),
                        Text('Caught'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => selectCatchResult('No catch'),
                child: Card(
                  color: catchResult == 'No catch'
                      ? Colors.red.shade100
                      : null,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        Icon(Icons.sentiment_dissatisfied, size: 32),
                        SizedBox(height: 8),
                        Text('No catch'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Selected: ${catchResult ?? '--'}',
          style: const TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _notesController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Notes',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.photo_camera_outlined),
          label: const Text('Add Photo (later)'),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: saveTrip,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('Save Trip'),
          ),
        ),
      ],
    );
  }
}