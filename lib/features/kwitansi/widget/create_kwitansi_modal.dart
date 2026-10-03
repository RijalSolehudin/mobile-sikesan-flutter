import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../core/network/api_result.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/image_upload_helper.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../data/models/spp_models.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/infaq_repository.dart';
import '../../../data/repositories/kwitansi_repository.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../models/kwitansi_model.dart';

class CreateKwitansiModal extends StatefulWidget {
  final List<String> existingCategories;
  final Function(KwitansiModel newKwitansi, String? newCategory) onCreated;

  const CreateKwitansiModal({
    super.key,
    required this.existingCategories,
    required this.onCreated,
  });

  static Future<void> show(
    BuildContext context, {
    required List<String> existingCategories,
    required Function(KwitansiModel newKwitansi, String? newCategory) onCreated,
  }) {
    return showDialog(
      context: context,
      useRootNavigator: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => CreateKwitansiModal(
        existingCategories: existingCategories,
        onCreated: onCreated,
      ),
    );
  }

  @override
  State<CreateKwitansiModal> createState() => _CreateKwitansiModalState();
}

class _CreateKwitansiItemInput {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController qtyController = TextEditingController(text: '1');
  final TextEditingController priceController = TextEditingController(
    text: '0',
  );

  void dispose() {
    descriptionController.dispose();
    qtyController.dispose();
    priceController.dispose();
  }

  int get qty => int.tryParse(qtyController.text) ?? 1;
  num get price => CurrencyFormatter.parseClean(priceController.text);
  num get total => qty * price;
}

class _CreateKwitansiModalState extends State<CreateKwitansiModal> {
  final _formKey = GlobalKey<FormState>();

  DateTime _selectedDate = DateTime.now();
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  late List<String> _categoryOptions;
  String _selectedCategory = 'Pondok';
  bool _isCreatingNewCategory = false;
  final TextEditingController _newCategoryController = TextEditingController();

  String _selectedPaymentMethod = 'Transfer';
  final List<String> _paymentMethods = ['Transfer', 'Tunai', 'Saldo Santri'];

  final List<_CreateKwitansiItemInput> _items = [];

  final TextEditingController _signerRoleController = TextEditingController(
    text: KwitansiModel.defaultSignerRole,
  );
  final TextEditingController _noteController = TextEditingController();

  XFile? _attachedFile;
  final ImagePicker _picker = ImagePicker();

  /// Data santri dari backend untuk autocomplete "Nama Tujuan".
  List<StudentLookupModel> _students = [];
  int? _selectedStudentId;

  bool _isSubmitting = false;

  /// Dipertahankan antar-percobaan agar retry tidak membuat kwitansi ganda.
  final String _idempotencyKey = const Uuid().v4();

