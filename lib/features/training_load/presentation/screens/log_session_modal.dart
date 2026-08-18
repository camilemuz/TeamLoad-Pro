import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../providers/training_load_provider.dart';
import '../widgets/category_chip_selector.dart';
import '../widgets/intensity_selector.dart';

class LogSessionModal extends StatefulWidget {
  const LogSessionModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const LogSessionModal(),
    );
  }

  @override
  State<LogSessionModal> createState() => _LogSessionModalState();
}

class _LogSessionModalState extends State<LogSessionModal> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  String? _selectedIntensity;
  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = context.watch<SettingsProvider>();
    if (_selectedCategory == null && settings.categories.isNotEmpty) {
      _selectedCategory = settings.categories.first;
    }
    if (_selectedIntensity == null && settings.intensities.isNotEmpty) {
      _selectedIntensity = settings.intensities.length > 1 ? settings.intensities[1] : settings.intensities.first;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now().add(const Duration(days: 7)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveSession() async {
    if (_selectedCategory == null || _selectedIntensity == null) return;

    setState(() {
      _isSaving = true;
    });

    final authProvider = context.read<AppAuthProvider>();
    final trainingProvider = context.read<TrainingLoadProvider>();
    final userId = authProvider.userId ?? 'tablet_kiosk_player';

    try {
      await trainingProvider.logTrainingLoad(
        userId: userId,
        date: _selectedDate,
        category: _selectedCategory!,
        intensity: _selectedIntensity!,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '¡Voto registrado para $_selectedCategory ($_selectedIntensity)!',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.secondary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final dateFormatted = DateFormat("EEEE, d 'de' MMMM", 'es').format(_selectedDate);

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Barra superior del modal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.how_to_vote, color: AppTheme.primary, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'VOTAR CARGA DE ENTRENAMIENTO',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 16),
              const SizedBox(height: 12),

              // Selector de Fecha
              const Text(
                'FECHA DEL ENTRENAMIENTO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 18, color: AppTheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          dateFormatted,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Selector de Categoría
              const Text(
                'CATEGORÍA DEL JUGADOR',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              if (settings.categories.isEmpty)
                const Text('No hay categorías disponibles',
                    style: TextStyle(color: AppTheme.textHint))
              else
                CategoryChipSelector(
                  categories: settings.categories,
                  selectedCategory: _selectedCategory ?? settings.categories.first,
                  onSelected: (cat) => setState(() => _selectedCategory = cat),
                ),
              const SizedBox(height: 20),

              // Selector de Intensidad
              const Text(
                '¿CÓMO SENTISTE EL ENTRENAMIENTO?',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              if (settings.intensities.isEmpty)
                const Text('No hay niveles de intensidad configurados',
                    style: TextStyle(color: AppTheme.textHint))
              else
                IntensitySelector(
                  intensities: settings.intensities,
                  selectedIntensity: _selectedIntensity ?? settings.intensities.first,
                  onSelected: (intensity) => setState(() => _selectedIntensity = intensity),
                ),
              const SizedBox(height: 28),

              // Botón de Voto con estilo destacado y siempre visible
              FilledButton(
                onPressed: _isSaving ? null : _saveSession,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'REGISTRAR MI VOTO',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
