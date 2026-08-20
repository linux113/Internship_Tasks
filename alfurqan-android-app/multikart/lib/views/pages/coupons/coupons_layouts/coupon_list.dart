import 'package:multikart/config.dart';

class CouponList extends StatelessWidget {
  final List<CouponModel>? couponList;
  const CouponList({Key? key,this.couponList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...couponList!.asMap().entries.map((e) {
          return CouponCard(couponModel: e.value,index: e.key,lastIndex: couponList!.length - 1,);
        }).toList()
      ],
    );
  }
}
