import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pocketllm/services/api_service.dart';

void main() {
  group('ApiService Tests', () {
    test('checkHealth returns online status and device info', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/health');
        return http.Response(
          json.encode({
            'status': 'online',
            'service': 'PocketLLM Backend',
            'device': 'cuda',
            'model': 'Qwen/Qwen2.5-0.5B-Instruct',
            'rag_chunks_indexed': 5,
            'uptime_seconds': 42.0,
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final api = ApiService(baseUrl: 'http://test-server:8000', client: mockClient);
      final health = await api.checkHealth();

      expect(health['status'], equals('online'));
      expect(health['device'], equals('cuda'));
      expect(health['rag_chunks_indexed'], equals(5));
    });

    test('streamChat parses SSE tokens and source citations', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/chat');
        final ssePayload = 'data: {"type": "sources", "sources": ["ncert_physics.pdf"]}\n\n'
            'data: {"type": "token", "content": "Newton"}\n\n'
            'data: {"type": "token", "content": " Third"}\n\n'
            'data: {"type": "token", "content": " Law"}\n\n'
            'data: {"type": "done"}\n\n';

        return http.Response(
          ssePayload,
          200,
          headers: {'content-type': 'text/event-stream'},
        );
      });

      final api = ApiService(baseUrl: 'http://test-server:8000', client: mockClient);
      List<String> receivedSources = [];
      final stream = api.streamChat(
        message: 'Explain Third Law',
        onSources: (srcs) => receivedSources = srcs,
      );

      final tokens = await stream.toList();
      expect(tokens, equals(['Newton', ' Third', ' Law']));
      expect(receivedSources, equals(['ncert_physics.pdf']));
    });

    test('streamChat correctly includes activeDocument in payload', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/chat');
        final body = json.decode(request.body) as Map<String, dynamic>;
        expect(body['active_document'], equals('Assignment_1.pdf'));
        expect(body['use_rag'], isTrue);

        final ssePayload = 'data: {"type": "sources", "sources": ["Assignment_1.pdf"]}\n\n'
            'data: {"type": "token", "content": "Summary"}\n\n'
            'data: {"type": "done"}\n\n';

        return http.Response(
          ssePayload,
          200,
          headers: {'content-type': 'text/event-stream'},
        );
      });

      final api = ApiService(baseUrl: 'http://test-server:8000', client: mockClient);
      final stream = api.streamChat(
        message: 'Summarize the complete pdf in hinglish',
        activeDocument: 'Assignment_1.pdf',
      );

      final tokens = await stream.toList();
      expect(tokens, equals(['Summary']));
    });

    test('uploadDocument correctly transmits bytes', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/upload');
        return http.Response(
          json.encode({
            'success': true,
            'filename': 'formula_sheet.txt',
            'chunks_added': 3,
            'total_chunks_in_db': 8,
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final api = ApiService(baseUrl: 'http://test-server:8000', client: mockClient);
      final res = await api.uploadDocument(
        bytes: utf8.encode('Kinetic Energy = 0.5 * m * v^2'),
        filename: 'formula_sheet.txt',
      );

      expect(res['success'], isTrue);
      expect(res['chunks_added'], equals(3));
      expect(res['total_chunks_in_db'], equals(8));
    });
  });
}

