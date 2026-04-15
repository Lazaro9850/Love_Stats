import 'dart:io';
import 'package:archive/archive.dart';
import 'package:love_stats_app/conversa.dart';
import 'package:love_stats_app/parser.dart';
import 'package:path_provider/path_provider.dart';

class ImportadorServico {
  /// Processa um arquivo recebido (seja .txt ou .zip) e retorna uma Conversa
  static Future<Conversa?> processarArquivoCompartilhado(String path) async {
    File arquivoOriginal = File(path);
    String extensao = path.split('.').last.toLowerCase();

    if (extensao == 'zip') {
      return await _processarZip(arquivoOriginal);
    } else if (extensao == 'txt') {
      return await _processarTxt(arquivoOriginal);
    }
    
    return null;
  }

  static Future<Conversa?> _processarZip(File zipFile) async {
    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final file in archive) {
      if (file.isFile && file.name.endsWith('.txt')) {
        final content = file.content as List<int>;
        
        // Salvar o TXT extraído em um local temporário/permanente do app
        final directory = await getApplicationDocumentsDirectory();
        final tempFile = File('${directory.path}/${file.name}');
        await tempFile.writeAsBytes(content);

        return await _processarTxt(tempFile);
      }
    }
    return null;
  }

  static Future<Conversa?> _processarTxt(File txtFile) async {
    try {
      final mensagens = await receberTxt(txtFile.path);
      
      return Conversa(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nome: txtFile.path.split('/').last.split('\\').last,
        dataDeImportacao: DateTime.now(),
        tipoDeConversa: TipoConversa.privado,
        participantes: [],
        caminhoArquivo: txtFile.path,
        mensagens: mensagens,
      );
    } catch (e) {
      print('Erro ao processar TXT: $e');
      return null;
    }
  }
}
