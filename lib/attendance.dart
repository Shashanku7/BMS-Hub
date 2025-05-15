import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// --- Subject Model ---
class Subject {
  String name; // MADE MUTABLE for editing
  int present;
  int total;
  List<String> days;
  Map<String, List<String>> attendanceHistory = {};

  Subject({
    required this.name,
    required this.present,
    required this.total,
    required this.days,
  });

  double get attendancePercentage => total == 0 ? 0 : (present / total) * 100;
  int get absent => total - present;

  void setStatusForDate(String dateStr, int classIndex, String? newStatus) {
    attendanceHistory.putIfAbsent(dateStr, () => []);
    while (attendanceHistory[dateStr]!.length <= classIndex) {
      attendanceHistory[dateStr]!.add("No Class");
    }
    final prev = attendanceHistory[dateStr]![classIndex];
    if (prev == newStatus) return;
    if (prev == "Present") {
      present--;
      total--;
    } else if (prev == "Absent") {
      total--;
    }
    if (newStatus == "Present") {
      present++;
      total++;
    } else if (newStatus == "Absent") {
      total++;
    }
    attendanceHistory[dateStr]![classIndex] = newStatus ?? "No Class";
  }

  void addExtraClass(String dateStr) {
    attendanceHistory.putIfAbsent(dateStr, () => []);
    attendanceHistory[dateStr]!.add("No Class");
  }

  int get bunkableClassesToMaintain85 {
    if (total == 0) return 0;
    int x = 0, maxMiss = 0;
    while (true) {
      double perc = (present / (total + x)) * 100;
      if (perc < 85) break;
      maxMiss = x;
      x++;
    }
    return maxMiss;
  }

  int get classesToAttendToReach85 {
    if (total == 0 || attendancePercentage >= 85) return 0;
    int x = 0, needed = 0;
    while (true) {
      x++;
      double perc = ((present + x) / (total + x)) * 100;
      if (perc >= 85) {
        needed = x;
        break;
      }
      if (x > 1000) break;
    }
    return needed;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await NotificationService().init();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AttendanceTrackerPage(),
  ));
}

// --- Notification Service ---
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Request notification permission (Android 13+)
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
  }

  Future<void> scheduleDailyNotification(TimeOfDay time) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Attendance Reminder',
      'Don\'t forget to mark your attendance for today!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'attendance_reminder_channel',
          'Attendance Reminders',
          channelDescription: 'Reminds you to mark attendance daily',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // updated
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}

extension on AndroidFlutterLocalNotificationsPlugin? {
  requestPermission() {}
}

// --- Main Page ---
class AttendanceTrackerPage extends StatefulWidget {
  const AttendanceTrackerPage({super.key});
  @override
  _AttendanceTrackerPageState createState() => _AttendanceTrackerPageState();
}

class _AttendanceTrackerPageState extends State<AttendanceTrackerPage> {
  final List<Subject> subjects = [];
  int _selectedIndex = 0;
  TimeOfDay? _reminderTime;

  tz.TZDateTime getBangaloreNow() {
    final bangalore = tz.getLocation('Asia/Kolkata');
    return tz.TZDateTime.now(bangalore);
  }

  String getCurrentDay() => DateFormat('EEEE').format(getBangaloreNow());
  String getCurrentDate() => DateFormat('MMMM d, yyyy').format(getBangaloreNow());

  List<Subject> get todaySubjects {
    final today = getCurrentDay();
    final now = getBangaloreNow();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    return subjects.where((subj) {
      final scheduled = subj.days.contains(today);
      final added = (subj.attendanceHistory[todayStr]?.isNotEmpty ?? false);
      return scheduled || added;
    }).toList();
  }

