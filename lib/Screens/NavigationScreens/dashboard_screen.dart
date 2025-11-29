import 'dart:math';
import 'package:flutter/material.dart';

// Minimal data models
class ActiveArea {
  String id;
  String name;
  int count;
  ActiveArea({required this.id, required this.name, required this.count});
}

class BinItem {
  String id;
  String name;
  String status;
  double percentage;
  BinItem(
      {required this.id,
      required this.name,
      required this.status,
      required this.percentage});
}

// -------------------- Dashboard Screen --------------------
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  // mock chart data
  static const List<double> area1 = [1, 3, 5, 7, 6, 8, 5, 9, 7, 10, 8];
  static const List<double> area2 = [2, 6, 9, 5, 12, 8, 6, 14, 11, 13, 12];
  static const List<double> area3 = [0, 1, 3, 2, 4, 3, 6, 5, 9, 7, 10];

  static const List<double> responseTimes = [
    1.0,
    0.8,
    2.4,
    3.2,
    1.8,
    2.0,
    2.6,
    3.6
  ];

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  // In-memory datasets (editable)
  final List<ActiveArea> _areas = [
    ActiveArea(id: 'a1', name: 'Creekside', count: 25),
    ActiveArea(id: 'a2', name: 'Riverside', count: 18),
    ActiveArea(id: 'a3', name: 'Park Zone', count: 12),
  ];

  final List<BinItem> _bins = [
    BinItem(id: 'b1', name: 'Bin A', status: 'Active', percentage: 0.75),
    BinItem(id: 'b2', name: 'Bin B', status: 'Full', percentage: 0.98),
    BinItem(id: 'b3', name: 'Bin C', status: 'Offline', percentage: 0.0),
  ];

  // animation controller for charts
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  // helpers to compute a status map for donut painter
  Map<String, double> get _binStatusMap {
    final map = <String, double>{};
    for (var b in _bins) {
      map[b.status] = (map[b.status] ?? 0) + 1.0;
    }
    return map;
  }

  // ----- CRUD operations -----
  void _addOrEditArea({ActiveArea? existing}) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final countController = TextEditingController(
        text: existing != null ? '${existing.count}' : '');
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(existing == null ? 'Add Area' : 'Edit Area'),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Area name'),
              ),
              TextField(
                controller: countController,
                decoration: const InputDecoration(labelText: 'Count'),
                keyboardType: TextInputType.number,
              ),
            ]),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel')),
              ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final count =
                        int.tryParse(countController.text.trim()) ?? 0;
                    if (name.isEmpty) return;
                    setState(() {
                      if (existing == null) {
                        _areas.add(ActiveArea(
                            id: 'a${DateTime.now().millisecondsSinceEpoch}',
                            name: name,
                            count: count));
                      } else {
                        existing.name = name;
                        existing.count = count;
                      }
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Save'))
            ],
          );
        });
  }

  void _addOrEditBin({BinItem? existing}) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    String status = existing?.status ?? 'Active';
    double pct = existing?.percentage ?? 0.0;
    showDialog(
        context: context,
        builder: (_) {
          return StatefulBuilder(builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(existing == null ? 'Add Bin' : 'Edit Bin'),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Bin name'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                    value: status,
                    items: const [
                      DropdownMenuItem(value: 'Active', child: Text('Active')),
                      DropdownMenuItem(value: 'Full', child: Text('Full')),
                      DropdownMenuItem(
                          value: 'Offline', child: Text('Offline')),
                      DropdownMenuItem(
                          value: 'Maintenance', child: Text('Maintenance')),
                    ],
                    onChanged: (v) =>
                        setStateDialog(() => status = v ?? status)),
                const SizedBox(height: 8),
                Row(children: [
                  const Text('Fill:'),
                  Expanded(
                      child: Slider(
                          value: pct,
                          onChanged: (v) => setStateDialog(() => pct = v))),
                  Text('${(pct * 100).round()}%'),
                ])
              ]),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                ElevatedButton(
                    onPressed: () {
                      final name = nameController.text.trim();
                      if (name.isEmpty) return;
                      setState(() {
                        if (existing == null) {
                          _bins.add(BinItem(
                              id: 'b${DateTime.now().millisecondsSinceEpoch}',
                              name: name,
                              status: status,
                              percentage: pct));
                        } else {
                          existing.name = name;
                          existing.status = status;
                          existing.percentage = pct;
                        }
                      });
                      // replay anim
                      _anim.forward(from: 0.0);
                      Navigator.pop(context);
                    },
                    child: const Text('Save'))
              ],
            );
          });
        });
  }

  void _showBinDetails(BinItem b) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(b.name),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                const Text('Status: ',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                Text(b.status)
              ]),
              const SizedBox(height: 8),
              Row(children: [
                const Text('Fill: ',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                Text('${(b.percentage * 100).round()}%')
              ]),
            ]),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close')),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _addOrEditBin(existing: b);
                  },
                  child: const Text('Edit')),
            ],
          );
        });
  }

  void _removeArea(ActiveArea a) {
    setState(() => _areas.removeWhere((x) => x.id == a.id));
  }

  void _removeBin(BinItem b) {
    setState(() => _bins.removeWhere((x) => x.id == b.id));
  }

  // -------------------- UI --------------------
  @override
  Widget build(BuildContext context) {
    // Pre-built maps needed by painters
    final activeAreasMap = {for (var a in _areas) a.name: a.count};
    final binStatusMap = _binStatusMap;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      endDrawer: _buildDrawer(context),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                // MENU BUTTON MOVED HERE
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black, size: 28),
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // summary row
          Row(children: [
            Expanded(
                child: _summaryCard(
                    icon: Icons.delete,
                    title: 'Active Bins',
                    value:
                        '${_bins.where((b) => b.status == 'Active').length} / ${_bins.length}',
                    color: Colors.green)),
            const SizedBox(width: 10),
            Expanded(
                child: _summaryCard(
                    icon: Icons.warning_amber_rounded,
                    title: 'Alerts Today',
                    value: '5',
                    color: Colors.red)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
                child: _summaryCard(
                    icon: Icons.access_time,
                    title: 'Avg Response',
                    value: '2h 15m',
                    color: Colors.blue)),
            const SizedBox(width: 10),
            Expanded(
                child: _summaryCard(
                    icon: Icons.autorenew,
                    title: 'Collections Done',
                    value: '12',
                    color: Colors.indigo)),
          ]),
          const SizedBox(height: 18),
          // collection trend
          _analyticCard(
            title: 'Collection Trend',
            children: [
              SizedBox(
                height: 160,
                child: AnimatedBuilder(
                    animation: _anim,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: LineChartPainter([
                          DashboardScreen.area1,
                          DashboardScreen.area2,
                          DashboardScreen.area3
                        ], progress: _anim.value),
                      );
                    }),
              ),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                LegendDot(color: Colors.orange, label: 'Area 1'),
                SizedBox(width: 8),
                LegendDot(color: Colors.green, label: 'Area 2'),
                SizedBox(width: 8),
                LegendDot(color: Colors.indigo, label: 'Area 3'),
              ]),
              const Divider(height: 24),
              const Text('Weekly Comparison',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _circularStat(
                    value: '70 kg', label: 'This Week', change: -0.20),
                _circularStat(value: '80 kg', label: 'Last Week', change: 0.20),
              ]),
            ],
          ),
          const SizedBox(height: 14),
          // Most active areas - interactive list
          _analyticCard(
            title: 'Most Active Areas',
            children: [
              const SizedBox(height: 8),
              ..._areas.map((a) => Dismissible(
                    key: ValueKey(a.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) => _removeArea(a),
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(a.name,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: LinearProgressIndicator(
                        value:
                            a.count / (_areas.map((e) => e.count).fold(1, max)),
                        minHeight: 8,
                        color: a.name == 'Creekside'
                            ? Colors.indigo
                            : (a.name == 'Riverside'
                                ? Colors.green
                                : Colors.orange),
                      ),
                      trailing: SizedBox(
                          width: 64,
                          child:
                              Text('${a.count}', textAlign: TextAlign.right)),
                      onTap: () => _addOrEditArea(existing: a),
                    ),
                  )),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                    onPressed: () => _addOrEditArea(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Area')),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Response Time
          _analyticCard(title: 'Response Time Analysis', children: [
            const SizedBox(height: 10),
            SizedBox(
              height: 150,
              child: AnimatedBuilder(
                animation: _anim,
                builder: (context, _) => CustomPaint(
                    painter: BarChartPainter(DashboardScreen.responseTimes,
                        progress: _anim.value)),
              ),
            ),
          ]),
          const SizedBox(height: 14),
          // Bin Status - interactive
          _analyticCard(title: 'Bin Status Breakdown', children: [
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: SizedBox(
                  height: 140,
                  child: AnimatedBuilder(
                    animation: _anim,
                    builder: (context, _) {
                      return CustomPaint(
                        painter:
                            DonutPainter(binStatusMap, progress: _anim.value),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: _bins.map((b) {
                    return GestureDetector(
                      onTap: () => _showBinDetails(b),
                      child: Chip(
                        label:
                            Text('${b.name} ${(b.percentage * 100).round()}%'),
                        avatar: _statusIcon(b.status),
                      ),
                    );
                  }).toList(),
                ),
              )
            ]),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                  onPressed: () => _addOrEditBin(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Bin')),
            )
          ]),
          const SizedBox(height: 14),
          // Environmental Impact (static)
          _analyticCard(title: 'Environmental Impact', children: const [
            SizedBox(height: 8),
            ImpactRow(
                icon: Icons.recycling,
                value: '365 kg',
                label: 'Total Waste Collected'),
            SizedBox(height: 10),
            ImpactRow(icon: Icons.eco, value: '≈18 kg', label: 'CO₂ Reduced'),
            SizedBox(height: 10),
            ImpactRow(
                icon: Icons.alt_route,
                value: '≈-12%',
                label: 'Optimized Routes'),
          ]),
          const SizedBox(height: 24),
          // Bins list for quick management
          _analyticCard(title: 'All Bins', children: [
            ..._bins.map((b) => Dismissible(
                  key: ValueKey(b.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => _removeBin(b),
                  child: ListTile(
                    leading: _statusIcon(b.status),
                    title: Text(b.name),
                    subtitle:
                        Text('${(b.percentage * 100).round()}% • ${b.status}'),
                    onTap: () => _showBinDetails(b),
                  ),
                ))
          ]),
        ]),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMenu(),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Small FAB menu for add options
  void _showAddMenu() {
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return SafeArea(
            child: Wrap(children: [
              ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Add Bin'),
                  onTap: () {
                    Navigator.pop(context);
                    _addOrEditBin();
                  }),
              ListTile(
                  leading: const Icon(Icons.map),
                  title: const Text('Add Area'),
                  onTap: () {
                    Navigator.pop(context);
                    _addOrEditArea();
                  }),
            ]),
          );
        });
  }

  // -------------------- Reused widgets from your original file (simplified) --------------------
  static Widget _analyticCard(
      {required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
              color: Color.fromARGB(20, 0, 0, 0),
              blurRadius: 4,
              offset: Offset(0, 2))
        ],
      ),
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        ...children
      ]),
    );
  }

  static Widget _summaryCard(
      {required IconData icon,
      required String title,
      required String value,
      required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
                color: Color.fromARGB(20, 0, 0, 0),
                blurRadius: 4,
                offset: Offset(0, 2))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.all(6),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black))
        ]),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54))
      ]),
    );
  }

  static Widget _circularStat(
      {required String value, required String label, required double change}) {
    final bool isNegative = change < 0;
    final Color ringColor = isNegative ? Colors.green : Colors.red;
    final IconData icon =
        isNegative ? Icons.arrow_downward : Icons.arrow_upward;
    return Column(children: [
      SizedBox(
        width: 80,
        height: 80,
        child: CustomPaint(
          painter: RingPainter(progress: 0.8, color: ringColor),
          child: Center(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700))),
        ),
      ),
      const SizedBox(height: 8),
      Text(label, style: const TextStyle(fontSize: 13, color: Colors.black)),
      const SizedBox(height: 4),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 14, color: ringColor),
        Text('${(change * 100).abs().toStringAsFixed(0)}% vs last',
            style: TextStyle(
                fontSize: 12, color: ringColor, fontWeight: FontWeight.w600))
      ])
    ]);
  }

  static Widget _statusIcon(String status) {
    switch (status) {
      case 'Active':
        return CircleAvatar(
            backgroundColor: Colors.green.shade100,
            child: const Icon(Icons.check, size: 16, color: Colors.green));
      case 'Full':
        return CircleAvatar(
            backgroundColor: Colors.orange.shade100,
            child: const Icon(Icons.warning, size: 16, color: Colors.orange));
      case 'Offline':
        return CircleAvatar(
            backgroundColor: Colors.red.shade100,
            child: const Icon(Icons.power_off, size: 16, color: Colors.red));
      default:
        return CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            child: const Icon(Icons.build, size: 16, color: Colors.grey));
    }
  }
}

