// ignore_for_file: depend_on_referenced_packages, implementation_imports

import 'dart:async';

import 'package:_fe_analyzer_shared/src/macros/api.dart';

macro class Model implements ClassDeclarationsMacro {
  const Model();

  static const _baseTypes = ['bool', 'double', 'int', 'num', 'String'];
  static const _collectionTypes = ['List'];

  @override
  Future<void> buildDeclarationsForClass(
    ClassDeclaration classDeclaration,
    MemberDeclarationBuilder builder,
  ) async {
    final className = classDeclaration.identifier.name;

    final fields = await builder.fieldsOf(classDeclaration);

    final fieldNames = <String>[];
    final fieldTypes = <String, String>{};
    final fieldGenerics = <String, List<String>>{};

    for (final field in fields) {
      final fieldName = field.identifier.name;
      fieldNames.add(fieldName);

      final fieldType = (field.type.code as NamedTypeAnnotationCode).name.name;
      fieldTypes[fieldName] = fieldType;

      if (_collectionTypes.contains(fieldType)) {
        final generics = (field.type.code as NamedTypeAnnotationCode)
            .typeArguments
            .map((e) => (e as NamedTypeAnnotationCode).name.name)
            .toList();
        fieldGenerics[fieldName] = generics;
      }
    }

    final fieldTypesWithGenerics = fieldTypes.map(
      (name, type) {
        final generics = fieldGenerics[name];
        return MapEntry(
          name,
          generics == null ? type : '$type<${generics.join(', ')}>',
        );
      },
    );

    _buildFromJson(builder, className, fieldNames, fieldTypes, fieldGenerics);
    _buildToJson(builder, fieldNames, fieldTypes);
    _buildCopyWith(builder, className, fieldNames, fieldTypesWithGenerics);
    _buildToString(builder, className, fieldNames);
    _buildEquals(builder, className, fieldNames);
    _buildHashCode(builder, fieldNames);
  }

  void _buildFromJson(
    MemberDeclarationBuilder builder,
    String className,
    List<String> fieldNames,
    Map<String, String> fieldTypes,
    Map<String, List<String>> fieldGenerics,
  ) {
    final code = [
      'factory $className.fromJson(Map<String, dynamic> json) {'.indent(2),
      'return $className('.indent(4),
      for (final fieldName in fieldNames) ...[
        if (_baseTypes.contains(fieldTypes[fieldName])) ...[
          "$fieldName: json['$fieldName'] as ${fieldTypes[fieldName]},"
              .indent(6),
        ] else if (_collectionTypes.contains(fieldTypes[fieldName])) ...[
          "$fieldName: (json['$fieldName'] as List<dynamic>)".indent(6),
          '.whereType<Map<String, dynamic>>()'.indent(10),
          '.map(${fieldGenerics[fieldName]?.first}.fromJson)'.indent(10),
          '.toList(),'.indent(10),
        ] else ...[
          '$fieldName: ${fieldTypes[fieldName]}'
                  ".fromJson(json['$fieldName'] "
                  'as Map<String, dynamic>),'
              .indent(6),
        ],
      ],
      ');'.indent(4),
      '}'.indent(2),
    ].join('\n');
    builder.declareInType(DeclarationCode.fromString(code));
  }

  void _buildToJson(
    MemberDeclarationBuilder builder,
    List<String> fieldNames,
    Map<String, String> fieldTypes,
  ) {
    final code = [
      'Map<String, dynamic> toJson() {'.indent(2),
      'return {'.indent(4),
      for (final fieldName in fieldNames) ...[
        if (_baseTypes.contains(fieldTypes[fieldName])) ...[
          "'$fieldName': $fieldName,".indent(6),
        ] else if (_collectionTypes.contains(fieldTypes[fieldName])) ...[
          "'$fieldName': $fieldName.map((e) => e.toJson()).toList(),".indent(6),
        ] else ...[
          "'$fieldName': $fieldName.toJson(),".indent(6),
        ],
      ],
      '};'.indent(4),
      '}'.indent(2),
    ].join('\n');
    builder.declareInType(DeclarationCode.fromString(code));
  }

  void _buildCopyWith(
    MemberDeclarationBuilder builder,
    String className,
    List<String> fieldNames,
    Map<String, String> fieldTypes,
  ) {
    final code = [
      '$className copyWith({'.indent(2),
      for (final fieldName in fieldNames) ...[
        '${fieldTypes[fieldName]}? $fieldName,'.indent(4),
      ],
      '}) {'.indent(2),
      'return $className('.indent(4),
      for (final fieldName in fieldNames) ...[
        '$fieldName: $fieldName ?? this.$fieldName,'.indent(6),
      ],
      ');'.indent(4),
      '}'.indent(2),
    ].join('\n');
    builder.declareInType(DeclarationCode.fromString(code));
  }

  void _buildToString(
    MemberDeclarationBuilder builder,
    String className,
    List<String> fieldNames,
  ) {
    final code = [
      '@override'.indent(2),
      'String toString() {'.indent(2),
      "return '$className('".indent(4),
      for (final fieldName in fieldNames) ...[
        if (fieldName != fieldNames.last) ...[
          "'$fieldName: \$$fieldName, '".indent(8),
        ] else ...[
          "'$fieldName: \$$fieldName'".indent(8),
        ],
      ],
      "')';".indent(8),
      '}'.indent(2),
    ].join('\n');
    builder.declareInType(DeclarationCode.fromString(code));
  }

  void _buildEquals(
    MemberDeclarationBuilder builder,
    String className,
    List<String> fieldNames,
  ) {
    final code = [
      '@override'.indent(2),
      'bool operator ==(Object other) {'.indent(2),
      'return other is $className &&'.indent(4),
      'runtimeType == other.runtimeType &&'.indent(8),
      for (final fieldName in fieldNames) ...[
        if (fieldName != fieldNames.last) ...[
          '$fieldName == other.$fieldName &&'.indent(8),
        ] else ...[
          '$fieldName == other.$fieldName;'.indent(8),
        ],
      ],
      '}'.indent(2),
    ].join('\n');
    builder.declareInType(DeclarationCode.fromString(code));
  }

  void _buildHashCode(
    MemberDeclarationBuilder builder,
    List<String> fieldNames,
  ) {
    final code = [
      '@override'.indent(2),
      'int get hashCode {'.indent(2),
      'return Object.hash('.indent(4),
      'runtimeType,'.indent(6),
      for (final fieldName in fieldNames) ...[
        '$fieldName,'.indent(6),
      ],
      ');'.indent(4),
      '}'.indent(2),
    ].join('\n');
    builder.declareInType(DeclarationCode.fromString(code));
  }
}

extension on String {
  String indent(int length) {
    final space = StringBuffer();
    for (var i = 0; i < length; i++) {
      space.write(' ');
    }
    return '$space$this';
  }
}
