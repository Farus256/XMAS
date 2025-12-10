import 'dart:convert';
import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/tree_result.dart';
import '../secrets.dart';

class TreeRaterService {
  Future<TreeResult> rateTree(Uint8List imageBytes, String mimeType) async {
    try {
      final key = geminiApiKey.trim();
      if (key.isEmpty) {
        return const TreeResult(
          score: 0,
          lights: 0,
          decor: 0,
          vibe: 0,
          symmetry: 0,
          comment: 'Ошибка: API ключ пустой. Вставьте ваш Gemini ключ в secrets.dart.',
          advice: <String>[],
        );
      }
      if (!_isAscii(key)) {
        return const TreeResult(
          score: 0,
          lights: 0,
          decor: 0,
          vibe: 0,
          symmetry: 0,
          comment:
              'Ошибка: API ключ содержит не-ASCII символы. Убедитесь, что ключ скопирован без кириллицы/пробелов.',
          advice: <String>[],
        );
      }

      if (imageBytes.isEmpty) {
        return const TreeResult(
          score: 0,
          lights: 0,
          decor: 0,
          vibe: 0,
          symmetry: 0,
          comment: 'Ошибка: изображение пустое.',
          advice: <String>[],
        );
      }

      const maxBytes = 10 * 1024 * 1024; // 10 MB
      if (imageBytes.length > maxBytes) {
        return const TreeResult(
          score: 0,
          lights: 0,
          decor: 0,
          vibe: 0,
          symmetry: 0,
          comment: 'Ошибка: файл изображения слишком большой (>10MB).',
          advice: <String>[],
        );
      }

      const allowedMime = ['image/jpeg', 'image/png', 'image/webp'];
      if (!allowedMime.contains(mimeType.toLowerCase())) {
        return const TreeResult(
          score: 0,
          lights: 0,
          decor: 0,
          vibe: 0,
          symmetry: 0,
          comment: 'Ошибка: неподдерживаемый тип файла. Используйте JPEG/PNG/WebP.',
          advice: <String>[],
        );
      }

      final model = GenerativeModel(
        model: 'gemini-2.5-flash-lite',
        apiKey: key,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
        ),
      );

      final prompt = '''
You are a professional expert in visual assessment of Christmas trees.

Task:
You are shown a photo of a single holiday tree. Your goal is to objectively and consistently evaluate it using a set of criteria. For the same photo, you must provide the same scores and very similar wording, with no jokes or randomness.

Rating scale:
- All scores are whole numbers from 1 to 10.
- 1–2: very poor
- 3–4: below average
- 5–6: acceptable
- 7–8: good
- 9–10: excellent
- The field "score" is the rounded average of lights, decor, vibe, and symmetry.

Criteria:
- lights: quality of lighting  
  Consider presence of garlands, amount and brightness of lights, color harmony, and even distribution across the height and width of the tree. Large dark areas, chaotic blinking, or overly harsh brightness reduce the score.

- decor: ornaments and overall decoration  
  Consider variety and compatibility of ornaments, color combinations, density, and even placement. Empty areas, visual clutter, mismatched colors, or excessive overload reduce the score.

- vibe: overall festive atmosphere  
  Consider how cozy and festive the tree feels as a whole: the combination of the tree, lighting, and decorations, how it integrates with the room background, and the sense of a complete composition. A dull, cold, or unfinished look reduces the score.

- symmetry: shape and neatness  
  Consider the tree silhouette, the straightness of the top, symmetry of branches, presence of bare spots, and noticeable tilt or distortion. The more even and full the shape, the higher the score.

Text fields:
- comment: 1–2 short neutral sentences summarizing the strengths and weaknesses based on the given scores. Wording must be simple and repeatable for identical scores.
- advice: an array of exactly 3 short and specific recommendations to improve lights, decor, vibe, or symmetry.

Response format:
Return only JSON without explanations or extra text, strictly in the format:

{
  "score": int,
  "lights": int,
  "decor": int,
  "vibe": int,
  "symmetry": int,
  "comment": "string",
  "advice": ["string", "string", "string"]
}

''';


      final content = Content.multi([
        TextPart(prompt),
        DataPart(mimeType, imageBytes),
      ]);

      final response = await model.generateContent([content]);
      final text = response.text ?? '';
      final cleaned = _cleanResponse(text);
      final decoded = jsonDecode(cleaned);
      if (decoded is! Map<String, dynamic>) {
        throw FormatException('Некорректный формат JSON от модели');
      }
      return TreeResult.fromJson(decoded);
    } catch (e) {
      return TreeResult(
        score: 0,
        lights: 0,
        decor: 0,
        vibe: 0,
        symmetry: 0,
        comment: 'Ошибка: $e',
        advice: const <String>[],
      );
    }
  }

  bool _isAscii(String value) => value.runes.every((r) => r <= 0x7F);

  String _cleanResponse(String raw) {
    var cleaned = raw.trim();
    cleaned = cleaned.replaceAll(RegExp(r'^```[a-zA-Z]*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'```$'), '');
    cleaned = cleaned.trim();
    return cleaned;
  }
}

