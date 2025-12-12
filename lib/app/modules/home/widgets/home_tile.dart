import 'package:flutter/material.dart';

class HomeTile extends StatelessWidget {
  const HomeTile({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    required this.icon,
  });

  final String label;
  final String value;
  final String? unit;
  final Widget icon;

  bool get _hasUnit => unit != null && unit!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBAD0D0), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff00df82), Color(0xff2ea7a9)],
                stops: [0.25, 0.75],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(child: icon),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF03624C),
                  fontSize: 14,
                ),
              ),
              RichText(
                text: TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF03624C),
                    fontSize: 18,
                  ),
                  children: _hasUnit
                      ? [
                          TextSpan(
                            text: '  ${unit!.trim()}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6F7D7D),
                              fontSize: 12,
                            ),
                          ),
                        ]
                      : const <InlineSpan>[],
                ),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF03624C)),
        ],
      ),
    );
  }
}
