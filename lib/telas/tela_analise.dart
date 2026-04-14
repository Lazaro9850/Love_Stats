import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:love_stats_app/conversa.dart';
import 'package:love_stats_app/analises.dart';

class TelaAnalise extends StatelessWidget {
  final Conversa conversa;
  // 
  const TelaAnalise({required this.conversa});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('LoveStats - Analises '),),
        body: Center(
            child: Column(
                children: [
                    Text(' . . . . . . . .'),
                    Text(' . . . . . . . .'),
                    Text(' . . . . . . . .'),
                    Text('Total de mensagens que cada um mandou ${contarMensagensPorUsuario(conversa.mensagens)}'),
                    Text(' . . . . . . . .'),
                    Text(' . . . . . . . .'),
                    Text(' . . . . . . . .'),
                    Text('Total de eu te amo que cada um disse: ${euTeAmoPorUsuario(conversa.mensagens)}'),
                    Text(' . . . . . . . .'),
                    Text(' . . . . . . . .'),
                    Text(' . . . . . . . .'),
                    Text('Total de midia que cada um mandou (audio, videos e fotos): ${contarMidia(conversa.mensagens)}'),
                    Text(' . . . . . . . .'),
                    Text(' . . . . . . . .'),
                    Text(' . . . . . . . .'),
                    Text('Total de "Bom dia" que cada um mandou: ${contarBomDia(conversa.mensagens)}'),
                    Text(' . . . . . . . .'),
                    Text(' . . . . . . . .'),
                    Text(' . . . . . . . .'),
                    Text('Quem pediu mais desculpas: ${contarDesculpas(conversa.mensagens)}'),

                ],
            ),
        ),
    );
  }
}