  @override
  void initState() {
    super.initState();
    // Build category list without 'Semua', plus the '+ Kategori Baru' option
    _categoryOptions = widget.existingCategories
        .where((c) => c.toLowerCase() != 'semua')
        .toList();
    if (!_categoryOptions.contains('Pondok')) {
      _categoryOptions.insert(0, 'Pondok');
    }
    if (_categoryOptions.isNotEmpty) {
      _selectedCategory = _categoryOptions.first;
    }

    // Initialize with 1 default item
    _items.add(_CreateKwitansiItemInput());

    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final result = await context.read<InfaqRepository>().getStudents();
    if (!mounted) return;
    if (result is ApiSuccess<List<StudentLookupModel>>) {
      setState(() => _students = result.data);
    }
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _newCategoryController.dispose();
    _signerRoleController.dispose();
    _noteController.dispose();
    for (var item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  num get _grandTotal {
    return _items.fold<num>(0, (sum, item) => sum + item.total);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickAttachment() async {
    try {
      final file = await ImageUploadHelper.pickImageWithCompression(
        _picker,
        source: ImageSource.gallery,
      );
      if (file == null) return;
      if (!await ImageUploadHelper.validateFileSize(file)) {
        if (mounted) {
          AppSnackBar.showError(
            context,
            'Ukuran lampiran terlalu besar (maksimal 2MB).',
          );
        }
        return;
      }
      if (mounted) setState(() => _attachedFile = file);
    } catch (_) {}
  }

  void _addItem() {
    setState(() {
      _items.add(_CreateKwitansiItemInput());
    });
  }

  void _removeItem(int index) {
    if (_items.length > 1) {
      setState(() {
        _items[index].dispose();
        _items.removeAt(index);
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    final recipient = _recipientController.text.trim();
    if (recipient.isEmpty) {
      AppSnackBar.showError(context, 'Nama Tujuan wajib diisi');
      return;
    }

    String categoryToUse = _selectedCategory;
    String? newCategorySaved;
    if (_isCreatingNewCategory) {
      final typedCat = _newCategoryController.text.trim();
      if (typedCat.isEmpty) {
        AppSnackBar.showError(context, 'Nama kategori baru wajib diisi');
        return;
      }
      categoryToUse = typedCat;
      newCategorySaved = typedCat;
    }

    if (_grandTotal <= 0) {
      AppSnackBar.showError(context, 'Total kwitansi harus lebih dari 0');
      return;
    }

    final parsedItems = _items.map((it) {
      final desc = it.descriptionController.text.trim().isEmpty
          ? 'Item Pembayaran'
          : it.descriptionController.text.trim();
      return KwitansiItemDetail(
        description: desc,
        qty: it.qty < 1 ? 1 : it.qty,
        price: it.price,
      );
    }).toList();

    // Pakai jam saat ini pada tanggal yang dipilih.
    final now = DateTime.now();
    final issuedAt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      now.hour,
      now.minute,
      now.second,
    );

    final request = KwitansiRequest(
      issuedAt: issuedAt,
      recipientName: recipient,
      studentId: _selectedStudentId,
      whatsappNumber: _whatsappController.text,
      email: _emailController.text,
      address: _addressController.text,
      category: categoryToUse,
      paymentMethod: _selectedPaymentMethod,
      items: parsedItems,
      signerRole: _signerRoleController.text.trim().isEmpty
          ? KwitansiModel.defaultSignerRole
          : _signerRoleController.text.trim(),
      note: _noteController.text,
    );

    setState(() => _isSubmitting = true);
    final result = await context.read<KwitansiRepository>().create(
      request,
      attachment: _attachedFile,
      idempotencyKey: _idempotencyKey,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    switch (result) {
      case ApiSuccess(data: final created):
        Navigator.of(context).pop();
        widget.onCreated(created, newCategorySaved);
      case ApiFailure(message: final message):
        AppSnackBar.showError(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460, maxHeight: 690),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // 1. Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Buat Invoice Digital',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Isi detail invoice / kwitansi digital',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFF1F5F9),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),

                // 2. Scrollable Form
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    thickness: 3.5,
                    radius: const Radius.circular(8),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tanggal *
                            _buildLabel('Tanggal', isRequired: true),
                            InkWell(
                              onTap: _pickDate,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(_selectedDate),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.calendar_today_outlined,
                                      size: 17,
                                      color: Color(0xFF64748B),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Nama Tujuan *
                            _buildLabel('Nama Tujuan', isRequired: true),
                            Autocomplete<StudentLookupModel>(
                              displayStringForOption: (s) => s.name,
                              optionsBuilder: (textEditingValue) {
                                final q = textEditingValue.text
                                    .toLowerCase()
                                    .trim();
                                if (q.isEmpty) return _students.take(20);
                                return _students
                                    .where(
                                      (s) =>
                                          s.name.toLowerCase().contains(q) ||
                                          s.nis.toLowerCase().contains(q),
                                    )
                                    .take(20);
                              },
                              onSelected: (student) {
                                _recipientController.text = student.name;
                                _selectedStudentId = student.id;
                              },
                              optionsViewBuilder:
                                  (context, onSelected, options) =>
                                      _buildStudentOptions(onSelected, options),
                              fieldViewBuilder:
                                  (
                                    context,
                                    controller,
                                    focusNode,
                                    onFieldSubmitted,
                                  ) {
                                    return TextFormField(
                                      controller: controller,
                                      focusNode: focusNode,
                                      onChanged: (val) {
                                        _recipientController.text = val;
                                        // Nama diketik manual → bukan santri terdaftar
                                        _selectedStudentId = null;
                                      },
                                      validator: (v) =>
                                          (v == null || v.trim().isEmpty)
                                          ? 'Nama tujuan wajib diisi'
                                          : null,
                                      decoration: _inputDecoration(
                                        hint:
                                            'Ketik nama atau pilih dari database..',
                                        suffixIcon:
                                            Icons.person_outline_rounded,
                                      ),
                                    );
                                  },
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Nomor invoice akan dibuat otomatis setelah disimpan.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontStyle: FontStyle.italic,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // No WhatsApp & Email
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel('No WhatsApp (Opsional)'),
                                      TextFormField(
                                        controller: _whatsappController,
                                        keyboardType: TextInputType.phone,
                                        decoration: _inputDecoration(
                                          hint: '08xxxxxxxxxx',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel('Email (Opsional)'),
                                      TextFormField(
                                        controller: _emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        decoration: _inputDecoration(
                                          hint: 'email@contoh.com',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Alamat (Opsional)
                            _buildLabel('Alamat (Opsional)'),
                            TextFormField(
                              controller: _addressController,
                              decoration: _inputDecoration(
                                hint: 'Alamat tujuan',
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Kategori & Metode Bayar
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Kategori
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel('Kategori', isRequired: true),
                                      DropdownButtonFormField<String>(
                                        key: ValueKey(
                                          _isCreatingNewCategory
                                              ? '+ Kategori Baru'
                                              : _selectedCategory,
                                        ),
                                        initialValue: _isCreatingNewCategory
                                            ? '+ Kategori Baru'
                                            : _selectedCategory,
                                        isExpanded: true,
                                        decoration: _inputDecoration(
                                          hint: 'Pilih Kategori..',
                                        ),
                                        icon: const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: Color(0xFF64748B),
                                          size: 18,
                                        ),
                                        items: [
                                          ..._categoryOptions.map(
                                            (cat) => DropdownMenuItem(
                                              value: cat,
                                              child: Text(cat),
                                            ),
                                          ),
                                          const DropdownMenuItem(
                                            value: '+ Kategori Baru',
                                            child: Text(
                                              '+ Kategori Baru',
                                              style: TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                        onChanged: (val) {
                                          if (val == '+ Kategori Baru') {
                                            setState(() {
                                              _isCreatingNewCategory = true;
                                            });
                                          } else if (val != null) {
                                            setState(() {
                                              _isCreatingNewCategory = false;
                                              _selectedCategory = val;
                                            });
                                          }
                                        },
                                      ),
                                      if (_isCreatingNewCategory) ...[
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: _newCategoryController,
                                          autofocus: true,
                                          decoration: _inputDecoration(
                                            hint: 'Ketik nama kategori baru...',
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // Metode Bayar
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel(
                                        'Metode Bayar',
                                        isRequired: true,
                                      ),
                                      DropdownButtonFormField<String>(
                                        key: ValueKey(_selectedPaymentMethod),
                                        initialValue: _selectedPaymentMethod,
                                        isExpanded: true,
                                        decoration: _inputDecoration(
                                          hint: 'Pilih Metode..',
                                        ),
                                        icon: const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: Color(0xFF64748B),
                                          size: 18,
                                        ),
                                        items: _paymentMethods.map((m) {
                                          return DropdownMenuItem(
                                            value: m,
                                            child: Text(m),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          if (val != null) {
                                            setState(
                                              () =>
                                                  _selectedPaymentMethod = val,
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Detail Item Header with "+ Tambah Item"
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildLabel('Detail Item', isRequired: true),
                                InkWell(
                                  onTap: _addItem,
                                  borderRadius: BorderRadius.circular(6),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.add,
                                          size: 14,
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          'Tambah Item',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Item Cards
                            ...List.generate(_items.length, (index) {
                              final item = _items[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    // Deskripsi Item Row
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller:
                                                item.descriptionController,
                                            decoration: _itemInputDecoration(
                                              hint: 'Deskripsi Item',
                                            ),
                                          ),
                                        ),
                                        if (_items.length > 1) ...[
                                          const SizedBox(width: 6),
                                          InkWell(
                                            onTap: () => _removeItem(index),
                                            child: const Icon(
                                              Icons.delete_outline_rounded,
                                              size: 18,
                                              color: Color(0xFFEF4444),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // Qty, Harga, Total Row
                                    Row(
                                      children: [
                                        // Qty
                                        Expanded(
                                          flex: 2,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildMicroLabel('Qty'),
                                              TextFormField(
                                                controller: item.qtyController,
                                                keyboardType:
                                                    TextInputType.number,
                                                textAlign: TextAlign.center,
                                                onChanged: (_) =>
                                                    setState(() {}),
                                                decoration:
                                                    _itemInputDecoration(
                                                      hint: '1',
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),

                                        // Harga
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildMicroLabel('Harga'),
                                              TextFormField(
                                                controller:
                                                    item.priceController,
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  CurrencyInputFormatter(),
                                                ],
                                                textAlign: TextAlign.center,
                                                onChanged: (_) =>
                                                    setState(() {}),
                                                decoration:
                                                    _itemInputDecoration(
                                                      hint: '0',
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),

                                        // Total
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildMicroLabel('Total'),
                                              Container(
                                                height: 38,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFEEF2F6,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  CurrencyFormatter.format(
                                                    item.total,
                                                  ),
                                                  style:
                                                      GoogleFonts.plusJakartaSans(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: const Color(
                                                          0xFF0F172A,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: 8),

                            // Grand Total Box
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Grand Total',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF15803D),
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.format(_grandTotal),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF15803D),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Jabatan Penandatangan
                            _buildLabel('Jabatan', isRequired: true),
                            TextFormField(
                              controller: _signerRoleController,
                              decoration: _inputDecoration(
                                hint: 'Contoh: Bendahara Yayasan',
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Penandatangan = akun yang memproses (read-only)
                            _buildLabel('Penandatangan & Kontak'),
                            _buildProcessorCard(),
                            const SizedBox(height: 14),

                            // Catatan (Maks. 100 karakter)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildLabel('Catatan (Maks. 100 karakter)'),
                              ],
                            ),
                            TextFormField(
                              controller: _noteController,
                              maxLength: 100,
                              maxLines: 3,
                              onChanged: (_) => setState(() {}),
                              buildCounter:
                                  (
                                    context, {
                                    required currentLength,
                                    required isFocused,
                                    maxLength,
                                  }) {
                                    return Text(
                                      '$currentLength/$maxLength',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        color: const Color(0xFF94A3B8),
                                      ),
                                    );
                                  },
                              decoration: _inputDecoration(
                                hint: 'Catatan tambahan (opsional)',
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Upload Lampiran (Opsional)
                            _buildLabel('Upload Lampiran (Opsional)'),
                            InkWell(
                              onTap: _pickAttachment,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFCBD5E1),
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.cloud_upload_outlined,
                                      size: 30,
                                      color: Color(0xFF94A3B8),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _attachedFile != null
                                          ? _attachedFile!.name
                                          : 'Klik untuk upload',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: _attachedFile != null
                                            ? AppColors.primary
                                            : const Color(0xFF00B074),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'PNG, JPG, JPEG (Maks. 2MB)',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        color: const Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // 3. Pinned Bottom Action Button ("Simpan Invoice")
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        disabledBackgroundColor: const Color(
                          0xFF16A34A,
                        ).withValues(alpha: 0.6),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Simpan Invoice',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProcessorCard() {
    final user = context.select<AuthBloc, UserModel?>((b) => b.state.user);
    final name = user?.name ?? '-';
    final phone = user?.phone?.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.verified_user_outlined,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  phone == null || phone.isEmpty
                      ? 'Diambil otomatis dari akun yang memproses kwitansi'
                      : 'Kontak: $phone • otomatis dari akun Anda',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentOptions(
    AutocompleteOnSelected<StudentLookupModel> onSelected,
    Iterable<StudentLookupModel> options,
  ) {
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 240, maxWidth: 400),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (context, index) {
              final s = options.elementAt(index);
              return ListTile(
                dense: true,
                title: Text(
                  s.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '${s.nis} • ${s.grade}',
                  style: GoogleFonts.plusJakartaSans(fontSize: 10.5),
                ),
                onTap: () => onSelected(s),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF334155),
          ),
          children: [
            if (isRequired)
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMicroLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10.5,
          color: const Color(0xFF64748B),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    IconData? suffixIcon,
  }) {
    return InputDecoration(
      isDense: true,
      hintText: hint,
      suffixIcon: suffixIcon != null
          ? Icon(suffixIcon, size: 18, color: const Color(0xFF94A3B8))
          : null,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      hintStyle: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        color: const Color(0xFF94A3B8),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  InputDecoration _itemInputDecoration({required String hint}) {
    return InputDecoration(
      isDense: true,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      hintStyle: GoogleFonts.plusJakartaSans(
        fontSize: 11.5,
        color: const Color(0xFF94A3B8),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
      ),
    );
  }
}
