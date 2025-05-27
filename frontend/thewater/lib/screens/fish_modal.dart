import 'package:flutter/material.dart';

class FishSelectModal extends StatefulWidget {
  final void Function(String imagePath, int fishId, bool currentHasVisible)
  onToggleFish;
  final Set<String> selectedFish;
  final List<String> fishImages;
  final List<Map<String, dynamic>> fishDataList;

  const FishSelectModal({
    Key? key,
    required this.onToggleFish,
    required this.selectedFish,
    required this.fishImages,
    required this.fishDataList,
  }) : super(key: key);

  @override
  _FishSelectModalState createState() => _FishSelectModalState();
}

class _FishSelectModalState extends State<FishSelectModal> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 10,
            children:
                widget.fishImages.map((path) {
                  final fishName = path.split('/').last.split('.').first;

                  final matchingFish = widget.fishDataList.firstWhere(
                    (data) => data['fishName'] == fishName,
                    orElse: () => {"id": null, "hasVisible": false},
                  );

                  final fishId = matchingFish['id'];
                  // hasVisible을 안전하게 처리 (null이면 false로 간주)
                  final hasVisible =
                      (matchingFish['hasVisible'] ?? false) as bool;

                  return GestureDetector(
                    onTap: () {
                      widget.onToggleFish(path, fishId, hasVisible);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 90,
                      height: 90,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: hasVisible ? Colors.blue : Colors.grey[300]!,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(child: Image.asset(path)),
                          const SizedBox(height: 4),
                          Text(
                            fishName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}
