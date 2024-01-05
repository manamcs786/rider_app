import 'package:flutter/material.dart';

class DrawerWidget extends StatelessWidget {
  final String userName;

  const DrawerWidget({Key? key, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      child: Drawer(
        elevation: 0.1,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                userName.isNotEmpty ? userName : "Profile name",
                style: TextStyle(
                  fontSize: 18.0,
                  fontFamily: "Roboto", // Change the font family here
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade900,
                ),
              ),
              accountEmail: Text(
                "Visit Profile",
                style: TextStyle(
                  color: Colors.blueGrey.shade700,
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage("images/user.png"),
              ),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade100,
              ),
            ),
            buildListTile(
              title: "Home",
              icon: 'images/home.png',
            ),
            buildListTile(
              title: "History",
              icon: 'images/history.png',
            ),
            buildListTile(
              title: "Invite Friends",
              icon: 'images/share.png',
            ),
            buildListTile(
              title: "Message",
              icon: 'images/message.png',
            ),
            buildListTile(
              title: "Payment",
              icon: 'images/payment.png',
            ),
            buildListTile(
              title: "About Us",
              icon: 'images/about.png',
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(width: 1.0, color: Colors.grey), // Add a border at the top of the image
                ),
              ),

            ),
          ],
        ),
      ),
    );
  }

  ListTile buildListTile({required String title, required String icon}) {
    return ListTile(
      leading: SizedBox(
        width: 28,
        height: 28,
        child: Image.asset(icon),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.0,
          fontFamily: "Roboto", // Change the font family here
          color: Colors.blueGrey.shade900,
        ),
      ),
      onTap: () {
        // Add functionality here if needed
      },
    );
  }
}
