import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_stats_app/conversa.dart';
import 'package:love_stats_app/analises.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:love_stats_app/telas/tela_stories.dart';
import 'package:fl_chart/fl_chart.dart';

class TelaAnalise extends StatelessWidget {
  final Conversa conversa;

  const TelaAnalise({required this.conversa, super.key});

  // Função utilitária para ordenar o Map por valores (decrescente)
  Map<String, int> _ordenarDados(Map<String, int> dados) {
    var entradas = dados.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(entradas);
  }

  @override
  Widget build(BuildContext context) {
    final mensagensPorUser = _ordenarDados(contarMensagensPorUsuario(conversa.mensagens));
    final euTeAmoPorUser = _ordenarDados(euTeAmoPorUsuario(conversa.mensagens));
    final midiaPorUser = _ordenarDados(contarMidia(conversa.mensagens));
    final bomDiaPorUser = _ordenarDados(contarBomDia(conversa.mensagens));
    final desculpasPorUser = _ordenarDados(contarDesculpas(conversa.mensagens));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Análise de Amor',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildGraficoPrincipal(mensagensPorUser),
            const SizedBox(height: 24),
            _buildCardMetrica(
              context, 
              'Quem fala mais? 📱', 
              mensagensPorUser,
              Colors.blue[400]!,
            ),
            _buildCardMetrica(
              context, 
              'Quem ama mais? ❤️', 
              euTeAmoPorUser,
              const Color(0xFFFF6B6B),
            ),
            _buildCardMetrica(
              context, 
              'Mestre da Mídia 📸', 
              midiaPorUser,
              Colors.purple[400]!,
            ),
            _buildCardMetrica(
              context, 
              'Educação em dia ☕', 
              bomDiaPorUser,
              Colors.orange[400]!,
            ),
            _buildCardMetrica(
              context, 
              'Quem pede mais desculpa? 😅', 
              desculpasPorUser,
              Colors.green[400]!,
            ),
            const SizedBox(height: 16),
            _buildCardBloqueado(context, 'Horário que mais conversam ⏰'),
            _buildCardBloqueado(context, 'Palavras mais usadas 🔤'),
            const SizedBox(height: 32),
            _buildBotaoStories(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFFF6B6B), const Color(0xFFA29BFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          const Icon(Icons.favorite, color: Colors.white, size: 40),
          const SizedBox(height: 12),
          Text(
            conversa.nome.replaceAll('Chat do WhatsApp com ', '').replaceAll('.txt', ''),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${conversa.mensagens.length} mensagens analisadas',
            style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.9), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildGraficoPrincipal(Map<String, int> dados) {
    if (dados.length < 2) return const SizedBox.shrink();
    
    final total = dados.values.reduce((a, b) => a + b);
    final keys = dados.keys.toList();

    return AspectRatio(
      aspectRatio: 1.3,
      child: Card(
        elevation: 0,
        color: Colors.grey[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text('Distribuição de Mensagens', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: dados[keys[0]]!.toDouble(),
                      title: '${((dados[keys[0]]! / total) * 100).toStringAsFixed(1)}%',
                      color: const Color(0xFFFF6B6B),
                      radius: 50,
                      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    PieChartSectionData(
                      value: dados[keys[1]]!.toDouble(),
                      title: '${((dados[keys[1]]! / total) * 100).toStringAsFixed(1)}%',
                      color: const Color(0xFFA29BFE),
                      radius: 50,
                      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegenda(keys[0], const Color(0xFFFF6B6B)),
                const SizedBox(width: 20),
                _buildLegenda(keys[1], const Color(0xFFA29BFE)),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLegenda(String nome, Color cor) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: cor, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(nome, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _buildCardMetrica(BuildContext context, String titulo, Map<String, int> dados, Color cor) {
    if (dados.isEmpty) return const SizedBox.shrink();

    final keys = dados.keys.toList();
    if (keys.length < 2) return const SizedBox.shrink();

    final total = dados.values.reduce((a, b) => a + b);
    final user1 = keys[0]; // Agora garantidamente o vencedor por causa do _ordenarDados
    final user2 = keys[1];
    final val1 = dados[user1] ?? 0;
    final val2 = dados[user2] ?? 0;
    
    double percent = total > 0 ? val1 / total : 0.5;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(titulo, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
                const Icon(Icons.stars, color: Colors.amber, size: 20),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(user1, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                Text('$val1', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: cor)),
              ],
            ),
            const SizedBox(height: 8),
            LinearPercentIndicator(
              lineHeight: 12.0,
              percent: percent,
              backgroundColor: cor.withOpacity(0.1),
              progressColor: cor,
              barRadius: const Radius.circular(10),
              animation: true,
              animationDuration: 1000,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(user2, style: GoogleFonts.poppins(fontSize: 12), overflow: TextOverflow.ellipsis, textAlign: TextAlign.right)),
                Text('$val2', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: cor.withOpacity(0.6))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBloqueado(BuildContext context, String titulo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, color: Colors.grey),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              titulo,
              style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text('Desbloquear', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFFFF6B6B))),
          ),
        ],
      ),
    );
  }

  Widget _buildBotaoStories(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TelaStories(conversa: conversa)),
        );
      },
      icon: const Icon(Icons.auto_awesome, color: Colors.white),
      label: Text(
        'VER COMO STORY ✨',
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF6B6B),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 8,
      ),
    );
  }
}
