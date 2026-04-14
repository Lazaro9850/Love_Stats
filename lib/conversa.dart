enum TipoConversa { privado, grupo }

class Conversa {
  String id;
  List<String> participantes;
  String nome;
  DateTime dataDeImportacao;
  TipoConversa tipoDeConversa;
  String caminhoArquivo;
  List<Mensagem> mensagens;

  Conversa({
    required this.id,
    required this.nome,
    required this.dataDeImportacao,
    required this.tipoDeConversa,
    required this.participantes,
    required this.caminhoArquivo,
    required this.mensagens,
  });
}

class Mensagem {
  String id;
  DateTime data;
  String usuario;
  String texto;

  Mensagem({
    required this.id,
    required this.data,
    required this.usuario,
    required this.texto,
  });
}