  void showAddSubjectDialog() {
    final formKey = GlobalKey<FormState>();
    String subjectName = '';
    List<String> selectedDays = [];
    int alreadyPresent = 0;
    int alreadyAbsent = 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: const Color(0xFF181C20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              child: Container(
                padding: const EdgeInsets.only(bottom: 10),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 70,
                            decoration: const BoxDecoration(
                              borderRadius:
                              BorderRadius.vertical(top: Radius.circular(18)),
                              gradient: LinearGradient(
                                colors: [Color(0xFF6DB3F2), Color(0xFF1E69DE)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white, size: 28),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Text(
                                "Add Subject",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4)
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // All form fields now INSIDE padding
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 20),
                              // Subject Name
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Color(0xFF399BE7), width: 1.3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: TextFormField(
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 18),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    prefixIcon: Icon(Icons.title,
                                        color: Colors.white60, size: 26),
                                    hintText: "Subject Name",
                                    hintStyle: TextStyle(
                                        color: Colors.white60, fontSize: 18),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 18),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "Please enter a subject name";
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    subjectName = value!.trim();
                                  },
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Padding(
                                padding:
                                EdgeInsets.only(left: 2.0, top: 2, bottom: 4),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Better to keep a short name",
                                    style: TextStyle(
                                        color: Colors.white54, fontSize: 14),
                                  ),
                                ),
                              ),
                              // Class Days
                              Container(
                                margin:
                                const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Color(0xFF399BE7), width: 1.3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Class Days",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 8.0,
                                      runSpacing: 8.0,
                                      children: [
                                        for (final day in [
                                          "Monday",
                                          "Tuesday",
                                          "Wednesday",
                                          "Thursday",
                                          "Friday",
                                          "Saturday",
                                          "Sunday"
                                        ])
                                          ChoiceChip(
                                            label: Text(day,
                                                style: TextStyle(
                                                  color: selectedDays
                                                      .contains(day)
                                                      ? Colors.white
                                                      : Colors.white70,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                )),
                                            selected: selectedDays.contains(day),
                                            selectedColor: Colors.blue[700],
                                            backgroundColor:
                                            const Color(0xFF22262B),
                                            side: BorderSide(
                                                color: Colors.blue[400]!),
                                            onSelected: (isSelected) {
                                              setDialogState(() {
                                                if (isSelected &&
                                                    !selectedDays
                                                        .contains(day)) {
                                                  selectedDays.add(day);
                                                } else if (!isSelected &&
                                                    selectedDays
                                                        .contains(day)) {
                                                  selectedDays.remove(day);
                                                }
                                              });
                                            },
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 7),
                                    const Text(
                                      "You can edit class days anytime",
                                      style: TextStyle(
                                          color: Colors.white54, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              // Already Present
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Color(0xFF399BE7), width: 1.3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                margin: const EdgeInsets.only(top: 10),
                                child: TextFormField(
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 17),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    prefixIcon: Icon(Icons.check_circle_outline,
                                        color: Colors.white54),
                                    hintText: "Already Present",
                                    hintStyle: TextStyle(
                                        color: Colors.white60, fontSize: 16),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 18),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty)
                                      return "Enter number of classes present";
                                    if (int.tryParse(value) == null)
                                      return "Enter a valid number";
                                    return null;
                                  },
                                  onSaved: (value) {
                                    alreadyPresent = int.parse(value!);
                                  },
                                ),
                              ),
                              // Already Absent
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Color(0xFF399BE7), width: 1.3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                margin: const EdgeInsets.only(top: 14),
                                child: TextFormField(
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 17),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    prefixIcon: Icon(Icons.cancel_outlined,
                                        color: Colors.white54),
                                    hintText: "Already Absent",
                                    hintStyle: TextStyle(
                                        color: Colors.white60, fontSize: 16),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 18),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty)
                                      return "Enter number of classes absent";
                                    if (int.tryParse(value) == null)
                                      return "Enter a valid number";
                                    return null;
                                  },
                                  onSaved: (value) {
                                    alreadyAbsent = int.parse(value!);
                                  },
                                ),
                              ),
                              const SizedBox(height: 22),
                              Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.blue[200],
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 48, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32),
                                      side: BorderSide(
                                          color: Colors.blue[400]!, width: 1.5),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (formKey.currentState!.validate()) {
                                      if (selectedDays.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  "Please select at least one class day")),
                                        );
                                        return;
                                      }
                                      formKey.currentState!.save();
                                      setState(() {
                                        subjects.add(
                                          Subject(
                                            name: subjectName,
                                            present: alreadyPresent,
                                            total: alreadyPresent + alreadyAbsent,
                                            days: List<String>.from(selectedDays),
                                          ),
                                        );
                                      });
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: const Text(
                                    "Submit",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void openSubjectCalendar(Subject subject) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubjectCalendarPage(
          subject: subject,
          getBangaloreNow: getBangaloreNow,
          allSubjects: subjects,
        ),
      ),
    ).then((_) => setState(() {}));
  }

  void _showClassesTabSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181C20),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    icon: const Icon(Icons.add,color: Colors.white),
                    label: const Text("Add Subject", style: TextStyle(fontSize: 18)),
                    onPressed: () {
                      Navigator.pop(context);
                      showAddSubjectDialog();
                    },
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    icon: const Icon(Icons.schedule,color: Colors.white),
                    label: const Text("View Schedule", style: TextStyle(fontSize: 18)),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SchedulePage(subjects: subjects)),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    icon: const Icon(Icons.alarm,color: Colors.white),
                    label: const Text("Set Reminder", style: TextStyle(fontSize: 18)),
                    onPressed: () async {
                      Navigator.pop(context);
                      await _showSetReminderDialog();
                    },
                  ),
                  const SizedBox(height: 18),
                  // --- EDIT SCHEDULE BUTTON HERE ---
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    icon: const Icon(Icons.edit,color: Colors.white),
                    label: const Text("Edit Schedule", style: TextStyle(fontSize: 18)),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditSchedulePage(
                            subjects: subjects,
                            onUpdate: () => setState(() {}),
                          ),
                        ),
                      );
                    },
                  ),
                  if (_reminderTime != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Text(
                        "Current daily reminder: ${_reminderTime != null ? _reminderTime!.format(context) : ""}",
                        style: const TextStyle(color: Colors.orangeAccent, fontSize: 15),
                      ),
                    ),
                  const SizedBox(height: 24),
                  const Divider(color: Colors.white24, thickness: 1),
                  const SizedBox(height: 14),
                  Text(
                    "Your Subjects",
                    style: TextStyle(color: Colors.blue[200], fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  ...subjects.isEmpty
                      ? [Center(child: Text("No subjects added!", style: TextStyle(color: Colors.white54, fontSize: 16)))]
                      : subjects.map((subject) => Card(
                    color: Colors.grey[900],
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    child: ListTile(
                      title: Text(subject.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        "Present: ${subject.present}, Absent: ${subject.absent}, Total: ${subject.total}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: const Icon(Icons.calendar_today, color: Colors.blue),
                      onTap: () {
                        Navigator.pop(context);
                        openSubjectCalendar(subject);
                      },
                    ),
                  )),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
      isScrollControlled: true,
    );
  }

  Future<void> _showSetReminderDialog() async {
    TimeOfDay? selectedTime = _reminderTime ?? TimeOfDay.now();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF181C20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "Set Daily Attendance Reminder",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.access_time, color: Colors.blue),
                title: Text(
                  selectedTime != null
                      ? selectedTime!.format(context)
                      : "Choose Time",
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: selectedTime ?? TimeOfDay.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedTime = picked;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: (selectedTime != null)
                  ? () async {
                Navigator.pop(context);
                _reminderTime = selectedTime;
                await NotificationService().cancelAll();
                await NotificationService()
                    .scheduleDailyNotification(selectedTime!);
                if (!mounted) return;
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Daily reminder set for ${selectedTime!.format(context)}",
                    ),
                    backgroundColor: Colors.blue,
                  ),
                );
              }
                  : null,
              child: const Text("Set Reminder"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = getCurrentDate();
    final String formattedDay = getCurrentDay();

    Widget mainContent = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            color: Colors.blue,
            padding: const EdgeInsets.all(16.0),
            child: const Text(
              "ATTENDANCE TRACKER",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$formattedDate\n$formattedDay",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              ElevatedButton.icon(
                onPressed: _showAddClassToTodayDialog,
                icon: const Icon(Icons.add),
                label: const Text("Add a Class"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Builder(
              builder: (context) {
                if (subjects.isEmpty) {
                  return Center(
                    child: Text(
                      "Add a class to begin!",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  );
                }
                if (todaySubjects.isEmpty) {
                  return Center(
                    child: Text(
                      "No classes for today.",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  );
                }
                final now = getBangaloreNow();
                final todayStr = DateFormat('yyyy-MM-dd').format(now);
                return ListView.builder(
                  itemCount: todaySubjects.length,
                  itemBuilder: (context, index) {
                    final subject = todaySubjects[index];
                    final statuses = subject.attendanceHistory[todayStr] ??
                        (subject.days.contains(getCurrentDay())
                            ? ["No Class"]
                            : []);
                    return GestureDetector(
                      onTap: () => openSubjectCalendar(subject),
                      child: Card(
                        color: Colors.grey[900],
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subject.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...List.generate(statuses.length, (classIdx) {
                                String classStatus = statuses[classIdx];
                                return Padding(
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Class ${classIdx + 1}: ",
                                        style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 16),
                                      ),
                                      _statusButton(
                                        subject,
                                        todayStr,
                                        classIdx,
                                        "Present",
                                        classStatus,
                                      ),
                                      const SizedBox(width: 8),
                                      _statusButton(
                                        subject,
                                        todayStr,
                                        classIdx,
                                        "Absent",
                                        classStatus,
                                      ),
                                      const SizedBox(width: 8),
                                      _statusButton(
                                        subject,
                                        todayStr,
                                        classIdx,
                                        "No Class",
                                        classStatus,
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Attendance: ${subject.present}/${subject.total}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    "${subject.attendancePercentage.toStringAsFixed(0)}%",
                                    style: TextStyle(
                                      color: subject.attendancePercentage < 85
                                          ? Colors.red
                                          : Colors.green,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance Tracker"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: mainContent,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: (index) {
          // Only Home and Classes (remove History)
          if (index == 1) {
            _showClassesTabSheet();
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Classes",
          ),
        ],
      ),
    );
  }

  void _showAddClassToTodayDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Add Class For Subject",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            ...subjects.map((subj) => ListTile(
              title: Text(subj.name,
                  style: const TextStyle(color: Colors.white)),
              onTap: () {
                String dateStr =
                DateFormat('yyyy-MM-dd').format(getBangaloreNow());
                setState(() {
                  subj.addExtraClass(dateStr);
                });
                Navigator.pop(context);
              },
            )),
          ],
        );
      },
    );
  }

  Widget _statusButton(
      Subject subject,
      String dateStr,
      int classIndex,
      String status,
      String currentStatus,
      ) {
    bool selected = status == currentStatus;
    Color selectedColor;
    if (status == "Present") selectedColor = Colors.green;
    else if (status == "Absent") selectedColor = Colors.red;
    else selectedColor = Colors.orange;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3.0),
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: selected ? selectedColor : Colors.grey[800],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            minimumSize: const Size(0, 42),
            textStyle: TextStyle(
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              fontSize: 15,
            ),
          ),
          onPressed: () {
            setState(() {
              subject.setStatusForDate(dateStr, classIndex, status);
            });
          },
          child: Text(status),
        ),
      ),
    );
  }
}

