// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, body_might_complete_normally_nullable

import 'dart:developer';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'package:sqflite/sqflite.dart';
import 'package:test_sqlite/DatabaseSqlite.dart';

class ListItemPage extends StatefulWidget {
  @override
  _ListItemPageState createState() => _ListItemPageState();
}

class _ListItemPageState extends State<ListItemPage> {
  //  final _fbKey = GlobalKey<FormState>();
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  List<Map> customers = [];
  late DBHelper dbHelper;
  late Database db;

  // ?------------------ฟังค์ชันดึงข้อมูลมาแสดง
  _getCustomer() async {
    db = (await dbHelper.db)!; // เป็นการ get db ออกมา
    var cust = await db.rawQuery("SELECT * FROM products ORDER BY id DESC");
    setState(() {
      customers = cust;
    });
  }

  // ?------------------ฟังค์ชันเพิ่มข้อมูลลง database (SQLite)
  _insertCustomer(Map values) async {
    db = (await dbHelper.db)!;
    await db.rawInsert("INSERT INTO products (item, qty) VALUES (?, ?)",
        [values['item'], values['qty']]);
    _getCustomer();
  }

  // ?------------------ฟังค์ชันแก้ไขข้อมูล
  _updateCustomer(int id, Map values) async {
    db = (await dbHelper.db)!;
    await db.rawUpdate("UPDATE products SET item = ?, qty = ? WHERE id = ?",
        [values['item'], values['qty'], id]);
    _getCustomer(); // _getCustomer() to rebuild screen
  }

  // ?------------------ฟังค์ชันลบข้อมูลตาม id
  _deleteCustomer(int id) async {
    db = (await dbHelper.db)!;
    await db.rawDelete("DELETE FROM products WHERE id = ?", [id]);
    _getCustomer();
  }

  @override
  void initState() {
    dbHelper = DBHelper(); // new instance ขั้นมา
    _getCustomer();
    super.initState();
  }

