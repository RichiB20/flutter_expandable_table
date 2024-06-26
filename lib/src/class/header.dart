// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:flutter_expandable_table/flutter_expandable_table.dart';

/// [ExpandableTableHeader] class.
/// This class defines a single table header.
class ExpandableTableHeader extends ChangeNotifier {
  /// [cell] Defines the contents of the column header cell.
  /// `required`
  final ExpandableTableCell cell;
  late List<ExpandableTableHeader>? _children;

  /// [children] returns nested columns to this one.
  List<ExpandableTableHeader>? get children => _children;

  /// [children] defines columns nested to this, populating
  /// this list will create an expandable column.
  set children(List<ExpandableTableHeader>? value) {
    _removeChildrenListener();
    _children = value;
    _addChildrenListener();
    notifyListeners();
  }

  /// [width] defines the width of the column, if not specified
  /// the default width defined in the table will be used.
  /// `optional`
  final double? width;

  /// [hideWhenExpanded] Defines whether this column should be
  /// hidden when nested columns are expanded. Attention, by setting
  /// this property to true it will be necessary to implement manual
  /// management of column expansion.
  /// `Default: false`
  final bool hideWhenExpanded;

  /// [disableDefaultOnTapExpansion] Defines whether to disable the
  /// standard expand interaction, setting to true will require
  /// manually implementing an expand logic.
  /// `Default: false`
  final bool disableDefaultOnTapExpansion;

  late bool _childrenExpanded;

  /// [childrenExpanded] returns true if the children nested to this column have been expanded.
  bool get childrenExpanded =>
      children?.isNotEmpty == true && _childrenExpanded;

  /// [childrenExpanded] allows you to expand or not the columns nested within this one.
  set childrenExpanded(bool value) {
    if (children != null) {
      _childrenExpanded = value;
      if (!_childrenExpanded) {
        for (var child in children!) {
          child.childrenExpanded = false;
        }
      }
      notifyListeners();
    }
  }

  ExpandableTableHeader? _parent;

  /// [parent] if this column is nested within another,
  /// the instance of the parent column is returned
  ExpandableTableHeader? get parent => _parent;

  /// [index] indicates the current index of this column, referring to the parent.
  int? index;

  /// [ExpandableTableHeader] class constructor.
  /// This class defines a single table header.
  ExpandableTableHeader({
    required this.cell,
    List<ExpandableTableHeader>? children,
    this.width,
    this.hideWhenExpanded = false,
    bool childrenExpanded = false,
    this.disableDefaultOnTapExpansion = false,
  }) {
    _childrenExpanded = childrenExpanded;
    _children = children;
    _addChildrenListener();
  }

  void _addChildrenListener() {
    if (_children != null) {
      for (var i = 0; i < _children!.length; i++) {
        children![i]._parent = this;
        _children![i].addListener(_listener);
        _children![i].index = i;
      }
    }
  }

  void _removeChildrenListener() {
    if (_children != null) {
      for (var child in _children!) {
        child.removeListener(_listener);
      }
    }
  }

  @override
  void dispose() {
    _removeChildrenListener();
    super.dispose();
  }

  void _listener() => notifyListeners();

  /// [columnsCount] returns the number of columns, this one and
  /// all those nested within it.
  int get columnsCount {
    int count = 1;
    if (children != null) {
      for (var e in children!) {
        count += e.columnsCount;
      }
    }
    return count;
  }

  /// [visibleColumnsCount] returns the number of columns currently visible,
  /// this one and all those nested within it.
  int get visibleColumnsCount {
    int count = childrenExpanded && hideWhenExpanded ? 0 : 1;
    if (children != null) {
      for (var e in children!) {
        count += e.visibleColumnsCount;
      }
    }
    return count;
  }

  /// [visible] returns true if this column is currently visible.
  bool get visible =>
      (!childrenExpanded || !hideWhenExpanded) &&
      (parent == null || parent?.childrenExpanded == true);

  /// [address] returns a list of integers, each of which the position
  /// referred to the parent column, each nesting adds an element to the
  /// list, this element will be the address of the column with respect to the parent.
  List<int> get address => (parent?.address ?? [])..add(index ?? -1);

  /// [toggleExpand] this method allows you to reverse the
  /// expansion or not of the child columns.
  void toggleExpand() => childrenExpanded = !childrenExpanded;
}
