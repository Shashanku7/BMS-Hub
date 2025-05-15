import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PlacementStatsPage extends StatefulWidget {
  const PlacementStatsPage({super.key});

  @override
  _PlacementStatsPageState createState() => _PlacementStatsPageState();
}

class _PlacementStatsPageState extends State<PlacementStatsPage> {
  String selectedYear = '2024';
  String selectedDepartment = 'CSE';

  final List<String> years = ['2024', '2023', '2022'];
  final List<String> departments = ['CSE', 'AIML', 'ECE', 'ME', 'EEE', 'Civil'];

  final Map<String, Map<String, Map<String, dynamic>>> placementData = {
    'CSE': {
      '2024': {'students': 812, 'avgPackage': 12, 'highPackage': 42, 'topRecruiter': 'Google'},
      '2023': {'students': 750, 'avgPackage': 10, 'highPackage': 40, 'topRecruiter': 'Amazon'},
      '2022': {'students': 700, 'avgPackage': 8, 'highPackage': 35, 'topRecruiter': 'Microsoft'},
    },
    'AIML': {
      '2024': {'students': 600, 'avgPackage': 10, 'highPackage': 35, 'topRecruiter': 'Facebook'},
      '2023': {'students': 550, 'avgPackage': 9, 'highPackage': 32, 'topRecruiter': 'Amazon'},
      '2022': {'students': 500, 'avgPackage': 7, 'highPackage': 30, 'topRecruiter': 'IBM'},
    },
    'ECE': {
      '2024': {'students': 500, 'avgPackage': 9, 'highPackage': 32, 'topRecruiter': 'Cisco'},
      '2023': {'students': 480, 'avgPackage': 8, 'highPackage': 30, 'topRecruiter': 'Intel'},
      '2022': {'students': 450, 'avgPackage': 7, 'highPackage': 28, 'topRecruiter': 'Qualcomm'},
    },
    'ME': {
      '2024': {'students': 300, 'avgPackage': 8, 'highPackage': 28, 'topRecruiter': 'Bosch'},
      '2023': {'students': 280, 'avgPackage': 6, 'highPackage': 25, 'topRecruiter': 'GE'},
      '2022': {'students': 250, 'avgPackage': 5, 'highPackage': 22, 'topRecruiter': 'Tata Motors'},
    },
    'EEE': {
      '2024': {'students': 350, 'avgPackage': 9, 'highPackage': 30, 'topRecruiter': 'ABB'},
      '2023': {'students': 320, 'avgPackage': 8, 'highPackage': 28, 'topRecruiter': 'Siemens'},
      '2022': {'students': 300, 'avgPackage': 7, 'highPackage': 25, 'topRecruiter': 'Schneider'},
    },
    'Civil': {
      '2024': {'students': 200, 'avgPackage': 6, 'highPackage': 20, 'topRecruiter': 'L&T'},
      '2023': {'students': 180, 'avgPackage': 5, 'highPackage': 18, 'topRecruiter': 'Shapoorji'},
      '2022': {'students': 150, 'avgPackage': 4, 'highPackage': 15, 'topRecruiter': 'DLF'},
    },
  };

  @override
  Widget build(BuildContext context) {
    final stats = placementData[selectedDepartment]![selectedYear]!;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Placement Stats"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title
              Container(
                width: double.infinity,
                color: Colors.blue,
                padding: const EdgeInsets.all(16.0),
                child: const Text(
                  "PLACEMENT STATISTICS",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              // Dynamic Statistics Overview
              Wrap(
                alignment: WrapAlignment.spaceEvenly,
                spacing: 20.0,
                runSpacing: 20.0,
                children: [
                  _buildStatCard("${stats['students']}", "Students Placed", Icons.group),
                  _buildStatCard("${stats['avgPackage']} LPA", "Average Package", Icons.bar_chart),
                  _buildStatCard("${stats['highPackage']} LPA", "Highest Package", Icons.trending_up),
                  _buildStatCard("${stats['topRecruiter']}", "Top Recruiter", Icons.business),
                ],
              ),
              const SizedBox(height: 20),
              // Dropdowns
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDropdown(
                    "Year",
                    years,
                    selectedYear,
                        (value) {
                      setState(() {
                        selectedYear = value!;
                      });
                    },
                  ),
                  _buildDropdown(
                    "Department",
                    departments,
                    selectedDepartment,
                        (value) {
                      setState(() {
                        selectedDepartment = value!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Bar Chart
              SizedBox(
                height: 300,
                child: BarChart(
                  BarChartData(
                    barGroups: _generateBarGroups(),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Text(
                                value.toInt().toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          },
                          reservedSize: 40,
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            switch (value.toInt()) {
                              case 0:
                                return const Text("2022",
                                    style: TextStyle(color: Colors.white));
                              case 1:
                                return const Text("2023",
                                    style: TextStyle(color: Colors.white));
                              case 2:
                                return const Text("2024",
                                    style: TextStyle(color: Colors.white));
                              default:
                                return const Text("");
                            }
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(
                      show: false, // Removed vertical grid lines
                    ),
                    barTouchData: BarTouchData(enabled: false), // Disabled touch interactions
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // The Download Button has been removed!
            ],
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups() {
    final data = placementData[selectedDepartment]!;
    return [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: data['2022']!['students'].toDouble(),
            width: 20,
            color: Colors.blue,
          ),
        ],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            toY: data['2023']!['students'].toDouble(),
            width: 20,
            color: Colors.blue,
          ),
        ],
      ),
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(
            toY: data['2024']!['students'].toDouble(),
            width: 20,
            color: Colors.blue,
          ),
        ],
      ),
    ];
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.blueGrey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue, size: 40),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
      String label,
      List<String> items,
      String selectedValue,
      ValueChanged<String?>? onChanged,
      ) {
    return DropdownButton<String>(
      value: selectedValue,
      dropdownColor: Colors.grey[900],
      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: const TextStyle(color: Colors.white),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}