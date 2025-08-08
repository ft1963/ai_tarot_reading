// lib/pages/tarot_input_page.dart
import 'package:flutter/material.dart';
import 'tarot_result_page.dart';

class TarotInputPage extends StatefulWidget {
  const TarotInputPage({super.key});

  @override
  State<TarotInputPage> createState() => _TarotInputPageState();
}

class _TarotInputPageState extends State<TarotInputPage> {
  final TextEditingController _consultationController = TextEditingController();

  String _cardType = '大アルカナ';
  String? _selectedMajorCard;
  String _selectedMinorSuit = 'ワンド';
  String? _selectedMinorValue;
  String _selectedPosition = '正位置';

  final List<String> _majorArcanaCards = [
    '0. 愚者', 'I. 魔術師', 'II. 女教皇', 'III. 女帝', 'IV. 皇帝', 'V. 法皇', 'VI. 恋人',
    'VII. 戦車', 'VIII. 力', 'IX. 隠者', 'X. 運命の輪', 'XI. 正義', 'XII. 吊るされた男',
    'XIII. 死神', 'XIV. 節制', 'XV. 悪魔', 'XVI. 塔', 'XVII. 星', 'XVIII. 月',
    'XIX. 太陽', 'XX. 審判', 'XXI. 世界',
  ];

  final List<String> _minorSuits = ['ワンド', 'カップ', 'ソード', 'ペンタクル'];
  final Map<String, List<String>> _minorValues = {
    'ワンド': ['エース', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'ペイジ', 'ナイト', 'クイーン', 'キング'],
    'カップ': ['エース', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'ペイジ', 'ナイト', 'クイーン', 'キング'],
    'ソード': ['エース', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'ペイジ', 'ナイト', 'クイーン', 'キング'],
    'ペンタクル': ['エース', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'ペイジ', 'ナイト', 'クイーン', 'キング'],
  };

  @override
  void initState() {
    super.initState();
    _selectedMajorCard = _majorArcanaCards.first;
    _selectedMinorValue = _minorValues[_selectedMinorSuit]!.first;
  }

  void _onCardTypeChanged(String? value) {
    setState(() => _cardType = value!);
  }

  void _onMinorSuitChanged(String? value) {
    setState(() {
      _selectedMinorSuit = value!;
      _selectedMinorValue = _minorValues[value]!.first;
    });
  }

  void _onTarotSubmit() {
    if (_consultationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('相談内容を入力してください。')),
      );
      return;
    }

    final String selectedCardName = _cardType == '大アルカナ'
        ? _selectedMajorCard!
        : '$_selectedMinorSuitの$_selectedMinorValue';

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TarotResultPage(
          consultation: _consultationController.text,
          selectedCard: selectedCardName,
          position: _selectedPosition,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _consultationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🃏 タロット占い'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🔮 相談内容', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _consultationController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        hintText: '例: 今後の仕事についてアドバイスがほしい',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('🎴 カードの種類', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: '大アルカナ', label: Text('大アルカナ')),
                        ButtonSegment(value: '小アルカナ', label: Text('小アルカナ')),
                      ],
                      selected: {_cardType},
                      onSelectionChanged: (val) => _onCardTypeChanged(val.first),
                    ),
                    const SizedBox(height: 20),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _cardType == '大アルカナ'
                          ? _buildMajorArcanaSelector()
                          : _buildMinorArcanaSelector(),
                    ),
                    const SizedBox(height: 24),
                    Text('🧭 カードの位置', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: '正位置', label: Text('正位置')),
                        ButtonSegment(value: '逆位置', label: Text('逆位置')),
                      ],
                      selected: {_selectedPosition},
                      onSelectionChanged: (val) => setState(() => _selectedPosition = val.first),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _onTarotSubmit,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('鑑定する'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMajorArcanaSelector() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedMajorCard,
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: _majorArcanaCards
                .map((card) => DropdownMenuItem(value: card, child: Text(card)))
                .toList(),
            onChanged: (value) => setState(() => _selectedMajorCard = value),
          ),
        ],
      );

  Widget _buildMinorArcanaSelector() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            children: _minorSuits.map((suit) => ChoiceChip(
                  label: Text(suit),
                  selected: _selectedMinorSuit == suit,
                  onSelected: (_) => _onMinorSuitChanged(suit),
                )).toList(),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedMinorValue,
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: _minorValues[_selectedMinorSuit]!
                .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                .toList(),
            onChanged: (value) => setState(() => _selectedMinorValue = value),
          ),
        ],
      );
}
