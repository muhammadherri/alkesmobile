import 'package:flutter/material.dart';

class DateDropdown extends StatelessWidget {
  final String labelText;
  final String valueText;
  final TextStyle valueStyle;
  final VoidCallback onPressed;
  final Widget child;

  const DateDropdown({Key key, this.labelText, this.valueText, this.valueStyle, this.onPressed, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: InputDecorator(
        decoration: InputDecoration(
          border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(20.0)),
          labelText:labelText
        ),
        baseStyle: valueStyle,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(valueText,style: valueStyle,),
            Icon(Icons.arrow_drop_down,color: Theme.of(context).brightness==Brightness.light ? Colors.grey.shade700:Colors.white70)
          ],
        ),
      ),
    );
  }
}