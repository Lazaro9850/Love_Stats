import "dart:io";
import "package:love_stats_app/conversa.dart";

Future<List<Mensagem>> receberTxt(String caminho) async {
  File arquivo = File(caminho);
  List<String> linhas = await arquivo.readAsLines();

  List<Mensagem> mensagem = [];
  for (var i = 0; i < linhas.length; i++) {
    // Se usa i como contador para a lista que no futuro sera o DF
    var linha = linhas[i];
    RegExp padrao = RegExp(r"(\d{2}/\d{2}/\d{4} \d{2}:\d{2}) - (.*?): (.*)");
    var buscaDePadrao = padrao.firstMatch(linha);

    if (buscaDePadrao != null) {

      // Data vem no formato BR
      // DD/MM/YYYY HH:MM mas quero YYYY/MM/DD HH:MM
      // SOLUÇÃO: separar hora e minuto, apops isso separar por barras e deixar na ordem desejada
      String dataStr = buscaDePadrao.group(1)!;

      // Separando data
      List<String> partes = dataStr.split(' '); // horas esta em partes[1]

      // STR dia para pegar apenas data
      List<String> dia = partes[0].split('/');
      DateTime data = DateTime(
        int.parse(dia[2]),
        int.parse(dia[1]),
        int.parse(dia[0]),
        int.parse(partes[1].split(':')[0]),
        int.parse(partes[1].split(':')[1]),
      );
      mensagem.add(
        Mensagem(
          id: i.toString(),
          data: data,
          usuario: buscaDePadrao.group(2)!,
          texto: buscaDePadrao.group(3)!,
        ),
      );
    }
  }
  return mensagem;
}
