import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0,vertical: 10),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children:[Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: HexColor("105d5e")),
                  child: Center(child: Text("Y",style: TextStyle(color: Theme.of(context).colorScheme.tertiary,fontSize: 25),)),   
                ),
                SizedBox(
                  width: 8,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "welcome",
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.outline),
                    ),
                    Text("Yash Agarwal",
                    style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onBackground),
                    )
                  ],
                ),],),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(onPressed: (){}, icon: Icon(Icons.settings)))
              ],
            )
          ],
        ),
      ),
    );
  }
}
