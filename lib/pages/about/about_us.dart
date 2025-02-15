import 'package:flutter/material.dart';
import 'package:flutter_app/utils/app_constant.dart';
import 'package:flutter_app/utils/app_util.dart';
import 'package:flutter_app/utils/keys.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "About",
          key: ValueKey(AboutUsKeys.TITLE_ABOUT),
        ),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: <Widget>[
              Card(
                child: Column(
                  children: <Widget>[
                    ListTile(
                        leading: Icon(Icons.bug_report, color: Colors.black),
                        title: Text(
                          "Report an Issue",
                          key: ValueKey(AboutUsKeys.TITLE_REPORT),
                        ),
                        subtitle: Text(
                          "Having an issue ? Report it here",
                          key: ValueKey(AboutUsKeys.SUBTITLE_REPORT),
                        ),
                        onTap: () => launchURL(ISSUE_URL)),
                    ListTile(
                      leading: Icon(Icons.update, color: Colors.black),
                      title: Text("Version"),
                      subtitle: FutureBuilder<PackageInfo>(
                        future: PackageInfo.fromPlatform(),
                        builder: (context, snapshot) {
                          final versionName = snapshot.data?.version ?? '1.0.0';
                          return Text(
                            versionName,
                            key: ValueKey(AboutUsKeys.VERSION_NUMBER),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, left: 16.0),
                      child: Text("Author",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: FONT_MEDIUM)),
                    ),
                    ListTile(
                      leading: Icon(Icons.perm_identity, color: Colors.black),
                      title: Text(
                        "TimeNest",
                        key: ValueKey(AboutUsKeys.AUTHOR_NAME),
                      ),
                      subtitle: Text(
                        "Aplikasi Manajemen Waktu",
                        key: ValueKey(AboutUsKeys.AUTHOR_USERNAME),
                      ),
                      onTap: () => launchURL(GITHUB_URL),
                    ),
                    ListTile(
                        leading: Icon(Icons.email, color: Colors.black),
                        title: Text("Send an Email"),
                        subtitle: Text(
                          "TimeNest@gmail.com",
                          key: ValueKey(AboutUsKeys.AUTHOR_EMAIL),
                        ),
                        onTap: () => launchURL(EMAIL_URL)),
                  ],
                ),
              ),
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, left: 16.0),
                      child: Text("Ask Question ?",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: FONT_MEDIUM)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          IconButton(
                            icon: Image.asset(
                              "assets/twitter_logo.png",
                              scale: 8.75,
                            ),
                            onPressed: () => launchURL(TWITTER_URL),
                          ),
                          IconButton(
                            icon: Image.asset(
                              "assets/facebook_logo.png",
                              scale: 14.25,
                            ),
                            onPressed: () => launchURL(FACEBOOK_URL),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
