import 'package:flutter/material.dart';
import 'package:slide_to_act/slide_to_act.dart';

import '../../../utils/managers/color_manager.dart';
import '../../../utils/managers/string_manager.dart';
import '../../../utils/managers/value_manager.dart';
import '../../../utils/router/router.dart';


class SliderBoardingWidget extends StatelessWidget {
  const SliderBoardingWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(PaddingManager.p28),
      child: SlideAction(
        outerColor: ColorManager.black87,
        innerColor: ColorManager.limeGreen,
        sliderButtonIcon: const Icon(Icons.double_arrow_sharp),
        text: StringsManager.swipeToPrc,
        onSubmit: () {
          Navigator.of(context).pushReplacementNamed(Routes.authRoute);
          return null;
        },
      ),
    );
  }
}
