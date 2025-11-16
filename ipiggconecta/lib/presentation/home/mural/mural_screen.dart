import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/mural_model.dart';
import '../../../data/repositories/mural_repository.dart';
import '../../../data/services/mural_service.dart';
import '../../../data/session/session_manager.dart';
import '../../widgets/app_bottom_navigation.dart';
import 'mural_controller.dart';

class MuralScreen extends StatefulWidget {
  const MuralScreen({super.key});

  @override
  State<MuralScreen> createState() => _MuralScreenState();
}

class _MuralScreenState extends State<MuralScreen> {
  late final MuralController _controller;
  late final MuralService _muralService;
  String? _lastError;

  UserSession? get _currentUser => SessionManager.instance.currentUser;
  bool get _isAdmin => _currentUser?.isAdmin ?? false;

  @override
  void initState() {
    super.initState();
    _muralService = const MuralService();
    _controller = MuralController(
      repository: MuralRepository(_muralService),
    );
    _controller.addListener(_handleControllerUpdate);
    _controller.load();
  }

  void _handleControllerUpdate() {
    final error = _controller.error;
    if (error != null && error != _lastError && mounted) {
      _lastError = error;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
    }
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() => _controller.refresh();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final items = _controller.items;
        final isLoading = _controller.isLoading;
        final hasBlockingError = _controller.error != null && items.isEmpty;

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFDE9D8),
                Color(0xFFF7F3EE),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: RefreshIndicator(
                color: const Color(0xFFFF9F43),
                onRefresh: _onRefresh,
                child: _buildBody(
                  isLoading: isLoading,
                  hasBlockingError: hasBlockingError,
                  items: items,
                ),
              ),
            ),
            floatingActionButton: _isAdmin
                ? FloatingActionButton(
                    onPressed: _openCreateDialog,
                    backgroundColor: const Color(0xFFFF9F43),
                    foregroundColor: Colors.white,
                    child: const Icon(Icons.add),
                  )
                : null,
            bottomNavigationBar:
                const AppBottomNavigation(currentRoute: '/home'),
          ),
        );
      },
    );
  }

  Widget _buildBody({
    required bool isLoading,
    required bool hasBlockingError,
    required List<MuralModel> items,
  }) {
    if (isLoading && items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 180),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (hasBlockingError) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 120),
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off,
                size: 48,
                color: Color(0xFFFFB36B),
              ),
              const SizedBox(height: 12),
              const Text(
                'Erro ao carregar o mural.',
                style: TextStyle(color: Color(0xFF8D93A3)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9F43),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  _controller.load();
                },
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ],
      );
    }

    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 120),
        children: const [
          Center(
            child: Text(
              'Nenhum aviso por enquanto',
              style: TextStyle(color: Color(0xFF8D93A3), fontSize: 16),
            ),
          )
        ],
      );
    }

    return _buildList(items);
  }

  Widget _buildList(List<MuralModel> items) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Mural Oficial',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F1F1F),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Publicações da igreja',
                style: TextStyle(
                  color: Color(0xFF8E94A3),
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 24),
            ],
          );
        }

        final mural = items[index - 1];

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 35,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mural.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2F2F2F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        mural.subtitle,
                        style: const TextStyle(
                          color: Color(0xFF666D80),
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_outlined,
                            size: 18,
                            color: Color(0xFFB0B6C5),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            mural.formattedDate,
                            style: const TextStyle(
                              color: Color(0xFF8E94A3),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (mural.link != null) ...[
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFFFF2E1),
                              foregroundColor: const Color(0xFFFF9F43),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onPressed: () => _openLink(mural.link!),
                            child: const Text('Clique aqui'),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF2E1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    color: Color(0xFFFF9F43),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openCreateDialog() async {
    final token = SessionManager.instance.token;
    if (token == null || token.isEmpty) {
      _showMessage('Sessão expirada. Faça login novamente.');
      return;
    }

    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    final linkController = TextEditingController();
    DateTime? publishDate = DateTime.now();
    bool isSaving = false;

    String formatDate(DateTime date) {
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();
      return '$day/$month/$year';
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickDate() async {
              final now = DateTime.now();
              final initial = publishDate ?? now;
              final result = await showDatePicker(
                context: context,
                initialDate: initial,
                firstDate: DateTime(now.year - 1),
                lastDate: DateTime(now.year + 5),
              );
              if (result != null) {
                setModalState(() {
                  publishDate = result;
                });
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Novo aviso',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: titleController,
                      decoration: _inputDecoration('Título'),
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Informe o título.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: subtitleController,
                      decoration: _inputDecoration('Descrição'),
                      maxLines: 3,
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Informe a descrição.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: pickDate,
                      behavior: HitTestBehavior.opaque,
                      child: InputDecorator(
                        decoration: _inputDecoration('Data de publicação'),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              publishDate != null
                                  ? formatDate(publishDate!)
                                  : 'Selecione a data',
                              style: const TextStyle(
                                color: Color(0xFF2F2F2F),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today,
                              color: Color(0xFFFF9F43),
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: linkController,
                      decoration: _inputDecoration('Link (opcional)'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              if (!(formKey.currentState?.validate() ?? false)) {
                                return;
                              }
                              if (publishDate == null) {
                                _showMessage('Selecione a data de publicação.');
                                return;
                              }
                              setModalState(() => isSaving = true);
                              try {
                                await _muralService.createMural(
                                  title: titleController.text.trim(),
                                  subtitle: subtitleController.text.trim(),
                                  publishDate: publishDate!,
                                  link: linkController.text.trim().isEmpty
                                      ? null
                                      : linkController.text.trim(),
                                  token: token,
                                );
                                if (!mounted) return;
                                Navigator.pop(context);
                                _showMessage('Aviso criado com sucesso!');
                                await _controller.refresh();
                              } catch (error) {
                                _showMessage(error.toString());
                              } finally {
                                if (context.mounted) {
                                  setModalState(() => isSaving = false);
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9F43),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Publicar',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    titleController.dispose();
    subtitleController.dispose();
    linkController.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: Color(0xFFE4E5EE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: Color(0xFFFF9F43), width: 1.4),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    );
  }
}
