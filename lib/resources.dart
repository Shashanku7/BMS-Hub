import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class FileInfo {
  final String name;
  final String? path;
  FileInfo(this.name, this.path);
}

const departments = ['CSE', 'ECE', 'AIML', 'Civil', 'Mech', 'EEE'];
const semesters = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII'];
const resourceTypes = ['Notes', 'PYQ'];
final Map<String, Map<String, List<String>>> subjectsByDeptAndSem = {
  'CSE': {
    'IV': ['ADA', 'DS in C++', 'Operating Systems', 'TFCS', 'DBMS', 'Linear Algebra'],
    'III': ['Maths III', 'DSA', 'OOP', 'COA', 'Digital Logic'],
  },
  // Add other departments and semesters as needed!
};

class _FileDb {
  // dept -> sem -> subject -> type -> files
  final Map<String, Map<String, Map<String, Map<String, List<FileInfo>>>>> files = {};

  List<FileInfo> getFiles(String dept, String sem, String subject, String type) =>
      files[dept]?[sem]?[subject]?[type] ?? [];

  void addFile(String dept, String sem, String subject, String type, FileInfo file) {
    files.putIfAbsent(dept, () => {});
    files[dept]!.putIfAbsent(sem, () => {});
    files[dept]![sem]!.putIfAbsent(subject, () => {});
    files[dept]![sem]![subject]!.putIfAbsent(type, () => []);
    files[dept]![sem]![subject]![type]!.add(file);
  }
}

void main() => runApp(const StudyResourcesApp());

class StudyResourcesApp extends StatelessWidget {
  const StudyResourcesApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    home: MainNavigationScreen(),
    debugShowCheckedModeBanner: false,
  );
}

class MainNavigationScreen extends StatefulWidget {
  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final _pages = [
    StudyResourcesHome(),
    DummyPage('Announcements'),
    DummyPage('Campus Map'),
    DummyPage('Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.black,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: List.generate(4, (index) {
          final icons = [
            Icons.home,
            Icons.campaign,
            Icons.map_outlined,
            Icons.person_outline,
          ];
          final labels = ["Home", "Announcements", "Campus Map", "Profile"];
          return BottomNavigationBarItem(
            icon: Stack(
              alignment: Alignment.center,
              children: [
                if (_currentIndex == index)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                Icon(
                  icons[index],
                  size: _currentIndex == index ? 30 : 24,
                  color: _currentIndex == index ? Colors.white : Colors.white54,
                ),
              ],
            ),
            label: labels[index],
          );
        }),
      ),
    );
  }
}

