import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_stats_app/conversa.dart';
import 'package:love_stats_app/parser.dart';
import 'package:love_stats_app/telas/tela_analise.dart';

class PaginaInicial extends StatefulWidget {
  @override
  State<PaginaInicial> createState() => _PaginaInicialState();
}

class _PaginaInicialState extends State<PaginaInicial> {
  List<Conversa> conversas = [];
  bool _estaCarregando = false;

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
      body: _estaCarregando 
        ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor))
        : Stack(
            children: [
              conversas.isEmpty ? _buildEstadoVazio() : _buildListaConversas(),
            ],
          ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFFFF6B6B), const Color(0xFFA29BFE)],
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add_rounded, size: 30),
          onPressed: () async {
            _importarConversa();
          },
        ),
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
              'Nenhuma conversa ainda!',
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey[800]),
            ),
            const SizedBox(height: 8),
            Text(
              'Importe um arquivo .txt do WhatsApp para ver as estatísticas do seu amor.',
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
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, const Color(0xFFFFF0F0)],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B6B).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chat_bubble_rounded, color: Color(0xFFFF6B6B)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          conversa.nome.replaceAll('Chat do WhatsApp com ', '').replaceAll('.txt', ''),
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Importado em ${conversa.dataDeImportacao.day}/${conversa.dataDeImportacao.month}/${conversa.dataDeImportacao.year}',
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _importarConversa() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );
    if (result != null) {
      setState(() {
        _estaCarregando = true;
      });
      try {
        var resultado = await receberTxt(result.files.single.path!);
        setState(() {
          conversas.add(Conversa(
            id: DateTime.now().toString(),
            nome: result.files.single.name,
            dataDeImportacao: DateTime.now(),
            tipoDeConversa: TipoConversa.privado,
            participantes: [],
            caminhoArquivo: result.files.single.path!,
            mensagens: resultado,
          ));
          _estaCarregando = false;
        });
      } catch (e) {
        setState(() {
          _estaCarregando = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao processar arquivo')),
        );
      }
    }
  }
}
