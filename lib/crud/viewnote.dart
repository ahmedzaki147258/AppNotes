import 'package:flutter/material.dart';

class ViewNotes extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final notes;
  const ViewNotes({Key? key,this.notes}):super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _ViewNotesState();
  }
}

class _ViewNotesState extends State<ViewNotes> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Note"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(children: [
        Image.network("${widget.notes['image url']}",
            fit:BoxFit.fill,
            width: double.infinity,
            height: 300),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 15),
          child: Text("${widget.notes['title']}",style: Theme.of(context).textTheme.headline5,),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 15),
          child: Text("${widget.notes['note']}",style: Theme.of(context).textTheme.bodyText2,),
        ),
      ])
    );
  }
}
