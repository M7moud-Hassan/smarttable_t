class AdministrativeActionModel {
  const AdministrativeActionModel({
    required this.id,
    required this.procedureType,
    required this.title,
    required this.date,
    required this.subtitle,
    required this.status,
    required this.statusDisplay,
    required this.needsAction,
    required this.managerDecision,
    required this.managerDecisionDisplay,
    required this.managerDecidedAtHijri,
  });

  final int id;
  final String procedureType;
  final String title;
  final String date;
  final String subtitle;
  final String status;
  final String statusDisplay;
  final bool needsAction;
  final String managerDecision;
  final String managerDecisionDisplay;
  final String managerDecidedAtHijri;

  factory AdministrativeActionModel.fromJson(Map<String, dynamic> json) {
    return AdministrativeActionModel(
      id: _asInt(json['id']),
      procedureType: _asString(json['procedure_type']),
      title: _asString(json['title']),
      date: _asString(json['date']),
      subtitle: _asString(json['subtitle']),
      status: _asString(json['status']),
      statusDisplay: _asString(json['status_display']),
      needsAction: _asBool(json['needs_action']),
      managerDecision: _asString(json['manager_decision']),
      managerDecisionDisplay: _asString(json['manager_decision_display']),
      managerDecidedAtHijri: _asString(json['manager_decided_at_hijri']),
    );
  }
}

class AdministrativeActionDetailModel {
  const AdministrativeActionDetailModel({
    required this.id,
    required this.procedureType,
    required this.title,
    required this.date,
    required this.subtitle,
    required this.status,
    required this.statusDisplay,
    required this.needsAction,
    required this.managerDecision,
    required this.managerDecisionDisplay,
    required this.managerDecidedAtHijri,
    required this.details,
    required this.teacherReason,
    required this.teacherRepliedAtHijri,
    required this.canReply,
    required this.reasonLabel,
    required this.reasonHint,
  });

  final int id;
  final String procedureType;
  final String title;
  final String date;
  final String subtitle;
  final String status;
  final String statusDisplay;
  final bool needsAction;
  final String managerDecision;
  final String managerDecisionDisplay;
  final String managerDecidedAtHijri;
  final List<AdministrativeActionDetailItem> details;
  final String teacherReason;
  final String teacherRepliedAtHijri;
  final bool canReply;
  final String reasonLabel;
  final String reasonHint;

  factory AdministrativeActionDetailModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AdministrativeActionDetailModel(
      id: _asInt(json['id']),
      procedureType: _asString(json['procedure_type']),
      title: _asString(json['title']),
      date: _asString(json['date']),
      subtitle: _asString(json['subtitle']),
      status: _asString(json['status']),
      statusDisplay: _asString(json['status_display']),
      needsAction: _asBool(json['needs_action']),
      managerDecision: _asString(json['manager_decision']),
      managerDecisionDisplay: _asString(json['manager_decision_display']),
      managerDecidedAtHijri: _asString(json['manager_decided_at_hijri']),
      details: AdministrativeActionDetailItem.parseList(json['details']),
      teacherReason: _asString(json['teacher_reason']),
      teacherRepliedAtHijri: _asString(json['teacher_replied_at_hijri']),
      canReply: _asBool(json['can_reply']),
      reasonLabel: _asString(json['reason_label']),
      reasonHint: _asString(json['reason_hint']),
    );
  }
}

class AdministrativeActionDetailItem {
  const AdministrativeActionDetailItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  factory AdministrativeActionDetailItem.fromJson(Map<String, dynamic> json) {
    return AdministrativeActionDetailItem(
      label: _asString(json['label']),
      value: _asString(json['value']),
    );
  }

  static List<AdministrativeActionDetailItem> parseList(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map(
          (item) => AdministrativeActionDetailItem.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .where((item) => item.label.isNotEmpty || item.value.isNotEmpty)
        .toList(growable: false);
  }
}

class AdministrativeActionsPage {
  const AdministrativeActionsPage({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  final int count;
  final String? next;
  final String? previous;
  final List<AdministrativeActionModel> results;

  factory AdministrativeActionsPage.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'];
    final results = rawResults is List
        ? rawResults
            .whereType<Map>()
            .map(
              (item) => AdministrativeActionModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList(growable: false)
        : const <AdministrativeActionModel>[];
    return AdministrativeActionsPage(
      count: _asInt(json['count'], fallback: results.length),
      next: _asNullableString(json['next']),
      previous: _asNullableString(json['previous']),
      results: results,
    );
  }
}

class AdministrativeProcedureKey {
  const AdministrativeProcedureKey({
    required this.procedureType,
    required this.id,
  });

  final String procedureType;
  final int id;

  @override
  bool operator ==(Object other) {
    return other is AdministrativeProcedureKey &&
        other.procedureType == procedureType &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hash(procedureType, id);
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

String _asString(dynamic value) => value?.toString() ?? '';

String? _asNullableString(dynamic value) {
  final parsed = value?.toString();
  return parsed == null || parsed.isEmpty ? null : parsed;
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  return const {'true', '1', 'yes'}.contains(value?.toString().toLowerCase());
}
