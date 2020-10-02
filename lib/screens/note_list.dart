

import 'package:flutter/material.dart';
import 'package:notekeeper/screens/note_d.dart';
import 'dart:async';
import 'package:notekeeper/models/node.dart';
import 'package:notekeeper/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class NoteList extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return NoteListState();
  }
}

class NoteListState extends State<NoteList> {
  int count = 0;
  DatabaseHelper databaseHelper=DatabaseHelper();
  List<Note> noteList;

  @override
  Widget build(BuildContext context) {
    if(noteList==null){
      noteList=List<Note>();
      updateListView();
    }
    return Scaffold(
        appBar: AppBar(
            title: Center(
              child: Text(
          'Notes',
          style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          ),
        ),
            ),
        backgroundColor: Colors.blue,    
            ),
        body: getNoteListView(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            debugPrint('Fab pressed');
            navigateToData(Note('','',2),'Add Note');
          },
          tooltip: 'Add Note',
          child: Icon(Icons.add),
        ));
  }

  ListView getNoteListView() {
    TextStyle textStyle = Theme.of(context).textTheme.subhead;
    return ListView.builder(
        itemCount: count,
        // ignore: missing_return
        itemBuilder: (BuildContext context, int position) {
          return Card(
            color: Colors.yellow,
            elevation: 3.0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: getPriorityColor(this.noteList[position].priority),
                child: getPriorityIcons(this.noteList[position].priority),
              ),
              title: Text(
                this.noteList[position].title,
                style: textStyle(
                fontStyle: FontStyle.italic,),
              ),
              subtitle: Text(this.noteList[position].date),
              trailing: GestureDetector(child: Icon(
                Icons.delete,
                color: Colors.grey[200],
              ),
              onTap: (){
                _delete(context, noteList[position]);
              },),
              onTap: () {
                debugPrint('Listtile tapped');
                navigateToData(this.noteList[position],'Edit Note');
                }));
              },
            );

        }


  //return priority color
  Color getPriorityColor(int priority){
    switch(priority){
      case 1: return Colors.blue; break;
      case 2: return Colors.yellow; break;
      default: return Colors.yellow;
    }
  }

  //return priority icon
  Icon getPriorityIcons(int priority){
    switch(priority){
      case 1: return Icon(Icons.play_arrow); break;
      case 2: return Icon(Icons.keyboard_arrow_right); break;
      default: return Icon(Icons.keyboard_arrow_right);
    }
  }

  //delete icon
  void _delete(BuildContext context, Note note) async{
    int result= await databaseHelper.deleteNote(note.id);
    if(result!=0){
      _showSnackBar(context, 'Note deleted successsfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String msg){
    final snackBar=SnackBar(content: Text(msg));
    Scaffold.of(context).showSnackBar(snackBar);

  }

  //next page
  void navigateToData(Note note,String title) async{
    bool result=await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteData(note,title);
    }));
    if(result == true){
      updateListView();
    }
  }
  void updateListView(){
    final Future<Database> dbfuture= databaseHelper.initializeDatabase();
    dbfuture.then((database){
      Future<List<Note>> noteListFuture=databaseHelper.getNoteList();
      noteListFuture.then((noteList){
        this.noteList=noteList;
        this.count=noteList.length;
      }) ;
    });
  }
}
