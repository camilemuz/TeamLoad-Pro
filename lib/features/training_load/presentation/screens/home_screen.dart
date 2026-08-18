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
    final pinController = TextEditingController();
    String? errorMessage;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            void verify() {
              final settings = dialogCtx.read<SettingsProvider>();
              final success = settings.authenticateSuperUser(pinController.text.trim());
              if (success) {
                Navigator.of(dialogCtx).pop();
                setState(() {
                  _isSuperUserViewActive = true;
                });
              } else {
                setDialogState(() {
                  errorMessage = 'PIN incorrecto. (PIN por defecto: 1234)';
                });
              }
            }

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              backgroundColor: AppTheme.surface,
              surfaceTintColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.shield_rounded,
                          size: 40,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Acceso Súper Usuario',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Ingresa el PIN de seguridad para acceder a las estadísticas, ratios ACWR y ajustes.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: pinController,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      autofocus: true,
                      maxLength: 6,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 8,
                        color: AppTheme.textPrimary,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '••••',
                        errorText: errorMessage,
                        filled: true,
                        fillColor: AppTheme.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => verify(),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(dialogCtx).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: verify,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Entrar',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
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
