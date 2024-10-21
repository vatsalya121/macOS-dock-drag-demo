import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e) {
              return Container(
                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[e.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(e, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T extends Object> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder building the provided [T] item.
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T extends Object> extends State<Dock<T>>
    with SingleTickerProviderStateMixin {
  /// [T] items being manipulated.
  late List<T> _items = widget.items.toList();
  int? _draggedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          return LongPressDraggable<T>(
            data: item,
            onDragStarted: () {
              setState(() {
                _draggedIndex = index;
              });
            },
            onDragCompleted: () {
              setState(() {
                _draggedIndex = null;
              });
            },
            onDraggableCanceled: (_, __) {
              setState(() {
                _draggedIndex = null;
              });
            },
            feedback: Material(
              child: widget.builder(item),
              elevation: 4.0,
            ),
            childWhenDragging: const SizedBox.shrink(),
            child: DragTarget<T>(
              onWillAccept: (receivedItem) {
                setState(() {
                  final draggedItemIndex = _items.indexOf(receivedItem!);
                  if (draggedItemIndex != index) {
                    _items.remove(receivedItem);
                    _items.insert(index, receivedItem);
                  }
                });
                return true;
              },
              onAccept: (receivedItem) {
                setState(() {
                  _draggedIndex = null;
                });
              },
              builder: (context, candidateData, rejectedData) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: widget.builder(item),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
