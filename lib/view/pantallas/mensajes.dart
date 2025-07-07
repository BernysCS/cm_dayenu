import 'package:cm_dayenu/controller/controller_colors.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class PantallaMensajes extends StatefulWidget {
  const PantallaMensajes({super.key});

  @override
  State<PantallaMensajes> createState() => _PantallaMensajesState();
}

class _PantallaMensajesState extends State<PantallaMensajes> {
  final TextEditingController _mensajeController = TextEditingController();
  String? _mensajeSeleccionado;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();

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

  void _mostrarInfoDialog() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Información"),
            content: const Text(
              "Aquí puedes seleccionar un mensaje rápido, escribir uno personalizado o escanear texto desde una imagen para enviarlo por WhatsApp.",
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF009688),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Cerrar"),
              ),
            ],
          ),
    );
  }

  Future<void> _escanearTexto({required ImageSource source}) async {
    final XFile? imagen = await picker.pickImage(source: source);
    if (imagen == null) return;

    final inputImage = InputImage.fromFilePath(imagen.path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final recognizedText = await textRecognizer.processImage(inputImage);

    final buffer = StringBuffer();
    for (final block in recognizedText.blocks) {
      buffer.writeln(block.text);
    }

    await textRecognizer.close();

    setState(() {
      _mensajeController.text = buffer.toString();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Texto escaneado insertado.")));
  }

  void _mostrarOpcionesEscaneo() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (_) => Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              runSpacing: 12,
              children: [
                const Center(
                  child: Text(
                    "Selecciona la fuente del documento",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: Color(0xFF009688),
                  ),
                  title: const Text("Escanear con cámara"),
                  onTap: () {
                    Navigator.pop(context);
                    _escanearTexto(source: ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    size: 16,
                    color: Color(0xFF009688),
                  ),
                  title: const Text("Seleccionar desde galería"),
                  onTap: () {
                    Navigator.pop(context);
                    _escanearTexto(source: ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensajes Rápidos'),
        backgroundColor: Color(0xFF009688),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _mostrarInfoDialog,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: const Text(
                        "Seleccione un mensaje predefinido para enviar:",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Lista de mensajes predefinidos como ElevatedButton cards
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _mensajesPreestablecidos.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final mensaje = _mensajesPreestablecidos[index];
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFF599B0),
                            elevation: 6,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.centerLeft,
                          ),
                          onPressed: () {
                            setState(() {
                              _mensajeSeleccionado = mensaje;
                              _mensajeController.text = mensaje;
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  mensaje,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 18,
                                color: Colors.black54,
                              ),
                            ],
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
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _mensajeController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: "Mensaje personalizado",
                        labelStyle: TextStyle(color: Color(0xFF41A2AE)),
                        border:
                            OutlineInputBorder(), // por si quieres dejarlo como fallback
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                          ), // cuando no está enfocado
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF41A2AE),
                            width: 2,
                          ), // al hacer focus
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Escribe o escanea un mensaje para enviarlo';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF009688),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                final mensaje = _mensajeController.text.trim();
                                _abrirWhatsApp(mensaje);
                              }
                            },
                            icon: const Icon(Icons.send, color: Colors.white),
                            label: const Text(
                              "Enviar",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFF599B0),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _mostrarOpcionesEscaneo,
                            icon: const Icon(
                              Icons.document_scanner,
                              color: Colors.white,
                            ),
                            label: const Text(
                              "Escanear",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