// -------------------- Reusable UI pieces --------------------
class LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const LegendDot({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54))
    ]);
  }
}

class ImpactRow extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const ImpactRow(
      {super.key,
      required this.icon,
      required this.value,
      required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      CircleAvatar(
          radius: 18,
          backgroundColor: Colors.grey.shade100,
          child: Icon(icon, color: Colors.green)),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12))
      ])
    ]);
  }
}

// -------------------- Simple placeholder painters (animated via progress) --------------------
class LineChartPainter extends CustomPainter {
  final List<List<double>> series;
  final double progress; // 0..1
  LineChartPainter(this.series, {this.progress = 1.0});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (var s = 0; s < series.length; s++) {
      paint.color = [Colors.orange, Colors.green, Colors.indigo][s % 3];
      final points = series[s];
      if (points.isEmpty) continue;
      final path = Path();
      final maxVal = points.reduce(max);
      final len = (points.length * progress).clamp(1, points.length).floor();
      for (var i = 0; i < len; i++) {
        final dx = (i / max(1, points.length - 1)) * size.width;
        final dy = size.height - (points[i] / (maxVal + 1)) * size.height;
        if (i == 0) {
          path.moveTo(dx, dy);
        } else {
          path.lineTo(dx, dy);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant LineChartPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.series != series;
}

class BarChartPainter extends CustomPainter {
  final List<double> values;
  final double progress;
  BarChartPainter(this.values, {this.progress = 1.0});
  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.blue.shade300;
    final w = size.width / (values.length * 2);
    final maxVal = values.reduce(max);
    final count = (values.length * progress).clamp(1, values.length).floor();
    for (var i = 0; i < count; i++) {
      final x = i * 2 * w + w / 2;
      final h = (values[i] / (maxVal + 1)) * size.height;
      canvas.drawRect(Rect.fromLTWH(x, size.height - h, w, h), paint);
    }
  }

  @override
  bool shouldRepaint(covariant BarChartPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.values != values;
}

class DonutPainter extends CustomPainter {
  final Map<String, double> data;
  final double progress;
  DonutPainter(this.data, {this.progress = 1.0});
  @override
  void paint(Canvas canvas, Size size) {
    final total = data.values.fold(0.0, (a, b) => a + b);
    double start = -pi / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18;
    final colors = [Colors.green, Colors.orange, Colors.red, Colors.grey];
    var i = 0;
    if (data.isEmpty) {
      // draw neutral ring
      paint.color = Colors.grey.shade200;
      canvas.drawCircle(center, radius - 10, paint);
      return;
    }
    // Animated sweep
    final animatedTotal = total * progress;
    for (var v in data.values) {
      final sweep = total == 0 ? 2 * pi / data.length : (v / total) * 2 * pi;
      final sweepToDraw = sweep * progress;
      paint.color = colors[i % colors.length];
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius - 10),
          start, sweepToDraw, false, paint);
      start += sweep;
      i++;
    }
  }

  @override
  bool shouldRepaint(covariant DonutPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.data != data;
}

class RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  RingPainter({required this.progress, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 8.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - stroke;
    final bg = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final fg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bg);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2,
        2 * pi * progress, false, fg);
  }

