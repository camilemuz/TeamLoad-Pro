import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../settings/presentation/screens/super_user_screen.dart';
import '../providers/training_load_provider.dart';
import 'voting_kiosk_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSuperUserViewActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrainingLoadProvider>().subscribeToTeamLoads();
      context.read<SettingsProvider>().loadSettings();
    });
  }

  void _openSuperUserGate() {
    final settingsProvider = context.read<SettingsProvider>();
    if (settingsProvider.isSuperUser) {
      setState(() {
        _isSuperUserViewActive = true;
      });
      return;
    }

    _showPinDialog(context);
  }

  void _showPinDialog(BuildContext context) {
    String currentPin = '';
    String? errorMessage;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            void verify([String? customPin]) {
              final pinToTest = (customPin ?? currentPin).trim();
              if (pinToTest.isEmpty) {
                setDialogState(() {
                  errorMessage = 'Ingresa el PIN de acceso';
                });
                return;
              }
              final settings = dialogCtx.read<SettingsProvider>();
              final success = settings.authenticateSuperUser(pinToTest);
              if (success) {
                Navigator.of(dialogCtx).pop();
                setState(() {
                  _isSuperUserViewActive = true;
                });
              } else {
                setDialogState(() {
                  errorMessage = 'PIN incorrecto (Prueba 1234)';
                  currentPin = '';
                });
              }
            }

            void onKeyPressed(String key) {
              if (currentPin.length < 6) {
                setDialogState(() {
                  errorMessage = null;
                  currentPin += key;
                });
                if (currentPin.length == 4) {
                  verify();
                }
              }
            }

            void onBackspace() {
              if (currentPin.isNotEmpty) {
                setDialogState(() {
                  errorMessage = null;
                  currentPin = currentPin.substring(0, currentPin.length - 1);
                });
              }
            }

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              backgroundColor: AppTheme.surface,
              surfaceTintColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(20),
                constraints: const BoxConstraints(maxWidth: 380),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4)),
                          ),
                          child: const Icon(
                            Icons.shield_rounded,
                            size: 38,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Acceso Súper Usuario',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Ingresa el PIN de Entrenador (PIN por defecto: 1234)',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 14),

                      // Visor de PIN con puntos
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: errorMessage != null ? AppTheme.error : AppTheme.divider,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(4, (index) {
                            final filled = index < currentPin.length;
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: filled ? AppTheme.primary : AppTheme.divider,
                                border: Border.all(
                                  color: filled ? AppTheme.primary : AppTheme.textHint,
                                  width: 2,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      if (errorMessage != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11, color: AppTheme.error, fontWeight: FontWeight.bold),
                        ),
                      ],
                      const SizedBox(height: 14),

                      // Teclado Numérico Táctil en Pantalla
                      Column(
                        children: [
                          for (var row in [
                            ['1', '2', '3'],
                            ['4', '5', '6'],
                            ['7', '8', '9'],
                          ])
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: row.map((key) {
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: Material(
                                        color: AppTheme.surfaceVariant,
                                        borderRadius: BorderRadius.circular(12),
                                        child: InkWell(
                                          onTap: () => onKeyPressed(key),
                                          borderRadius: BorderRadius.circular(12),
                                          child: Container(
                                            height: 48,
                                            alignment: Alignment.center,
                                            child: Text(
                                              key,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w800,
                                                color: AppTheme.textPrimary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          // Fila inferior: Cerrar, 0, Borrar
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Material(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    child: InkWell(
                                      onTap: () => Navigator.of(dialogCtx).pop(),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        height: 48,
                                        alignment: Alignment.center,
                                        child: const Icon(Icons.close_rounded, color: AppTheme.textSecondary),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Material(
                                    color: AppTheme.surfaceVariant,
                                    borderRadius: BorderRadius.circular(12),
                                    child: InkWell(
                                      onTap: () => onKeyPressed('0'),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        height: 48,
                                        alignment: Alignment.center,
                                        child: const Text(
                                          '0',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Material(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    child: InkWell(
                                      onTap: onBackspace,
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        height: 48,
                                        alignment: Alignment.center,
                                        child: const Icon(Icons.backspace_outlined, color: AppTheme.textSecondary),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Botón de 1 toque de acceso rápido con PIN por defecto
                      FilledButton.icon(
                        onPressed: () => verify('1234'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.flash_on_rounded, size: 16),
                        label: const Text(
                          'Entrar con PIN por defecto (1234)',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isSuperUserViewActive) {
      return SuperUserScreen(
        onExit: () {
          setState(() {
            _isSuperUserViewActive = false;
          });
        },
      );
    }

    return VotingKioskScreen(
      onOpenSuperUser: _openSuperUserGate,
    );
  }
}
