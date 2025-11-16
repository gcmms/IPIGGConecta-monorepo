import 'package:flutter/material.dart';

import '../../../data/models/mural_model.dart';
import '../../../data/repositories/mural_repository.dart';

class MuralController extends ChangeNotifier {
  MuralController({required MuralRepository repository})
      : _repository = repository;

  final MuralRepository _repository;

  List<MuralModel> _items = [];
  bool _isLoading = false;
  String? _error;

  List<MuralModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _items.isNotEmpty;

  Future<void> load() async {
    if (_isLoading && hasData) return;
    await _fetch();
  }

  Future<void> refresh() => _fetch();

  Future<void> _fetch() async {
    _updateLoading(true);
    try {
      final result = await _repository.fetchMural();
      _items = result;
      _error = null;
    } catch (error) {
      _error = error.toString();
    } finally {
      _updateLoading(false);
    }
  }

  void _updateLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }
}
