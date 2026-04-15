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

  // Cores fixas para manter consistência
  static const Color colorUser1 = Color(0xFFFF6B6B); // Rosa
  static const Color colorUser2 = Color(0xFFA29BFE); // Roxo/Azul suave

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
    final saudacoes = contarSaudacoesDetalhado(conversa.mensagens);
    final desculpasPorUser = _ordenarDados(contarDesculpas(conversa.mensagens));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('Análise de Amor', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            
            // 1. Total de mensagens (Bar Chart Vertical)
            _buildSectionTitle('Total de Mensagens 📱'),
            _buildBarChartVertical(mensagensPorUser),
            
            const SizedBox(height: 32),
            
            // 2. Eu te amo (Horizontal Bar Chart)
            _buildSectionTitle('Quem falou mais eu te amo? ❤️'),
            _buildBarChartHorizontal(euTeAmoPorUser),
            
            const SizedBox(height: 32),

            // 3. Mídias enviadas (Pie Chart)
            _buildSectionTitle('Mestre da Mídia 📸'),
            _buildPieChartMidia(midiaPorUser),

            const SizedBox(height: 32),

            // 4. Saudações (Stacked Bar Chart)
            _buildSectionTitle('Padrões de Saudações ☕'),
            _buildStackedBarChart(saudacoes),

            const SizedBox(height: 32),

            // 5. Desculpas (Percent Indicator)
            _buildSectionTitle('Quem pede mais desculpa? 😅'),
            _buildDesculpasIndicator(desculpasPorUser),

            const SizedBox(height: 40),
            _buildBotaoStories(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(width: 4, height: 24, decoration: BoxDecoration(color: colorUser1, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 12),
          Text(titulo, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [colorUser1, colorUser2], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: colorUser1.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          const Icon(Icons.favorite, color: Colors.white, size: 40),
          const SizedBox(height: 12),
          Text(
            conversa.nome.replaceAll('Chat do WhatsApp com ', '').replaceAll('.txt', ''),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text('${conversa.mensagens.length} mensagens analisadas', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.9), fontSize: 13)),
        ],
      ),
    );
  }

  // 1. Bar Chart Vertical (Total Mensagens)
  Widget _buildBarChartVertical(Map<String, int> dados) {
    if (dados.isEmpty) return const Text('Sem dados');
    final keys = dados.keys.toList();
    final maxVal = dados.values.reduce((a, b) => a > b ? a : b).toDouble();

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxVal * 1.2,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int i = value.toInt();
                  if (i >= 0 && i < keys.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(keys[i].split(' ')[0], style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold)),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(keys.length, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: dados[keys[index]]!.toDouble(),
                  color: index == 0 ? colorUser1 : colorUser2,
                  width: 40,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                )
              ],
              showingTooltipIndicators: [0],
            );
          }),
        ),
      ),
    );
  }

  // 2. Horizontal Bar Chart (Eu Te Amo)
  Widget _buildBarChartHorizontal(Map<String, int> dados) {
    if (dados.isEmpty) return const Text('Ninguém disse eu te amo ainda? 😢');
    final keys = dados.keys.toList();
    final total = dados.values.fold(0, (sum, item) => sum + item);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: List.generate(keys.length, (index) {
          final user = keys[index];
          final val = dados[user] ?? 0;
          final percent = total > 0 ? val / total : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(user, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('$val ❤️', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: colorUser1)),
                  ],
                ),
                const SizedBox(height: 8),
                LinearPercentIndicator(
                  lineHeight: 20.0,
                  percent: percent,
                  backgroundColor: Colors.grey[100],
                  progressColor: index == 0 ? colorUser1 : colorUser2,
                  barRadius: const Radius.circular(10),
                  animation: true,
                  animationDuration: 1000,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // 3. Pie Chart (Mídia)
  Widget _buildPieChartMidia(Map<String, int> dados) {
    if (dados.isEmpty) return const Text('Sem mídias detectadas');
    final keys = dados.keys.toList();
    final total = dados.values.reduce((a, b) => a + b);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: List.generate(keys.length, (index) {
                  final val = dados[keys[index]]!.toDouble();
                  final perc = (val / total * 100).toStringAsFixed(1);
                  return PieChartSectionData(
                    value: val,
                    title: '$perc%',
                    color: index == 0 ? colorUser1 : colorUser2,
                    radius: 60,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  );
                }),
                sectionsSpace: 2,
                centerSpaceRadius: 30,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(keys.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(width: 12, height: 12, decoration: BoxDecoration(color: index == 0 ? colorUser1 : colorUser2, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text(keys[index].split(' ')[0], style: GoogleFonts.poppins(fontSize: 12)),
                  ],
                ),
              );
            }),
          )
        ],
      ),
    );
  }

  // 4. Stacked Bar Chart (Saudações)
  Widget _buildStackedBarChart(Map<String, Map<String, int>> dados) {
    if (dados.isEmpty) return const Text('Sem saudações registradas');
    final users = dados.keys.toList();

    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int i = value.toInt();
                        if (i >= 0 && i < users.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(users[i].split(' ')[0], style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(users.length, (index) {
                  final user = users[index];
                  final dia = dados[user]!['dia']!.toDouble();
                  final tarde = dados[user]!['tarde']!.toDouble();
                  final noite = dados[user]!['noite']!.toDouble();
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: dia + tarde + noite,
                        width: 35,
                        borderRadius: BorderRadius.circular(6),
                        rodStackItems: [
                          BarChartRodStackItem(0, dia, Colors.orangeAccent),
                          BarChartRodStackItem(dia, dia + tarde, Colors.blueAccent),
                          BarChartRodStackItem(dia + tarde, dia + tarde + noite, Colors.indigo),
                        ],
                      )
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendaMini('Manhã', Colors.orangeAccent),
              const SizedBox(width: 12),
              _buildLegendaMini('Tarde', Colors.blueAccent),
              const SizedBox(width: 12),
              _buildLegendaMini('Noite', Colors.indigo),
            ],
          )
        ],
      ),
    );
  }

  // 5. Desculpas (Percent Indicator)
  Widget _buildDesculpasIndicator(Map<String, int> dados) {
    if (dados.isEmpty) return const Text('Ninguém errou ainda? Impossível! 😂');
    final keys = dados.keys.toList();
    if (keys.length < 2) return Text('${keys[0]} é o único que pede desculpas!');

    final total = dados.values.reduce((a, b) => a + b);
    final val1 = dados[keys[0]] ?? 0;
    final percent = total > 0 ? val1 / total : 0.5;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(keys[0].split(' ')[0], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: colorUser1)),
              Text(keys[1].split(' ')[0], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: colorUser2)),
            ],
          ),
          const SizedBox(height: 12),
          LinearPercentIndicator(
            lineHeight: 30.0,
            percent: percent,
            center: Text("${(percent * 100).toStringAsFixed(0)}% vs ${( (1-percent) * 100).toStringAsFixed(0)}%", 
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
            backgroundColor: colorUser2,
            progressColor: colorUser1,
            barRadius: const Radius.circular(15),
            animation: true,
            animationDuration: 1200,
          ),
          const SizedBox(height: 16),
          Text('Total de ${total} pedidos de desculpas', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildLegendaMini(String texto, Color cor) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: cor, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(texto, style: GoogleFonts.poppins(fontSize: 10)),
      ],
    );
  }

  Widget _buildBotaoStories(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => TelaStories(conversa: conversa)));
      },
      icon: const Icon(Icons.auto_awesome, color: Colors.white),
      label: Text('VER COMO STORY ✨', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      style: ElevatedButton.styleFrom(
        backgroundColor: colorUser1,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
        elevation: 10,
        shadowColor: colorUser1.withOpacity(0.5),
      ),
    );
  }
}
