import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_stats_app/conversa.dart';
import 'package:love_stats_app/analises.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class TelaStories extends StatefulWidget {
  final Conversa conversa;

  const TelaStories({required this.conversa, super.key});

  @override
  State<TelaStories> createState() => _TelaStoriesState();
}

class _TelaStoriesState extends State<TelaStories> {
  int _indiceAtual = 0;
  late List<Widget> _slides;
  final PageController _pageController = PageController();
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _slides = _gerarSlides();
  }

  // Função utilitária para ordenar o Map por valores (decrescente)
  Map<String, int> _ordenarDados(Map<String, int> dados) {
    var entradas = dados.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(entradas);
  }

  List<Widget> _gerarSlides() {
    final msgs = _ordenarDados(contarMensagensPorUsuario(widget.conversa.mensagens));
    final love = _ordenarDados(euTeAmoPorUsuario(widget.conversa.mensagens));
    final midia = _ordenarDados(contarMidia(widget.conversa.mensagens));
    final desculpas = _ordenarDados(contarDesculpas(widget.conversa.mensagens));

    return [
      _buildSlideCapa(),
      _buildSlideMetrica('Quem fala mais? 📱', msgs, [const Color(0xFF64B5F6), const Color(0xFF1E88E5)]),
      _buildSlideMetrica('Quem ama mais? ❤️', love, [const Color(0xFFFF8A80), const Color(0xFFFF5252)]),
      _buildSlideMetrica('Mestre da Mídia 📸', midia, [const Color(0xFFCE93D8), const Color(0xFFAB47BC)]),
      _buildSlideMetrica('Quem pede mais desculpa? 😅', desculpas, [const Color(0xFFA5D6A7), const Color(0xFF43A047)]),
      _buildSlideFinal(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Slides envoltos pelo ScreenshotController
          Screenshot(
            controller: _screenshotController,
            child: GestureDetector(
              onTapDown: (details) {
                final screenWidth = MediaQuery.of(context).size.width;
                if (details.globalPosition.dx < screenWidth / 3) {
                  if (_indiceAtual > 0) {
                    _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  }
                } else {
                  if (_indiceAtual < _slides.length - 1) {
                    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  } else {
                    Navigator.pop(context);
                  }
                }
              },
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _indiceAtual = index;
                  });
                },
                children: _slides,
              ),
            ),
          ),

          // Barras de progresso no topo
          PositionedBarra(
            top: 50,
            left: 10,
            right: 10,
            child: Row(
              children: List.generate(_slides.length, (index) {
                return Expanded(
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: index <= _indiceAtual ? Colors.white : Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Botão Fechar
          Positioned(
            top: 60,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          
          // Botão Compartilhar (sempre visível no story)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _compartilharSlide,
                icon: const Icon(Icons.share, size: 20),
                label: const Text('Compartilhar este Story'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30), side: const BorderSide(color: Colors.white)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _compartilharSlide() async {
    final image = await _screenshotController.capture();
    if (image != null) {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = await File('${directory.path}/love_stats_story.png').create();
      await imagePath.writeAsBytes(image);
      
      await Share.shareXFiles([XFile(imagePath.path)], text: 'Olha os dados da nossa conversa no LoveStats! ❤️');
    }
  }

  Widget _buildSlideCapa() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFA29BFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 80), // Espaço para não sobrepor a barra
            const Icon(Icons.favorite, color: Colors.white, size: 100),
            const SizedBox(height: 20),
            Text(
              'Nossa História',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'em cada detalhe ❤️',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlideMetrica(String titulo, Map<String, int> dados, List<Color> cores) {
    if (dados.isEmpty) return Container(color: cores[0], child: const Center(child: Text('Sem dados')));
    
    final keys = dados.keys.toList();
    final vencedor = keys[0];
    final total = dados.values.fold(0, (sum, i) => sum + i);

    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: cores,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 60), // Espaço para não sobrepor a barra
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          // Mini Gráfico no Story
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sections: List.generate(keys.length, (index) {
                  final val = dados[keys[index]]!.toDouble();
                  return PieChartSectionData(
                    value: val,
                    title: '${(val/total*100).toStringAsFixed(0)}%',
                    color: index == 0 ? Colors.white : Colors.white.withOpacity(0.4),
                    radius: 50,
                    titleStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                  );
                }),
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 40),
          _buildRankingStory(keys, dados),
          const Spacer(),
          Text(
            '$vencedor ganhou essa!',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 100), // Espaço para o botão de compartilhar
        ],
      ),
    );
  }

  Widget _buildRankingStory(List<String> keys, Map<String, int> dados) {
    return Column(
      children: List.generate(keys.length, (index) {
        final user = keys[index];
        final val = dados[user] ?? 0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(user, style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: index == 0 ? FontWeight.bold : FontWeight.normal)),
              Text('$val', style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSlideFinal() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 80),
            Text(
              'O amor nos dados!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.favorite, color: Colors.red, size: 60),
            const SizedBox(height: 40),
            Text(
              'LoveStats',
              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class PositionedBarra extends Positioned {
  const PositionedBarra({super.key, super.left, super.top, super.right, super.bottom, required super.child});
}
