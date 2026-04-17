import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/connection.dart';
import 'database_provider.dart';

/// All Connections Provider (Stream)
final connectionsProvider = StreamProvider<List<Connection>>((ref) async* {
  final repo = ref.watch(connectionRepositoryProvider);
  await for (final connections in Stream.fromFuture(repo.getAll())) {
    yield connections;
  }
});

/// Connections for Entity Provider
final connectionsForEntityProvider =
    FutureProvider.family<List<Connection>, ({int id, String type})>((ref, params) async {
  final repo = ref.watch(connectionRepositoryProvider);
  return await repo.getForEntity(params.id, params.type);
});

/// Selected Node Provider (for graph view)
final selectedNodeProvider = StateProvider<({int id, String type})?>((ref) => null);

/// Graph Layout Provider
/// Returns positioned nodes for graph visualization
final graphLayoutProvider = Provider<Map<String, dynamic>>((ref) {
  final selectedNode = ref.watch(selectedNodeProvider);
  
  if (selectedNode == null) {
    return {};
  }

  // TODO: Implement graph layout algorithm
  // For now, return empty map
  return {
    'centerNode': selectedNode,
    'connectedNodes': [],
  };
});
