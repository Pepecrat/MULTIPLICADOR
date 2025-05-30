import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/audio_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AudioService _audioService = AudioService();
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Por ahora solo cargamos la configuración de sonido
    setState(() {
      _soundEnabled = _audioService.isSoundEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackPearl,
      appBar: AppBar(
        title: const Text(
          'OPCIONES',
          style: TextStyle(
            fontFamily: 'PressStart2P',
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: AppColors.blackPearl,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Sonido y Vibración'),
          const SizedBox(height: 16),
          _buildSettingTile(
            title: 'Efectos de sonido',
            subtitle: 'Reproduccir sonidos durante el juego',
            icon: Icons.volume_up,
            value: _soundEnabled,
            onChanged: (value) async {
              await _audioService.toggleSound();
              setState(() {
                _soundEnabled = _audioService.isSoundEnabled;
              });
            },
          ),
          const Divider(color: Colors.white10),
          _buildSettingTile(
            title: 'Vibración',
            subtitle: 'Vibrar en eventos importantes',
            icon: Icons.vibration,
            value: _vibrationEnabled,
            onChanged: (value) {
              setState(() {
                _vibrationEnabled = value;
              });
              // TODO: Implementar guardado de esta configuración
            },
          ),
          const SizedBox(height: 32),

          _buildSectionTitle('Sobre el juego'),
          const SizedBox(height: 16),
          _buildInfoTile(
            title: 'Versión',
            content: '1.0.0',
            icon: Icons.info_outline,
          ),
          const Divider(color: Colors.white10),
          _buildInfoTile(
            title: 'Cómo jugar',
            content: 'Haz una apuesta y retira antes de que explote el barco',
            icon: Icons.help_outline,
            onTap: () {
              _showHowToPlayDialog(context);
            },
          ),
          const Divider(color: Colors.white10),
          _buildInfoTile(
            title: 'Desarrollador',
            content: 'Black Pearl Studios',
            icon: Icons.code,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: AppColors.java,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.java.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.java),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.java,
        activeTrackColor: AppColors.java.withOpacity(0.5),
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String content,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.funBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.funBlue),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        content,
        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
      ),
      trailing:
          onTap != null
              ? const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.white24,
              )
              : null,
    );
  }

  void _showHowToPlayDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.blackPearl,
            title: const Text(
              'Cómo Jugar',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInstructionStep(
                    '1',
                    'Ingresa tu apuesta',
                    'Escribe la cantidad en USD que quieres apostar.',
                    Icons.attach_money,
                  ),
                  const SizedBox(height: 24),
                  _buildInstructionStep(
                    '2',
                    'Observa el multiplicador',
                    'El multiplicador aumenta con el tiempo. Entre más alto, mayor será tu ganancia potencial.',
                    Icons.trending_up,
                  ),
                  const SizedBox(height: 24),
                  _buildInstructionStep(
                    '3',
                    'Haz Cashout a tiempo',
                    'Presiona "CASH OUT" antes de que explote el barco para ganar tu apuesta multiplicada.',
                    Icons.warning,
                  ),
                  const SizedBox(height: 24),
                  _buildInstructionStep(
                    '4',
                    'Si el barco explota...',
                    'Pierdes tu apuesta. El juego se reiniciará automáticamente después de 3 segundos.',
                    Icons.cancel,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'ENTENDIDO',
                  style: TextStyle(
                    color: AppColors.java,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildInstructionStep(
    String step,
    String title,
    String description,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.mediumPurple.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: const TextStyle(
                color: AppColors.mediumPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: AppColors.java),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
