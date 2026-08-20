import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../training_load/presentation/providers/training_load_provider.dart';
import '../../../training_load/presentation/widgets/metric_card.dart';
import '../../../training_load/presentation/widgets/load_chart_widget.dart';
import '../providers/settings_provider.dart';

class SuperUserScreen extends StatefulWidget {
  final VoidCallback onExit;

  const SuperUserScreen({
    super.key,
    required this.onExit,
  });

  @override
  State<SuperUserScreen> createState() => _SuperUserScreenState();
}

class _SuperUserScreenState extends State<SuperUserScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _newCategoryController = TextEditingController();
  final _newIntensityController = TextEditingController();
  final _newPinController = TextEditingController();
  bool _isGuideExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _newCategoryController.dispose();
    _newIntensityController.dispose();
    _newPinController.dispose();
    super.dispose();
  }

  void _showEditCategoryDialog(BuildContext context, SettingsProvider provider, String currentCategory) {
    final editController = TextEditingController(text: currentCategory);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Modificar Categoría'),
        content: TextField(
          controller: editController,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nombre de la categoría'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (editController.text.trim().isNotEmpty) {
                provider.editCategory(currentCategory, editController.text.trim());
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showEditIntensityDialog(BuildContext context, SettingsProvider provider, String currentIntensity) {
    final editController = TextEditingController(text: currentIntensity);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Modificar Intensidad'),
        content: TextField(
          controller: editController,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nombre de la intensidad'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (editController.text.trim().isNotEmpty) {
                provider.editIntensity(currentIntensity, editController.text.trim());
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteVote(BuildContext context, TrainingLoadProvider trainingProvider, String voteId, String category, String intensity) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: AppTheme.error),
            SizedBox(width: 8),
            Text('Eliminar Voto'),
          ],
        ),
        content: Text('¿Deseas eliminar este registro de $category ($intensity)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () {
              trainingProvider.deleteTrainingLoad(voteId);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Voto eliminado del registro')),
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showGuideModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.menu_book_rounded, color: AppTheme.primary, size: 24),
                    SizedBox(width: 10),
                    Text(
                      'GUÍA DE LECTURA DE MÉTRICAS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            const Divider(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGuideItem(
                      icon: Icons.speed_rounded,
                      iconColor: AppTheme.primary,
                      title: '¿Qué significa "u.a." (Unidades Arbitrarias)?',
                      content:
                          'En la ciencia del deporte y clubes profesionales, la carga de entrenamiento no se mide en kilogramos ni en kilómetros, sino en **u.a. (Unidades Arbitrarias)**.\n\n'
                          'Representa la magnitud del esfuerzo percibido por los jugadores:\n'
                          '• 🟢 **Muy Ligero = 20 u.a.** (Activación / regenerativo suave)\n'
                          '• 🟢 **Ligero = 40 u.a.** (Sesión suave / calentamiento o descarga)\n'
                          '• 🔵 **Normal = 60 u.a.** (Sesión óptima / ritmo estándar)\n'
                          '• 🟠 **Intenso = 80 u.a.** (Alta exigencia física / competitiva)\n'
                          '• 🔴 **Muy Intenso = 100 u.a.** (Fatiga extrema / máximo esfuerzo al límite)',
                    ),
                    const SizedBox(height: 16),
                    _buildGuideItem(
                      icon: Icons.flash_on_rounded,
                      iconColor: AppTheme.intensityFuerte,
                      title: 'Carga Aguda (Últimos 7 días)',
                      content:
                          'Representa la **fatiga reciente acumulada** por el equipo en la última semana.\n\n'
                          'Si la Carga Aguda sube de forma repentina sin que el equipo esté preparado, el riesgo de lesión muscular se dispara.',
                    ),
                    const SizedBox(height: 16),
                    _buildGuideItem(
                      icon: Icons.shield_rounded,
                      iconColor: AppTheme.secondary,
                      title: 'Carga Crónica (Últimos 28 días)',
                      content:
                          'Representa la **condición física y base de resistencia** construida en el último mes (4 semanas).\n\n'
                          'Una Carga Crónica alta y progresiva actúa como un **"escudo protector"** que hace a los futbolistas más resistentes a las lesiones.',
                    ),
                    const SizedBox(height: 16),
                    _buildGuideItem(
                      icon: Icons.traffic_rounded,
                      iconColor: AppTheme.primary,
                      title: 'Semáforo del Ratio ACWR (Carga Aguda ÷ Crónica)',
                      content:
                          'Es la métrica dorada recomendada por la FIFA y comités olímpicos para prevenir sobrecargas:\n\n'
                          '• 🟢 **0.8 a 1.3 (Óptimo / "Zona Dulce")**: El equipo está en su mejor estado de rendimiento físico con mínimo riesgo de lesión.\n'
                          '• 🟠 **1.3 a 1.5 (Atención)**: La fatiga está creciendo rápido. Se aconseja priorizar recuperación, masajes e hidratación.\n'
                          '• 🔴 **> 1.5 (Riesgo Alto / Zona Peligrosa)**: Sobrecarga severa. El riesgo de contracturas o roturas se multiplica por 3. Se recomienda reducir la intensidad del próximo entrenamiento.\n'
                          '• 🔵 **< 0.8 (Descarga / Desentrenamiento)**: El equipo viene de un periodo de baja exigencia o descanso prolongado.',
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              height: 1.45,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary, size: 24),
          tooltip: 'Volver a Votación de Jugadores',
          onPressed: widget.onExit,
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // LOGO 1: TeamLoad Pro
            Container(
              height: 34,
              width: 34,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  'assets/images/app_logo_transparent.png',
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) => Image.asset(
                    'assets/images/app_logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (c2, e2, s2) => const Icon(Icons.bolt, color: AppTheme.primary, size: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            // LOGO 2: MC Emprender
            Container(
              height: 34,
              width: 34,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.secondary.withValues(alpha: 0.4)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  'assets/images/logo_mc.png',
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, err, st) => const Icon(Icons.shield, color: AppTheme.secondary, size: 18),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'TeamLoad Pro',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    'PANEL DT • MC EMPRENDER ⚽',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10, color: AppTheme.secondary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: AppTheme.primary, size: 24),
            tooltip: 'Guía de Métricas Deportivas',
            onPressed: () => _showGuideModal(context),
          ),
          const SizedBox(width: 2),
          IconButton(
            icon: const Icon(Icons.lock_outline_rounded, color: AppTheme.textSecondary, size: 22),
            tooltip: 'Bloquear / Cerrar Sesión Súper Usuario',
            onPressed: () {
              context.read<SettingsProvider>().logoutSuperUser();
              widget.onExit();
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.analytics_outlined), text: 'Estadísticas & Ratios'),
            Tab(icon: Icon(Icons.settings_outlined), text: 'Gestión & Ajustes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatsTab(context),
          _buildSettingsTab(context),
        ],
      ),
    );
  }

  Widget _buildStatsTab(BuildContext context) {
    final trainingProvider = context.watch<TrainingLoadProvider>();
    final settingsProvider = context.watch<SettingsProvider>();

    final totalVotes = trainingProvider.totalVotesInPeriod;
    final acuteLoad = trainingProvider.acuteLoad;
    final chronicLoad = trainingProvider.chronicLoad;
    final acwr = trainingProvider.acwrRatio;

    String acwrStatus = 'Óptimo';
    Color acwrColor = AppTheme.secondary;
    String acwrDescription = 'Zona dulce: Alta preparación física y mínimo riesgo de lesión.';
    if (acwr > 1.5) {
      acwrStatus = 'Riesgo Alto';
      acwrColor = AppTheme.error;
      acwrDescription = '¡Peligro! Fatiga excesiva. Alto riesgo de lesión muscular.';
    } else if (acwr > 1.3) {
      acwrStatus = 'Atención';
      acwrColor = AppTheme.intensityFuerte;
      acwrDescription = 'Incremento rápido de fatiga. Conviene priorizar descanso.';
    } else if (acwr < 0.8 && acwr > 0) {
      acwrStatus = 'Descarga';
      acwrColor = AppTheme.intensityNormal;
      acwrDescription = 'Nivel bajo de exigencia o semana de recuperación.';
    }

    final allCategories = ['Todas', ...settingsProvider.categories];
    final distribution = trainingProvider.intensityDistribution;

    return RefreshIndicator(
      onRefresh: () async {
        trainingProvider.subscribeToTeamLoads();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TARJETA INFORMATIVA / GUÍA DESPLEGABLE
            Container(
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.25)),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  initiallyExpanded: _isGuideExpanded,
                  onExpansionChanged: (exp) => setState(() => _isGuideExpanded = exp),
                  leading: const CircleAvatar(
                    backgroundColor: AppTheme.primary,
                    radius: 16,
                    child: Icon(Icons.info_outline_rounded, color: Colors.white, size: 18),
                  ),
                  title: const Text(
                    '¿Cómo leer estas métricas? (¿Qué es u.a. y ACWR?)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                    ),
                  ),
                  subtitle: const Text(
                    'Toca aquí para ver la explicación deportiva en lenguaje simple',
                    style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          _buildMiniGuideRow(
                            'u.a.',
                            'Unidades Arbitrarias: Escala de cansancio (Muy Ligero=20, Ligero=40, Normal=60, Intenso=80, Muy Intenso=100).',
                          ),
                          const SizedBox(height: 8),
                          _buildMiniGuideRow(
                            'Carga Aguda (7d)',
                            'Fatiga reciente de la última semana. Si sube de golpe, hay riesgo de lesión.',
                          ),
                          const SizedBox(height: 8),
                          _buildMiniGuideRow(
                            'Carga Crónica (28d)',
                            'Condición física acumulada del último mes. Es el "escudo protector" del equipo.',
                          ),
                          const SizedBox(height: 8),
                          _buildMiniGuideRow(
                            'Ratio ACWR',
                            'Cociente Agudo ÷ Crónico. 🟢 0.8-1.3 es Óptimo | 🟠 1.3-1.5 es Atención | 🔴 >1.5 es Riesgo Alto.',
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () => _showGuideModal(context),
                              icon: const Icon(Icons.open_in_new, size: 16),
                              label: const Text('Ver Guía Completa Detallada'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Selector de Periodo de Análisis (Día / Semana / Mes / Todo)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'PERIODO DE ANÁLISIS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildPeriodButton(
                        label: 'Día',
                        isSelected: trainingProvider.selectedDateFilter == DateFilter.day,
                        onTap: () => trainingProvider.setDateFilter(DateFilter.day),
                      ),
                      _buildPeriodButton(
                        label: 'Semana',
                        isSelected: trainingProvider.selectedDateFilter == DateFilter.week,
                        onTap: () => trainingProvider.setDateFilter(DateFilter.week),
                      ),
                      _buildPeriodButton(
                        label: 'Mes',
                        isSelected: trainingProvider.selectedDateFilter == DateFilter.month,
                        onTap: () => trainingProvider.setDateFilter(DateFilter.month),
                      ),
                      _buildPeriodButton(
                        label: 'Todo',
                        isSelected: trainingProvider.selectedDateFilter == DateFilter.all,
                        onTap: () => trainingProvider.setDateFilter(DateFilter.all),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 4 TARJETAS DE MÉTRICAS RESPONSIVAS (2x2 en móviles, 1x4 en Desktop)
            LayoutBuilder(
              builder: (context, constraints) {
                final card1 = MetricCard(
                  title: 'Votaciones',
                  value: totalVotes.toString(),
                  subtitle: _getPeriodSubtitle(trainingProvider.selectedDateFilter),
                  statusColor: AppTheme.primary,
                );
                final card2 = MetricCard(
                  title: 'Carga Aguda (7d)',
                  value: '${acuteLoad.toStringAsFixed(0)} u.a.',
                  subtitle: 'Fatiga reciente',
                  statusColor: AppTheme.intensityFuerte,
                );
                final card3 = MetricCard(
                  title: 'Carga Crónica (28d)',
                  value: '${chronicLoad.toStringAsFixed(0)} u.a.',
                  subtitle: 'Base física',
                  statusColor: AppTheme.primary,
                );
                final card4 = MetricCard(
                  title: 'Ratio ACWR',
                  value: acwr.toStringAsFixed(2),
                  subtitle: acwrStatus,
                  statusColor: acwrColor,
                );

                if (constraints.maxWidth < 600) {
                  // Cuadrícula 2x2 para móviles
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: card1),
                          const SizedBox(width: 8),
                          Expanded(child: card2),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: card3),
                          const SizedBox(width: 8),
                          Expanded(child: card4),
                        ],
                      ),
                    ],
                  );
                } else {
                  // 1 fila de 4 para tablets y escritorios
                  return Row(
                    children: [
                      Expanded(child: card1),
                      const SizedBox(width: 8),
                      Expanded(child: card2),
                      const SizedBox(width: 8),
                      Expanded(child: card3),
                      const SizedBox(width: 8),
                      Expanded(child: card4),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 16),

            // SEMÁFORO VISUAL DE RIESGO ACWR (TERMÓMETRO)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'SEMÁFORO DE PREVENCIÓN DE LESIONES (ACWR)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: acwrColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: acwrColor.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(radius: 4, backgroundColor: acwrColor),
                            const SizedBox(width: 6),
                            Text(
                              acwrStatus.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: acwrColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Barra visual segmentada
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      height: 10,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 8,
                            child: Container(
                              color: acwr < 0.8 && acwr > 0 ? AppTheme.intensityNormal : AppTheme.intensityNormal.withValues(alpha: 0.3),
                            ),
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            flex: 5,
                            child: Container(
                              color: acwr >= 0.8 && acwr <= 1.3 ? AppTheme.secondary : AppTheme.secondary.withValues(alpha: 0.3),
                            ),
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            flex: 2,
                            child: Container(
                              color: acwr > 1.3 && acwr <= 1.5 ? AppTheme.intensityFuerte : AppTheme.intensityFuerte.withValues(alpha: 0.3),
                            ),
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            flex: 5,
                            child: Container(
                              color: acwr > 1.5 ? AppTheme.error : AppTheme.error.withValues(alpha: 0.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('0.0 (Descarga)', style: TextStyle(fontSize: 10, color: AppTheme.textHint)),
                      Text('0.8 - 1.3 (Óptimo)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondary)),
                      Text('1.3 - 1.5 (Atención)', style: TextStyle(fontSize: 10, color: AppTheme.intensityFuerte)),
                      Text('> 1.5 (Riesgo)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.error)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    acwrDescription,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: acwrColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // FILTRO HORIZONTAL DE CATEGORÍAS
            const Text(
              'FILTRAR POR CATEGORÍA',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppTheme.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: allCategories.map((cat) {
                  final isSelected = trainingProvider.selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (_) => trainingProvider.setCategoryFilter(cat),
                      selectedColor: AppTheme.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textSecondary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 13,
                      ),
                      backgroundColor: AppTheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isSelected ? AppTheme.primary : AppTheme.divider,
                        ),
                      ),
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 18),

            // DISTRIBUCIÓN DE VOTOS POR NIVEL DE ESFUERZO
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DISTRIBUCIÓN DE VOTOS POR NIVEL DE ESFUERZO',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Builder(
                    builder: (context) {
                      final activeIntensities = settingsProvider.intensities.isNotEmpty
                          ? settingsProvider.intensities
                          : ['Muy Ligero', 'Ligero', 'Normal', 'Intenso', 'Muy Intenso'];
                      return Row(
                        children: activeIntensities.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final name = entry.value;
                          final score = AppTheme.getIntensityScore(name, idx, activeIntensities.length);
                          final color = AppTheme.getIntensityColor(name, idx, activeIntensities.length);
                          final count = distribution[name] ?? 0;
                          return _buildDistributionItem('$name ($score)', count, totalVotes, color);
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // GRÁFICO SEMANAL DE CURVA DE INTENSIDAD (Lunes a Domingo)
            LoadChartWidget(
              weeklyData: trainingProvider.weeklyDayLoads,
            ),
            const SizedBox(height: 24),

            // HISTORIAL DETALLADO DE VOTOS EN VIVO
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'HISTORIAL EN VIVO DE VOTOS REGISTRADOS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '$totalVotes votos en periodo',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (trainingProvider.filteredLoads.isEmpty)
              Container(
                padding: const EdgeInsets.all(28),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.how_to_vote_outlined, size: 40, color: AppTheme.textHint),
                    SizedBox(height: 8),
                    Text(
                      'Sin votos en este periodo',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Los votos emitidos por los jugadores en la tablet aparecerán aquí en vivo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: trainingProvider.filteredLoads.length,
                separatorBuilder: (context, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final load = trainingProvider.filteredLoads[index];
                  final color = AppTheme.getIntensityColor(load.intensity);
                  final dateStr = DateFormat("d 'de' MMMM, yyyy - HH:mm", 'es').format(load.date);

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.sports_soccer, color: color, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                load.category,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                dateStr,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            load.intensity,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.textHint),
                          tooltip: 'Eliminar este voto',
                          onPressed: () => _confirmDeleteVote(
                            context,
                            trainingProvider,
                            load.id,
                            load.category,
                            load.intensity,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniGuideRow(String term, String definition) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            term,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            definition,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textPrimary,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTab(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sección Categorías
          const Text(
            'CATEGORÍAS DE ENTRENAMIENTO',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Toca una categoría para renombrarla o pulsa el icono de eliminar.',
            style: TextStyle(fontSize: 11, color: AppTheme.textHint),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: settingsProvider.categories.map((cat) {
              return InputChip(
                avatar: const Icon(Icons.edit_outlined, size: 14, color: AppTheme.primary),
                label: Text(cat),
                onPressed: () => _showEditCategoryDialog(context, settingsProvider, cat),
                onDeleted: () => settingsProvider.removeCategory(cat),
                deleteIcon: const Icon(Icons.cancel, size: 16),
                backgroundColor: AppTheme.surfaceVariant,
                side: const BorderSide(color: AppTheme.divider),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newCategoryController,
                  decoration: const InputDecoration(
                    hintText: 'Añadir nueva categoría...',
                    isDense: true,
                  ),
                  onSubmitted: (val) {
                    if (val.trim().isNotEmpty) {
                      settingsProvider.addCategory(val);
                      _newCategoryController.clear();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(backgroundColor: AppTheme.primary),
                onPressed: () {
                  if (_newCategoryController.text.trim().isNotEmpty) {
                    settingsProvider.addCategory(_newCategoryController.text);
                    _newCategoryController.clear();
                  }
                },
              ),
            ],
          ),
          const Divider(height: 36),

          // Sección Intensidades
          const Text(
            'NIVELES DE INTENSIDAD',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Toca una intensidad para modificar su nombre.',
            style: TextStyle(fontSize: 11, color: AppTheme.textHint),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: settingsProvider.intensities.map((intensity) {
              final color = AppTheme.getIntensityColor(intensity);
              return InputChip(
                avatar: Icon(Icons.edit_outlined, size: 14, color: color),
                label: Text(intensity),
                onPressed: () => _showEditIntensityDialog(context, settingsProvider, intensity),
                onDeleted: () => settingsProvider.removeIntensity(intensity),
                deleteIcon: const Icon(Icons.cancel, size: 16),
                backgroundColor: AppTheme.surfaceVariant,
                side: const BorderSide(color: AppTheme.divider),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newIntensityController,
                  decoration: const InputDecoration(
                    hintText: 'Añadir nuevo nivel de intensidad...',
                    isDense: true,
                  ),
                  onSubmitted: (val) {
                    if (val.trim().isNotEmpty) {
                      settingsProvider.addIntensity(val);
                      _newIntensityController.clear();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(backgroundColor: AppTheme.primary),
                onPressed: () {
                  if (_newIntensityController.text.trim().isNotEmpty) {
                    settingsProvider.addIntensity(_newIntensityController.text);
                    _newIntensityController.clear();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (dCtx) => AlertDialog(
                    title: const Text('¿Restablecer Intensidades?'),
                    content: const Text('Se configurarán los 5 niveles oficiales:\n• Muy Ligero (20 u.a.)\n• Ligero (40 u.a.)\n• Normal (60 u.a.)\n• Intenso (80 u.a.)\n• Muy Intenso (100 u.a.)'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(dCtx).pop(false), child: const Text('Cancelar')),
                      FilledButton(onPressed: () => Navigator.of(dCtx).pop(true), child: const Text('Restablecer')),
                    ],
                  ),
                );
                if (confirm == true) {
                  await settingsProvider.restoreDefaultIntensities();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Intensidades restablecidas a los 5 niveles oficiales')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.restore, size: 16),
              label: const Text(
                'Restablecer a los 5 niveles oficiales (Muy Ligero, Ligero, Normal, Intenso, Muy Intenso)',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
          const Divider(height: 36),

          // Sección Cambiar PIN
          const Text(
            'CAMBIAR PIN DE SÚPER USUARIO',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newPinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Nuevo PIN (mín. 4 dígitos)',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.tonal(
                onPressed: () {
                  if (_newPinController.text.length >= 4) {
                    settingsProvider.updatePin(_newPinController.text);
                    _newPinController.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('¡PIN actualizado con éxito!')),
                    );
                  }
                },
                child: const Text('Guardar PIN'),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPeriodButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildDistributionItem(String label, int count, int total, Color color) {
    final pct = total > 0 ? (count / total * 100).toStringAsFixed(0) : '0';
    return Expanded(
      child: Column(
        children: [
          Text(
            '$count ($pct%)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _getPeriodSubtitle(DateFilter filter) {
    switch (filter) {
      case DateFilter.day:
        return 'Hoy';
      case DateFilter.week:
        return 'Esta Semana';
      case DateFilter.month:
        return 'Este Mes';
      case DateFilter.all:
        return 'Todo el histórico';
    }
  }
}
