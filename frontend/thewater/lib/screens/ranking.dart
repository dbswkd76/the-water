import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thewater/providers/ranking_provider.dart';
import 'package:thewater/providers/search_provider.dart';
import 'package:thewater/screens/friend_aquarium.dart';

class RankingModal extends StatefulWidget {
  const RankingModal({super.key});

  @override
  State<RankingModal> createState() => _RankingModalState();
}

class _RankingModalState extends State<RankingModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _iconController;
  bool isRandom = false;
  bool isSearching = false;
  String searchQuery = '';
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    // 초기 데이터 로딩
    final rankingProvider = Provider.of<RankingProvider>(
      context,
      listen: false,
    );
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    rankingProvider.fetchTopRanking();
    searchProvider.fetchAllNicknames();
  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rankingProvider = Provider.of<RankingProvider>(context);
    final searchProvider = Provider.of<SearchProvider>(context);

    final List rankingList =
        isSearching
            ? searchProvider.searchResults
            : isRandom
            ? rankingProvider.randomRanking
            : rankingProvider.topRanking;

    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.8,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 8),
            child: Text(
              isRandom ? "랭킹 둘러보기" : "주간 랭킹",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // 검색창
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: '닉네임을 입력해주세요..',
                    border: const OutlineInputBorder(),
                    isDense: true,
                    suffixIcon:
                        _controller.text.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _controller.clear();
                                setState(() {
                                  isSearching = false;
                                });
                              },
                            )
                            : null,
                  ),
                  onChanged: (value) async {
                    if (value.trim().isEmpty) {
                      setState(() {
                        isSearching = false;
                      });
                    } else {
                      await Provider.of<SearchProvider>(
                        context,
                        listen: false,
                      ).searchUsersByNickname(value.trim());
                      setState(() {
                        isSearching = true;
                      });
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () async {
                  String keyword = _controller.text.trim();
                  if (keyword.isNotEmpty) {
                    await Provider.of<SearchProvider>(
                      context,
                      listen: false,
                    ).searchUsersByNickname(keyword);
                    setState(() {
                      isSearching = true;
                    });
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(color: Colors.grey, thickness: 0.8),
          const SizedBox(height: 8),

          Expanded(
            child:
                rankingList.isEmpty
                    ? const Center(child: Text("데이터가 없습니다."))
                    : ListView.separated(
                      itemCount: rankingList.length,
                      separatorBuilder:
                          (context, index) => const Divider(
                            color: Colors.grey,
                            thickness: 0.6,
                            indent: 10,
                            endIndent: 10,
                          ),
                      itemBuilder: (context, index) {
                        final item = rankingList[index];
                        final isSearchResult = isSearching;

                        final nickname = item.nickname;
                        final comment =
                            isSearchResult
                                ? (item.comment ?? "한 줄 소개가 없습니다.")
                                : (item.memberComment ?? "한 줄 소개가 없습니다.");
                        final totalPrice =
                            isSearchResult ? null : item.totalPrice;

                        final userId = isSearchResult ? item.id : item.memberId;

                        return ListTile(
                          leading: Text(
                            isRandom ? '-' : '${index + 1}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          title: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => FriendAquarium(
                                        userId: userId,
                                        nickname: nickname,
                                      ),
                                ),
                              );
                            },
                            child: Text(
                              nickname,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (totalPrice != null)
                                Text('어항 가치 : ₩${_formatPrice(totalPrice)}'),
                              Text(comment),
                            ],
                          ),
                        );
                      },
                    ),
          ),

          Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
              icon: AnimatedIcon(
                icon: AnimatedIcons.view_list,
                progress: _iconController,
              ),
              onPressed: () async {
                setState(() {
                  isSearching = false;
                  isRandom = !isRandom;
                });

                if (isRandom) {
                  await rankingProvider.fetchRandomRanking();
                  _iconController.forward();
                } else {
                  await rankingProvider.fetchTopRanking();
                  _iconController.reverse();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