class DummyPage extends StatelessWidget {
  final String label;
  const DummyPage(this.label, {super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(label),
      ),
      body: Center(
        child: Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}

enum ViewScreen { browser, upload, subdirectory, files }

class StudyResourcesHome extends StatefulWidget {
  @override
  State<StudyResourcesHome> createState() => _StudyResourcesHomeState();
}

class _StudyResourcesHomeState extends State<StudyResourcesHome> {
  String selectedDept = departments[0];
  String selectedSem = semesters[3];

  String? uploadDept, uploadSem, uploadSubject, uploadType;
  PlatformFile? selectedFile;
  String? uploadResultPath;
  String? currentSubject, currentSubdirectory;
  ViewScreen screen = ViewScreen.browser;

  final _FileDb filesDb = _FileDb();

  List<String> get currentSubjects =>
      subjectsByDeptAndSem[selectedDept]?[selectedSem] ?? [];
  List<String> get uploadSubjects {
    if (uploadDept != null && uploadSem != null) {
      return subjectsByDeptAndSem[uploadDept!]?[uploadSem!] ?? [];
    }
    return [];
  }

  List<FileInfo> get filesInCurrentFolder {
    if (currentSubject == null || currentSubdirectory == null) return [];
    return filesDb.getFiles(selectedDept, selectedSem, currentSubject!, currentSubdirectory!);
  }

  void goToUpload({String? dept, String? sem, String? subject}) {
    setState(() {
      uploadDept = dept ?? selectedDept;
      uploadSem = sem ?? selectedSem;
      uploadSubject = subject;
      uploadType = resourceTypes[0];
      selectedFile = null;
      uploadResultPath = null;
      screen = ViewScreen.upload;
    });
  }

  void goToBrowser() {
    setState(() {
      screen = ViewScreen.browser;
      uploadDept = null;
      uploadSem = null;
      uploadSubject = null;
      uploadType = null;
      selectedFile = null;
      uploadResultPath = null;
      currentSubject = null;
      currentSubdirectory = null;
    });
  }

  void goToSubdirectory(String subject) {
    setState(() {
      currentSubject = subject;
      currentSubdirectory = null;
      screen = ViewScreen.subdirectory;
    });
  }

  void goToFiles(String resourceType) {
    setState(() {
      currentSubdirectory = resourceType;
      screen = ViewScreen.files;
    });
  }

  void goBackFromFiles() {
    setState(() {
      screen = ViewScreen.subdirectory;
      currentSubdirectory = null;
    });
  }

  void goBackFromSubdirectory() {
    setState(() {
      screen = ViewScreen.browser;
      currentSubject = null;
      currentSubdirectory = null;
    });
  }

  Future<void> pickFileBottomSheet() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.folder_open, color: Colors.blue),
            title: const Text("Pick from device",
                style: TextStyle(color: Colors.white)),
            onTap: () async {
              Navigator.pop(ctx);
              final result = await FilePicker.platform.pickFiles(
                allowMultiple: false,
                withReadStream: true,
                type: FileType.any,
              );
              if (result != null && result.files.isNotEmpty) {
                setState(() {
                  selectedFile = result.files.first;
                });
              }
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void upload() {
    if (uploadDept == null ||
        uploadSem == null ||
        uploadSubject == null ||
        uploadType == null ||
        selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select a file')),
      );
      return;
    }
    // Actually add file to the in-memory database
    filesDb.addFile(uploadDept!, uploadSem!, uploadSubject!, uploadType!, FileInfo(selectedFile!.name, selectedFile!.path));
    final path =
        '${uploadDept!.toLowerCase()}/sem${uploadSem!.toLowerCase()}/${uploadSubject!.toLowerCase().replaceAll(' ', '_')}/${uploadType!.toLowerCase()}/${selectedFile!.name}';
    setState(() {
      uploadResultPath = path;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('File uploaded to $path')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.black,
            child: Row(
              children: [
                // Back button for explore page (main resource browser)
                if (screen == ViewScreen.browser)
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).maybePop();
                    },
                  ),
                if (screen == ViewScreen.upload)
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: goToBrowser,
                  ),
                if (screen == ViewScreen.subdirectory)
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: goBackFromSubdirectory,
                  ),
                if (screen == ViewScreen.files)
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: goBackFromFiles,
                  ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                    color: Colors.blue,
                    child: const Text(
                      "STUDY RESOUCES",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Builder(
        builder: (context) {
          switch (screen) {
            case ViewScreen.browser:
              return _buildResourceBrowser(context);
            case ViewScreen.upload:
              return _buildUploadScreen(context);
            case ViewScreen.subdirectory:
              return _buildSubdirectory(context);
            case ViewScreen.files:
              return _buildFileList(context);
          }
        },
      ),
      floatingActionButton: screen == ViewScreen.browser
          ? Padding(
        padding: const EdgeInsets.only(bottom: 60.0),
        child: SizedBox(
          width: 165,
          height: 44,
          child: ElevatedButton.icon(
            onPressed: () => goToUpload(),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text("Upload Notes",
                style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              elevation: 5,
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildResourceBrowser(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 18),
        const Padding(
          padding: EdgeInsets.only(left: 20.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Notes? Q papers? Got You Covered! 📚",
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Row(
            children: [
              Expanded(
                child: _blackDropdown(
                  value: selectedSem,
                  items: semesters,
                  onChanged: (val) {
                    setState(() {
                      selectedSem = val!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _blackDropdown(
                  value: selectedDept,
                  items: departments,
                  onChanged: (val) {
                    setState(() {
                      selectedDept = val!;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
            child: currentSubjects.isEmpty
                ? const Center(
              child: Text(
                "No subjects available.",
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            )
                : GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 28,
              crossAxisSpacing: 28,
              childAspectRatio: 1.12,
              children: currentSubjects
                  .map(
                    (subject) => GestureDetector(
                  onTap: () => goToSubdirectory(subject),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Center(
                            child: Icon(Icons.folder,
                                size: 60, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subject,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13.5),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          goToUpload(
                            dept: selectedDept,
                            sem: selectedSem,
                            subject: subject,
                          );
                        },
                        child: const Icon(Icons.add_circle_outline,
                            color: Colors.blue, size: 20),
                      ),
                    ],
                  ),
                ),
              )
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildSubdirectory(BuildContext context) {
    // Shows Notes & PYQ folders for a subject
    return Column(
      children: [
        const SizedBox(height: 24),
        Text(
          "$currentSubject",
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 19,
              letterSpacing: 1.1),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 54, vertical: 10),
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 34,
              crossAxisSpacing: 34,
              childAspectRatio: 1.05,
              children: resourceTypes
                  .map(
                    (type) => GestureDetector(
                  onTap: () => goToFiles(type),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Center(
                            child: Icon(Icons.folder,
                                size: 60, color: Colors.blue[300]),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        type,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileList(BuildContext context) {
    final files = (currentSubject != null && currentSubdirectory != null)
        ? filesDb.getFiles(selectedDept, selectedSem, currentSubject!, currentSubdirectory!)
        : <FileInfo>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Text(
            "$currentSubject > $currentSubdirectory",
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17),
          ),
        ),
        const SizedBox(height: 18),
        Expanded(
          child: files.isEmpty
              ? const Center(
            child: Text(
              "No files found.",
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          )
              : ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            itemCount: files.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, idx) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.insert_drive_file,
                    color: Colors.blue[300],
                  ),
                  title: Text(files[idx].name,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 15)),
                  onTap: () {
                    // Optionally open the file from files[idx].path
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUploadScreen(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 18),
            const Text(
              "Got Notes? Q papers? Upload and Help your peers! 😃",
              style: TextStyle(color: Colors.white, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            _blackDropdown(
              value: uploadDept,
              items: departments,
              label: "Choose Department",
              onChanged: (val) {
                setState(() {
                  uploadDept = val;
                  uploadSem = null;
                  uploadSubject = null;
                });
              },
            ),
            const SizedBox(height: 16),
            _blackDropdown(
              value: uploadSem,
              items: semesters,
              label: "Choose Semester",
              onChanged: (val) {
                setState(() {
                  uploadSem = val;
                  uploadSubject = null;
                });
              },
            ),
            const SizedBox(height: 16),
            _blackDropdown(
              value: uploadType,
              items: resourceTypes,
              label: "Resource Type",
              onChanged: (val) {
                setState(() {
                  uploadType = val;
                });
              },
            ),
            const SizedBox(height: 16),
            _blackDropdown(
              value: uploadSubject,
              items: uploadSubjects,
              label: "Select Subject",
              onChanged: (val) {
                setState(() {
                  uploadSubject = val;
                });
              },
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: pickFileBottomSheet,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    const Icon(Icons.upload_file,
                        color: Colors.blueAccent, size: 22),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        selectedFile != null
                            ? selectedFile!.name
                            : "Select a file to upload",
                        style: const TextStyle(color: Colors.white70, fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
            ),
            if (uploadResultPath != null)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "File uploaded to:\n$uploadResultPath",
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 90),
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: ElevatedButton.icon(
                onPressed: upload,
                icon: const Icon(Icons.cloud_upload, color: Colors.white),
                label: const Text("Upload !!",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 5,
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blackDropdown<T>({
    required T? value,
    required List<T> items,
    String? label,
    required void Function(T?)? onChanged,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(7),
      ),
      margin: const EdgeInsets.symmetric(vertical: 0),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: label != null
              ? Text(label, style: const TextStyle(color: Colors.white70))
              : null,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
          dropdownColor: Colors.grey[900],
          style: const TextStyle(color: Colors.white, fontSize: 16),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(item.toString(),
                  style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}