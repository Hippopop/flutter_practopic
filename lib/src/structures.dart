import 'package:flutter/material.dart';

class Example {
  final Widget page;
  final String name;
  final Widget icon;

  const Example({
    required this.page,
    required this.name,
    this.icon = const FlutterLogo(),
  });
}

class FrontPageStructure extends StatelessWidget {
  const FrontPageStructure({
    super.key,
    required this.name,
    required this.topicColor,
    required this.exampleList,
    required this.linkList,
  });

  final String name;
  final Color topicColor;
  final List<Example> exampleList;
  final List<({String? title, String link})> linkList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: GridView.builder(
        itemCount: exampleList.length,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        itemBuilder: (context, index) => ExampleCard(
          example: exampleList[index],
          backgroundColor: topicColor,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
      ),
    );
  }
}

class ExampleCard extends StatelessWidget {
  const ExampleCard({
    super.key,
    required this.example,
    required this.backgroundColor,
  });

  final Example example;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => example.page,
        ),
      ),
      child: Card(
        clipBehavior: Clip.hardEdge,
        color: backgroundColor,
        child: SizedBox.expand(
          child: Column(
            children: [
              Expanded(
                child: SizedBox.expand(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FittedBox(
                      child: Center(child: example.icon),
                    ),
                  ),
                ),
              ),
              ColoredBox(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    example.name,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
