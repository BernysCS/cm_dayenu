import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PantallaMensajes extends StatefulWidget {
  const PantallaMensajes({super.key});

  @override
  State<PantallaMensajes> createState() => _PantallaMensajesState();
}

class _PantallaMensajesState extends State<PantallaMensajes> {
  final TextEditingController _mensajeController = TextEditingController();
  String? _mensajeSeleccionado;

  final List<String> _mensajesPreestablecidos = [
    "Te saludamos desde centro médico Dayenú.",
    "Buen día, no olvide asistir a su control médico esta semana.",
    "¿Sabía que dormir 8 horas mejora su sistema inmunológico?",
  ];

  Future<void> _abrirWhatsApp(String mensaje) async {
    final url = Uri.parse(
      "https://wa.me/?text=${Uri.encodeComponent(mensaje)}",
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error al abrir WhatsApp")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Mensajes rápidos",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Seleccione un mensaje predefinido para enviar:",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _mensajesPreestablecidos.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final mensaje = _mensajesPreestablecidos[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.pink[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              mensaje,
                              style: const TextStyle(fontSize: 16),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 18,
                            ),
                            onTap: () {
                              setState(() {
                                _mensajeSeleccionado = mensaje;
                                _mensajeController.text = mensaje;
                              });
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _mensajeController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Mensaje personalizado",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        final mensaje = _mensajeController.text.trim();
                        if (mensaje.isNotEmpty) {
                          _abrirWhatsApp(mensaje);
                        }
                      },
                      icon: const Icon(Icons.send, color: Colors.white),
                      label: const Text(
                        "Enviar por WhatsApp",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
