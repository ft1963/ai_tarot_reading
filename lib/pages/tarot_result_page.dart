// lib/pages/tarot_result_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';

class TarotResultPage extends StatefulWidget {
  final String consultation;
  final String selectedCard;
  final String position;

  const TarotResultPage({
    super.key,
    required this.consultation,
    required this.selectedCard,
    required this.position,
  });

  @override
  State<TarotResultPage> createState() => _TarotResultPageState();
}

class _TarotResultPageState extends State<TarotResultPage> {
  String _resultMessage = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTarotReading();
  }

  Future<void> _fetchTarotReading() async {
    final prompt = 'あなたはタロットカード占い師です。「${widget.consultation}」という相談に対してカードを引いたところ、「${widget.selectedCard}」の「${widget.position}」が出ました。相手に寄り添った親切な鑑定をお願いします。鑑定結果はMarkdown記法を用いて、見出しや箇条書きで分かりやすく整理してください。';
    final List<Map<String, String>> chatHistory = [
      {'role': 'user', 'content': prompt}
    ];

    try {
      final response = await http.post(
        Uri.parse('http://localhost:11434/api/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': 'gemma3:4b',
          'messages': chatHistory,
          'stream': false,
        }),
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String modelResponse = data['message']['content'];
        setState(() => _resultMessage = modelResponse);
      } else {
        setState(() => _resultMessage = 'エラー: ステータスコード: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _resultMessage = 'エラー: 通信中に問題が発生しました。$e');
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _copyToClipboard() {
    if (_resultMessage.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _resultMessage)).then((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('鑑定結果をコピーしました！')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔮 鑑定結果'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'カード: ${widget.selectedCard} (${widget.position})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : MarkdownBody(data: _resultMessage, selectable: true),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _copyToClipboard,
                icon: const Icon(Icons.copy),
                label: const Text('結果をコピー'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
