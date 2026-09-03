import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_searchfield.dart';
import 'webview_screen.dart';

class BrowserScreen extends StatefulWidget {
  const BrowserScreen({Key? key}) : super(key: key);

  @override
  _BrowserScreenState createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _shortcuts = [
    {
      'title': 'Google',
      'url': 'https://www.google.com',
      'icon': Icons.search,
      'color': Colors.blue,
      'isAdult': false,
    },
    {
      'title': 'Facebook',
      'url': 'https://www.facebook.com',
      'icon': Icons.facebook,
      'color': Colors.blueAccent,
      'isAdult': false,
    },
    {
      'title': 'Opera Mini',
      'url': 'https://www.opera.com',
      'icon': Icons.public,
      'color': Colors.red,
      'isAdult': false,
    },
    {
      'title': 'Adult Site',
      'url': 'https://example.com/adult', // Placeholder URL for adult site
      'icon': Icons.warning_rounded,
      'color': Colors.orange,
      'isAdult': true,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToUrl(String url, String title) {
    if (url.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewScreen(url: url, title: title),
      ),
    );
  }

  void _handleShortcutTap(Map<String, dynamic> shortcut) {
    if (shortcut['isAdult'] == true) {
      _showAgeVerificationDialog(shortcut['url'], shortcut['title']);
    } else {
      _navigateToUrl(shortcut['url'], shortcut['title']);
    }
  }

  void _showAgeVerificationDialog(String targetUrl, String title) {
    bool isChecked = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const CustomText(text: 'Age Verification', fontWeight: FontWeight.bold, fontSize: 18),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CustomText(
                    text: 'This site contains adult content. You must be 18 years or older to proceed.',
                    fontSize: 14,
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Checkbox(
                        value: isChecked,
                        onChanged: (val) {
                          setState(() {
                            isChecked = val ?? false;
                          });
                        },
                      ),
                      const Expanded(
                        child: Text(
                          'I confirm that I am 18+ years old.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: isChecked
                      ? () {
                          Navigator.pop(context); // Close dialog
                          _navigateToUrl(targetUrl, title); // Navigate
                        }
                      : null,
                  child: const Text('Proceed'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomText(text: 'Browser', fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            CustomSearchField(
              controller: _searchController,
              hintText: 'Search or type URL...',
              onSubmitted: (val) {
                _navigateToUrl(val, val);
              },
              onClear: () {
                _searchController.clear();
                setState(() {});
              },
            ),
            SizedBox(height: 24.h),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 20.h,
                  crossAxisSpacing: 20.w,
                  childAspectRatio: 0.8,
                ),
                itemCount: _shortcuts.length,
                itemBuilder: (context, index) {
                  final shortcut = _shortcuts[index];
                  return InkWell(
                    onTap: () => _handleShortcutTap(shortcut),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 60.w,
                          width: 60.w,
                          decoration: BoxDecoration(
                            color: shortcut['color'].withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            shortcut['icon'],
                            color: shortcut['color'],
                            size: 30.w,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          shortcut['title'],
                          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
