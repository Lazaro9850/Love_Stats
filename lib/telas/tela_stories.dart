import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_stats_app/conversa.dart';
import 'package:love_stats_app/analises.dart';

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
          // Slides
          GestureDetector(
            onTapDown: (details) {
              final screenWidth = MediaQuery.of(context).size.width;
              if (details.globalPosition.dx < screenWidth / 3) {
                // Toque na esquerda: volta
                if (_indiceAtual > 0) {
                  _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                }
              } else {
                // Toque na direita: avança
                if (_indiceAtual < _slides.length - 1) {
                  _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                } else {
                  Navigator.pop(context);
                }
              }
            },
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _indiceAtual = index;
                });
              },
              children: _slides,
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
        ],
      ),
    );
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
              'em dados ❤️',
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
    final maxVal = dados[vencedor] ?? 0;
    
    String outroUser = "";
    int outroVal = 0;
    if (keys.length > 1) {
      outroUser = keys[1];
      outroVal = dados[outroUser] ?? 0;
    }

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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          // Winner Card
          _buildUserScoreCard(vencedor, maxVal, true),
          const SizedBox(height: 20),
          if (outroUser.isNotEmpty) ...[
            Text('vs', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 18, fontStyle: FontStyle.italic)),
            const SizedBox(height: 20),
            _buildUserScoreCard(outroUser, outroVal, false),
          ],
          const Spacer(),
          Text(
            '$vencedor ganhou essa!',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.share),
            label: const Text('Compartilhar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: cores[1],
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserScoreCard(String nome, int valor, bool isWinner) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: isWinner ? Colors.white.withOpacity(0.3) : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: isWinner ? Border.all(color: Colors.amber, width: 2) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              nome,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$valor',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (isWinner) ...[
            const SizedBox(width: 10),
            const Icon(Icons.stars, color: Colors.amber),
          ]
        ],
      ),
    );
  }

  Widget _buildSlideFinal() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Obrigado por amarem!',
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
