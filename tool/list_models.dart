import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:xmas/secrets.dart';

Future<void> main() async {
  final key = geminiApiKey.trim();
  if (key.isEmpty) {
    print('Ошибка: в secrets.dart не указан geminiApiKey.');
    return;
  }

  final url = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models?key=$key',
  );

  try {
    final response = await http.get(url);
    if (response.statusCode != 200) {
      print('Ошибка запроса: ${response.statusCode}');
      print(response.body);
      return;
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final models = (data['models'] as List?) ?? [];

    final filtered = <Map<String, dynamic>>[];

    print('=== Доступные модели (generateContent) ===');
    for (final item in models) {
      if (item is! Map) continue;
      final supported = item['supportedGenerationMethods'];
      if (supported is List && supported.contains('generateContent')) {
        final name = item['name'] ?? 'unknown';
        final desc = item['description'] ?? '';
        print('Название: $name');
        print('Описание: $desc\n');
        filtered.add({
          'name': name,
          'description': desc,
          'supportedGenerationMethods': supported,
        });
      }
    }

    final output = {
      'timestamp': DateTime.now().toIso8601String(),
      'count': filtered.length,
      'models': filtered,
    };

    final outFile = File('tool/models.json');
    await outFile.writeAsString(const JsonEncoder.withIndent('  ').convert(output));
    print('Сохранено в ${outFile.path}');
  } catch (e) {
    print('Произошла ошибка: $e');
  }
}

