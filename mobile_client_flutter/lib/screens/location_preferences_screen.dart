import 'package:flutter/material.dart';

class LocationPreferencesScreen extends StatefulWidget {
  const LocationPreferencesScreen({super.key});

  @override
  State<LocationPreferencesScreen> createState() => _LocationPreferencesScreenState();
}

class _LocationPreferencesScreenState extends State<LocationPreferencesScreen> {
  final _budgetController = TextEditingController();
  String _selectedArea = 'Kigali Heights';
  double _maxDistance = 5.0;
  bool _hasTransport = false;

  final List<String> _areas = [
    'Kigali Heights',
    'Nyarugenge',
    'Kimihurura',
    'Kacyiru',
    'Gisozi',
    'Remera',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Preferences'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LinearProgressIndicator(value: 1.0),
            const SizedBox(height: 16),
            Text(
              'Step 4 of 4',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.brown[700],
                  ),
            ),
            const SizedBox(height: 24),
            Text(
              'Location & Budget',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.brown,
                  ),
            ),
            const SizedBox(height: 24),
            const Text('Preferred Area'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedArea,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Select preferred area',
              ),
              items: _areas.map((area) {
                return DropdownMenuItem(
                  value: area,
                  child: Text(area),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedArea = value);
                }
              },
            ),
            const SizedBox(height: 24),
            const Text('Maximum Distance from Campus (km)'),
            Slider(
              value: _maxDistance,
              min: 1.0,
              max: 10.0,
              divisions: 9,
              label: '${_maxDistance.round()} km',
              onChanged: (value) => setState(() => _maxDistance = value),
            ),
            const SizedBox(height: 24),
            const Text('Monthly Budget Range (RWF)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _budgetController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your maximum budget',
                prefixText: 'RWF ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('I have my own transport'),
              value: _hasTransport,
              onChanged: (value) => setState(() => _hasTransport = value),
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
                      // TODO: Save preferences and navigate to home
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                    ),
                    child: const Text('Finish'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }
}