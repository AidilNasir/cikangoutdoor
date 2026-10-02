import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/gear_item.dart';
import '../services/gear_service.dart';
import '../widgets/product_image.dart';

class _SpecField {
  final TextEditingController keyController;
  final TextEditingController valueController;

  _SpecField({String key = '', String value = ''})
      : keyController = TextEditingController(text: key),
        valueController = TextEditingController(text: value);

  void dispose() {
    keyController.dispose();
    valueController.dispose();
  }
}

class GearFormScreen extends StatefulWidget {
  final GearItem? gear;

  const GearFormScreen({super.key, this.gear});

  @override
  State<GearFormScreen> createState() => _GearFormScreenState();
}

class _GearFormScreenState extends State<GearFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _gearService = GearService();
  final _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _imageUrlController;
  late TextEditingController _descController;
  String _category = 'Tenda';
  bool _isLoading = false;
  String? _selectedImagePreview; // Bisa URL http, data:image base64, atau file path
  final List<_SpecField> _specFields = [];

  final List<String> _categories = [
    'Tenda',
    'Tas Carrier',
    'Perlengkapan Tidur',
    'Peralatan Masak',
    'Penerangan',
    'Aksesoris Gunung',
  ];

  // Preset foto berkualitas tinggi untuk memudahkan pengisian cepat
  final Map<String, String> _samplePhotos = {
    'Tenda Dome 4P':
        'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=600',
    'Tas Carrier 60L':
        'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=600',
    'Sleeping Bag':
        'https://images.unsplash.com/photo-1510312305653-8ed496efae75?w=600',
    'Kompor Camping':
        'https://images.unsplash.com/photo-1525811902-f2342640856e?w=600',
    'Lampu Tenda':
        'https://images.unsplash.com/photo-1508873696983-2df5293cb395?w=600',
    'Matras Outdoor':
        'https://images.unsplash.com/photo-1478131143081-80f7f84ca84d?w=600',
  };

  @override
  void initState() {
    super.initState();
    final g = widget.gear;
    _nameController = TextEditingController(text: g?.name ?? '');
    _priceController =
        TextEditingController(text: g != null ? g.pricePerDay.toString() : '');
    _stockController =
        TextEditingController(text: g != null ? g.stock.toString() : '5');
    _imageUrlController = TextEditingController(text: g?.imageUrl ?? '');
    _descController = TextEditingController(text: g?.description ?? '');
    _selectedImagePreview = g?.imageUrl;

    if (g != null && g.category.trim().isNotEmpty) {
      final cat = g.category.trim();
      if (_categories.contains(cat)) {
        _category = cat;
      } else if (cat == 'Aksesoris') {
        _category = 'Aksesoris Gunung';
      } else {
        _categories.add(cat);
        _category = cat;
      }
    }

    // Inisialisasi daftar spesifikasi alat
    if (g != null && g.specifications.isNotEmpty) {
      g.specifications.forEach((key, value) {
        _specFields.add(_SpecField(key: key, value: value));
      });
    } else if (g == null) {
      // Rekomendasi field awal untuk alat baru agar admin mudah mengisi
      _specFields.addAll([
        _SpecField(key: 'Bahan', value: ''),
        _SpecField(key: 'Kapasitas', value: ''),
        _SpecField(key: 'Berat', value: ''),
        _SpecField(key: 'Kondisi', value: 'Bersih & Siap Pakai'),
      ]);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    _descController.dispose();
    for (final sf in _specFields) {
      sf.dispose();
    }
    super.dispose();
  }

  void _addQuickSpec(String keyName) {
    final existing = _specFields.any(
      (f) => f.keyController.text.trim().toLowerCase() == keyName.toLowerCase(),
    );
    if (existing) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Spesifikasi "$keyName" sudah ada di daftar.'),
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }
    setState(() {
      _specFields.add(_SpecField(key: keyName, value: ''));
    });
  }

  /// Opsi 1: Mengambil foto dari Galeri / Berkas HP pengguna
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 480,
        maxHeight: 480,
        imageQuality: 60,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final base64String = base64Encode(bytes);
        final dataUri = 'data:image/jpeg;base64,$base64String';

        setState(() {
          _selectedImagePreview = dataUri;
          _imageUrlController.text = dataUri;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto dari berkas HP berhasil dipilih!'),
              backgroundColor: Color(0xFF2D5A27),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Opsi 1b: Mengambil foto langsung dari Kamera HP
  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 480,
        maxHeight: 480,
        imageQuality: 60,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final base64String = base64Encode(bytes);
        final dataUri = 'data:image/jpeg;base64,$base64String';

        setState(() {
          _selectedImagePreview = dataUri;
          _imageUrlController.text = dataUri;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil foto kamera: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Opsi 2: Dialog memasukkan link URL dari Google / Web
  void _showGoogleUrlDialog() {
    final urlController = TextEditingController(
      text: _imageUrlController.text.startsWith('http')
          ? _imageUrlController.text
          : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.link, color: Color(0xFF2D5A27)),
              SizedBox(width: 8),
              Text('Link Foto Google / Web'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tempel URL link gambar dari Google Gambar, Unsplash, atau internet:',
                  style: TextStyle(fontSize: 12.5, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlController,
                  decoration: InputDecoration(
                    hintText: 'https://...',
                    labelText: 'URL Gambar',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.public),
                    suffixIcon: urlController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              urlController.clear();
                              setDialogState(() {});
                            },
                          )
                        : null,
                  ),
                  onChanged: (_) => setDialogState(() {}),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Atau pilih contoh foto outdoor:',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: _samplePhotos.entries.map((entry) {
                    return ActionChip(
                      label: Text(
                        entry.key,
                        style: const TextStyle(fontSize: 11),
                      ),
                      avatar: const Icon(Icons.image, size: 14),
                      onPressed: () {
                        urlController.text = entry.value;
                        setDialogState(() {});
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D5A27),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final url = urlController.text.trim();
                if (url.isNotEmpty) {
                  setState(() {
                    _imageUrlController.text = url;
                    _selectedImagePreview = url;
                  });
                }
                Navigator.pop(ctx);
              },
              child: const Text('Gunakan Foto'),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom sheet pilihan sumber gambar (Google / Berkas HP / Kamera)
  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Text(
                  'Pilih Sumber Foto Produk',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(Icons.photo_library_rounded, color: Color(0xFF2D5A27)),
                ),
                title: const Text('Upload dari Berkas / Galeri HP'),
                subtitle: const Text('Pilih foto alat dari penyimpanan HP'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE3F2FD),
                  child: Icon(Icons.language_rounded, color: Colors.blue),
                ),
                title: const Text('Link dari Google / Internet'),
                subtitle: const Text('Tempel link URL foto dari browser atau web'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showGoogleUrlDialog();
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFFF3CD),
                  child: Icon(Icons.camera_alt_rounded, color: Color(0xFF856404)),
                ),
                title: const Text('Ambil Foto dari Kamera'),
                subtitle: const Text('Buka kamera HP dan foto alat secara langsung'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImageFromCamera();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveGear() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final cleanPrice = _priceController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final price = int.tryParse(cleanPrice) ?? 0;
      final cleanStock = _stockController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final stock = int.tryParse(cleanStock) ?? 1;
      final imageUrl = _imageUrlController.text.trim().isNotEmpty
          ? _imageUrlController.text.trim()
          : 'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=600';
      final desc = _descController.text.trim();

      // Kumpulkan data spesifikasi dinamis
      final Map<String, String> specs = {};
      for (final sf in _specFields) {
        final k = sf.keyController.text.trim();
        final v = sf.valueController.text.trim();
        if (k.isNotEmpty && v.isNotEmpty) {
          specs[k] = v;
        }
      }

      GearItem savedResult;
      if (widget.gear == null) {
        // Tambah baru ke Firestore
        final newGear = GearItem(
          id: '',
          name: name,
          category: _category,
          pricePerDay: price,
          imageUrl: imageUrl,
          description: desc,
          specifications: specs.isNotEmpty
              ? specs
              : {
                  'Kategori': _category,
                  'Stok Tersedia': '$stock Unit',
                  'Kondisi': 'Bersih & Siap Pakai',
                },
          stock: stock,
          isAvailable: stock > 0,
        );

        final newId = await _gearService.addGear(newGear);
        savedResult = newGear.copyWith(id: newId);
      } else {
        // Update alat yang ada
        final updatedGear = widget.gear!.copyWith(
          name: name,
          category: _category,
          pricePerDay: price,
          imageUrl: imageUrl,
          description: desc,
          specifications: specs,
          stock: stock,
          isAvailable: stock > 0,
        );

        await _gearService.updateGear(updatedGear);
        savedResult = updatedGear;
      }

      if (mounted) {
        Navigator.pop(context, savedResult);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  widget.gear == null
                      ? 'Alat baru berhasil ditambahkan!'
                      : 'Data alat berhasil diperbarui!',
                ),
              ],
            ),
            backgroundColor: const Color(0xFF2D5A27),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.gear != null;
    final hasImage = _selectedImagePreview != null &&
        _selectedImagePreview!.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F5),
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Alat Camping' : 'Tambah Alat Camping',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2D5A27),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Foto Produk & Dua Opsi Pilihan
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.photo_camera_back, color: Color(0xFF2D5A27), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Foto Produk',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B2E18),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Preview Foto
                    if (hasImage)
                      Stack(
                        children: [
                          Container(
                            height: 180,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: ProductImage(
                              imageUrl: _selectedImagePreview!,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: CircleAvatar(
                              backgroundColor: Colors.black.withValues(alpha: 0.6),
                              radius: 16,
                              child: IconButton(
                                icon: const Icon(Icons.close, size: 16, color: Colors.white),
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  setState(() {
                                    _selectedImagePreview = null;
                                    _imageUrlController.clear();
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      InkWell(
                        onTap: _showImageSourcePicker,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 130,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F4EF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF2D5A27).withValues(alpha: 0.25),
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 44,
                                color: const Color(0xFF2D5A27).withValues(alpha: 0.7),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Ketuk untuk pilih foto produk',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF2D5A27),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Bisa dari berkas HP atau link Google',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 14),

                    // Dua Tombol Pilihan: Dari Galeri HP & Dari Google
                    Row(
                      children: [
                        // Tombol 1: Dari Galeri / Berkas HP
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2D5A27),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.file_upload_outlined, size: 18),
                            label: const Text(
                              'Berkas HP',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                            ),
                            onPressed: _pickImageFromGallery,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Tombol 2: Dari Google / Web
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF2D5A27),
                              side: const BorderSide(color: Color(0xFF2D5A27)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.language_rounded, size: 18),
                            label: const Text(
                              'Dari Google',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                            ),
                            onPressed: _showGoogleUrlDialog,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Card Informasi Produk
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama Alat
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Alat Camping *',
                        hintText: 'Contoh: Tenda Dome Arpenaz 4.1',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.label_outline),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Nama alat wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 14),

                    // Kategori
                    DropdownButtonFormField<String>(
                      initialValue: _categories.contains(_category) ? _category : _categories.first,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Kategori Alat *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.category_outlined),
                      ),
                      items: _categories.toSet().map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _category = val);
                      },
                    ),
                    const SizedBox(height: 14),

                    // Tarif Sewa & Stok
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Tarif / Hari *',
                              hintText: '50000',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.payments_outlined),
                              prefixText: 'Rp ',
                            ),
                            validator: (val) => val == null || val.trim().isEmpty
                                ? 'Wajib diisi'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _stockController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Stok *',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.inventory_2_outlined),
                            ),
                            validator: (val) => val == null || val.trim().isEmpty
                                ? 'Wajib diisi'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Deskripsi
                    TextFormField(
                      controller: _descController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Deskripsi Alat *',
                        hintText: 'Jelaskan kondisi, kapasitas, kelengkapan alat...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignLabelWithHint: true,
                      ),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Deskripsi wajib diisi'
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Card Spesifikasi Alat
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Spesifikasi
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D5A27).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.tune_rounded,
                            size: 20,
                            color: Color(0xFF2D5A27),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Spesifikasi Alat',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2D5A27),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2D5A27).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${_specFields.length} Butir',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2D5A27),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Contoh: Grip, Panjang, Bahan, Kapasitas, Berat, dll.',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Preset Chips Pintar
                    Text(
                      'Pilih Template Cepat:',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        'Grip',
                        'Panjang',
                        'Bahan',
                        'Kapasitas',
                        'Berat',
                        'Dimensi',
                        'Warna',
                        'Daya Tahan',
                        'Kondisi',
                      ].map((preset) {
                        return InkWell(
                          onTap: () => _addQuickSpec(preset),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5EF),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF2D5A27).withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.add_rounded,
                                  size: 14,
                                  color: Color(0xFF2D5A27),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  preset,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2D5A27),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Daftar Baris Spesifikasi
                    if (_specFields.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAF8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.format_list_bulleted_add, size: 36, color: Colors.grey.shade400),
                            const SizedBox(height: 6),
                            const Text(
                              'Belum ada spesifikasi khusus',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tekan template di atas atau tombol tambah di bawah untuk memasukkan spesifikasi.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _specFields.length,
                        separatorBuilder: (_, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = _specFields[index];
                          return Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAF7),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Nama Spesifikasi
                                Expanded(
                                  flex: 4,
                                  child: TextFormField(
                                    controller: item.keyController,
                                    style: const TextStyle(fontSize: 12.5),
                                    decoration: InputDecoration(
                                      labelText: 'Nama Spesifikasi',
                                      labelStyle: const TextStyle(fontSize: 11.5),
                                      hintText: 'Misal: Grip',
                                      hintStyle: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Nilai / Keterangan
                                Expanded(
                                  flex: 5,
                                  child: TextFormField(
                                    controller: item.valueController,
                                    style: const TextStyle(fontSize: 12.5),
                                    decoration: InputDecoration(
                                      labelText: 'Keterangan / Nilai',
                                      labelStyle: const TextStyle(fontSize: 11.5),
                                      hintText: 'Misal: Busa EVA Lembut',
                                      hintStyle: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                // Tombol Hapus Baris
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle_outline_rounded,
                                    color: Colors.redAccent,
                                    size: 22,
                                  ),
                                  tooltip: 'Hapus baris ini',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    setState(() {
                                      item.dispose();
                                      _specFields.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 12),

                    // Tombol Tambah Baris Manual
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2D5A27),
                          side: const BorderSide(color: Color(0xFF2D5A27)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text(
                          'Tambah Baris Spesifikasi',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _specFields.add(_SpecField());
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveGear,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D5A27),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 1,
                  ),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(
                    _isLoading
                        ? 'Menyimpan ke Firestore...'
                        : (isEdit ? 'Simpan Perubahan' : 'Tambahkan Alat ke Katalog'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
