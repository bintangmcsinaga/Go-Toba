import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ─── Color Palette (Lake Toba inspired) ────────────────────────────────────
const _deepTeal = Color(0xFF0D4F6C); // Danau dalam
const _midTeal = Color(0xFF1A7A9A); // Air biru
const _skyBlue = Color(0xFF4DB6E4); // Langit Toba
const _warmGold = Color(0xFFE8A923); // Cahaya matahari
const _softCream = Color(0xFFF4F1E8); // Pasir & batu
const _cardBg = Color(0xFFFFFFFF);

/// Halaman Database Seeder — premium redesign, animasi smooth.
/// Gunakan hanya saat development.
class DatabaseSeederPage extends StatefulWidget {
  const DatabaseSeederPage({super.key});

  @override
  State<DatabaseSeederPage> createState() => _DatabaseSeederPageState();
}

class _DatabaseSeederPageState extends State<DatabaseSeederPage>
    with TickerProviderStateMixin {
  // ─── Animation controllers ───────────────────────────────────────────────
  late AnimationController _headerPulse;
  late AnimationController _waveController;
  late AnimationController _cardsEntrance;
  late AnimationController _progressBarCtrl;

  late Animation<double> _headerScale;
  late Animation<double> _waveAnim;
  late Animation<double> _progressBarAnim;
  late List<Animation<Offset>> _cardSlide;

  // ─── State ───────────────────────────────────────────────────────────────
  bool _isLoading = false;
  double _progress = 0;
  String _status = '';
  final List<_StepStatus> _steps = [
    _StepStatus('🏨', 'Hotel', 'Menambahkan 5 hotel + kamar'),
    _StepStatus('🍽️', 'Kuliner', 'Menambahkan 8 kuliner khas Toba'),
    _StepStatus('⛵', 'Kapal Ferry', 'Menambahkan 10 rute ferry'),
    _StepStatus('🚌', 'Bus', 'Menambahkan 12 rute bus'),
  ];

  @override
  void initState() {
    super.initState();

    _headerPulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _headerScale = Tween<double>(begin: 1.0, end: 1.04).animate(
        CurvedAnimation(parent: _headerPulse, curve: Curves.easeInOut));

    _waveController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat();
    _waveAnim = Tween<double>(begin: 0, end: 2 * pi).animate(_waveController);

    _cardsEntrance = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _cardSlide = List.generate(
        _steps.length,
        (i) => Tween<Offset>(
              begin: const Offset(0.6, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _cardsEntrance,
              curve: Interval(i * 0.18, min(i * 0.18 + 0.5, 1.0),
                  curve: Curves.easeOutBack),
            )));
    _cardsEntrance.forward();

    _progressBarCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _progressBarAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _progressBarCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _headerPulse.dispose();
    _waveController.dispose();
    _cardsEntrance.dispose();
    _progressBarCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // DATA DUMMY
  // ─────────────────────────────────────────────

  final List<Map<String, dynamic>> _hotels = [
    {
      'name': 'Hotel Niagara Parapat',
      'imageUrl':
          'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
      'imageUrls': [
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
        'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800',
        'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=800',
      ],
      'price': 450000,
      'address': [
        'Jl. Sisingamangaraja No.1',
        'Parapat',
        'Simalungun',
        'Sumatera Utara'
      ],
      'contact': '0625-41012',
      'rating': 4,
      'facilities': [
        'WiFi',
        'Kolam Renang',
        'Restoran',
        'Parkir',
        'AC',
        'View Danau'
      ],
      'tags': ['parapat', 'danau', 'tuktuk', 'bintang4'],
      'rooms': [
        {
          'type': 'Standard Room',
          'pricePerNight': 450000,
          'facilities': ['AC', 'TV', 'WiFi', 'Kamar Mandi Pribadi'],
          'available': true,
          'imageUrl':
              'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800'
        },
        {
          'type': 'Deluxe Lake View',
          'pricePerNight': 750000,
          'facilities': [
            'AC',
            'TV',
            'WiFi',
            'Balkon',
            'View Danau',
            'Mini Bar'
          ],
          'available': true,
          'imageUrl':
              'https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800'
        },
        {
          'type': 'Suite Room',
          'pricePerNight': 1250000,
          'facilities': [
            'AC',
            'TV',
            'WiFi',
            'Ruang Tamu',
            'Bathtub',
            'View Danau',
            'Mini Bar'
          ],
          'available': true,
          'imageUrl':
              'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800'
        },
      ]
    },
    {
      'name': 'Tabo Cottage Samosir',
      'imageUrl':
          'https://images.unsplash.com/photo-1540541338287-41700207dee6?w=800',
      'imageUrls': [
        'https://images.unsplash.com/photo-1540541338287-41700207dee6?w=800',
        'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800',
        'https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=800'
      ],
      'price': 350000,
      'address': ['Tuk Tuk Siadong', 'Samosir', 'Sumatera Utara'],
      'contact': '0813-6000-0000',
      'rating': 5,
      'facilities': [
        'WiFi',
        'Restoran',
        'Kayak',
        'Sepeda',
        'Taman',
        'View Danau'
      ],
      'tags': ['tuktuk', 'samosir', 'danau', 'cottage', 'pemandangandanau'],
      'rooms': [
        {
          'type': 'Garden Cottage',
          'pricePerNight': 350000,
          'facilities': ['AC', 'WiFi', 'Teras', 'Kamar Mandi'],
          'available': true,
          'imageUrl':
              'https://images.unsplash.com/photo-1499793983690-e29da59ef1c2?w=800'
        },
        {
          'type': 'Lake View Cottage',
          'pricePerNight': 600000,
          'facilities': ['AC', 'WiFi', 'View Danau', 'Teras', 'Hammock'],
          'available': true,
          'imageUrl':
              'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800'
        },
      ]
    },
    {
      'name': 'Silintong Hotel & Resort',
      'imageUrl':
          'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800',
      'imageUrls': [
        'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800',
        'https://images.unsplash.com/photo-1445019980597-93fa8acb246c?w=800',
        'https://images.unsplash.com/photo-1506059612708-99d6128b4cf8?w=800'
      ],
      'price': 550000,
      'address': ['Jl. Lintas Sumatera', 'Balige', 'Toba', 'Sumatera Utara'],
      'contact': '0632-21300',
      'rating': 4,
      'facilities': [
        'WiFi',
        'Kolam Renang',
        'Spa',
        'Restoran',
        'Ballroom',
        'Parkir Luas'
      ],
      'tags': ['balige', 'resort', 'danau', 'bintang4', 'parapat'],
      'rooms': [
        {
          'type': 'Superior Room',
          'pricePerNight': 550000,
          'facilities': ['AC', 'TV', 'WiFi', 'Kamar Mandi', 'Sarapan'],
          'available': true,
          'imageUrl':
              'https://images.unsplash.com/photo-1631049035182-249067d7ef5d?w=800'
        },
        {
          'type': 'Junior Suite',
          'pricePerNight': 900000,
          'facilities': [
            'AC',
            'TV',
            'WiFi',
            'Bathtub',
            'Ruang Keluarga',
            'Sarapan'
          ],
          'available': true,
          'imageUrl':
              'https://images.unsplash.com/photo-1591088398332-8a7791972843?w=800'
        },
      ]
    },
    {
      'name': 'Horas Family Hotel',
      'imageUrl':
          'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800',
      'imageUrls': [
        'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800',
        'https://images.unsplash.com/photo-1445019980597-93fa8acb246c?w=800'
      ],
      'price': 200000,
      'address': ['Jl. Marpaung No.5', 'Balige', 'Toba', 'Sumatera Utara'],
      'contact': '0632-21450',
      'rating': 3,
      'facilities': ['WiFi', 'Parkir', 'Restoran', 'AC'],
      'tags': ['balige', 'budget', 'keluarga', 'danau'],
      'rooms': [
        {
          'type': 'Standard',
          'pricePerNight': 200000,
          'facilities': ['AC', 'WiFi', 'TV'],
          'available': true,
          'imageUrl':
              'https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800'
        }
      ]
    },
    {
      'name': 'Lakhsmy Hotel Siborong-borong',
      'imageUrl':
          'https://images.unsplash.com/photo-1496417263034-38ec4f0b665a?w=800',
      'imageUrls': [
        'https://images.unsplash.com/photo-1496417263034-38ec4f0b665a?w=800',
        'https://images.unsplash.com/photo-1506059612708-99d6128b4cf8?w=800'
      ],
      'price': 300000,
      'address': [
        'Jl. Siborongborong No.12',
        'Siborongborong',
        'Tapanuli Utara'
      ],
      'contact': '0633-41200',
      'rating': 3,
      'facilities': ['WiFi', 'Parkir', 'Sarapan', 'AC'],
      'tags': ['siborongborong', 'budget', 'danau', 'batak'],
      'rooms': [
        {
          'type': 'Standard',
          'pricePerNight': 300000,
          'facilities': ['AC', 'WiFi', 'TV', 'Kamar Mandi'],
          'available': true,
          'imageUrl':
              'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800'
        },
        {
          'type': 'Deluxe',
          'pricePerNight': 450000,
          'facilities': ['AC', 'WiFi', 'TV', 'Bathtub', 'Balkon'],
          'available': true,
          'imageUrl':
              'https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800'
        },
      ]
    },
  ];

  final List<Map<String, dynamic>> _kuliner = [
    {
      'name': 'Arsik Ikan Mas',
      'imageUrl':
          'https://images.unsplash.com/photo-1627308595229-7830a5c18106?w=800',
      'price': 45000,
      'rating': 5,
      'deskripsi':
          'Ikan mas dimasak dengan bumbu andaliman, kunyit, dan asam cikala. Masakan ikonik Batak Toba.',
      'gmaps': 'https://maps.app.goo.gl/feXxyRyVYjXYrbJBA',
      'tags': ['ikan', 'batak', 'pedas', 'arsik', 'kuah']
    },
    {
      'name': 'Naniura',
      'imageUrl':
          'https://images.unsplash.com/photo-1614777735614-2c6b9d55e8a0?w=800',
      'price': 55000,
      'rating': 4,
      'deskripsi':
          'Ikan mas mentah yang dimatangkan dengan asam jungga dan rempah. Sashimi-nya orang Batak.',
      'gmaps': 'https://maps.app.goo.gl/feXxyRyVYjXYrbJBA',
      'tags': ['ikan', 'batak', 'mentah', 'asam', 'naniura']
    },
    {
      'name': 'Saksang Babi',
      'imageUrl':
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800',
      'price': 60000,
      'rating': 5,
      'deskripsi':
          'Daging babi dimasak dengan darah dan rempah batak termasuk andaliman yang kuat.',
      'gmaps': 'https://maps.app.goo.gl/feXxyRyVYjXYrbJBA',
      'tags': ['babi', 'batak', 'pedas', 'andaliman', 'saksang']
    },
    {
      'name': 'Mangga Goreng Tepung',
      'imageUrl':
          'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800',
      'price': 25000,
      'rating': 4,
      'deskripsi':
          'Mangga muda dibalut tepung renyah, disajikan dengan sambal pedas dan asam.',
      'gmaps': 'https://maps.app.goo.gl/feXxyRyVYjXYrbJBA',
      'tags': ['snack', 'mangga', 'goreng', 'samosir', 'parapat']
    },
    {
      'name': 'Mi Gomak',
      'imageUrl':
          'https://images.unsplash.com/photo-1569050467447-ce54b3bbc37d?w=800',
      'price': 20000,
      'rating': 4,
      'deskripsi':
          'Mie lidi khas Batak dengan kuah kaldu dan bumbu andaliman. Dijuluki spaghetti Batak.',
      'gmaps': 'https://maps.app.goo.gl/feXxyRyVYjXYrbJBA',
      'tags': ['mie', 'batak', 'gomak', 'andaliman', 'kuah']
    },
    {
      'name': 'Natinombur',
      'imageUrl':
          'https://images.unsplash.com/photo-1519984388953-d2406bc725e1?w=800',
      'price': 50000,
      'rating': 4,
      'deskripsi':
          'Ikan bakar khas Batak yang disiram bumbu andaliman dan asam saat masih panas.',
      'gmaps': 'https://maps.app.goo.gl/feXxyRyVYjXYrbJBA',
      'tags': ['ikan', 'batak', 'bakar', 'andaliman', 'natinombur']
    },
    {
      'name': 'Kopi Sidikalang',
      'imageUrl':
          'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800',
      'price': 15000,
      'rating': 5,
      'deskripsi':
          'Kopi arabika terbaik dari dataran tinggi Sidikalang. Wajib dicoba di kawasan Toba.',
      'gmaps': 'https://maps.app.goo.gl/feXxyRyVYjXYrbJBA',
      'tags': ['kopi', 'sidikalang', 'minuman', 'arabika']
    },
    {
      'name': 'Sambal Tuktuk',
      'imageUrl':
          'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=800',
      'price': 10000,
      'rating': 4,
      'deskripsi':
          'Sambal andaliman khas Batak dengan sensasi kesemutan di lidah. Pelengkap semua hidangan.',
      'gmaps': 'https://maps.app.goo.gl/feXxyRyVYjXYrbJBA',
      'tags': ['sambal', 'batak', 'andaliman', 'pedas', 'tuktuk']
    },
  ];

  final List<Map<String, dynamic>> _ships = [
    {
      'from': 'Pelabuhan Ajibata',
      'to': 'Pelabuhan Simanindo',
      'departTime': ['08:00', '10:00', '12:00', '14:00', '16:00'],
      'price': 15000
    },
    {
      'from': 'Pelabuhan Simanindo',
      'to': 'Pelabuhan Ajibata',
      'departTime': ['09:00', '11:00', '13:00', '15:00', '17:00'],
      'price': 15000
    },
    {
      'from': 'Pelabuhan Ajibata',
      'to': 'Pelabuhan Tigaras',
      'departTime': ['08:30', '12:30', '16:30'],
      'price': 20000
    },
    {
      'from': 'Pelabuhan Tigaras',
      'to': 'Pelabuhan Ajibata',
      'departTime': ['09:30', '13:30', '17:30'],
      'price': 20000
    },
    {
      'from': 'Pelabuhan Muara',
      'to': 'Pelabuhan Bakti Raja',
      'departTime': ['07:00', '11:00', '15:00'],
      'price': 25000
    },
    {
      'from': 'Pelabuhan Bakti Raja',
      'to': 'Pelabuhan Muara',
      'departTime': ['08:00', '12:00', '16:00'],
      'price': 25000
    },
    {
      'from': 'Pelabuhan Ajibata',
      'to': 'Pelabuhan Muara',
      'departTime': ['07:00', '10:00', '13:00'],
      'price': 35000
    },
    {
      'from': 'Pelabuhan Muara',
      'to': 'Pelabuhan Ajibata',
      'departTime': ['08:30', '11:30', '14:30'],
      'price': 35000
    },
    {
      'from': 'Pelabuhan Tongging',
      'to': 'Pelabuhan Tigaras',
      'departTime': ['09:00', '13:00'],
      'price': 30000
    },
    {
      'from': 'Pelabuhan Tigaras',
      'to': 'Pelabuhan Tongging',
      'departTime': ['10:00', '14:00'],
      'price': 30000
    },
  ];

  final List<Map<String, dynamic>> _buses = [
    {
      'transportName': 'AKDP Sinar Raya',
      'from': 'Medan',
      'to': 'Parapat',
      'departTime': ['06:00', '08:00', '10:00', '12:00', '14:00', '16:00'],
      'price': 60000
    },
    {
      'transportName': 'AKDP Sinar Raya',
      'from': 'Parapat',
      'to': 'Medan',
      'departTime': ['06:00', '08:00', '10:00', '12:00', '14:00', '16:00'],
      'price': 60000
    },
    {
      'transportName': 'Tiara Bus',
      'from': 'Medan',
      'to': 'Parapat',
      'departTime': ['07:30', '12:30', '17:30'],
      'price': 70000
    },
    {
      'transportName': 'Tiara Bus',
      'from': 'Parapat',
      'to': 'Medan',
      'departTime': ['07:00', '11:00', '15:00'],
      'price': 70000
    },
    {
      'transportName': 'Bus Damri Pariwisata',
      'from': 'Medan',
      'to': 'Berastagi',
      'departTime': ['08:00', '10:00', '14:00'],
      'price': 45000
    },
    {
      'transportName': 'Bus Damri Pariwisata',
      'from': 'Berastagi',
      'to': 'Medan',
      'departTime': ['09:00', '12:00', '16:00'],
      'price': 45000
    },
    {
      'transportName': 'Taxi KPUM',
      'from': 'Medan',
      'to': 'Pematang Siantar',
      'departTime': [
        '06:00',
        '07:00',
        '08:00',
        '09:00',
        '10:00',
        '12:00',
        '14:00'
      ],
      'price': 35000
    },
    {
      'transportName': 'Taxi KPUM',
      'from': 'Pematang Siantar',
      'to': 'Medan',
      'departTime': ['06:00', '07:00', '09:00', '11:00', '13:00', '15:00'],
      'price': 35000
    },
    {
      'transportName': 'Samosir Trans',
      'from': 'Parapat',
      'to': 'Samosir',
      'departTime': ['08:00', '12:00', '16:00'],
      'price': 50000
    },
    {
      'transportName': 'Samosir Trans',
      'from': 'Samosir',
      'to': 'Parapat',
      'departTime': ['09:00', '13:00', '17:00'],
      'price': 50000
    },
    {
      'transportName': 'Shuttle Silangit',
      'from': 'Silangit Airport',
      'to': 'Parapat',
      'departTime': ['09:00', '14:00', '19:00'],
      'price': 100000
    },
    {
      'transportName': 'Shuttle Silangit',
      'from': 'Parapat',
      'to': 'Silangit Airport',
      'departTime': ['06:00', '11:00', '15:00'],
      'price': 100000
    },
  ];

  // ─────────────────────────────────────────────
  // SEEDING LOGIC
  // ─────────────────────────────────────────────

  Future<void> _seedAll() async {
    setState(() {
      _isLoading = true;
      _progress = 0;
    });

    final tasks = [_seedHotels, _seedKuliner, _seedShips, _seedBuses];
    for (int i = 0; i < tasks.length; i++) {
      setState(() {
        _steps[i].state = _SeedState.loading;
        _status = _steps[i].subtitle;
      });
      try {
        await tasks[i]();
        setState(() {
          _steps[i].state = _SeedState.done;
        });
      } catch (e) {
        setState(() {
          _steps[i].state = _SeedState.error;
        });
      }
      final target = (i + 1) / tasks.length;
      _progressBarCtrl
        ..stop()
        ..value = _progress;
      await _progressBarCtrl.animateTo(target,
          duration: const Duration(milliseconds: 600));
      setState(() => _progress = target);
    }

    setState(() {
      _isLoading = false;
      _status = 'Selesai!';
    });
  }

  Future<void> _seedHotels() async {
    final ref = FirebaseFirestore.instance.collection('hotels');
    for (final hotel in _hotels) {
      final rooms = List<Map<String, dynamic>>.from(hotel['rooms'] as List);
      final data = Map<String, dynamic>.from(hotel)..remove('rooms');
      final doc = await ref.add(data);
      for (final r in rooms) {
        await doc.collection('rooms').add(r);
      }
    }
  }

  Future<void> _seedKuliner() async {
    final ref = FirebaseFirestore.instance.collection('kuliner');
    for (final k in _kuliner) {
      await ref.add(k);
    }
  }

  Future<void> _seedShips() async {
    final ref = FirebaseFirestore.instance.collection('ship');
    for (final s in _ships) {
      await ref.add(s);
    }
  }

  Future<void> _seedBuses() async {
    final ref = FirebaseFirestore.instance.collection('buses');
    for (final b in _buses) {
      await ref.add(b);
    }
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _softCream,
      body: CustomScrollView(
        slivers: [
          // ── Animated SliverAppBar ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: _deepTeal,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: _AnimatedHeader(
                pulseAnim: _headerScale,
                waveAnim: _waveAnim,
              ),
              title: const Text(
                'Database Seeder',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  shadows: [Shadow(color: Colors.black38, blurRadius: 4)],
                ),
              ),
              centerTitle: true,
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Warning banner ─────────────────────────────────────
                _WarningBanner(),
                const SizedBox(height: 24),

                // ── Data summary cards ─────────────────────────────────
                ...List.generate(_steps.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SlideTransition(
                      position: _cardSlide[i],
                      child: _SummaryCard(step: _steps[i]),
                    ),
                  );
                }),

                const SizedBox(height: 28),

                // ── Progress bar (only visible while seeding) ──────────
                if (_isLoading || _progress > 0) ...[
                  _ProgressSection(
                      progressAnim: _progressBarAnim, progress: _progress),
                  const SizedBox(height: 16),
                  Text(
                    _status,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: _deepTeal,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                ],

                // ── Seed button ────────────────────────────────────────
                if (!_isLoading && _progress == 0)
                  _GradientButton(
                    label: 'Seed Semua Data ke Firestore',
                    icon: Icons.cloud_upload_rounded,
                    onTap: _seedAll,
                  )
                else if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(color: _deepTeal),
                  )
                else if (_progress >= 1)
                  _DoneCard(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ANIMATED HEADER  (wave + pulse icon)
// ─────────────────────────────────────────────

class _AnimatedHeader extends StatelessWidget {
  final Animation<double> pulseAnim;
  final Animation<double> waveAnim;
  const _AnimatedHeader({required this.pulseAnim, required this.waveAnim});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([pulseAnim, waveAnim]),
      builder: (_, __) {
        return Stack(
          children: [
            // gradient bg
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_deepTeal, _midTeal, _skyBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // wave painter
            CustomPaint(
              painter: _WavePainter(waveAnim.value),
              size: Size.infinite,
            ),
            // centre icon
            Center(
              child: Transform.scale(
                scale: pulseAnim.value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromRGBO(255, 255, 255, 38),
                    border: Border.all(
                        color: const Color.fromRGBO(255, 255, 255, 102),
                        width: 2),
                  ),
                  child: const Icon(Icons.storage_rounded,
                      size: 40, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  final double phase;
  _WavePainter(this.phase);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromRGBO(255, 255, 255, 18)
      ..style = PaintingStyle.fill;

    for (int wave = 0; wave < 3; wave++) {
      final path = Path();
      path.moveTo(0, size.height * 0.6);
      for (double x = 0; x <= size.width; x++) {
        final y = size.height * 0.6 +
            sin(x / size.width * 2 * pi * 2 + phase + wave * 1.2) *
                (12.0 - wave * 3);
        path.lineTo(x, y);
      }
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.phase != phase;
}

// ─────────────────────────────────────────────
// WARNING BANNER
// ─────────────────────────────────────────────

class _WarningBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _warmGold.withValues(alpha: 0.6)),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: _warmGold, size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Hanya untuk development. Jalankan sekali saja!',
              style: TextStyle(
                  color: Color(0xFF7D5A00),
                  fontWeight: FontWeight.w600,
                  fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SUMMARY CARD
// ─────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final _StepStatus step;
  const _SummaryCard({required this.step});

  @override
  Widget build(BuildContext context) {
    // color used via _stateColor calls below
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(13, 79, 108, 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: _stateColor(step.state) == Colors.grey
              ? const Color.fromRGBO(128, 128, 128, 0.1)
              : Color.fromRGBO(
                  _stateColor(step.state).r.toInt(),
                  _stateColor(step.state).g.toInt(),
                  _stateColor(step.state).b.toInt(),
                  step.state != _SeedState.idle ? 0.5 : 0.1),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Icon bubble
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [_deepTeal, _midTeal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(step.emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: _deepTeal)),
                  const SizedBox(height: 2),
                  Text(step.subtitle,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
            _StateIndicator(state: step.state),
          ],
        ),
      ),
    );
  }

  Color _stateColor(_SeedState s) {
    switch (s) {
      case _SeedState.loading:
        return _skyBlue;
      case _SeedState.done:
        return Colors.green;
      case _SeedState.error:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _StateIndicator extends StatelessWidget {
  final _SeedState state;
  const _StateIndicator({required this.state});

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case _SeedState.loading:
        return const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.5, color: _skyBlue),
        );
      case _SeedState.done:
        return const Icon(Icons.check_circle, color: Colors.green, size: 26);
      case _SeedState.error:
        return const Icon(Icons.error, color: Colors.red, size: 26);
      default:
        return const Icon(Icons.circle_outlined, color: Colors.grey, size: 22);
    }
  }
}

// ─────────────────────────────────────────────
// PROGRESS SECTION
// ─────────────────────────────────────────────

class _ProgressSection extends StatelessWidget {
  final Animation<double> progressAnim;
  final double progress;
  const _ProgressSection({required this.progressAnim, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Progress',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _deepTeal,
                    fontSize: 13)),
            Text('${(progress * 100).toInt()}%',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _warmGold,
                    fontSize: 13)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: const Color.fromRGBO(77, 182, 228, 0.15),
            valueColor: const AlwaysStoppedAnimation<Color>(_midTeal),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// GRADIENT BUTTON
// ─────────────────────────────────────────────

class _GradientButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _GradientButton(
      {required this.label, required this.icon, required this.onTap});

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerCtrl;
  late Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat();
    _shimmer = Tween<double>(begin: -1.5, end: 2.5)
        .animate(CurvedAnimation(parent: _shimmerCtrl, curve: Curves.linear));
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _shimmer,
        builder: (_, __) {
          return Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: const [_deepTeal, _midTeal, _skyBlue],
                stops: const [0.0, 0.5, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(26, 122, 154, 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Stack(
              children: [
                // shimmer overlay
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          begin: Alignment(_shimmer.value - 0.5, 0),
                          end: Alignment(_shimmer.value + 0.5, 0),
                          colors: [
                            Colors.transparent,
                            Color.fromRGBO(255, 255, 255, 0.18),
                            Colors.transparent,
                          ],
                        ).createShader(bounds);
                      },
                      child: Container(color: Colors.white),
                    ),
                  ),
                ),
                // label
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(widget.icon, color: Colors.white, size: 22),
                      const SizedBox(width: 10),
                      Text(widget.label,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              letterSpacing: 0.5)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DONE STATE CARD
// ─────────────────────────────────────────────

class _DoneCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 32),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Seeding Selesai!',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 16)),
                SizedBox(height: 4),
                Text('Semua data berhasil ditambahkan ke Firestore.',
                    style: TextStyle(color: Colors.green, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────

enum _SeedState { idle, loading, done, error }

class _StepStatus {
  final String emoji;
  final String title;
  final String subtitle;
  _SeedState state;
  _StepStatus(this.emoji, this.title, this.subtitle) : state = _SeedState.idle;
}
