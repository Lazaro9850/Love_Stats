import 'conversa.dart';

Map<String, int> contarMensagensPorUsuario(List<Mensagem> mensagens) {
  Map<String, int> contagem = {};
  //contagem.containsKey(usuario)
  for (var msg in mensagens) {
    if (contagem.containsKey(msg.usuario)) {
      contagem[msg.usuario] = contagem[msg.usuario]! + 1;
    } else {
      contagem[msg.usuario] = 1;
    }
  }
  return contagem;
  }

Map<String, int> euTeAmoPorUsuario(List<Mensagem> mensagens) {
  //  RegExp padrao = RegExp(r"(\d{2}/\d{2}/\d{4} \d{2}:\d{2}) - (.*?): (.*)");
  RegExp padrao = RegExp(r"\be+u+ te+ a+mo+\b|\bte+ a+mo+\b|\ba+mo+ mu+i+to+ vc+\b|\ba+mo+ mu+i+to+ vo+ce+\b|\bte+ a+mo+ mu+i+to+\b|\ba+mo+ mu+i+to+ vc+\b|\be+u+ te+ a+mo+ tmb+\b|\be+u+ tmb te+ a+mo+\b|\be+u+ ta+mbe+m+ te+ a+mo+\b|\be+u+ te+ a+mo+ ta+m+be+m+\b|\btb+m+ te a+mo+\b|\beu te a+mo+ tb+m+\b",
  caseSensitive: false);
  Map<String, int> contagem = {};
  for (var msg in mensagens) {
    if (padrao.hasMatch(msg.texto)) {
      if (contagem.containsKey(msg.usuario)) {
        contagem[msg.usuario] = contagem[msg.usuario]! + 1;
      } else {
        contagem[msg.usuario] = 1;
      }
    }
  }
  return contagem;
}

Map<String, int> contarMidia(List<Mensagem> mensagens) {
  RegExp padrao = RegExp(r"<Mídia oculta>");
  Map<String, int> contagem = {};
  for (var msg in mensagens) {
    if (padrao.hasMatch(msg.texto)) {
      if (contagem.containsKey(msg.usuario)) {
        contagem[msg.usuario] = contagem[msg.usuario]! + 1;
      } else {
        contagem[msg.usuario] = 1;
      }
    }
  }
  return contagem;
}

Map<String, int> contarBomDia(List<Mensagem> mensagens) {
  Map<String, int> contagem = {};
  RegExp padrao = RegExp(r'\bbo+m+ di+a+\b|\bbo+a+ no+i+te+\b|\bbo+a+ ta+r+de+\b|\bbo+m+di+a+\b|\bbo+a+no+i+te+\b', 
  caseSensitive:false);
  for (var msg in mensagens) {
    if (padrao.hasMatch(msg.texto)) {
      if (contagem.containsKey(msg.usuario)) {
        contagem[msg.usuario] = contagem[msg.usuario]! + 1;
      } else {
        contagem[msg.usuario] = 1;
      }      
    }
  }
  return contagem;
}

Map<String, Map<String, int>> contarSaudacoesDetalhado(List<Mensagem> mensagens) {
  Map<String, Map<String, int>> contagem = {};
  RegExp dia = RegExp(r'\bbo+m+ di+a+\b|\bbo+m+di+a+\b', caseSensitive: false);
  RegExp tarde = RegExp(r'\bbo+a+ ta+r+de+\b', caseSensitive: false);
  RegExp noite = RegExp(r'\bbo+a+ no+i+te+\b|\bbo+a+no+i+te+\b', caseSensitive: false);

  for (var msg in mensagens) {
    String? tipo;
    if (dia.hasMatch(msg.texto)) tipo = 'dia';
    else if (tarde.hasMatch(msg.texto)) tipo = 'tarde';
    else if (noite.hasMatch(msg.texto)) tipo = 'noite';

    if (tipo != null) {
      contagem.putIfAbsent(msg.usuario, () => {'dia': 0, 'tarde': 0, 'noite': 0});
      contagem[msg.usuario]![tipo] = contagem[msg.usuario]![tipo]! + 1;
    }
  }
  return contagem;
}

//\bdescu+l+pa+\b|\bme+ de+scu+lpa+\b|\bme+ pe+rdo+a+\b|\bperda+o+\b|\bperdã+o+\b|\bfoi mal\b|\beu erre+i+\b

Map<String, int> contarDesculpas(List<Mensagem> mensagens) {
  Map<String, int> contagem = {};
  RegExp padrao = RegExp(r'\bdescu+l+pa+\b|\bme+ de+scu+lpa+\b|\bme+ pe+rdo+a+\b|\bperda+o+\b|\bperdã+o+\b|\bfoi mal\b|\beu erre+i+\b', 
  caseSensitive:false);
  for (var msg in mensagens) {
    if (padrao.hasMatch(msg.texto)) {
      if (contagem.containsKey(msg.usuario)) {
        contagem[msg.usuario] = contagem[msg.usuario]! + 1;
      } else {
        contagem[msg.usuario] = 1;
      }      
    }
  }
  return contagem;
}