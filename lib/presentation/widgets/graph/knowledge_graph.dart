import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphview/GraphView.dart';
import '../../../data/models/connection.dart';
import '../../../domain/providers/graph_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import 'graph_node_widget.dart';

/// Knowledge Graph Widget - Node-based visualization
class KnowledgeGraph extends ConsumerStatefulWidget {
  final int entityId;
  final String entityType;

  const KnowledgeGraph({
    super.key,
    required this.entityId,
    required this.entityType,
  });

  @override
  ConsumerState<KnowledgeGraph> createState() => _KnowledgeGraphState();
}

class _KnowledgeGraphState extends ConsumerState<KnowledgeGraph> {
  final Graph graph = Graph()..isTree = false;
  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();

  @override
  void initState() {
    super.initState();
    _configureGraph();
  }

  void _configureGraph() {
    builder
      ..siblingSeparation = (AppConstants.nodeSpacing.toInt())
      ..levelSeparation = (AppConstants.nodeSpacing.toInt())
      ..subtreeSeparation = (AppConstants.nodeSpacing.toInt() * 2)
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;
  }

  @override
  Widget build(BuildContext context) {
    final connectionsAsync = ref.watch(
      connectionsForEntityProvider((id: widget.entityId, type: widget.entityType)),
    );

    return connectionsAsync.when(
      data: (connections) {
        if (connections.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_tree_outlined,
                  size: 64,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 16),
                const Text('Henüz bağlantı yok'),
                const SizedBox(height: 8),
                const Text(
                  'Inspector panelinden bağlantı ekleyebilirsiniz',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        _buildGraph(connections);

        return InteractiveViewer(
          constrained: false,
          boundaryMargin: const EdgeInsets.all(100),
          minScale: 0.01,
          maxScale: 10.6,
          child: GraphView(
            graph: graph,
            algorithm: BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder)),
            paint: Paint()
              ..color = AppColors.primary
              ..strokeWidth = AppConstants.connectionLineWidth
              ..style = PaintingStyle.stroke,
            builder: (Node node) {
              final data = node.key!.value as Map<String, dynamic>;
              return GraphNodeWidget(
                id: data['id'] as int,
                type: data['type'] as String,
                title: data['title'] as String,
                isCenter: data['isCenter'] as bool,
                onTap: () => _onNodeTap(data),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Hata: $error'),
      ),
    );
  }

  void _buildGraph(List<Connection> connections) {
    graph.nodes.clear();
    graph.edges.clear();

    // Center node
    final centerNode = Node.Id({
      'id': widget.entityId,
      'type': widget.entityType,
      'title': 'Merkez',
      'isCenter': true,
    });
    graph.addNode(centerNode);

    // Connected nodes
    final addedNodes = <String, Node>{};
    addedNodes['${widget.entityType}_${widget.entityId}'] = centerNode;

    for (var connection in connections) {
      final isSource = connection.sourceId == widget.entityId &&
          connection.sourceType == widget.entityType;

      final connectedId = isSource ? connection.targetId : connection.sourceId;
      final connectedType = isSource ? connection.targetType : connection.sourceType;
      final nodeKey = '${connectedType}_$connectedId';

      if (!addedNodes.containsKey(nodeKey)) {
        final node = Node.Id({
          'id': connectedId,
          'type': connectedType,
          'title': connection.label ?? 'Node $connectedId',
          'isCenter': false,
        });
        graph.addNode(node);
        addedNodes[nodeKey] = node;
      }

      // Add edge
      graph.addEdge(
        centerNode,
        addedNodes[nodeKey]!,
        paint: Paint()
          ..color = ConnectionTypes.getColor(connection.connectionType)
          ..strokeWidth = AppConstants.connectionLineWidth,
      );
    }
  }

  void _onNodeTap(Map<String, dynamic> data) {
    // Navigate to node details or update center
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Node tapped: ${data['title']}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
