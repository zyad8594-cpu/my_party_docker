import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../themes/app_colors.dart';
import 'app_form_widgets.dart';


class SearchBox 
{ 

  static Widget withLayout(
    BuildContext context, String searchText,{
    void Function(String)? searchOnChanged,
    InputDecoration? decoration,
    Decoration? layoutDecoration,
    EdgeInsetsGeometry layoutPadding = const EdgeInsets.fromLTRB(20, 10, 20, 10),
    
  }){
    final brightness = Theme.of(context).brightness;

    return Padding(
      padding: layoutPadding,
      child: Container(
        decoration: layoutDecoration ??  BoxDecoration(
          color: AppColors.surface.getByBrightness(brightness),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.textSubtitle.getByBrightness(brightness).withValues(alpha: 0.1)),
        ),
        /// صندوق البحث 
        child: withNotLayout(context, searchText, searchOnChanged: searchOnChanged, decoration: decoration),
      ),
    );
  }

  static Widget withNotLayout(BuildContext context, 
    String searchText, {
    void Function(String)? searchOnChanged,
    InputDecoration? decoration
  }) 
  {
    return TextField(
      onChanged: searchOnChanged,
      decoration: decoration ?? AppFormWidgets.searchDecoration(searchText, context),
    );
  }

  static Widget withNLOtFilters(
    BuildContext context,  String searchText, {
    void Function(String)? searchOnChanged,
    InputDecoration? decoration,
    List<String> filtersNames = const [],
    void Function(bool, String)? onSelected,
    AppColorSet<Color> selectedColor = AppColors.textBody,
    AppColorSet<Color> unSelectedColor = AppColors.textBody,
    FontWeight? selectedFontWeight,
    FontWeight? unSelectedFontWeight,
    required RxString initSelect
  }) {
    // final controller = Get.find<EventController>();
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          withNotLayout(context, searchText, searchOnChanged: searchOnChanged, decoration: decoration),
          const SizedBox(height: 16),

          filters(
            context,
            filtersNames: filtersNames,
            initSelect: initSelect,
            onSelected: onSelected,
            selectedColor: selectedColor,
            unSelectedColor: unSelectedColor,
            selectedFontWeight: selectedFontWeight,
            unSelectedFontWeight: unSelectedFontWeight,
          ),
        ],
      ),
    );
  }


  static Widget filters(BuildContext context,{
    List<String> filtersNames = const [],
    required RxString initSelect,
    void Function(bool, String)? onSelected,
    AppColorSet<Color> selectedColor = AppColors.textBody,
    AppColorSet<Color> unSelectedColor = AppColors.textBody,
    FontWeight? selectedFontWeight,
    FontWeight? unSelectedFontWeight,
  }){
    final brightness = Theme.of(context).brightness;

    return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filtersNames.map((status) 
              {
                return Obx(() {

                  final bool isSelected = initSelect.value == status;
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: ChoiceChip(
                      label: Text(status),
                      selected: isSelected,
                      onSelected: (s){
                        initSelect.value = status;
                        if(onSelected != null) onSelected(s, status);
                      },

                      selectedColor: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.8),
                      labelStyle: TextStyle(
                        color: isSelected ? 
                          selectedColor.getByBrightness(brightness) : 
                          unSelectedColor.getByBrightness(brightness) ,
                        fontWeight: isSelected
                            ? selectedFontWeight
                            : unSelectedFontWeight,
                      ),
                      backgroundColor: AppColors.searchBarFillColor.getByBrightness(brightness).withValues(alpha: 0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      showCheckmark: false,
                    ),
                  );
                });
              }).toList(),
              
            ),
          );
  }
}
  