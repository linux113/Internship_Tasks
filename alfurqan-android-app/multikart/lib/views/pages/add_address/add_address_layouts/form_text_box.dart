
import '../../../../config.dart';

class FormTextBox extends StatelessWidget {
  const FormTextBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      children:[
        CountryTextBox(),
        Space(0, 30),
        FullNameTextBox(),
        Space(0, 30),
        PhoneTextBox(),
        Space(0, 30),
        PinCodeTextBox(),
        Space(0, 30),
        FlatHouseTextBox(),
        Space(0, 30),
        AreaColonyTextBox(),
        Space(0, 30),
        LandmarkTextBox(),
        Space(0, 30),
        TownCityTextBox(),
        Space(0, 30),
        StateProvisionTextBox(),
      ],
    ).marginSymmetric(
        vertical: AppScreenUtil().screenHeight(20),
        horizontal: AppScreenUtil().screenWidth(15));
  }
}
