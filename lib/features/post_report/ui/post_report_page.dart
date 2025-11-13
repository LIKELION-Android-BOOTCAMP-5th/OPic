import 'package:flutter/material.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:opicproject/core/manager/supabase_manager.dart';
import 'package:opicproject/features/post/ui/post_detail_page.dart';

class PostReportScreen extends StatefulWidget {
  final int postId;
  const PostReportScreen({super.key, required this.postId});

  @override
  _PostReportScreenState createState() => _PostReportScreenState();
}

class _PostReportScreenState extends State<PostReportScreen> {
  final TextEditingController _reasonController = TextEditingController();

  Future<void> _submitReport(int postId) async {
    final reason = _reasonController.text;

    if (reason.isEmpty) {
      showToast('신고 사유를 입력해주세요.');
      return;
    }

    final userId = AuthManager.shared.userInfo?.id ?? 0;

    try {
      await SupabaseManager.shared.supabase.from('post_report').insert({
        'reported_post_id': postId,
        'reporter_id': userId,
        'report_reason': reason,
        'checked_at': DateTime.now().toIso8601String(),
        'is_checked': false,
      });

      showToast('신고가 접수되었습니다.');
      Navigator.pop(context);
    } catch (error) {
      print('신고 에러 상세: $error');
      showToast('신고 실패');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Color(0xfffefefe),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("신고하기", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 15),
                  Text(
                    "신고 사유를 입력해주세요",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Color(0xff515151),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.only(left: 15),
              color: Color(0xFFFCFCF0),
              height: 150,
              child: TextField(
                controller: _reasonController,
                maxLines: null,
                obscureText: false,
                decoration: InputDecoration(
                  hintText: '신고 사유를 자세히 작성해주세요...',
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.text,
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _submitReport(widget.postId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff95b7db),
                      foregroundColor: Color(0xfffefefe),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "신고하기",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xfffefefe),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffe8e8dc),
                      foregroundColor: Color(0xfffefefe),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "닫기",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff515151),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
