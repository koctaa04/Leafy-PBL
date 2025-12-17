import 'package:flutter/material.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  int? _birthYear;
  int? _birthMonth;
  final List<String> _avatars = [
    'assets/avatars/leaf1.png',
    'assets/avatars/leaf2.png',
    'assets/avatars/leaf3.png',
    'assets/avatars/child1.png',
    'assets/avatars/child2.png',
  ];
  int _selectedAvatar = 0;

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  void _pickYear() async {
    final years = List.generate(20, (i) => DateTime.now().year - i);
    int? selected = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _BottomSheetPicker(
        title: 'Pilih Tahun Lahir',
        items: years.map((e) => e.toString()).toList(),
        selectedIndex: _birthYear != null ? years.indexOf(_birthYear!) : 0,
      ),
    );
    if (selected != null) setState(() => _birthYear = years[selected]);
  }

  void _pickMonth() async {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    int? selected = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _BottomSheetPicker(
        title: 'Pilih Bulan Lahir',
        items: months,
        selectedIndex: _birthMonth != null ? _birthMonth! - 1 : 0,
      ),
    );
    if (selected != null) setState(() => _birthMonth = selected + 1);
  }

  @override
  Widget build(BuildContext context) {
    final pastelGreen = const Color(0xFFE8F5E9);
    final pastelYellow = const Color(0xFFFFF9C4);
    final pastelBorder = const Color(0xFFB3E5FC);
    final pastelFill = const Color(0xFFF5F8FA);
    final pastelButton = const Color(0xFFB2DFDB);
    final pastelText = const Color(0xFF388E3C);
    final borderRadius = BorderRadius.circular(28);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF388E3C)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('Profil', style: TextStyle(color: Color(0xFF388E3C), fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            children: [
              // Avatar utama
              Center(
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: pastelGreen,
                    border: Border.all(color: pastelBorder, width: 4),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: pastelBorder.withOpacity(0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: pastelFill,
                    backgroundImage: AssetImage(_avatars[_selectedAvatar]),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Pilihan avatar
              SizedBox(
                height: 56,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _avatars.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (ctx, i) => GestureDetector(
                    onTap: () => setState(() => _selectedAvatar = i),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: i == _selectedAvatar ? pastelBorder : Colors.transparent,
                          width: 3,
                        ),
                        shape: BoxShape.circle,
                        color: pastelFill,
                      ),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: pastelGreen,
                        backgroundImage: AssetImage(_avatars[i]),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Form nickname
              TextField(
                controller: _nicknameController,
                style: TextStyle(color: pastelText, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'Nama Panggilan',
                  labelStyle: TextStyle(color: pastelText),
                  filled: true,
                  fillColor: pastelGreen,
                  border: OutlineInputBorder(
                    borderRadius: borderRadius,
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                ),
              ),
              const SizedBox(height: 18),
              // Selector tahun & bulan
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickYear,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          color: pastelYellow,
                          borderRadius: borderRadius,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _birthYear?.toString() ?? 'Tahun Lahir',
                              style: TextStyle(color: pastelText, fontWeight: FontWeight.w600),
                            ),
                            const Icon(Icons.expand_more, color: Color(0xFF388E3C)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickMonth,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          color: pastelYellow,
                          borderRadius: borderRadius,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _birthMonth != null
                                  ? [
                                      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
                                      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
                                    ][_birthMonth! - 1]
                                  : 'Bulan Lahir',
                              style: TextStyle(color: pastelText, fontWeight: FontWeight.w600),
                            ),
                            const Icon(Icons.expand_more, color: Color(0xFF388E3C)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // CTA
              const Spacer(),
              Text(
                'Sesuaikan pengalaman belajar anak',
                style: TextStyle(color: pastelText.withOpacity(0.7), fontSize: 13),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pastelButton,
                    foregroundColor: pastelText,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Simpan Perubahan',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomSheetPicker extends StatelessWidget {
  final String title;
  final List<String> items;
  final int selectedIndex;
  const _BottomSheetPicker({required this.title, required this.items, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.only(top: 18, left: 18, right: 18, bottom: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF388E3C))),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ListWheelScrollView.useDelegate(
              itemExtent: 38,
              diameterRatio: 1.2,
              physics: const FixedExtentScrollPhysics(),
              controller: FixedExtentScrollController(initialItem: selectedIndex),
              onSelectedItemChanged: (i) {},
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (ctx, i) => i < 0 || i >= items.length
                    ? null
                    : Center(
                        child: Text(
                          items[i],
                          style: TextStyle(
                            fontWeight: i == selectedIndex ? FontWeight.bold : FontWeight.normal,
                            color: i == selectedIndex ? const Color(0xFF388E3C) : Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                childCount: items.length,
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, selectedIndex),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB2DFDB),
                foregroundColor: const Color(0xFF388E3C),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
              ),
              child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
