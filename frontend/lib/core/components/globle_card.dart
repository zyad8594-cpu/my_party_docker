import 'package:flutter/material.dart';
import '../themes/app_colors.dart';


class GlobleCard extends StatelessWidget
{
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  
  const GlobleCard({
    super.key, 
    required this.title, 
    required this.value,
    required this.icon,
    required this.color
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 20),
            // const SizedBox(height: 22),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,)),
                // const SizedBox(height: 4),
                Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.grey)),
              ],
            )
          ],
        ),
      ),
    );
  }
}