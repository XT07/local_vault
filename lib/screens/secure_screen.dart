import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SecureScreen extends StatefulWidget {
  const SecureScreen({super.key});

  @override
  State<SecureScreen> createState() => _SecureScreenState();
}

class _SecureScreenState extends State<SecureScreen> {
  final _storageService = StorageService();
  final _tokenController = TextEditingController();

  String? _tokenExibido;
  bool _obscureToken = true;

  Future<void> _salvarToken() async {
    if (_tokenController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um token antes de salvar!')),
      );
      return;
    }
    await _storageService.saveToken(_tokenController.text.trim());
    setState(() => _tokenExibido = null);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🔒 Token salvo com segurança!')),
      );
    }
  }

  Future<void> _recuperarToken() async {
    final token = await _storageService.getToken();
    setState(() => _tokenExibido = token ?? '(nenhum token salvo)');
  }

  Future<void> _deletarToken() async {
    await _storageService.deleteToken();
    _tokenController.clear();
    setState(() => _tokenExibido = null);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🗑️ Token deletado com sucesso!')),
      );
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Armazenamento Seguro'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.security, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text('flutter_secure_storage',
                            style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tokens são armazenados de forma criptografada usando Keystore (Android) ou Keychain (iOS).',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _tokenController,
              obscureText: _obscureToken,
              decoration: InputDecoration(
                labelText: 'Token de Autenticação',
                hintText: 'Ex: eyJhbGciOiJIUzI1NiIsInR5cCI6...',
                prefixIcon: const Icon(Icons.vpn_key),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscureToken ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscureToken = !_obscureToken),
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _salvarToken,
              icon: const Icon(Icons.save),
              label: const Text('Salvar Token'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _recuperarToken,
              icon: const Icon(Icons.download),
              label: const Text('Recuperar Token'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _deletarToken,
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text('Deletar Token', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
            ),
            if (_tokenExibido != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).colorScheme.secondary),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Token Recuperado:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    SelectableText(
                      _tokenExibido!,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
