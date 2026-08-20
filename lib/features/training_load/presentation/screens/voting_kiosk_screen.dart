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
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              surface: AppTheme.surface,
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

    setState(() {
      _isSubmitting = false;
      _showSuccessOverlay = true;
      _countdownSeconds = 2;
    });

    _animController.forward(from: 0.0);

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(milliseconds: 900), (t) {
      if (!mounted) return;
      setState(() {
        if (_countdownSeconds > 1) {
          _countdownSeconds--;
        }
      });
    });

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
        : ['Muy Ligero', 'Ligero', 'Normal', 'Intenso', 'Muy Intenso'];

    final dateFormatted = DateFormat("EEEE, d 'de' MMMM", 'es').format(_selectedDate);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: AppTheme.surface,
            elevation: 3,
            shadowColor: Colors.black87,
            titleSpacing: 12,
            toolbarHeight: 70,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // LOGO 1: TeamLoad Pro
                Container(
                  height: 40,
                  width: 40,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/app_logo_transparent.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/images/app_logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => const Icon(Icons.fitness_center, color: AppTheme.primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // LOGO 2: Club Deportivo MC Emprender
                Container(
                  height: 40,
                  width: 40,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.secondary.withValues(alpha: 0.4)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/logo_mc.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.sports_soccer, color: AppTheme.secondary),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // TÍTULO DE LA APP Y CLUB
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'TeamLoad Pro',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'MC EMPRENDER ⚽',
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
              // BOTÓN SÚPER USUARIO PROMINENTE EN APPBAR
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: FilledButton.icon(
                  onPressed: widget.onOpenSuperUser,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                  ),
                  icon: const Icon(Icons.admin_panel_settings_rounded, size: 18, color: Colors.white),
                  label: const Text(
                    'Súper Usuario',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.2),
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 720),
                width: double.infinity,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // HERO BANNER PRINCIPAL CON AMBOS LOGOS Y NOMBRE OFICIAL
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.surface,
                              AppTheme.surfaceVariant.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // DUAL BADGE: TeamLoad Pro + MC Emprender
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  height: 52,
                                  width: 52,
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.5)),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                      'assets/images/app_logo_transparent.png',
                                      fit: BoxFit.contain,
                                      errorBuilder: (c, e, s) => Image.asset(
                                        'assets/images/app_logo.png',
                                        fit: BoxFit.contain,
                                        errorBuilder: (c2, e2, s2) => const Icon(Icons.bolt, color: AppTheme.primary),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  height: 52,
                                  width: 52,
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppTheme.secondary.withValues(alpha: 0.5)),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                      'assets/images/logo_mc.png',
                                      fit: BoxFit.contain,
                                      errorBuilder: (c, e, s) => const Icon(Icons.sports_soccer, color: AppTheme.secondary),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 14),
                            // INFO BANNER
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primary.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.5)),
                                        ),
                                        child: const Text(
                                          'TEAMLOAD PRO',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            color: AppTheme.primary,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'MC EMPRENDER',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                          color: AppTheme.secondary,
                                          letterSpacing: 0.6,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  const Text(
                                    'REGISTRO DE ESFUERZO (RPE)',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.textPrimary,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    dateFormatted.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton.filledTonal(
                              icon: const Icon(Icons.calendar_month_rounded, size: 20, color: AppTheme.primary),
                              tooltip: 'Cambiar fecha del entrenamiento',
                              style: IconButton.styleFrom(
                                backgroundColor: AppTheme.surfaceVariant,
                              ),
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
                              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'ELIGE TU CATEGORÍA',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (categories.isEmpty)
                        const Center(child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Text('Cargando categorías...'),
                        ))
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: categories.map((cat) {
                            final isSelected = _selectedCategory == cat;
                            return ChoiceChip(
                              label: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: Text(
                                  cat,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
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
                                  width: isSelected ? 2 : 1.2,
                                ),
                              ),
                              showCheckmark: false,
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 22),

                      // PASO 2: ¿CÓMO SENTISTE EL ENTRENAMIENTO?
                      const Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: AppTheme.secondary,
                            child: Text(
                              '2',
                              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            '¿CÓMO SENTISTE EL ENTRENAMIENTO HOY?',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Toca directamente la tarjeta que mejor describa tu esfuerzo:',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 12),

                      // TARJETAS TÁCTILES DE INTENSIDAD (DINÁMICAS)
                      ...intensities.asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildIntensityCard(entry.value, entry.key, intensities.length),
                        );
                      }),
                      const SizedBox(height: 16),

                      // BANNER INFERIOR DESTACADO DE ACCESO A ENTRENADOR / SÚPER USUARIO
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.surface,
                              AppTheme.surfaceVariant,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.5)),
                                  ),
                                  child: const Icon(Icons.admin_panel_settings_rounded, color: AppTheme.primary, size: 24),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '¿Eres el Entrenador / DT / Analista?',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Ver estadísticas en vivo, ratios ACWR y configuración',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: widget.onOpenSuperUser,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              icon: const Icon(Icons.vpn_key_rounded, size: 18),
                              label: const Text(
                                'Ingresar como Súper Usuario (PIN)',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
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
                color: Colors.black.withValues(alpha: 0.85),
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
                        border: Border.all(color: AppTheme.secondary.withValues(alpha: 0.5), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.secondary.withValues(alpha: 0.3),
                            blurRadius: 35,
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
                              color: AppTheme.secondary.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_circle_rounded,
                              color: AppTheme.secondary,
                              size: 68,
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
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$_selectedCategory • ${_selectedIntensity ?? ""}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '¡Excelente esfuerzo en el entrenamiento! ⚽',
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
                                    strokeWidth: 2.2,
                                    color: AppTheme.secondary,
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

  Widget _buildIntensityCard(String intensity, [int? index, int? total]) {
    final color = AppTheme.getIntensityColor(intensity, index, total);
    final isSelected = _selectedIntensity == intensity;
    final icon = AppTheme.getIntensityIcon(intensity);
    final score = AppTheme.getIntensityScore(intensity, index, total);
    final scoreText = '$score u.a.';
    final description = AppTheme.getIntensityDescription(intensity);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isSubmitting ? null : () => _submitVote(intensity),
        borderRadius: BorderRadius.circular(18),
        splashColor: color.withValues(alpha: 0.25),
        highlightColor: color.withValues(alpha: 0.15),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.18) : AppTheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? color : AppTheme.divider,
              width: isSelected ? 2.5 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected ? color.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.15),
                blurRadius: isSelected ? 14 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withValues(alpha: 0.4)),
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
                            color: color.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: color.withValues(alpha: 0.4)),
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
                  color: color.withValues(alpha: 0.15),
                  border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
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

