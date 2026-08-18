import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/settings_provider.dart';

class SuperUserDialog extends StatefulWidget {
  const SuperUserDialog({super.key});

  @override
  State<SuperUserDialog> createState() => _SuperUserDialogState();
}

class _SuperUserDialogState extends State<SuperUserDialog> {
  final _pinController = TextEditingController();
  final _newCategoryController = TextEditingController();
  final _newIntensityController = TextEditingController();
  final _newPinController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _pinController.dispose();
    _newCategoryController.dispose();
    _newIntensityController.dispose();
    _newPinController.dispose();
    super.dispose();
  }

  void _verifyPin(SettingsProvider provider) {
    final success = provider.authenticateSuperUser(_pinController.text.trim());
    if (!success) {
      setState(() {
        _errorMessage = 'PIN incorrecto. (PIN por defecto: 1234)';
      });
    } else {
      setState(() {
        _errorMessage = null;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 540 ? 480.0 : screenWidth * 0.9;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppTheme.surface,
      surfaceTintColor: Colors.transparent,
      child: SizedBox(
        width: dialogWidth,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: settingsProvider.isSuperUser
              ? _buildAdminPanel(context, settingsProvider)
              : _buildPinLogin(context, settingsProvider),
        ),
      ),
    );
  }

  Widget _buildPinLogin(BuildContext context, SettingsProvider provider) {
    return Column(
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
            child: const Icon(Icons.shield_rounded,
                size: 38, color: AppTheme.primary),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Acceso Súper Usuario',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Ingresa el PIN para crear, editar o eliminar categorías e intensidades.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _pinController,
          obscureText: true,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          autofocus: true,
          maxLength: 6,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: 8,
            color: AppTheme.textPrimary,
          ),
          decoration: InputDecoration(
            counterText: '',
            hintText: '••••',
            errorText: _errorMessage,
            filled: true,
            fillColor: AppTheme.surfaceVariant,
          ),
          onSubmitted: (_) => _verifyPin(provider),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Cancelar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => _verifyPin(provider),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    );
  }

  Widget _buildAdminPanel(BuildContext context, SettingsProvider provider) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.shield, color: AppTheme.primary),
                  SizedBox(width: 8),
                  Text(
                    'Panel Súper Usuario',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Divider(height: 24),
          const Text(
            'CATEGORÍAS DE ENTRENAMIENTO',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Toca una categoría para renombrarla o el icono de eliminar.',
            style: TextStyle(fontSize: 11, color: AppTheme.textHint),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: provider.categories.map((cat) {
              return InputChip(
                avatar: const Icon(Icons.edit_outlined, size: 14, color: AppTheme.primary),
                label: Text(cat),
                onPressed: () => _showEditCategoryDialog(context, provider, cat),
                onDeleted: () => provider.removeCategory(cat),
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
                      provider.addCategory(val);
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
                    provider.addCategory(_newCategoryController.text);
                    _newCategoryController.clear();
                  }
                },
              ),
            ],
          ),
          const Divider(height: 32),
          const Text(
            'NIVELES DE INTENSIDAD',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
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
            children: provider.intensities.map((intensity) {
              final color = AppTheme.getIntensityColor(intensity);
              return InputChip(
                avatar: Icon(Icons.edit_outlined, size: 14, color: color),
                label: Text(intensity),
                onPressed: () => _showEditIntensityDialog(context, provider, intensity),
                onDeleted: () => provider.removeIntensity(intensity),
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
                      provider.addIntensity(val);
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
                    provider.addIntensity(_newIntensityController.text);
                    _newIntensityController.clear();
                  }
                },
              ),
            ],
          ),
          const Divider(height: 32),
          const Text(
            'CAMBIAR PIN DE ACCESO',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
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
                    provider.updatePin(_newPinController.text);
                    _newPinController.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('¡PIN actualizado con éxito!')),
                    );
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              provider.logoutSuperUser();
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.lock_outline),
            label: const Text('Cerrar Modo Administrador'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
