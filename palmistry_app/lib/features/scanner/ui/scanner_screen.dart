import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/models/enums.dart';
import '../bloc/scanner_bloc.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScannerBloc(),
      child: const _ScannerView(),
    );
  }
}

class _ScannerView extends StatefulWidget {
  const _ScannerView();

  @override
  State<_ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<_ScannerView> {
  Hand _selectedHand = Hand.right;
  File? _pickedImage;
  final _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScannerBloc, ScannerState>(
      listener: (context, state) {
        if (state is ScannerDone) {
          context.go('/editor/${state.scanId}');
        } else if (state is ScannerError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red[700],
            ),
          );
        }
      },
      child: BlocBuilder<ScannerBloc, ScannerState>(
        builder: (context, state) {
          if (state is ScannerProcessing) {
            return _ProcessingView(state: state);
          }
          return _IdleView(
            selectedHand: _selectedHand,
            pickedImage: _pickedImage,
            onHandChanged: (hand) => setState(() => _selectedHand = hand),
            onPickCamera: () => _pick(context, ImageSource.camera),
            onPickGallery: () => _pick(context, ImageSource.gallery),
            onProcess: _pickedImage != null
                ? () => context.read<ScannerBloc>().add(
                      ProcessImage(
                        imageFile: _pickedImage!,
                        hand: _selectedHand,
                      ),
                    )
                : null,
          );
        },
      ),
    );
  }

  Future<void> _pick(BuildContext context, ImageSource source) async {
    final xFile = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1920,
    );
    if (xFile != null) {
      setState(() => _pickedImage = File(xFile.path));
    }
  }
}

// ---------------------------------------------------------------------------
// Idle / selection view
// ---------------------------------------------------------------------------

class _IdleView extends StatelessWidget {
  final Hand selectedHand;
  final File? pickedImage;
  final ValueChanged<Hand> onHandChanged;
  final VoidCallback onPickCamera;
  final VoidCallback onPickGallery;
  final VoidCallback? onProcess;

  const _IdleView({
    required this.selectedHand,
    required this.pickedImage,
    required this.onHandChanged,
    required this.onPickCamera,
    required this.onPickGallery,
    required this.onProcess,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = pickedImage != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Сканер ладони')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Image preview or placeholder
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: hasImage
                      ? Image.file(
                          pickedImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                      : Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A2E),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF7C3AED).withAlpha(80),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.back_hand_outlined,
                                size: 80,
                                color: theme.colorScheme.primary.withAlpha(120),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Выберите фото ладони',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(120),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Hand selection toggle
              _HandToggle(
                selected: selectedHand,
                onChanged: onHandChanged,
              ),

              const SizedBox(height: 20),

              // Capture buttons
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.camera_alt_outlined,
                      label: 'Камера',
                      onTap: onPickCamera,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.photo_library_outlined,
                      label: 'Галерея',
                      onTap: onPickGallery,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Scan button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: onProcess,
                  icon: const Icon(Icons.document_scanner_outlined),
                  label: const Text(
                    'Сканировать',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _HandToggle extends StatelessWidget {
  final Hand selected;
  final ValueChanged<Hand> onChanged;

  const _HandToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _ToggleChip(
            label: '✋ Левая',
            selected: selected == Hand.left,
            onTap: () => onChanged(Hand.left),
            primary: primary,
          ),
          _ToggleChip(
            label: '🤚 Правая',
            selected: selected == Hand.right,
            onTap: () => onChanged(Hand.right),
            primary: primary,
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color primary;

  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white54,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF7C3AED).withAlpha(60),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Processing view
// ---------------------------------------------------------------------------

class _ProcessingView extends StatelessWidget {
  final ScannerProcessing state;

  const _ProcessingView({required this.state});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Анализ ладони',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.stepLabel,
                style: const TextStyle(color: Colors.white54, fontSize: 15),
              ),
              const SizedBox(height: 48),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: state.progress,
                  minHeight: 8,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(primary),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${(state.progress * 100).toInt()}%',
                style: TextStyle(
                  color: primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
