import '../models/mural_model.dart';
import '../services/mural_service.dart';

class MuralRepository {
  const MuralRepository(this._service);

  final MuralService _service;

  Future<List<MuralModel>> fetchMural() {
    return _service.getMural();
  }
}
