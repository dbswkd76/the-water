import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class TideChart extends StatelessWidget {
  final Map<String, dynamic> tideData;
  final ScrollController scrollController;

  const TideChart({
    Key? key,
    required this.tideData,
    required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 타이드 데이터 처리
    List<FlSpot> spots = [];
    List<String> xLabels = [];

    // 데이터 추출
    final List<dynamic> tideInfo = tideData['tideInfo'];

    // 시간별 데이터 정리
    for (var dayData in tideInfo) {
      final List<dynamic> dailyData = dayData['조석데이터'];

      for (var point in dailyData) {
        final double level = double.parse(point['tph_level']);
        final DateTime time = DateTime.parse(point['tph_time']);

        // X축 값은 데이터 포인트의 인덱스 사용
        final index = spots.length.toDouble();
        spots.add(FlSpot(index, level));
        xLabels.add(DateFormat('HH:mm').format(time));
      }
    }

    // 차트 너비 계산 (각 포인트당 60 픽셀)
    double chartWidth = 31 * 60;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            7, // 예: 0 ~ 300까지 50 단위로 표시
            (index) {
              final value = 600 - index * 100;
              return SizedBox(
                width: 50,
                height: 30, // 간격 조정
                child: Center(
                  child: Text(
                    '$value m',
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.right,
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: scrollController, // 공유 스크롤 컨트롤러
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            child: Container(
              width: chartWidth,
              padding: const EdgeInsets.only(top: 20, right: 10),
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: spots.length - 1,
                  minY: 0,
                  maxY: 600, // 최대 타이드 레벨 기준으로 조정
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final index = spot.x.toInt();
                          return LineTooltipItem(
                            '${xLabels[index]}\n${spot.y.toStringAsFixed(1)}m',
                            const TextStyle(color: Colors.white),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 100,
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value < 0 || value >= xLabels.length)
                            return const Text('');
                          return Text(
                            xLabels[value.toInt()],
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                        interval: 1,
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      bottom: BorderSide(color: Colors.black26),
                      left: BorderSide(color: Colors.black26),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 2,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