// --- Edit Schedule Page ---
class EditSchedulePage extends StatefulWidget {
  final List<Subject> subjects;
  final VoidCallback onUpdate;
  const EditSchedulePage({super.key, required this.subjects, required this.onUpdate});

  @override
  State<EditSchedulePage> createState() => _EditSchedulePageState();
}

class _EditSchedulePageState extends State<EditSchedulePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Schedule"), backgroundColor: Colors.black),
      backgroundColor: Colors.black,
      body: ListView.builder(
        itemCount: widget.subjects.length,
        itemBuilder: (context, index) {
          final subj = widget.subjects[index];
          return Card(
            color: Colors.grey[900],
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: ListTile(
              title: Text(subj.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(
                "Days: ${subj.days.join(', ')}",
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: Colors.black,
                      title: const Text("Delete Subject", style: TextStyle(color: Colors.white)),
                      content: const Text("Are you sure you want to delete this subject?", style: TextStyle(color: Colors.white70)),
                      actions: [
                        TextButton(
                          child: const Text("Cancel"),
                          onPressed: () => Navigator.pop(context),
                        ),
                        TextButton(
                          child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
                          onPressed: () {
                            setState(() {
                              widget.subjects.removeAt(index);
                            });
                            widget.onUpdate();
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              onTap: () async {
                await showDialog(
                  context: context,
                  builder: (ctx) => EditSubjectDialog(
                    subject: subj,
                    onSave: () => setState(() {}),
                  ),
                );
                widget.onUpdate();
              },
            ),
          );
        },
      ),
    );
  }
}

// --- Edit Subject Dialog ---
class EditSubjectDialog extends StatefulWidget {
  final Subject subject;
  final VoidCallback onSave;
  const EditSubjectDialog({super.key, required this.subject, required this.onSave});

  @override
  State<EditSubjectDialog> createState() => _EditSubjectDialogState();
}

class _EditSubjectDialogState extends State<EditSubjectDialog> {
  late TextEditingController nameController;
  late List<String> selectedDays;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.subject.name);
    selectedDays = List<String>.from(widget.subject.days);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF181C20),
      title: const Text("Edit Subject", style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Subject Name",
                labelStyle: TextStyle(color: Colors.white60),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Class Days", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            Wrap(
              spacing: 8.0,
              children: [
                for (final day in [
                  "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
                ])
                  ChoiceChip(
                    label: Text(day, style: TextStyle(
                      color: selectedDays.contains(day) ? Colors.white : Colors.white70,
                    )),
                    selected: selectedDays.contains(day),
                    selectedColor: Colors.blue[700],
                    backgroundColor: const Color(0xFF22262B),
                    onSelected: (isSelected) {
                      setState(() {
                        if (isSelected && !selectedDays.contains(day)) selectedDays.add(day);
                        else if (!isSelected && selectedDays.contains(day)) selectedDays.remove(day);
                      });
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            widget.subject.name = nameController.text.trim();
            widget.subject.days
              ..clear()
              ..addAll(selectedDays);
            widget.onSave();
            Navigator.pop(context);
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}

// --- Subject Calendar Page ---
class SubjectCalendarPage extends StatefulWidget {
  final Subject subject;
  final tz.TZDateTime Function() getBangaloreNow;
  final List<Subject> allSubjects;

  const SubjectCalendarPage({
    super.key,
    required this.subject,
    required this.getBangaloreNow,
    required this.allSubjects,
  });

  @override
  State<SubjectCalendarPage> createState() => _SubjectCalendarPageState();
}

class _SubjectCalendarPageState extends State<SubjectCalendarPage> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
  }

  List<String> _getStatusesForDay(DateTime day, Subject subject) {
    String dateStr = DateFormat('yyyy-MM-dd').format(day);
    return subject.attendanceHistory[dateStr] ?? [];
  }

  List<Color> _getMarkerColorsForDay(DateTime day, Subject subject) {
    final statuses = _getStatusesForDay(day, subject);
    return statuses.map((status) {
      if (status == "Present") return Colors.green;
      if (status == "Absent") return Colors.red;
      return Colors.orange;
    }).toList();
  }

  void _showEditDialog(DateTime day) {
    String dateStr = DateFormat('yyyy-MM-dd').format(day);
    final subject = widget.subject;
    if ((subject.attendanceHistory[dateStr] ?? []).isEmpty) {
      subject.addExtraClass(dateStr);
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF232323),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final statuses = subject.attendanceHistory[dateStr] ?? [];
        return Padding(
          padding: EdgeInsets.only(
              left: 18, right: 18, top: 18, bottom: MediaQuery.of(context).viewInsets.bottom + 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat('EEE, MMM d').format(day),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              ...List.generate(statuses.length, (i) {
                final status = statuses[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        "Class ${i + 1}:",
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      _statusButton(subject, dateStr, i, "Present", status),
                      const SizedBox(width: 8),
                      _statusButton(subject, dateStr, i, "Absent", status),
                      const SizedBox(width: 8),
                      _statusButton(subject, dateStr, i, "No Class", status),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        subject.addExtraClass(dateStr);
                      });
                      Navigator.pop(context);
                      Future.delayed(const Duration(milliseconds: 200), () {
                        _showEditDialog(day);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text("Add Class"),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Done", style: TextStyle(color: Colors.white70)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ).whenComplete(() => setState(() {}));
  }

  Widget _statusButton(
      Subject subject,
      String dateStr,
      int classIndex,
      String status,
      String currentStatus,
      ) {
    bool selected = status == currentStatus;
    Color selectedColor;
    if (status == "Present") selectedColor = Colors.green;
    else if (status == "Absent") selectedColor = Colors.red;
    else selectedColor = Colors.orange;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3.0),
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: selected ? selectedColor : Colors.grey[800],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            minimumSize: const Size(0, 42),
            textStyle: TextStyle(
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              fontSize: 15,
            ),
          ),
          onPressed: () {
            setState(() {
              subject.setStatusForDate(dateStr, classIndex, status);
            });
          },
          child: Text(status),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subject = widget.subject;
    final attendance = subject.attendancePercentage;
    final bunk85 = subject.bunkableClassesToMaintain85;
    final attend85 = subject.classesToAttendToReach85;

    Widget statsMessage;
    if (attendance >= 85) {
      statsMessage = Text(
        "You can bunk next $bunk85 classes to stay at 85%",
        style: TextStyle(color: Colors.white70, fontSize: 14),
      );
    } else {
      statsMessage = Text(
        "You need to attend next $attend85 classes to reach 85%",
        style: TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.bold),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(subject.name),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Card: stats
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade300, Colors.blue.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  children: [
                    SizedBox(
                      height: 78,
                      width: 78,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: attendance / 100,
                            strokeWidth: 7,
                            backgroundColor: Colors.white24,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                attendance >= 85 ? Colors.limeAccent : Colors.redAccent),
                          ),
                          Center(
                            child: Text(
                              "${attendance.toStringAsFixed(0)}%",
                              style: TextStyle(
                                  color: attendance >= 85 ? Colors.white : Colors.redAccent,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Present: ${subject.present}",
                            style: const TextStyle(color: Colors.white, fontSize: 16)),
                        const SizedBox(width: 14),
                        Text("Absent: ${subject.absent}",
                            style: const TextStyle(color: Colors.white, fontSize: 16)),
                        const SizedBox(width: 14),
                        Text("Total: ${subject.total}",
                            style: const TextStyle(color: Colors.white, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    statsMessage,
                  ],
                ),
              ),
            ),

            // Calendar
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TableCalendar(
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekendStyle: TextStyle(color: Colors.white),
                  weekdayStyle: TextStyle(color: Colors.white),
                ),
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2100, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: CalendarFormat.month,
                calendarStyle: CalendarStyle(
                  defaultTextStyle: const TextStyle(color: Colors.white),
                  weekendTextStyle: const TextStyle(color: Colors.white),
                  outsideTextStyle: const TextStyle(color: Colors.white),
                  selectedDecoration: BoxDecoration(
                    color: const Color(0x2DFFFFFF), // 18% opacity
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.blue.shade300,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  markersAlignment: Alignment.bottomCenter,
                  markerMargin: const EdgeInsets.only(bottom: 2),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white),
                  rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.white),
                  titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  decoration: const BoxDecoration(color: Colors.transparent),
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _showEditDialog(selectedDay);
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    final statusColors = _getMarkerColorsForDay(date, subject);
                    if (statusColors.isEmpty) return null;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(statusColors.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1.5),
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: statusColors[i],
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Schedule Page ---
class SchedulePage extends StatelessWidget {
  final List<Subject> subjects;
  const SchedulePage({super.key, required this.subjects});
  @override
  Widget build(BuildContext context) {
    Map<String, List<Subject>> dayToSubjects = {
      for (var day in [
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday",
        "Sunday"
      ])
        day: []
    };
    for (final subj in subjects) {
      for (final day in subj.days) {
        dayToSubjects[day]?.add(subj);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Full Schedule"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: dayToSubjects.entries.map((entry) {
          final day = entry.key;
          final subs = entry.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                day,
                style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              const SizedBox(height: 6),
              if (subs.isEmpty)
                const Text(
                  "No classes scheduled.",
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ...subs.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "• ${s.name}",
                  style: const TextStyle(
                      color: Colors.white, fontSize: 16),
                ),
              )),
              const SizedBox(height: 18),
            ],
          );
        }).toList(),
      ),
    );
  }
}