import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileService = ProfileService();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _pontuacaoController = TextEditingController();

  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final profile = _profileService.getProfile();
    setState(() => _profile = profile);
    if (profile != null) {
      _nomeController.text = profile.nome;
      _emailController.text = profile.email;
      _pontuacaoController.text = profile.pontuacao.toString();
    }
  }

  Future<void> _saveProfile() async {
    if (_nomeController.text.isEmpty || _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha nome e e-mail!')),
      );
      return;
    }

    final now = DateTime.now();
    final dataCadastro = _profile?.dataCadastro ??
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    final profile = UserProfile(
      nome: _nomeController.text.trim(),
      email: _emailController.text.trim(),
      dataCadastro: dataCadastro,
      pontuacao: int.tryParse(_pontuacaoController.text) ?? 0,
    );

    await _profileService.saveProfile(profile);
    _loadProfile();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Perfil salvo com sucesso!')),
      );
    }
  }

  Future<void> _clearProfile() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Perfil'),
        content: const Text(
          'Todos os seus dados serão apagados permanentemente (LGPD — Direito ao Esquecimento). Confirmar?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _profileService.clearProfile();
      _nomeController.clear();
      _emailController.clear();
      _pontuacaoController.clear();
      _loadProfile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🗑️ Perfil excluído. Direito ao esquecimento exercido.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _pontuacaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil do Usuário'),
        actions: [
          if (_profile != null)
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              tooltip: 'Excluir perfil (LGPD)',
              onPressed: _clearProfile,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_profile != null) ...[
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Perfil Salvo (Hive)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      _InfoRow(label: 'Nome', value: _profile!.nome),
                      _InfoRow(label: 'E-mail', value: _profile!.email),
                      _InfoRow(label: 'Cadastro', value: _profile!.dataCadastro),
                      _InfoRow(label: 'Pontuação', value: '${_profile!.pontuacao} pts'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            Text(
              _profile == null ? 'Criar Perfil' : 'Editar Perfil',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome completo',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pontuacaoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Pontuação',
                prefixIcon: Icon(Icons.star),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _saveProfile,
              icon: const Icon(Icons.save),
              label: const Text('Salvar Perfil'),
            ),
            if (_profile != null) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _clearProfile,
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text('Excluir Dados (LGPD)', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          Text(value, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
