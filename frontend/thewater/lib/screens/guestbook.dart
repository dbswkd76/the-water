import 'package:flutter/material.dart';
import 'package:thewater/screens/friend_aquarium.dart';
import 'package:provider/provider.dart';
import 'package:thewater/providers/guestbook_provider.dart';

class GuestBookEntry {
  final int guestBookId;
  // final int userId; // 친구 페이지 이동을 위한 필드
  final String author;
  final String content;
  final bool wroteByMe;
  // final DateTime date; // 날짜 추후 사용

  GuestBookEntry({
    required this.guestBookId,
    // required this.userId,
    required this.author,
    required this.content,
    required this.wroteByMe,
    // required this.date,
  });

  factory GuestBookEntry.fromJson(Map<String, dynamic> json) {
    return GuestBookEntry(
      guestBookId: json['guestBookId'],
      // userId: json['userId'], // API 응답에 userId 필드가 포함되어야 함.
      author: json['guestNickname'],
      content: json['guestBookComment'],
      wroteByMe: json['wroteByMe'],
      // date: DateTime.now(), // 날짜 정보가 있다면 실제 값 사용
    );
  }
}

class GuestBookModal extends StatefulWidget {
  final List<GuestBookEntry> entries;

  const GuestBookModal({Key? key, required this.entries}) : super(key: key);

  @override
  State<GuestBookModal> createState() => _GuestBookModalState();
}

class _GuestBookModalState extends State<GuestBookModal> {
  bool isLatestOrder = true; // true면 최신순, false면 오래된순
  late List<GuestBookEntry> _entries;

  @override
  void initState() {
    super.initState();
    _entries = List.from(widget.entries);
  }

  @override
  Widget build(BuildContext context) {
    List<GuestBookEntry> sortedEntries = List.from(widget.entries);

    // guestBookId 기준 정렬
    sortedEntries.sort((a, b) {
      if (isLatestOrder) {
        return b.guestBookId.compareTo(a.guestBookId);
      } else {
        return a.guestBookId.compareTo(b.guestBookId);
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
          child: Text(
            "방명록",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        // 정렬 버튼 영역
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.0),
          child: Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() => isLatestOrder = true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLatestOrder ? Colors.blue : Colors.grey,
                  minimumSize: const Size(70, 32),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "최신순",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() => isLatestOrder = false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: !isLatestOrder ? Colors.blue : Colors.grey,
                  minimumSize: const Size(70, 32),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "오래된순",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // 방명록 리스트 영역
        Expanded(
          child:
              sortedEntries.isEmpty
                  ? const Center(child: Text("아직 등록된 방명록이 없습니다"))
                  : ListView.builder(
                    itemCount: sortedEntries.length,
                    itemBuilder: (context, index) {
                      final entry = sortedEntries[index];
                      return Column(
                        children: [
                          ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // 닉네임 터치 시 FriendAquarium 페이지로 이동
                                GestureDetector(
                                  // onTap: () {
                                  //   Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //       builder: (context) => FriendAquarium(
                                  //         userId: entry.userId,
                                  //         nickname: entry.author,
                                  //       ),
                                  //     ),
                                  //   );
                                  // },
                                  child: Text(
                                    entry.author,
                                    // style: const TextStyle(
                                    // color: Colors.blue,
                                    // decoration: TextDecoration.underline,
                                    // ),
                                  ),
                                ),
                                if (entry.wroteByMe)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextButton(
                                        onPressed: () async {
                                          final newContent =
                                              await showDialog<String>(
                                                context: context,
                                                builder: (context) {
                                                  final controller =
                                                      TextEditingController(
                                                        text: entry.content,
                                                      );
                                                  return AlertDialog(
                                                    title: const Text('방명록 수정'),
                                                    content: TextField(
                                                      controller: controller,
                                                      decoration:
                                                          const InputDecoration(
                                                            labelText: '내용',
                                                          ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed:
                                                            () => Navigator.pop(
                                                              context,
                                                            ),
                                                        child: const Text('취소'),
                                                      ),
                                                      TextButton(
                                                        onPressed:
                                                            () => Navigator.pop(
                                                              context,
                                                              controller.text,
                                                            ),
                                                        child: const Text('저장'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                          if (newContent != null &&
                                              newContent.trim().isNotEmpty) {
                                            bool success = await Provider.of<
                                              GuestBookProvider
                                            >(
                                              context,
                                              listen: false,
                                            ).editGuestBook(
                                              entry.guestBookId,
                                              newContent,
                                            );
                                            if (success) {
                                              setState(() {
                                                int idx = _entries.indexWhere(
                                                  (e) =>
                                                      e.guestBookId ==
                                                      entry.guestBookId,
                                                );
                                                if (idx != -1) {
                                                  _entries[idx] =
                                                      GuestBookEntry(
                                                        guestBookId:
                                                            entry.guestBookId,
                                                        // userId: entry.userId,
                                                        author: entry.author,
                                                        content: newContent,
                                                        wroteByMe:
                                                            entry.wroteByMe,
                                                      );
                                                }
                                              });
                                            }
                                          }
                                        },
                                        child: const Text('수정'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          bool success = await Provider.of<
                                            GuestBookProvider
                                          >(
                                            context,
                                            listen: false,
                                          ).deleteGuestBook(entry.guestBookId);
                                          if (success) {
                                            setState(() {
                                              _entries.removeWhere(
                                                (e) =>
                                                    e.guestBookId ==
                                                    entry.guestBookId,
                                              );
                                            });
                                          }
                                        },
                                        child: const Text('삭제'),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            subtitle: Text(entry.content),
                            trailing: Text("#${entry.guestBookId}"),
                          ),
                          const Divider(
                            height: 1,
                            thickness: 0.5,
                            color: Colors.grey,
                          ),
                        ],
                      );
                    },
                  ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
