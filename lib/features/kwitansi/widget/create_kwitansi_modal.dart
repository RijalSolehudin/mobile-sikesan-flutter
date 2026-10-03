import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
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
    try {
      final currentLoc = GoRouterState.of(context).matchedLocation;
      final targetPath = currentLoc.endsWith('/')
          ? '${currentLoc}create'
          : '$currentLoc/create';
      return context.push(
        targetPath,
        extra: {
          'categories': existingCategories,
          'onCreated': onCreated,
        },
      );
    } catch (_) {
      return showDialog(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.5),
        builder: (context) => CreateKwitansiModal(
          existingCategories: existingCategories,
          onCreated: onCreated,
        ),
      );
    }
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
    text: 'Bendahara',
  );
  final TextEditingController _signerNameController = TextEditingController(
    text: 'Risda Nur Fajar Purnama',
  );
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  XFile? _attachedFile;
  final ImagePicker _picker = ImagePicker();

  final List<String> _santriDatabase = [
    'M Rayyan Zaidane Alhaq',
    'M Nazri Fatih altaf',
    'Muhammad Rais Al Fatih',
    'Ahmad Zaky Mubarak',
    'Fathir Rahman Hakim',
    'Alifia Nurul Izzah',
    'Erlangga Putra Haryandi',
    'Yansen Panca Mahardika',
  ];

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
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _newCategoryController.dispose();
    _signerRoleController.dispose();
    _signerNameController.dispose();
    _contactController.dispose();
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
      final file = await _picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        setState(() => _attachedFile = file);
      }
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

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final recipient = _recipientController.text.trim();
    if (recipient.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama Tujuan wajib diisi'),
          backgroundColor: AppColors.expense,
        ),
      );
      return;
    }

    String categoryToUse = _selectedCategory;
    String? newCategorySaved;
    if (_isCreatingNewCategory) {
      final typedCat = _newCategoryController.text.trim();
      if (typedCat.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nama kategori baru wajib diisi'),
            backgroundColor: AppColors.expense,
          ),
        );
        return;
      }
      categoryToUse = typedCat;
      newCategorySaved = typedCat;
    }

    final totalAmount = _grandTotal;
    if (totalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Total kwitansi harus lebih dari 0'),
          backgroundColor: AppColors.expense,
        ),
      );
      return;
    }

    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(_selectedDate);
    final invoiceRandom =
        'INV/${categoryToUse.toUpperCase()}/${DateFormat('yyyy/MM/dd').format(_selectedDate)}/${(DateTime.now().millisecondsSinceEpoch % 900 + 100).toString().padLeft(3, '0')}';

    final parsedItems = _items.map((it) {
      final desc = it.descriptionController.text.trim().isEmpty
          ? 'Item Pembayaran'
          : it.descriptionController.text.trim();
      return KwitansiItemDetail(
        description: desc,
        qty: it.qty,
        price: it.price,
      );
    }).toList();

    final newKwitansi = KwitansiModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      receiptNumber: invoiceRandom,
      recipientName: recipient,
      category: categoryToUse,
      itemCountDescription: '${parsedItems.length} Item Pembayaran',
      amount: totalAmount,
      dateTime: dateStr,
      paymentMethod: _selectedPaymentMethod,
      status: 'Aktif',
      note: _noteController.text.trim(),
      signerRole: _signerRoleController.text.trim().isEmpty
          ? 'Bendahara Yayasan'
          : _signerRoleController.text.trim(),
      signerName: _signerNameController.text.trim().isEmpty
          ? 'Risda Nur Fajar Purnama'
          : _signerNameController.text.trim(),
      whatsappNumber: _whatsappController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
      contact: _contactController.text.trim(),
      attachmentPath: _attachedFile?.path,
      items: parsedItems,
    );

    Navigator.of(context).pop();
    widget.onCreated(newKwitansi, newCategorySaved);
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
                            Autocomplete<String>(
                              optionsBuilder: (textEditingValue) {
                                if (textEditingValue.text.isEmpty) {
                                  return _santriDatabase;
                                }
                                return _santriDatabase.where(
                                  (santri) => santri.toLowerCase().contains(
                                    textEditingValue.text.toLowerCase(),
                                  ),
                                );
                              },
                              onSelected: (val) {
                                _recipientController.text = val;
                              },
                              fieldViewBuilder:
                                  (
                                    context,
                                    controller,
                                    focusNode,
                                    onFieldSubmitted,
                                  ) {
                                    _recipientController.addListener(() {
                                      if (controller.text !=
                                          _recipientController.text) {
                                        controller.text =
                                            _recipientController.text;
                                      }
                                    });
                                    return TextFormField(
                                      controller: controller,
                                      focusNode: focusNode,
                                      onChanged: (val) =>
                                          _recipientController.text = val,
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

                            // Jabatan & Nama Lengkap
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel('Jabatan', isRequired: true),
                                      TextFormField(
                                        controller: _signerRoleController,
                                        decoration: _inputDecoration(
                                          hint: 'Contoh: Bendahara',
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
                                      _buildLabel(
                                        'Nama Lengkap',
                                        isRequired: true,
                                      ),
                                      TextFormField(
                                        controller: _signerNameController,
                                        decoration: _inputDecoration(
                                          hint: 'Nama penandatangan',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Kontak (Opsional)
                            _buildLabel('Kontak (Opsional)'),
                            TextFormField(
                              controller: _contactController,
                              decoration: _inputDecoration(
                                hint:
                                    'Nomor kontak yang ditampilkan di invoice',
                              ),
                            ),
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
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
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
