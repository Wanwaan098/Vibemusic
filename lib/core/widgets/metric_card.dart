import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool isLoading;

  const MetricCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.12),
              child: Icon(icon, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 6),
                  isLoading
                      ? Container(
                          width: 80,
                          height: 18,
                          color: Colors.grey.shade300,
                        )
                      : Text(
                          value,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
