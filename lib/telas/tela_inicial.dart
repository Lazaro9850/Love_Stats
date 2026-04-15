import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_stats_app/conversa.dart';
import 'package:love_stats_app/parser.dart';
import 'package:love_stats_app/telas/tela_analise.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:love_stats_app/importador_servico.dart';

class PaginaInicial extends StatefulWidget {
  @override
  State<PaginaInicial> createState() => _PaginaInicialState();
}

class _PaginaInicialState extends State<PaginaInicial> {
  List<Conversa> conversas = [];
  bool _estaCarregando = false;
  late StreamSubscription _intentDataStreamSubscription;

  @override
  void initState() {
    super.initState();

    // Para compartilhamento enquanto o app está rodando em segundo plano
    _intentDataStreamSubscription = ReceiveSharingIntent.instance.getMediaStream().listen((List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        _importarViaIntent(value.first.path);
      }
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // Para compartilhamento quando o app é aberto do zero
    ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        _importarViaIntent(value.first.path);
      }
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  Future<void> _importarViaIntent(String path) async {
    setState(() {
      _estaCarregando = true;
    });

    Conversa? novaConversa = await ImportadorServico.processarArquivoCompartilhado(path);

    setState(() {
      _estaCarregando = false;
      if (novaConversa != null) {
        conversas.add(novaConversa);
        // Opcional: Navegar direto para a análise
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TelaAnalise(conversa: novaConversa)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Arquivo inválido ou erro na importação')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'LoveStats',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          _estaCarregando 
            ? _buildOverlayLoading()
            : (conversas.isEmpty ? _buildEstadoVazio() : _buildListaConversas()),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildOverlayLoading() {
    return Container(
      color: Colors.white.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFFFF6B6B)),
            const SizedBox(height: 20),
            Text(
              'Importando conversa...',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFA29BFE)],
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: FloatingActionButton(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add_rounded, size: 30, color: Colors.white),
        onPressed: () => _selecionarArquivoManual(),
      ),
    );
  }

  Widget _buildEstadoVazio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_rounded, size: 100, color: const Color(0xFFFF6B6B).withOpacity(0.3)),
            const SizedBox(height: 24),
            Text(
              'Pronto para começar?',
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey[800]),
            ),
            const SizedBox(height: 8),
            Text(
              'Exporte uma conversa do WhatsApp e compartilhe com o LoveStats para ver a mágica!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaConversas() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: conversas.length,
      itemBuilder: (context, index) {
        final conversa = conversas[index];
        return _buildCardConversa(conversa);
      },
    );
  }

  Widget _buildCardConversa(Conversa conversa) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TelaAnalise(conversa: conversa)),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFFFF0F0)],
            ),
          ),
          child: Row(
            children: [
              _buildIconeCard(),
              const SizedBox(width: 16),
              Expanded(child: _buildInfoCard(conversa)),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconeCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6B6B).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.chat_bubble_rounded, color: Color(0xFFFF6B6B)),
    );
  }

  Widget _buildInfoCard(Conversa conversa) {
    String nomeLimpo = conversa.nome
        .replaceAll('Chat do WhatsApp com ', '')
        .replaceAll('WhatsApp Chat - ', '')
        .replaceAll('.txt', '');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          nomeLimpo,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          'Importado em ${conversa.dataDeImportacao.day}/${conversa.dataDeImportacao.month}',
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Future<void> _selecionarArquivoManual() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'zip'],
    );
    if (result != null) {
      _importarViaIntent(result.files.single.path!);
    }
  }
}
