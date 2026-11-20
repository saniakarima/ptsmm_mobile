import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/vacancy.dart';
import '../../services/admin_service.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class AdminVacanciesScreen extends StatefulWidget {
  const AdminVacanciesScreen({super.key});

  @override
  State<AdminVacanciesScreen> createState() => _AdminVacanciesScreenState();
}

class _AdminVacanciesScreenState extends State<AdminVacanciesScreen> {
  List<Vacancy> _vacancies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVacancies();
  }

  Future<void> _loadVacancies() async {
    setState(() => _isLoading = true);
    final list = await AdminService.getVacancies();
    if (mounted) {
      setState(() {
        _vacancies = list;
        _isLoading = false;
      });
    }
  }

  void _showFormDialog({Vacancy? vacancy}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleCtrl = TextEditingController(text: vacancy?.title ?? '');
    final posCtrl = TextEditingController(text: vacancy?.position ?? '');
    final descCtrl = TextEditingController(text: vacancy?.description ?? '');
    final qualCtrl = TextEditingController(text: vacancy?.qualifications ?? '');
    final locCtrl = TextEditingController(text: vacancy?.location ?? 'Bandar Lampung');
    String status = vacancy?.status ?? 'Dibuka';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(vacancy == null ? 'Tambah Lowongan Baru' : 'Edit Lowongan Karir'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Judul Lowongan')),
                const SizedBox(height: 10),
                TextField(controller: posCtrl, decoration: const InputDecoration(labelText: 'Posisi')),
                const SizedBox(height: 10),
                TextField(controller: locCtrl, decoration: const InputDecoration(labelText: 'Lokasi')),
                const SizedBox(height: 10),
                TextField(controller: descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Deskripsi Pekerjaan')),
                const SizedBox(height: 10),
                TextField(controller: qualCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Kualifikasi Pelamar')),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  dropdownColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  decoration: const InputDecoration(labelText: 'Status Lowongan'),
                  items: const [
                    DropdownMenuItem(value: 'Dibuka', child: Text('Dibuka (Aktif)')),
                    DropdownMenuItem(value: 'Ditutup', child: Text('Ditutup')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDlgState(() => status = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                final title = titleCtrl.text.trim();
                final pos = posCtrl.text.trim();
                if (title.isEmpty || pos.isEmpty) return;

                final token = context.read<AuthProvider>().user?.token ?? 'token';
                Navigator.pop(ctx);

                final data = {
                  'judul_lowongan': title,
                  'posisi': pos,
                  'deskripsi': descCtrl.text.trim(),
                  'kualifikasi': qualCtrl.text.trim(),
                  'lokasi': locCtrl.text.trim(),
                  'status_lowongan': status,
                };

                if (vacancy == null) {
                  await AdminService.addVacancy(token, data);
                } else {
                  await AdminService.updateVacancy(token, vacancy.id, data);
                }
                _loadVacancies();
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteVacancy(Vacancy vac) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Lowongan?'),
        content: Text('Yakin ingin menghapus lowongan "${vac.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final token = context.read<AuthProvider>().user?.token ?? 'token';
              await AdminService.deleteVacancy(token, vac.id);
              _loadVacancies();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Karir & Lowongan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(),
        backgroundColor: isDark ? AppColors.secondary : AppColors.primary,
        icon: Icon(Icons.add_rounded, color: isDark ? AppColors.darkBg : Colors.white),
        label: Text(
          'Tambah Lowongan',
          style: TextStyle(color: isDark ? AppColors.darkBg : Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: isDark ? AppColors.secondary : AppColors.primary))
          : _vacancies.isEmpty
              ? const Center(child: Text('Belum ada lowongan pekerjaan'))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _vacancies.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final vac = _vacancies[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: vac.isOpen
                                      ? AppColors.success.withValues(alpha: 0.15)
                                      : AppColors.error.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  vac.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: vac.isOpen ? AppColors.success : AppColors.error,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 20),
                                    color: isDark ? AppColors.secondary : AppColors.primary,
                                    onPressed: () => _showFormDialog(vacancy: vac),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
                                    onPressed: () => _deleteVacancy(vac),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            vac.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Posisi: ${vac.position} • Lokasi: ${vac.location}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.secondary : AppColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            vac.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

