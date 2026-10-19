import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum ResultadoStatus { nenhum, sucesso, jaPresente, invalido }

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _qrPayload;
  String? _nomeIngresso;
  String? _emailIngresso;

  bool _lendo = false;
  ResultadoStatus _statusLeitura = ResultadoStatus.nenhum;
  String _nomeLido = '';

  final List<String> _presentes = [];

  @override
  void initState() {
    super.initState();
    _nomeController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _gerarIngresso() {
    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();

    if (nome.isNotEmpty) {
      setState(() {
        _nomeIngresso = nome;
        _emailIngresso = email;
        _qrPayload = 'CHECKIN|$nome|$email';
      });
    }
  }

  void _processarCodigo(String codigo) {
    final partes = codigo.split('|');
    final bool ingressoValido =
        partes.length == 3 && partes[0] == 'CHECKIN';

    setState(() {
      _lendo = false;
      if (ingressoValido) {
        final nome = partes[1];
        if (_presentes.contains(nome)) {
          _statusLeitura = ResultadoStatus.jaPresente;
          _nomeLido = nome;
        } else {
          _presentes.add(nome);
          _statusLeitura = ResultadoStatus.sucesso;
          _nomeLido = nome;
        }
      } else {
        _statusLeitura = ResultadoStatus.invalido;
        _nomeLido = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_lendo) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Semana da Computação 2026'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: Stack(
          children: [
            MobileScanner(
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    _processarCodigo(barcode.rawValue!);
                    break;
                  }
                }
              },
            ),
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: const Center(
                child: Text(
                  'Aponte para o QR do ingresso',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    backgroundColor: Colors.black54,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  setState(() {
                    _lendo = false;
                  });
                },
                child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Semana da Computação 2026'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do participante',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _nomeController.text.trim().isEmpty
                  ? null
                  : _gerarIngresso,
              child: const Text('Gerar ingresso'),
            ),
            const SizedBox(height: 16),

            if (_qrPayload != null)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        color: Theme.of(context).colorScheme.primary,
                        child: const Text(
                          'imagem do evento',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _nomeIngresso!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(_emailIngresso!),
                      const SizedBox(height: 12),
                      QrImageView(
                        data: _qrPayload!,
                        version: QrVersions.auto,
                        size: 200.0,
                      ),
                    ],
                  ),
                ),
              ),

            const Divider(height: 32),

            const Text(
              'Check-in',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Ler ingresso'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                setState(() {
                  _lendo = true;
                });
              },
            ),
            const SizedBox(height: 12),

            _buildResultadoCard(),

            const SizedBox(height: 16),

            Text(
              'Presentes (${_presentes.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _presentes
                  .map(
                    (nome) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.check, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(nome, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultadoCard() {
    if (_statusLeitura == ResultadoStatus.nenhum) {
      return const SizedBox.shrink();
    }

    Color bgColor;
    Color textColor;
    IconData icon;
    String titulo;
    String subtitulo;

    switch (_statusLeitura) {
      case ResultadoStatus.sucesso:
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade900;
        icon = Icons.check;
        titulo = 'Check-in confirmado';
        subtitulo = _nomeLido;
        break;
      case ResultadoStatus.jaPresente:
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade900;
        icon = Icons.warning_amber_rounded;
        titulo = 'Já fez check-in';
        subtitulo = 'nome já está na lista';
        break;
      case ResultadoStatus.invalido:
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade900;
        icon = Icons.close;
        titulo = 'QR inválido';
        subtitulo = 'não começa com CHECKIN|';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontSize: 16,
                ),
              ),
              if (subtitulo.isNotEmpty)
                Text(
                  subtitulo,
                  style: TextStyle(color: textColor),
                ),
            ],
          ),
        ],
      ),
    );
  }
}