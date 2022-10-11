import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Items extends StatelessWidget {
  const Items({
    Key? key,
    required this.size,
    required this.icon,
    required this.onTap,
    required this.label,
    required this.color,
  }) : super(key: key);

  final size;
  final IconData icon;
  final Function() onTap;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadiusDirectional.circular(30),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: SizedBox(
            width: size.width / 6,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: color,
                ),
                Text(
                  label,
                  style: GoogleFonts.varela(
                      fontSize: 12, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
