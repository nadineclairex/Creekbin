import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Analytics Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Match the background color for uniformity
        scaffoldBackgroundColor: const Color(0xFFF6F8FB),
      ),
      home: const AnalyticScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AnalyticScreen extends StatelessWidget {
  const AnalyticScreen({super.key});

  // Mock data used by painters and widgets
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

  static const Map<String, int> activeAreas = {
    'Creekside': 25,
    'Riverside': 18,
    'Park Zone': 12,
  };

  static const Map<String, double> binStatus = {
    'Active': 0.75,
    'Full': 0.10,
    'Offline': 0.08,
    'Maintenance': 0.07,
  };

  // Set the padding based on observation of the Notifications screen
  static const double _sidePadding = 16.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // Match flat header
        centerTitle: false,
        title: const Text(
          'Analytics',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.black54),
            onPressed: () {},
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // Reduced horizontal padding here to match notifications list style
          padding: const EdgeInsets.symmetric(
              horizontal: _sidePadding, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Summary Cards row (kept 2x2 for space efficiency)
              Row(
                children: [
                  Expanded(
                      child: _summaryCard(
                          icon: Icons.delete,
                          title: 'Active Bins',
                          value: '8 / 10',
                          color: Colors.green)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _summaryCard(
                          icon: Icons.warning_amber_rounded,
                          title: 'Alerts Today',
                          value: '5',
                          color: Colors.red)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
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
                ],
              ),

              const SizedBox(height: 18),

              // 2. Collection Trend + Weekly Comparison (Single Column)
              _analyticCard(
                title: 'Collection Trend',
                children: [
                  SizedBox(
                    height: 160,
                    child: CustomPaint(
                      painter: LineChartPainter([area1, area2, area3]),
                      child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      LegendDot(color: Colors.orange, label: 'Area 1'),
                      SizedBox(width: 8),
                      LegendDot(color: Colors.green, label: 'Area 2'),
                      SizedBox(width: 8),
                      LegendDot(color: Colors.indigo, label: 'Area 3'),
                    ],
                  ),
                  const Divider(height: 24),
                  const Text('Weekly Comparison',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _circularStat(
                          value: '70 kg', label: 'This Week', change: -0.20),
                      _circularStat(
                          value: '80 kg', label: 'Last Week', change: 0.20),
                    ],
                  )
                ],
              ),

              const SizedBox(height: 14),

              // 4. Most Active Areas (Single Column)
              _analyticCard(
                title: 'Most Active Areas',
                children: [
                  const SizedBox(height: 8),
                  ...activeAreas.entries
                      .map((e) => _areaBar(e.key, e.value, activeAreas))
                      .toList(),
                ],
              ),

              const SizedBox(height: 14),

              // 5. Response Time Analysis (Single Column)
              _analyticCard(
                title: 'Response Time Analysis',
                children: [
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 150,
                    child: CustomPaint(
                      painter: BarChartPainter(responseTimes),
                      child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8)),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 14),

              // 6. Bin Status Breakdown (Single Column)
              _analyticCard(
                title: 'Bin Status Breakdown',
                children: [
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Pie Chart
                      Expanded(
                        child: SizedBox(
                          height: 120,
                          child: CustomPaint(
                            painter: DonutPainter(binStatus),
                            size: const Size(120, 120),
                          ),
                        ),
                      ),
                      // Legend
                      Expanded(
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 6,
                          children: binStatus.keys
                              .map((k) => Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _statusColorBox(k),
                                      const SizedBox(width: 6),
                                      Text(k),
                                    ],
                                  ))
                              .toList(),
                        ),
                      )
                    ],
                  )
                ],
              ),

              const SizedBox(height: 14),

              // 7. Environmental Impact (Single Column)
              _analyticCard(
                title: 'Environmental Impact',
                children: const [
                  SizedBox(height: 8),
                  ImpactRow(
                      icon: Icons.recycling,
                      value: '365 kg',
                      label: 'Total Waste Collected'),
                  SizedBox(height: 10),
                  ImpactRow(
                      icon: Icons.eco, value: '≈18 kg', label: 'CO₂ Reduced'),
                  SizedBox(height: 10),
                  ImpactRow(
                      icon: Icons.alt_route,
                      value: '≈-12%',
                      label: 'Optimized Routes'),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      // Add a placeholder bottom navigation bar for completeness
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey.shade600,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Map'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications_active_rounded),
              label: 'Notification'),
        ],
      ),
    );
  }

  // --- Helper Widgets and Functions ---

  // Reusable card container for main sections
  static Widget _analyticCard(
      {required String title, required List<Widget> children}) {
    return Container(
      decoration: _boxDecoration(),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  // Adjusted summary card style
  static Widget _summaryCard(
      {required IconData icon,
      required String title,
      required String value,
      required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
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
                      color: Colors.black)),
            ],
          ),
          const SizedBox(height: 6),
          Text(title,
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }

  static BoxDecoration _boxDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14), // Match notification tile radius
        boxShadow: const [
          // Use a subtle shadow like the image
          BoxShadow(
              color: Color.fromARGB(20, 0, 0, 0),
              blurRadius: 4,
              offset: Offset(0, 2)),
        ],
      );

  static Widget _areaBar(
      String label, int value, Map<String, int> activeAreas) {
    final int maxCount = activeAreas.values.reduce((a, b) => a > b ? a : b);
    final double pct = value / maxCount;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w600))),
          const SizedBox(width: 8),
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                Container(
                    height: 10,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(5))),
                FractionallySizedBox(
                  widthFactor: pct,
                  child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                          color: label == 'Creekside'
                              ? Colors.indigo
                              : (label == 'Riverside'
                                  ? Colors.green
                                  : Colors.orange),
                          borderRadius: BorderRadius.circular(5))),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
              width: 32,
              child: Text(value.toString(),
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  static Widget _statusColorBox(String key) {
    Color c;
    switch (key) {
      case 'Active':
        c = Colors.green;
        break;
      case 'Full':
        c = Colors.orange;
        break;
      case 'Offline':
        c = Colors.redAccent;
        break;
      default:
        c = Colors.grey;
    }
    return Container(
        width: 10,
        height: 10,
        decoration:
            BoxDecoration(color: c, borderRadius: BorderRadius.circular(3)));
  }

  static Widget _circularStat(
      {required String value, required String label, required double change}) {
    final bool isNegative = change < 0;
    final Color ringColor = isNegative ? Colors.green : Colors.red;
    final IconData icon =
        isNegative ? Icons.arrow_downward : Icons.arrow_upward;

    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: CustomPaint(
            painter:
                RingPainter(progress: 0.8, color: ringColor), // Mock progress
            child: Center(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.black)),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: ringColor),
            Text('${(change * 100).abs().toStringAsFixed(0)}% vs last',
                style: TextStyle(
                    fontSize: 12,
                    color: ringColor,
                    fontWeight: FontWeight.w600)),
          ],
        )
      ],
    );
  }
}

class LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const LegendDot({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}

// Updated RingPainter for better customization and visual match
class RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  RingPainter({this.progress = 0.7, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    const strokeWidth = 8.0;

    // Background circle (for inner white circle)
    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Gray track
    final trackPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius - (strokeWidth / 2), trackPaint);

    // Progress arc
    final ringPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double sweepAngle = 2 * pi * progress;
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - (strokeWidth / 2)),
        -pi / 2,
        sweepAngle,
        false,
        ringPaint);
  }

  @override
  bool shouldRepaint(covariant RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

/// Simple line chart painter for three series
class LineChartPainter extends CustomPainter {
  final List<List<double>> series;
  LineChartPainter(this.series);

  final List<Color> lineColors = [Colors.orange, Colors.green, Colors.indigo];

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // compute max
    double maxVal = 1;
    for (var s in series) {
      for (var v in s) if (v > maxVal) maxVal = v;
    }

    // Draw Y-axis guide lines
    final axis = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.0;
    const numLines = 4;
    for (int i = 0; i <= numLines; i++) {
      final y = h * (i / numLines);
      canvas.drawLine(Offset(0, y), Offset(w, y), axis);
    }

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    for (int s = 0; s < series.length; s++) {
      paint.color = lineColors[s % lineColors.length];
      final data = series[s];
      final path = Path();
      for (int i = 0; i < data.length; i++) {
        final dx = (i / (data.length - 1)) * w;
        final dy = h - (data[i] / maxVal) * h;
        if (i == 0)
          path.moveTo(dx, dy);
        else
          path.lineTo(dx, dy);
      }
      canvas.drawPath(path, paint);

      // draw little points
      final dot = Paint()
        ..style = PaintingStyle.fill
        ..color = paint.color;
      for (int i = 0; i < data.length; i++) {
        final dx = (i / (data.length - 1)) * w;
        final dy = h - (data[i] / maxVal) * h;
        canvas.drawCircle(Offset(dx, dy), 3, dot);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Simple vertical bars painter (response times)
class BarChartPainter extends CustomPainter {
  final List<double> values;
  BarChartPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double threshold = 3.0; // Highlight bars exceeding 3 hours
    final double maxVal = values.reduce(max);
    final int n = values.length;
    final double barWidth = w / (n * 1.6);

    // Draw threshold line (dotted)
    final double yThreshold = h - (threshold / maxVal) * (h - 20);
    final paintThreshold = Paint()
      ..color = Colors.red.shade300
      ..strokeWidth = 1.5;
    const dash = 6.0;
    double startX = 0;
    while (startX < w) {
      canvas.drawLine(Offset(startX, yThreshold),
          Offset(min(w, startX + dash), yThreshold), paintThreshold);
      startX += dash * 2;
    }

    // Draw Average Line (dashed gray)
    final avg = values.reduce((a, b) => a + b) / values.length;
    final double yAvg = h - (avg / maxVal) * (h - 20);
    final paintAvg = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;
    double startXAvg = 0;
    while (startXAvg < w) {
      canvas.drawLine(Offset(startXAvg, yAvg),
          Offset(min(w, startXAvg + dash), yAvg), paintAvg);
      startXAvg += dash * 2;
    }

    // Draw Bars
    for (int i = 0; i < n; i++) {
      final double x = i * (barWidth * 1.4) + 6;
      final double val = values[i];
      final double barH = (val / maxVal) * (h - 20);

      final barPaint = Paint()..style = PaintingStyle.fill;
      // Highlight bar if it exceeds the threshold
      barPaint.color =
          val > threshold ? Colors.redAccent.shade400 : Colors.indigo;

      final rect = Rect.fromLTWH(x, h - barH, barWidth, barH);
      final r = RRect.fromRectAndRadius(rect, const Radius.circular(6));
      canvas.drawRRect(r, barPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Donut chart painter
class DonutPainter extends CustomPainter {
  final Map<String, double> slices;
  DonutPainter(this.slices);

  final List<Color> colors = [
    Colors.green,
    Colors.orange,
    Colors.redAccent,
    Colors.grey
  ];
  static const double strokeWidth = 20.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    double start = -pi / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final vals = slices.values.toList();
    double total = vals.fold(0.0, (a, b) => a + b);

    for (int i = 0; i < vals.length; i++) {
      final sweep = (vals[i] / total) * pi * 2;
      paint.color = colors[i % colors.length];
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    }
    // center hole
    final hole = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius - strokeWidth + 6, hole);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
    return Row(
      children: [
        Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Colors.green)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ])
      ],
    );
  }
}
