import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class DocumentChunk {
  final String text;
  final String source;
  final int page;
  final int chunkIndex;

  DocumentChunk({
    required this.text,
    required this.source,
    required this.page,
    required this.chunkIndex,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'source': source,
        'page': page,
        'chunkIndex': chunkIndex,
      };

  factory DocumentChunk.fromJson(Map<String, dynamic> json) => DocumentChunk(
        text: json['text'] as String? ?? '',
        source: json['source'] as String? ?? 'Document',
        page: json['page'] as int? ?? 1,
        chunkIndex: json['chunkIndex'] as int? ?? 0,
      );
}

class ParseResult {
  final bool success;
  final int chunksCount;
  final String filename;
  final String message;
  final bool isScannedImage;

  ParseResult({
    required this.success,
    required this.chunksCount,
    required this.filename,
    required this.message,
    this.isScannedImage = false,
  });
}

/// Standalone, on-device RAG engine for Android phones.
/// Extracts text from PDFs/documents, creates semantic chunks, and performs
/// instant on-device BM25 ranking with zero server or internet requirements.
class OfflineRagService {
  static final OfflineRagService _instance = OfflineRagService._internal();
  factory OfflineRagService() => _instance;
  OfflineRagService._internal();

  final List<DocumentChunk> _chunks = [];
  bool _isInitialized = false;

  List<DocumentChunk> get allChunks => List.unmodifiable(_chunks);

  /// Initializes the RAG index by loading any previously parsed chunks from disk
  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final file = await _getIndexFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.trim().isNotEmpty) {
          final decoded = jsonDecode(content);
          if (decoded is List) {
            _chunks.clear();
            _chunks.addAll(
              decoded.map((item) => DocumentChunk.fromJson(item as Map<String, dynamic>)),
            );
            debugPrint('[OfflineRagService] Loaded ${_chunks.length} chunks from local index.');
          }
        }
      }
    } catch (e) {
      debugPrint('[OfflineRagService] Error loading local RAG index: $e');
    } finally {
      _isInitialized = true;
    }
  }

  Future<File> _getIndexFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/rag_index.json');
  }

  Future<void> _persistIndex() async {
    try {
      final file = await _getIndexFile();
      final tempFile = File('${file.path}.tmp');
      final data = jsonEncode(_chunks.map((c) => c.toJson()).toList());
      await tempFile.writeAsString(data, flush: true);
      if (await file.exists()) {
        await file.delete();
      }
      await tempFile.rename(file.path);
    } catch (e) {
      debugPrint('[OfflineRagService] Error persisting RAG index: $e');
    }
  }

  /// Parses bytes from PDF, TXT, or MD directly on the phone processor
  Future<ParseResult> indexDocument({
    required Uint8List bytes,
    required String filename,
  }) async {
    await init();

    final ext = filename.split('.').last.toLowerCase();
    final pagesContent = <Map<String, dynamic>>[];

    try {
      if (ext == 'pdf') {
        final PdfDocument document = PdfDocument(inputBytes: bytes);
        final PdfTextExtractor extractor = PdfTextExtractor(document);
        final pageCount = document.pages.count;

        int totalExtractedChars = 0;
        for (int i = 0; i < pageCount; i++) {
          final pageText = extractor.extractText(startPageIndex: i, endPageIndex: i).trim();
          if (pageText.isNotEmpty) {
            totalExtractedChars += pageText.length;
            pagesContent.add({'page': i + 1, 'text': pageText});
          }
        }
        document.dispose();

        // Check if the PDF has virtually no extractable digital text (e.g. CamScanner/photo PDF)
        if (totalExtractedChars < 25) {
          return ParseResult(
            success: false,
            chunksCount: 0,
            filename: filename,
            isScannedImage: true,
            message: 'No readable text found. This PDF appears to be a scanned image or photo.',
          );
        }
      } else {
        // Plain text, markdown, or code
        final rawText = utf8.decode(bytes, allowMalformed: true).trim();
        if (rawText.isNotEmpty) {
          pagesContent.add({'page': 1, 'text': rawText});
        }
      }

      if (pagesContent.isEmpty) {
        return ParseResult(
          success: false,
          chunksCount: 0,
          filename: filename,
          isScannedImage: true,
          message: 'The selected document appears to be empty or unreadable.',
        );
      }

      // Generate semantic chunks
      final newChunks = _chunkPages(pagesContent, filename);
      if (newChunks.isEmpty) {
        return ParseResult(
          success: false,
          chunksCount: 0,
          filename: filename,
          message: 'Failed to split document into readable chunks.',
        );
      }

      // Remove any existing chunks for this same filename to prevent duplication
      _chunks.removeWhere((c) => c.source.toLowerCase() == filename.toLowerCase());
      _chunks.addAll(newChunks);
      await _persistIndex();

      return ParseResult(
        success: true,
        chunksCount: newChunks.length,
        filename: filename,
        message: 'Successfully indexed ${newChunks.length} chunks from $filename!',
      );
    } catch (e) {
      debugPrint('[OfflineRagService] Indexing error: $e');
      return ParseResult(
        success: false,
        chunksCount: 0,
        filename: filename,
        message: 'Error processing document: $e',
      );
    }
  }

  /// Splits page text into semantic 800-character chunks with 120-character overlap
  List<DocumentChunk> _chunkPages(
    List<Map<String, dynamic>> pagesContent,
    String filename, {
    int chunkSize = 750,
    int chunkOverlap = 120,
  }) {
    final chunks = <DocumentChunk>[];
    int globalChunkIndex = 0;

    for (final pageInfo in pagesContent) {
      final pageNum = pageInfo['page'] as int;
      var text = pageInfo['text'] as String;

      text = text.replaceAll('\r\n', '\n');
      text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');

      int start = 0;
      final textLen = text.length;

      while (start < textLen) {
        int end = math.min(start + chunkSize, textLen);

        if (end < textLen) {
          // Priority 1: Double newline (paragraph/problem break)
          final paraBreak = text.lastIndexOf('\n\n', end);
          if (paraBreak != -1 && paraBreak > start + chunkOverlap) {
            end = paraBreak;
          } else {
            // Priority 2: Sentence endings (. / ? / ! / :)
            final s1 = text.lastIndexOf('. ', end);
            final s2 = text.lastIndexOf('? ', end);
            final s3 = text.lastIndexOf('!\n', end);
            final s4 = text.lastIndexOf(':\n', end);
            final bestSentenceBreak = [s1, s2, s3, s4].reduce(math.max);

            if (bestSentenceBreak != -1 && bestSentenceBreak > start + chunkOverlap) {
              end = bestSentenceBreak + 1;
            } else {
              // Priority 3: Word space
              final spaceBreak = text.lastIndexOf(' ', end);
              if (spaceBreak != -1 && spaceBreak > start + chunkOverlap) {
                end = spaceBreak;
              }
            }
          }
        }

        final rawChunk = text.substring(start, end).trim();
        if (rawChunk.isNotEmpty) {
          chunks.add(
            DocumentChunk(
              text: '[$filename | Page $pageNum]\n$rawChunk',
              source: filename,
              page: pageNum,
              chunkIndex: globalChunkIndex++,
            ),
          );
        }

        start = (end < textLen) ? end - chunkOverlap : textLen;
      }
    }

    return chunks;
  }

  /// Checks if a query is a greeting or casual chat, avoiding unwanted document injection
  bool isConversational(String text) {
    final clean = text.trim().toLowerCase().replaceAll(RegExp(r'[^a-z\s]'), '');
    const casual = {
      'hi', 'hello', 'hey', 'hello sir', 'hi sir', 'hey sir',
      'good morning', 'good evening', 'good afternoon', 'good night',
      'thanks', 'thank you', 'ok', 'okay', 'wth', 'what', 'bye', 'cool',
      'how are you', 'who are you', 'help'
    };
    return casual.contains(clean);
  }

  /// High-speed on-device BM25 ranking across specified or all active documents
  List<DocumentChunk> retrieve({
    required String query,
    List<String>? activeDocuments,
    int topK = 4,
  }) {
    if (_chunks.isEmpty || query.trim().isEmpty) return [];

    // Conversational greetings should NEVER receive document context
    if (isConversational(query)) return [];

    // Filter to target documents if specified
    var candidateChunks = _chunks;
    if (activeDocuments != null && activeDocuments.isNotEmpty) {
      final lowerDocs = activeDocuments.map((d) => d.toLowerCase()).toSet();
      candidateChunks = _chunks.where((c) => lowerDocs.contains(c.source.toLowerCase())).toList();
      if (candidateChunks.isEmpty) {
        // Fallback to all chunks if session document was renamed
        candidateChunks = _chunks;
      }
    }

    if (candidateChunks.isEmpty) return [];

    // Tokenize query with ordinal normalization
    final queryTokens = _tokenize(query);
    if (queryTokens.isEmpty) {
      return [];
    }

    // Precompute document lengths and frequencies for BM25
    final docTokensList = candidateChunks.map((c) => _tokenize(c.text)).toList();
    final int N = candidateChunks.length;
    double totalDocLength = 0;
    for (final dt in docTokensList) {
      totalDocLength += dt.length;
    }
    final double avgdl = totalDocLength / (N > 0 ? N : 1);

    // Document frequencies (DF) for each query token
    final Map<String, int> df = {};
    for (final qToken in queryTokens) {
      int count = 0;
      for (final docTokens in docTokensList) {
        if (docTokens.contains(qToken)) count++;
      }
      df[qToken] = count;
    }

    const double k1 = 1.2;
    const double b = 0.75;
    final lowerQuery = query.toLowerCase().trim();

    // Check if query targets a specific question number (e.g. "4th question", "question 4", "Q4")
    final qNumMatch = RegExp(r'\b(?:question\s*|q\s*|#\s*)?(\d+)(?:st|nd|rd|th)?\b', caseSensitive: false).firstMatch(lowerQuery);
    final targetQuestionNum = qNumMatch?.group(1);

    // Score each candidate chunk
    final scores = <double>[];
    for (int i = 0; i < N; i++) {
      final docTokens = docTokensList[i];
      final docLength = docTokens.length;
      double score = 0.0;

      // Count token frequencies in this document
      final Map<String, int> tf = {};
      for (final token in docTokens) {
        tf[token] = (tf[token] ?? 0) + 1;
      }

      for (final qToken in queryTokens) {
        final int termFreq = tf[qToken] ?? 0;
        if (termFreq == 0) continue;

        final int docFreq = df[qToken] ?? 0;
        // Standard BM25 IDF
        final double idf = math.log(1.0 + (N - docFreq + 0.5) / (docFreq + 0.5));
        final double numerator = termFreq * (k1 + 1);
        final double denominator = termFreq + k1 * (1 - b + b * (docLength / (avgdl > 0 ? avgdl : 1)));
        score += idf * (numerator / denominator);
      }

      final cText = candidateChunks[i].text.toLowerCase();

      // Bonus boost if the exact multi-word query phrase appears in the text
      if (lowerQuery.length > 3 && cText.contains(lowerQuery)) {
        score += 3.5;
      }

      // Question number boost: if user asks for question N, boost chunks containing "N." or "Question N"
      if (targetQuestionNum != null) {
        if (cText.contains('$targetQuestionNum.') ||
            cText.contains('question $targetQuestionNum') ||
            cText.contains('q$targetQuestionNum') ||
            cText.contains('q.$targetQuestionNum')) {
          score += 5.0;
        }
      }

      scores.add(score);
    }

    // Pair chunks with their scores
    final indexedPairs = List.generate(N, (i) => MapEntry(candidateChunks[i], scores[i]));
    indexedPairs.sort((a, b) => b.value.compareTo(a.value));

    // Return top-scoring chunks with positive match score
    final results = indexedPairs.where((p) => p.value > 0.05).map((p) => p.key).take(topK).toList();

    // If query has no keyword matches, fallback to first 2 sequential chunks only if query asks about summary/overview
    if (results.isEmpty) {
      if (lowerQuery.contains('summary') || lowerQuery.contains('contain') || lowerQuery.contains('overview') || lowerQuery.contains('notes')) {
        return candidateChunks.take(math.min(2, topK)).toList();
      }
      return [];
    }

    return results;
  }

  /// Removes common English/filler stopwords and normalizes ordinal numbers
  List<String> _tokenize(String text) {
    const stopWords = {
      'the', 'is', 'at', 'which', 'on', 'and', 'a', 'an', 'in', 'to', 'for', 'of',
      'or', 'by', 'with', 'from', 'as', 'that', 'this', 'it', 'are', 'was', 'were',
      'be', 'been', 'being', 'have', 'has', 'had', 'do', 'does', 'did', 'but', 'if',
      'then', 'else', 'when', 'up', 'down', 'out', 'all', 'any', 'both', 'each',
      'few', 'more', 'most', 'other', 'some', 'such', 'no', 'nor', 'not', 'only',
      'own', 'same', 'so', 'than', 'too', 'very', 'can', 'will', 'just', 'should',
      'now', 'tell', 'me', 'give', 'show', 'provide'
    };

    var normalized = text.toLowerCase();
    // Normalize ordinals so "4th" matches "4"
    normalized = normalized.replaceAll(RegExp(r'\b1st\b'), ' 1 first ');
    normalized = normalized.replaceAll(RegExp(r'\b2nd\b'), ' 2 second ');
    normalized = normalized.replaceAll(RegExp(r'\b3rd\b'), ' 3 third ');
    normalized = normalized.replaceAll(RegExp(r'\b4th\b'), ' 4 fourth ');
    normalized = normalized.replaceAll(RegExp(r'\b5th\b'), ' 5 fifth ');
    normalized = normalized.replaceAll(RegExp(r'\b6th\b'), ' 6 sixth ');
    normalized = normalized.replaceAll(RegExp(r'\b7th\b'), ' 7 seventh ');
    normalized = normalized.replaceAll(RegExp(r'\b8th\b'), ' 8 eighth ');
    normalized = normalized.replaceAll(RegExp(r'\b9th\b'), ' 9 ninth ');
    normalized = normalized.replaceAll(RegExp(r'\b10th\b'), ' 10 tenth ');

    return normalized
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty && !stopWords.contains(t))
        .toList();
  }

  /// Deletes all indexed chunks from memory and disk
  Future<void> clearAll() async {
    _chunks.clear();
    try {
      final file = await _getIndexFile();
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('[OfflineRagService] Error clearing index: $e');
    }
  }
}

