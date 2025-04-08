import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_client_flutter/providers/preferences_provider.dart';

class PreferencesSetupScreen extends StatefulWidget {
  const PreferencesSetupScreen({super.key});

  @override
  State<PreferencesSetupScreen> createState() => _PreferencesSetupScreenState();
}

class _PreferencesSetupScreenState extends State<PreferencesSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  int _cleanlinessLevel = 3;
  double _noiseTolerance = 0.5;
  String _studyHabits = 'Early morning studier';
  String _socialLevel = 'Medium';
  TimeOfDay _wakeUpTime = const TimeOfDay(hour: 5, minute: 0);
  TimeOfDay _sleepTime = const TimeOfDay(hour: 21, minute: 0);

  Future<void> _selectTime(BuildContext context, bool isWakeUp) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isWakeUp ? _wakeUpTime : _sleepTime,
    );
    if (picked != null) {
      setState(() {
        if (isWakeUp) {
          _wakeUpTime = picked;
        } else {
          _sleepTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Temporarily comment out provider until we implement it properly
    // final provider = Provider.of<PreferencesProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LinearProgressIndicator(value: 0.75),
              const SizedBox(height: 16),
              Text(
                'Step 3 of 4',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.brown[700],
                    ),
              ),
              const SizedBox(height: 24),
              Text(
                'Lifestyle Preferences',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.brown,
                    ),
              ),
              const SizedBox(height: 24),
              const Text('Cleanliness Level'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  5,
                  (index) => GestureDetector(
                    onTap: () => setState(() => _cleanlinessLevel = index + 1),
                    child: Icon(
                      index < _cleanlinessLevel
                          ? Icons.sentiment_very_satisfied
                          : Icons.sentiment_very_satisfied_outlined,
                      color: index < _cleanlinessLevel ? Colors.blue : Colors.grey,
                      size: 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Noise Tolerance'),
              Slider(
                value: _noiseTolerance,
                onChanged: (value) => setState(() => _noiseTolerance = value),
                activeColor: Colors.blue,
              ),
              const SizedBox(height: 24),
              const Text('Study Habits'),
              DropdownButtonFormField<String>(
                value: _studyHabits,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Early morning studier',
                    child: Text('Early morning studier'),
                  ),
                  DropdownMenuItem(
                    value: 'Late night studier',
                    child: Text('Late night studier'),
                  ),
                  DropdownMenuItem(
                    value: 'Afternoon studier',
                    child: Text('Afternoon studier'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _studyHabits = value);
                  }
                },
              ),
              const SizedBox(height: 24),
              const Text('Social Level'),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Low'),
                      selected: _socialLevel == 'Low',
                      onSelected: (selected) {
                        if (selected) setState(() => _socialLevel = 'Low');
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Medium'),
                      selected: _socialLevel == 'Medium',
                      onSelected: (selected) {
                        if (selected) setState(() => _socialLevel = 'Medium');
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('High'),
                      selected: _socialLevel == 'High',
                      onSelected: (selected) {
                        if (selected) setState(() => _socialLevel = 'High');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Schedule'),
              ListTile(
                title: const Text('Wake-up Time'),
                trailing: Text(_wakeUpTime.format(context)),
                onTap: () => _selectTime(context, true),
              ),
              ListTile(
                title: const Text('Sleep Time'),
                trailing: Text(_sleepTime.format(context)),
                onTap: () => _selectTime(context, false),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // TODO: Implement preferences saving when provider is ready
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}