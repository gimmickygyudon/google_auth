import 'package:flutter/material.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({super.key, required this.source});

  final Map? source;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Padding(
              padding: EdgeInsets.all(source?['photo_url'] != null ? 2 : 0),
              child: source?['photo_url'] != null 
              ? CircleAvatar(
                backgroundImage: NetworkImage(source?['photo_url']),
                radius: 32
              ) 
              : Icon(Icons.account_circle, size: 80, color: Theme.of(context).colorScheme.secondary),
            ),
            if (source?['photo_url'] != null) Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:BorderRadius.circular(25.7)
              ),
              child: const CircleAvatar(
                backgroundImage: NetworkImage('https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Google_%22G%22_Logo.svg/2008px-Google_%22G%22_Logo.svg.png'),
                radius: 10,
              ),
            )
          ],
        ),
        if (source?['photo_url'] != null) const SizedBox(height: 12),
        Text(source?['user_name'], style: Theme.of(context).textTheme.bodyLarge),
        Text(source?['user_email'], style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}