  @override
  bool shouldRepaint(covariant RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

// --- DRAWER (BURGER MENU) CONTENT ---
Widget _buildDrawer(BuildContext context) {
  return SizedBox(
    width: 250, // reduced width — adjust this value as needed (e.g. 200)
    child: Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // Drawer Header for branding/user info
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF648DDB),
            ),
            child: Text(
              'User Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),

          // Example Menu Item
          //ListTile(
          //leading: const Icon(Icons.settings),
          //title: const Text('Settings'),
          //onTap: () {
          // Handle settings navigation
          //Navigator.pop(context);
          //},
          //), huwag muna tanggalin ito

          // LOGOUT OPTION
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.black),
            title: const Text('Logout', style: TextStyle(color: Colors.black)),
            onTap: () {
              // Close the drawer before showing the modal
              Navigator.pop(context);
              _showLogoutModal(context);
            },
          ),
        ],
      ),
    ),
  );
}

// --- MODAL FUNCTION (Moved outside build for clean access) ---
void _showLogoutModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Are you sure you want to log out?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "It’s better to stay signed in so you can monitor the creekbins.",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF648DDB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Close modal
                  },
                  child: const Text("No, stay signed in"),
                ),
                const SizedBox(width: 20),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Close modal
                    // 👇 for demo purposes: go to welcome screen
                    // In a real app, this would trigger an authentication service logout
                    Navigator.pushReplacementNamed(context, "/welcome");
                  },
                  child: const Text("Yes, log me out"),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