  // * -----------------ฟอร์มเพิ่มข้อมูล
  _insertForm() {
    Alert(
        context: context,
        title: 'เพิ่มข้อมูล',
        // closeFunction: () => Navigator.pop(context),
        content: Column(
          children: <Widget>[
            FormBuilder(
              key: _fbKey,
              initialValue: {
                'item': '',
                'qty': '',
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    ' Item',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  FormBuilderTextField(
                    name: 'item',
                    maxLines: 1,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'กรุณากรอกข้อมูล';
                      }
                    },
                    decoration: InputDecoration(
                      fillColor: Colors.grey.shade300,
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    ' Qty',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  FormBuilderTextField(
                    keyboardType: TextInputType.number,
                    maxLines: 1,
                    name: 'qty',
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'กรุณากรอกข้อมูล';
                      }
                      if (!RegExp(r'^(?:[0-9])').hasMatch(value)) {
                        return 'กรอกตัวเลขได้เท่านั้น';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      fillColor: Colors.grey.shade300,
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        buttons: [
          DialogButton(
            color: Colors.green,
            onPressed: () {
              if (_fbKey.currentState!.saveAndValidate()) {
                // print(_fbKey.currentState.value);
                // ถ้ามีการกดปุ่ม จะนำข้อมูลตรงนี้ไป save ลง sqlite
                _insertCustomer(_fbKey.currentState!.value);
                Navigator.pop(context);
                _showinsertber();
              }
            },
            child: Text(
              'เพิ่ม',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700),
            ),
          ),
          DialogButton(
            color: Colors.red,
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'ยกเลิก',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700),
            ),
          )
        ]).show();
  }

  // * -----------------ฟอร์มแก้ไขข้อมูล
  _updateForm(int id, var item, var qty) {
    Alert(
        context: context,
        title: "แก้ไขข้อมูล",
        // closeFunction: () => Navigator.pop(context),
        content: Column(
          children: <Widget>[
            FormBuilder(
              key: _fbKey,
              initialValue: {
                'item': '$item',
                'qty': '$qty',
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: <Widget>[
                  FormBuilderTextField(
                    maxLines: 1,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'กรุณากรอกข้อมูล';
                      }
                    },
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                      labelText: "Item",
                      border: OutlineInputBorder(),
                    ),
                    name: 'item',
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  FormBuilderTextField(
                    keyboardType: TextInputType.number,
                    maxLines: 1,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'กรุณากรอกข้อมูล';
                      }
                      if (!RegExp(r'^(?:[0-9])').hasMatch(value)) {
                        return 'กรอกตัวเลขได้เท่านั้น';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                      labelText: "Qty",
                      border: OutlineInputBorder(),
                    ),
                    name: 'qty',
                  ),
                ],
              ),
            ),
          ],
        ),
        buttons: [
          DialogButton(
            onPressed: () {
              if (_fbKey.currentState!.saveAndValidate()) {
                _updateCustomer(id, _fbKey.currentState!.value);
                Navigator.pop(context);
                _showeditber();
              }
            },
            color: Colors.greenAccent.shade700,
            child: Text(
              "บันทึก",
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          DialogButton(
            child: Text(
              "ยกเลิก",
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            onPressed: () => Navigator.pop(context),
            color: Colors.red,
          )
        ]).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(112.0),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(0),
            ),
          ),
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 70),
            child: Column(
              children: [
                Container(
                  height: 50,
                  // width: 160,
                  padding: const EdgeInsets.only(left: 15, right: 10, top: 10),
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      Text(
                        'Item',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Spacer(),
                      Text(
                        'Qty',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Spacer(),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            color: Colors.blueAccent.shade400),
                        height: 35,
                        // width: 50,
                        child: TextButton.icon(
                          onPressed: () {
                            _insertForm();
                          },
                          icon: Icon(
                            Icons.add_box_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                          label: Text(
                            'เพิ่มข้อมูล',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  thickness: 2,
                  color: Colors.blue.shade400,
                ),
              ],
            ),
          ),
          centerTitle: true,
          title: Text(
            'Flutter Exam',
            style: TextStyle(
                color: Colors.black, fontSize: 16, fontStyle: FontStyle.italic),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SizedBox(
        child: customers.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Opacity(
                    //     opacity: 0.4,
                    //     child: Image.asset('assets/images/LoGo2.PNG')),
                    Text(
                      'ไม่มีข้อมูล',
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.black38,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                itemBuilder: (BuildContext context, int index) {
                  return SizedBox(
                    // padding: const EdgeInsets.all(5),
                    child: ListTile(
                      // leading: Text(index.toString(), style: const TextStyle(fontSize: 18)),
                      title: Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${customers[index]['item']}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          Spacer(),
                          SizedBox(
                            width: 40,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${customers[index]['qty']}',
                                    style: const TextStyle(
                                        fontSize: 13, color: Colors.indigo)),
                              ],
                            ),
                          ),
                          Spacer(),
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                    color: Colors.greenAccent.shade700),
                                height: 32,
                                // width: 50,
                                child: TextButton.icon(
                                  onPressed: () => _updateForm(
                                      customers[index]['id'],
                                      customers[index]['item'],
                                      customers[index]['qty']),
                                  icon: Icon(
                                    Icons.edit,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    'แก้ไข',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                    color: Colors.redAccent.shade200),
                                height: 32,
                                // width: 50,
                                child: TextButton.icon(
                                  onPressed: () => Alert(
                                    context: context,
                                    style: AlertStyle(
                                      descStyle: TextStyle(fontSize: 16),
                                      animationDuration:
                                          const Duration(milliseconds: 450),
                                    ),
                                    type: AlertType.warning,
                                    title: "ยืนยันการลบ",
                                    desc:
                                        "คุณแน่ใจหรือว่าต้องการลบ '${customers[index]['item']}' ?",
                                    buttons: [
                                      DialogButton(
                                          child: Text(
                                            "ยืนยัน",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _deleteCustomer(
                                                customers[index]['id']);
                                                _showdeteleber();
                                          },
                                          color: Colors.red),
                                      DialogButton(
                                        child: Text(
                                          "ยกเลิก",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14),
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                        gradient: LinearGradient(colors: [
                                          Colors.blue,
                                          Colors.greenAccent
                                        ]),
                                      )
                                    ],
                                  ).show(),
                                  icon: Icon(
                                    Icons.delete,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    'ลบ',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) => Divider(
                      thickness: 1,
                      indent: 10,
                      endIndent: 10,
                      // color: Colors.grey.shade400,
                    ),
                itemCount: customers.length),
      ),
    );
  }

  Widget _showinsertber() {
    return Center(
      child: Flushbar(
        message: "เพิ่มข้อมูลสำเร็จ",
        icon: Icon(
          Icons.done_rounded,
          size: 28.0,
          color: Colors.white,
        ),
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.only(left: 100,right: 100,bottom: 8,top: 8),
        borderRadius: BorderRadius.circular(10),
        duration: Duration(seconds: 2),
        // leftBarIndicatorColor: Colors.blue[300],
        backgroundColor: Colors.blueAccent.shade700.withOpacity(0.8),
      )..show(context),
    );
  }

  Widget _showeditber() {
    return Center(
      child: Flushbar(
        message: "แก้ไขข้อมูลสำเร็จ",
        icon: Icon(
          Icons.done_rounded,
          size: 28.0,
          color: Colors.white,
        ),
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.only(left: 100,right: 100,bottom: 8,top: 8),
        borderRadius: BorderRadius.circular(10),
        duration: Duration(seconds: 2),
        // leftBarIndicatorColor: Colors.blue[300],
        backgroundColor: Colors.greenAccent.shade700.withOpacity(0.8),
      )..show(context),
    );
  }

  Widget _showdeteleber() {
    return Center(
      child: Flushbar(
        message: "ลบข้อมูลสำเร็จ",
        icon: Icon(
          Icons.clear_rounded,
          size: 28.0,
          color: Colors.white,
        ),
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.only(left: 100,right: 100,bottom: 8,top: 8),
        borderRadius: BorderRadius.circular(10),
        duration: Duration(seconds: 2),
        // leftBarIndicatorColor: Colors.blue[300],
        backgroundColor: Colors.redAccent.shade700.withOpacity(0.7),
      )..show(context),
    );
  }

}
