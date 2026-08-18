import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../providers/training_load_provider.dart';
import '../widgets/metric_card.dart';
import '../widgets/load_chart_widget.dart';
import 'log_session_modal.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trainingProvider = context.watch<TrainingLoadProvider>();
    final settingsProvider = context.watch<SettingsProvider>();

    final totalVotes = trainingProvider.totalVotesInPeriod;
    final avgIntensity = trainingProvider.averageIntensityInPeriod;
    final acwr = trainingProvider.acwrRatio;

    String acwrStatus = 'Óptimo';
    Color acwrColor = AppTheme.secondary;
    if (acwr > 1.5) {
      acwrStatus = 'Riesgo Alto';
      acwrColor = AppTheme.error;
    } else if (acwr > 1.3) {
      acwrStatus = 'Atención';
      acwrColor = AppTheme.intensityFuerte;
    } else if (acwr < 0.8 && acwr > 0) {
      acwrStatus = 'Descarga';
      acwrColor = AppTheme.intensityNormal;
    }

    final allCategories = ['Todas', ...settingsProvider.categories];
    final distribution = trainingProvider.intensityDistribution;

    return Scaffold(
      body: trainingProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                trainingProvider.subscribeToTeamLoads();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cabecera del Analista con selector de periodo (Día / Semana / Mes)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cuadro de Mando del Analista',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.textPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Monitoreo de votaciones y cargas en vivo',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Selector de Periodo: Día, Semana, Mes
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
                                context,
                                label: 'Día',
                                isSelected: trainingProvider.selectedDateFilter == DateFilter.day,
                                onTap: () => trainingProvider.setDateFilter(DateFilter.day),
                              ),
                              _buildPeriodButton(
                                context,
                                label: 'Semana',
                                isSelected: trainingProvider.selectedDateFilter == DateFilter.week,
                                onTap: () => trainingProvider.setDateFilter(DateFilter.week),
                              ),
                              _buildPeriodButton(
                                context,
                                label: 'Mes',
                                isSelected: trainingProvider.selectedDateFilter == DateFilter.month,
                                onTap: () => trainingProvider.setDateFilter(DateFilter.month),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Tarjetas de Métricas de Rendimiento
                    Row(
                      children: [
                        MetricCard(
                          title: 'Votaciones',
                          value: totalVotes.toString(),
                          subtitle: _getPeriodSubtitle(trainingProvider.selectedDateFilter),
                          statusColor: AppTheme.primary,
                        ),
                        const SizedBox(width: 10),
                        MetricCard(
                          title: 'Carga Promedio',
                          value: '${avgIntensity.toStringAsFixed(0)} u.a.',
                          subtitle: _getIntensityLabel(avgIntensity),
                          statusColor: _getIntensityColor(avgIntensity),
                        ),
                        const SizedBox(width: 10),
                        MetricCard(
                          title: 'Ratio ACWR',
                          value: acwr.toStringAsFixed(2),
                          subtitle: acwrStatus,
                          statusColor: acwrColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Filtro de Categorías
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
                                borderRadius: BorderRadius.circular(20),
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
                    const SizedBox(height: 20),

                    // Distribución de Votos por Intensidad (Barra Visual)
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
                            'DISTRIBUCIÓN DE VOTOS DE LOS JUGADORES',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildDistributionItem('Ligero', distribution['Ligero'] ?? 0, totalVotes, AppTheme.intensityLigero),
                              _buildDistributionItem('Normal', distribution['Normal'] ?? 0, totalVotes, AppTheme.intensityNormal),
                              _buildDistributionItem('Fuerte', distribution['Fuerte'] ?? 0, totalVotes, AppTheme.intensityFuerte),
                              _buildDistributionItem('Muy fuerte', distribution['Muy fuerte'] ?? 0, totalVotes, AppTheme.intensityMuyFuerte),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Gráfico Semanal
                    LoadChartWidget(
                      weeklyData: trainingProvider.weeklyDayLoads,
                    ),
                    const SizedBox(height: 24),

                    // Historial de Votos
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'REGISTRO DETALLADO DE VOTOS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          '$totalVotes registrados',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (trainingProvider.filteredLoads.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.divider),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.how_to_vote_outlined,
                                size: 48, color: AppTheme.textHint.withValues(alpha: 0.5)),
                            const SizedBox(height: 12),
                            const Text(
                              'Aún no hay votos en este periodo',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Los votos que hagan los jugadores desde la tablet aparecerán aquí en vivo.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
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
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.divider),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.sports_soccer, color: color, size: 20),
                                ),
                                const SizedBox(width: 14),
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
                                      const SizedBox(height: 2),
                                      Text(
                                        dateStr,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    load.intensity,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => LogSessionModal.show(context),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.how_to_vote, color: Colors.white),
        label: const Text(
          'Votar Carga (Tablet)',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildPeriodButton(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

  String _getIntensityLabel(double score) {
    if (score == 0) return 'Sin datos';
    if (score <= 35) return 'Ligera';
    if (score <= 60) return 'Moderada';
    if (score <= 85) return 'Fuerte';
    return 'Muy Fuerte';
  }

  Color _getIntensityColor(double score) {
    if (score <= 35) return AppTheme.intensityLigero;
    if (score <= 60) return AppTheme.intensityNormal;
    if (score <= 85) return AppTheme.intensityFuerte;
    return AppTheme.intensityMuyFuerte;
  }
}
