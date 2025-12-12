import 'package:flutter/material.dart';

class ActivityTile extends StatelessWidget {
  const ActivityTile({super.key, required this.label, required this.icon });
  final String label;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFFBAD0D0), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff00df82), Color(0xff2ea7a9)],
                stops: [0.25, 0.75],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(child: icon),
          ),
          SizedBox(width: 20,),
          Expanded(child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: Color(0XFF03624C), fontSize: 20))),
          Icon(Icons.arrow_forward_ios, size: 16, color: Color(0XFF03624C)),
        ],
      ),
    );
  }
}
