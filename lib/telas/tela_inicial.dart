import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:love_stats_app/conversa.dart';
import 'package:love_stats_app/parser.dart';
import 'package:love_stats_app/telas/tela_analise.dart';

class PaginaInicial extends StatefulWidget {
  @override
  State<PaginaInicial> createState() => _PaginaInicialState();
}

class _PaginaInicialState extends State<PaginaInicial> {
  List<Conversa> conversas = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('LoveStats')),
      body: ListView.builder(
              itemCount: conversas.length,
              itemBuilder: (context, index) {
                final conversa = conversas[index];
                return ListTile(onTap: () {
                  Navigator.push(context,
                  MaterialPageRoute(builder: (context) => TelaAnalise(conversa: conversa)));
                },
                  title: Text(conversa.nome),
                  subtitle: Text(conversa.dataDeImportacao.toString()),
                );
              } ),
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        child: Icon(Icons.add),
        onPressed: () async {
          FilePickerResult? result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['txt'],
          );
          if (result != null) {
            var resultado = await receberTxt(result.files.single.path!);
            setState(() {
              conversas.add(Conversa(
              id: DateTime.now() .toString(),
              nome: result.files.single.name, 
              dataDeImportacao: DateTime.now(), 
              tipoDeConversa: TipoConversa.privado, 
              participantes: [], 
              caminhoArquivo: result.files.single.path!,
              mensagens: resultado));
            });
          }
        },
      ),
    );
  }
}
