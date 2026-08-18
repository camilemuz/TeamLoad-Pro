import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../providers/training_load_provider.dart';

class VotingKioskScreen extends StatefulWidget {
  final VoidCallback onOpenSuperUser;

  const VotingKioskScreen({
    super.key,
    required this.onOpenSuperUser,
  });

  @override
  State<VotingKioskScreen> createState() => _VotingKioskScreenState();
}

class _VotingKioskScreenState extends State<VotingKioskScreen> with SingleTickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  String? _selectedIntensity;
  bool _isSubmitting = false;
  bool _showSuccessOverlay = false;
  Timer? _resetTimer;
  int _countdownSeconds = 2;
  Timer? _countdownTimer;

  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    _countdownTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = context.watch<SettingsProvider>();
    if (_selectedCategory == null && settings.categories.isNotEmpty) {
      _selectedCategory = settings.categories.first;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 60)),
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

  Future<void> _submitVote(String intensity) async {
    if (_isSubmitting || _showSuccessOverlay) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona tu categoría primero')),
      );
      return;
    }

    setState(() {
      _selectedIntensity = intensity;
      _isSubmitting = true;
    });

    final authProvider = context.read<AppAuthProvider>();
    final trainingProvider = context.read<TrainingLoadProvider>();
    final userId = authProvider.userId ?? 'tablet_player_${DateTime.now().millisecondsSinceEpoch}';

    await trainingProvider.logTrainingLoad(
      userId: userId,
      date: _selectedDate,
      category: _selectedCategory!,
      intensity: intensity,
    );

    if (!mounted) return;

    // Mostrar overlay de éxito
    setState(() {
      _isSubmitting = false;
      _showSuccessOverlay = true;
      _countdownSeconds = 2;
    });

    _animController.forward(from: 0.0);

    // Cuenta regresiva
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(milliseconds: 900), (t) {
      if (!mounted) return;
      setState(() {
        if (_countdownSeconds > 1) {
          _countdownSeconds--;
        }
      });
    });

    // Auto-restablecimiento para el siguiente jugador en 1.8 segundos
    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(milliseconds: 1800), () {
      _resetForNextPlayer();
    });
  }

  void _resetForNextPlayer() {
    _resetTimer?.cancel();
    _countdownTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _showSuccessOverlay = false;
      _selectedIntensity = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final categories = settings.categories;
    final intensities = settings.intensities.isNotEmpty
        ? settings.intensities
        : ['Ligero', 'Normal', 'Fuerte', 'Muy fuerte'];

    final dateFormatted = DateFormat("EEEE, d 'de' MMMM", 'es').format(_selectedDate);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: AppTheme.surface,
            elevation: 1,
            shadowColor: Colors.black.withValues(alpha: 0.1),
            titleSpacing: 16,
            toolbarHeight: 68,
            title: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/logo_mc.png',
                    height: 44,
                    width: 44,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.sports_soccer,
                        color: AppTheme.primary,
                        size: 26,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'MC EMPRENDER',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Votación de Jugadores ⚽',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              // Botón destacado de acceso a Súper Usuario / DT
              FilledButton.icon(
                onPressed: widget.onOpenSuperUser,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.shield_rounded, size: 18, color: Colors.white),
                label: const Text(
                  'Súper Usuario',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Encabezado Principal y Selector de Fecha
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.divider),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 18, color: AppTheme.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'ENTRENAMIENTO DEL DÍA',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.textSecondary,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    dateFormatted,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_calendar_rounded, size: 20, color: AppTheme.textSecondary),
                              tooltip: 'Cambiar fecha',
                              onPressed: _pickDate,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // PASO 1: CATEGORÍA DEL JUGADOR
                      const Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: AppTheme.primary,
                            child: Text(
                              '1',
                              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'ELIGE TU CATEGORÍA',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (categories.isEmpty)
                        const Center(child: Text('Cargando categorías...'))
                      else
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: categories.map((cat) {
                            final isSelected = _selectedCategory == cat;
                            return ChoiceChip(
                              label: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                child: Text(
                                  cat,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (_) {
                                setState(() {
                                  _selectedCategory = cat;
                                });
                              },
                              selectedColor: AppTheme.primary,
                              backgroundColor: AppTheme.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isSelected ? AppTheme.primary : AppTheme.divider,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              showCheckmark: false,
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 24),

                      // PASO 2: ¿CÓMO SENTISTE EL ENTRENAMIENTO?
                      const Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: AppTheme.secondary,
                            child: Text(
                              '2',
                              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '¿CÓMO SENTISTE EL ENTRENAMIENTO HOY?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Toca directamente la tarjeta que mejor describa tu esfuerzo:',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 12),

                      // 4 TARJETAS TÁCTILES GIGANTES DE INTENSIDAD
                      ...intensities.map((intensity) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildIntensityCard(intensity),
                        );
                      }),
                      const SizedBox(height: 16),

                      // BANNER INFERIOR DE ACCESO A ENTRENADOR
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.divider),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.shield_outlined, color: AppTheme.primary, size: 22),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '¿Eres el Entrenador o Analista?',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Ingresa con PIN para ver ACWR y estadísticas',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            FilledButton.tonal(
                              onPressed: widget.onOpenSuperUser,
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              ),
                              child: const Text(
                                'Entrar (PIN)',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // OVERLAY ANIMADO DE ÉXITO Y AUTO-RESET
        if (_showSuccessOverlay)
          Positioned.fill(
            child: GestureDetector(
              onTap: _resetForNextPlayer,
              child: Container(
                color: Colors.black.withValues(alpha: 0.75),
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                      constraints: const BoxConstraints(maxWidth: 420),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: AppTheme.secondary.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_circle_rounded,
                              color: AppTheme.secondary,
                              size: 64,
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            '¡VOTO REGISTRADO!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$_selectedCategory • ${_selectedIntensity ?? ""}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '¡Buen trabajo en el entrenamiento! ⚽',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.divider),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Siguiente jugador en $_countdownSeconds s... (o toca aquí)',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildIntensityCard(String intensity) {
    final color = AppTheme.getIntensityColor(intensity);
    final isSelected = _selectedIntensity == intensity;

    IconData icon;
    String scoreText;
    String description;

    switch (intensity.toLowerCase()) {
      case 'ligero':
        icon = Icons.sentiment_satisfied_alt_rounded;
        scoreText = '25 u.a.';
        description = 'Suave • Calentamiento o recuperación';
        break;
      case 'normal':
        icon = Icons.fitness_center_rounded;
        scoreText = '50 u.a.';
        description = 'Buen ritmo • Carga adecuada y controlada';
        break;
      case 'fuerte':
        icon = Icons.local_fire_department_rounded;
        scoreText = '75 u.a.';
        description = 'Intenso • Gran exigencia física y mental';
        break;
      case 'muy fuerte':
        icon = Icons.bolt_rounded;
        scoreText = '100 u.a.';
        description = 'Al límite • Agotamiento máximo';
        break;
      default:
        icon = Icons.sports_score_rounded;
        scoreText = '50 u.a.';
        description = 'Nivel personalizado';
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isSubmitting ? null : () => _submitVote(intensity),
        borderRadius: BorderRadius.circular(18),
        splashColor: color.withValues(alpha: 0.2),
        highlightColor: color.withValues(alpha: 0.1),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.12) : AppTheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? color : AppTheme.divider,
              width: isSelected ? 2.5 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected ? color.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.02),
                blurRadius: isSelected ? 12 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          intensity.toUpperCase(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: isSelected ? color : AppTheme.textPrimary,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            scoreText,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.1),
                  border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
                ),
                child: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
