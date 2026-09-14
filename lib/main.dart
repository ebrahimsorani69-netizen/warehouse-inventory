import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const WarehouseApp());

class WarehouseApp extends StatelessWidget {
  const WarehouseApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'انبارگردانی',
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue, fontFamily: 'sans'),
    home: const HomePage(),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState()=>_HomePageState();
}
class _HomePageState extends State<HomePage>{
  int index=0;
  final pages=const [Dashboard(), Products(), InventoryCount(), Transactions(), Reports()];
  @override Widget build(BuildContext c)=>Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(title: const Text('سیستم انبارگردانی'), centerTitle:true),
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex:index,
        onDestinationSelected:(i)=>setState(()=>index=i),
        destinations: const [
          NavigationDestination(icon:Icon(Icons.home_outlined),selectedIcon:Icon(Icons.home),label:'خانه'),
          NavigationDestination(icon:Icon(Icons.inventory_2_outlined),selectedIcon:Icon(Icons.inventory_2),label:'کالاها'),
          NavigationDestination(icon:Icon(Icons.fact_check_outlined),selectedIcon:Icon(Icons.fact_check),label:'انبارگردانی'),
          NavigationDestination(icon:Icon(Icons.swap_vert),label:'ورود/خروج'),
          NavigationDestination(icon:Icon(Icons.bar_chart),label:'گزارش'),
        ],
      ),
    ),
  );
}

class Dashboard extends StatelessWidget{
 const Dashboard({super.key});
 Widget card(String t,String v,IconData i)=>Card(child:Padding(padding:const EdgeInsets.all(16),child:Row(children:[CircleAvatar(child:Icon(i)),const SizedBox(width:12),Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(t),Text(v,style:const TextStyle(fontSize:22,fontWeight:FontWeight.bold))])])));
 @override Widget build(BuildContext c)=>ListView(padding:const EdgeInsets.all(16),children:[
   const Text('خلاصه وضعیت انبار',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),const SizedBox(height:12),
   card('تعداد کالا','0','inventory_2'),card('موجودی کل','0','warehouse'),card('ورود امروز','0','arrow_downward'),card('خروج امروز','0','arrow_upward'),
   const SizedBox(height:16),Card(child:ListTile(leading:const Icon(Icons.info_outline),title:const Text('نسخه آفلاین تک‌گوشی'),subtitle:const Text('اطلاعات روی همین دستگاه ذخیره می‌شود.')))
 ]);
}

class Products extends StatefulWidget{const Products({super.key});@override State<Products> createState()=>_ProductsState();}
class _ProductsState extends State<Products>{
 List<Map<String,dynamic>> items=[];
 final name=TextEditingController(), code=TextEditingController();
 @override void initState(){super.initState();load();}
 Future<void> load()async{final p=await SharedPreferences.getInstance();final s=p.getString('products');if(s!=null)setState(()=>items=List<Map<String,dynamic>>.from(jsonDecode(s)));}
 Future<void> save()async{final p=await SharedPreferences.getInstance();await p.setString('products',jsonEncode(items));}
 void add(){name.clear();code.clear();showDialog(context:context,builder:(_)=>AlertDialog(title:const Text('ثبت کالای جدید'),content:Column(mainAxisSize:MainAxisSize.min,children:[TextField(controller:name,decoration:const InputDecoration(labelText:'نام کالا')),TextField(controller:code,decoration:const InputDecoration(labelText:'کد / بارکد'))]),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('لغو')),FilledButton(onPressed:(){if(name.text.trim().isEmpty)return;setState(()=>items.add({'name':name.text,'code':code.text,'qty':0}));save();Navigator.pop(context);},child:const Text('ثبت'))]));}
 @override Widget build(BuildContext c)=>Column(children:[Padding(padding:const EdgeInsets.all(16),child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[const Text('کالاها',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),FilledButton.icon(onPressed:add,icon:const Icon(Icons.add),label:const Text('کالای جدید'))])),Expanded(child:items.isEmpty?const Center(child:Text('هنوز کالایی ثبت نشده است')):ListView.builder(itemCount:items.length,itemBuilder:(_,i)=>Card(child:ListTile(leading:const Icon(Icons.inventory_2),title:Text(items[i]['name']),subtitle:Text('کد: ${items[i]['code']} | موجودی: ${items[i]['qty']}')))))]);}
}

class InventoryCount extends StatelessWidget{
 const InventoryCount({super.key});
 @override Widget build(BuildContext c)=>ListView(padding:const EdgeInsets.all(16),children:[
  const Text('انبارگردانی',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),const SizedBox(height:12),
  Card(child:ListTile(leading:const Icon(Icons.qr_code_scanner),title:const Text('اسکن بارکد'),subtitle:const Text('کالا را با دوربین اسکن کنید'),onTap:()=>showDialog(context:context,builder:(_)=>const AlertDialog(title:Text('بارکدخوان'),content:Text('بارکدخوان در نسخه Build فعال می‌شود.'))))),
  Card(child:ListTile(leading:const Icon(Icons.fact_check),title:const Text('شروع شمارش'),subtitle:const Text('ثبت موجودی واقعی و محاسبه مغایرت'),onTap:()=>showDialog(context:context,builder:(_)=>const AlertDialog(title:Text('شمارش موجودی'),content:Text('کالا را انتخاب و تعداد واقعی را وارد کنید.'))))),
 ]);
}
class Transactions extends StatelessWidget{const Transactions({super.key});@override Widget build(BuildContext c)=>ListView(padding:const EdgeInsets.all(16),children:[const Text('ورود و خروج کالا',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),const SizedBox(height:12),Card(child:ListTile(leading:const Icon(Icons.arrow_downward),title:const Text('ورود کالا'),onTap:()=>showDialog(context:context,builder:(_)=>const AlertDialog(title:Text('ورود کالا'),content:Text('ثبت ورود کالا آماده است.'))))),Card(child:ListTile(leading:const Icon(Icons.arrow_upward),title:const Text('خروج کالا'),onTap:()=>showDialog(context:context,builder:(_)=>const AlertDialog(title:Text('خروج کالا'),content:Text('ثبت خروج کالا آماده است.'))))) ]);}
class Reports extends StatelessWidget{const Reports({super.key});@override Widget build(BuildContext c)=>ListView(padding:const EdgeInsets.all(16),children:[const Text('گزارش‌ها',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),const SizedBox(height:12),Card(child:ListTile(leading:const Icon(Icons.inventory),title:const Text('گزارش موجودی'),subtitle:const Text('مشاهده موجودی کالاها'))),Card(child:ListTile(leading:const Icon(Icons.compare_arrows),title:const Text('گزارش مغایرت'),subtitle:const Text('کسری و اضافی انبار')))]);}
