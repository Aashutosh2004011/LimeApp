class ReasonNode {
  final String code;
  final String label;
  final List<ReasonNode>? children;

  ReasonNode({
    required this.code,
    required this.label,
    this.children,
  });

  factory ReasonNode.fromJson(Map<String, dynamic> json) {
    return ReasonNode(
      code: json['code'],
      label: json['label'],
      children: json['children'] != null
          ? (json['children'] as List).map((e) => ReasonNode.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'label': label,
        'children': children?.map((e) => e.toJson()).toList(),
      };
}