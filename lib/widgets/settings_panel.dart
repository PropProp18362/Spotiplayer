import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../models/spotify_models.dart';

class SettingsPanel extends StatefulWidget {
  final VisualizationStyle currentStyle;
  final Map<String, dynamic> settings;
  final Function(VisualizationStyle) onStyleChanged;
  final Function(Map<String, dynamic>) onSettingsChanged;
  final VoidCallback onClearSettings;
  final VoidCallback onClose;

  const SettingsPanel({
    Key? key,
    required this.currentStyle,
    required this.settings,
    required this.onStyleChanged,
    required this.onSettingsChanged,
    required this.onClearSettings,
    required this.onClose,
  }) : super(key: key);

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Map<String, dynamic> _currentSettings;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentSettings = Map.from(widget.settings);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateSetting(String key, dynamic value) {
    setState(() {
      _currentSettings[key] = value;
    });
    widget.onSettingsChanged(_currentSettings);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final panelWidth = constraints.maxWidth.clamp(280.0, 400.0);
        
        return GlassmorphicContainer(
          width: panelWidth,
          height: double.infinity,
          borderRadius: 0,
          blur: 20,
          alignment: Alignment.centerLeft,
          border: 0,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black.withOpacity(0.3),
              Colors.black.withOpacity(0.1),
            ],
          ),
          borderGradient: const LinearGradient(
            colors: [Colors.transparent, Colors.transparent],
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),
                
                // Tab bar
                _buildTabBar(),
                
                // Tab content - scrollable to prevent overflow
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildVisualizationTab(),
                      ),
                      SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildAudioTab(),
                      ),
                      SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildAppearanceTab(),
                      ),
                    ],
                  ),
                ),
                
                // Clear button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildClearButton(),
                ),
              ],
            ),
          ),
        ).animate().slideX(begin: 1, end: 0, duration: 300.ms);
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Icon(
            Icons.settings,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          const Text(
            'Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: widget.onClose,
            icon: const Icon(
              Icons.close,
              color: Colors.white70,
            ),
            tooltip: 'Close Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.white.withOpacity(0.1),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.purple.shade400],
          ),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Visual'),
          Tab(text: 'Audio'),
          Tab(text: 'Style'),
        ],
      ),
    );
  }

  Widget _buildVisualizationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Visualization Style'),
          const SizedBox(height: 16),
          
          // Style selector
          ...VisualizationStyle.values.map((style) => _buildStyleOption(style)),
          
          const SizedBox(height: 24),
          _buildSectionTitle('Visualization Settings'),
          const SizedBox(height: 16),
          
          // Sensitivity
          _buildSliderSetting(
            'Sensitivity',
            'sensitivity',
            0.1,
            3.0,
            _currentSettings['sensitivity']?.toDouble() ?? 1.0,
          ),
          
          // Smoothing
          _buildSliderSetting(
            'Smoothing',
            'smoothing',
            0.1,
            0.95,
            _currentSettings['smoothing']?.toDouble() ?? 0.8,
          ),
          
          // Show peaks
          _buildSwitchSetting(
            'Show Peaks',
            'showPeaks',
            _currentSettings['showPeaks'] ?? true,
          ),
          
          // React to beats
          _buildSwitchSetting(
            'React to Beats',
            'reactToBeats',
            _currentSettings['reactToBeats'] ?? true,
          ),
        ],
      ),
    );
  }

  Widget _buildAudioTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Frequency Response'),
          const SizedBox(height: 16),
          
          // Bass boost
          _buildSliderSetting(
            'Bass Boost',
            'bassBoost',
            0.5,
            3.0,
            _currentSettings['bassBoost']?.toDouble() ?? 1.0,
          ),
          
          // Treble boost
          _buildSliderSetting(
            'Treble Boost',
            'trebleBoost',
            0.5,
            3.0,
            _currentSettings['trebleBoost']?.toDouble() ?? 1.0,
          ),
          
          const SizedBox(height: 24),
          _buildSectionTitle('Audio Analysis'),
          const SizedBox(height: 16),
          
          // Beat sensitivity
          _buildSliderSetting(
            'Beat Sensitivity',
            'beatSensitivity',
            0.1,
            2.0,
            _currentSettings['beatSensitivity']?.toDouble() ?? 1.0,
          ),
          
          // Frequency bands
          _buildSliderSetting(
            'Frequency Bands',
            'frequencyBands',
            32,
            128,
            _currentSettings['frequencyBands']?.toDouble() ?? 64,
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Colors'),
          const SizedBox(height: 16),
          
          // Primary color
          _buildColorSetting(
            'Primary Color',
            'primaryColor',
            _currentSettings['primaryColor'] ?? Colors.blue,
          ),
          
          // Secondary color
          _buildColorSetting(
            'Secondary Color',
            'secondaryColor',
            _currentSettings['secondaryColor'] ?? Colors.purple,
          ),
          
          const SizedBox(height: 24),
          _buildSectionTitle('Effects'),
          const SizedBox(height: 16),
          
          // Glow effect
          _buildSwitchSetting(
            'Glow Effect',
            'glowEffect',
            _currentSettings['glowEffect'] ?? true,
          ),
          
          // Particle count (for particle visualizer)
          _buildSliderSetting(
            'Particle Count',
            'particleCount',
            50,
            500,
            _currentSettings['particleCount']?.toDouble() ?? 200,
          ),
          
          // Animation speed
          _buildSliderSetting(
            'Animation Speed',
            'animationSpeed',
            0.5,
            3.0,
            _currentSettings['animationSpeed']?.toDouble() ?? 1.0,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildStyleOption(VisualizationStyle style) {
    final isSelected = widget.currentStyle == style;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => widget.onStyleChanged(style),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.white.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.2),
                      Colors.purple.withOpacity(0.2),
                    ],
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                style.displayName,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                style.description,
                style: TextStyle(
                  color: isSelected ? Colors.white70 : Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate(target: isSelected ? 1 : 0).scale(duration: 200.ms);
  }

  Widget _buildSliderSetting(String title, String key, double min, double max, double value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Text(
                value.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.blue,
              inactiveTrackColor: Colors.white.withOpacity(0.2),
              thumbColor: Colors.white,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: (newValue) => _updateSetting(key, newValue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchSetting(String title, String key, bool value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Switch(
            value: value,
            onChanged: (newValue) => _updateSetting(key, newValue),
            activeColor: Colors.blue,
            activeTrackColor: Colors.blue.withOpacity(0.3),
            inactiveThumbColor: Colors.white54,
            inactiveTrackColor: Colors.white.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSetting(String title, String key, Color value) {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
      Colors.pink,
      Colors.cyan,
      Colors.teal,
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: colors.map((color) {
              final isSelected = value.value == color.value;
              return GestureDetector(
                onTap: () => _updateSetting(key, color),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildClearButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              _currentSettings.clear();
              _currentSettings.addAll({
                'sensitivity': 1.0,
                'smoothing': 0.8,
                'showPeaks': true,
                'reactToBeats': true,
                'bassBoost': 1.0,
                'trebleBoost': 1.0,
                'primaryColor': Colors.blue,
                'secondaryColor': Colors.purple,
              });
            });
            widget.onClearSettings();
            widget.onSettingsChanged(_currentSettings);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.withOpacity(0.8),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Reset to Defaults',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}