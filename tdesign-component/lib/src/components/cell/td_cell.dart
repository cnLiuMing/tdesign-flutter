import 'package:flutter/material.dart';

import '../../../tdesign_flutter.dart';
import 'td_cell_inherited.dart';

typedef TDCellClick = void Function(TDCell cell);

enum TDCellAlign { top, middle, bottom }

/// 单元格组件
class TDCell extends StatefulWidget {
  const TDCell({
    Key? key,
    this.align = TDCellAlign.middle,
    this.arrow = false,
    this.bordered = true,
    this.description,
    this.descriptionWidget,
    this.hover = true,
    this.image,
    this.imageSize,
    this.imageWidget,
    this.leftIcon,
    this.leftIconWidget,
    this.note,
    this.noteWidget,
    this.required = false,
    // this.rightIcon,
    this.title,
    this.titleWidget,
    this.onClick,
    this.style,
    this.rightIcon,
    this.rightIconWidget,
    this.disabled = false,
    this.imageCircle = 50,
  }) : super(key: key);

  /// 内容的对齐方式，默认居中对齐。可选项：top/middle/bottom
  final TDCellAlign? align;

  /// 是否显示右侧箭头
  final bool? arrow;

  /// 是否显示下边框，仅在TDCellGroup组件下起作用
  final bool? bordered;

  /// 下方内容描述文字
  final String? description;

  /// 下方内容描述组件
  final Widget? descriptionWidget;

  /// 是否开启点击反馈
  final bool? hover;

  /// 主图
  final ImageProvider? image;

  /// 主图尺寸
  final double? imageSize;

  /// 主图圆角，默认50（圆形）
  final double? imageCircle;

  /// 主图组件
  final Widget? imageWidget;

  /// 左侧图标，出现在单元格标题的左侧
  final IconData? leftIcon;

  /// 左侧图标组件
  final Widget? leftIconWidget;

  /// 和标题同行的说明文字
  final String? note;

  /// 说明文字组件
  final Widget? noteWidget;

  /// 是否显示表单必填星号
  final bool? required;

  /// 最右侧图标
  final IconData? rightIcon;

  /// 最右侧图标组件
  final Widget? rightIconWidget;

  /// 标题
  final String? title;

  /// 标题组件
  final Widget? titleWidget;

  /// 点击事件
  final TDCellClick? onClick;

  /// 自定义样式
  final TDCellStyle? style;

  /// 禁用
  final bool? disabled;

  @override
  _TDCellState createState() => _TDCellState();
}

class _TDCellState extends State<TDCell> {
  var _status = 'default';

  @override
  Widget build(BuildContext context) {
    var style = widget.style ?? TDCellInherited.of(context)?.style ?? TDCellStyle.cellStyle(context);
    var crossAxisAlignment = _getAlign();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (widget.onClick != null && !(widget.disabled ?? false)) {
          widget.onClick!(widget);
        }
      },
      onTapDown: (details) {
        _setStatus('active', 0);
      },
      onTapUp: (details) {
        _setStatus('default', 100);
      },
      onTapCancel: () {
        _setStatus('default', 0);
      },
      child: Container(
        color: _status == 'default' ? style.backgroundColor : style.clickBackgroundColor,
        padding: EdgeInsets.all(TDTheme.of(context).spacer16),
        child: Row(
          crossAxisAlignment: crossAxisAlignment,
          children: [
            ..._getImage(),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.leftIcon != null || widget.leftIconWidget != null) ...[
                    widget.leftIconWidget ?? Icon(widget.leftIcon, size: 24, color: style.leftIconColor),
                    SizedBox(width: TDTheme.of(context).spacer12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (widget.titleWidget != null)
                              Flexible(child: widget.titleWidget!)
                            else if (widget.title != null)
                              Flexible(child: TDText(widget.title!, style: style.titleStyle)),
                            if (widget.required ?? false) TDText(' *', style: style.requiredStyle),
                          ],
                        ),
                        if ((widget.titleWidget != null || widget.title != null) &&
                            (widget.descriptionWidget != null || widget.description != null))
                          SizedBox(height: TDTheme.of(context).spacer4),
                        if (widget.descriptionWidget != null)
                          widget.descriptionWidget!
                        else if (widget.description != null)
                          TDText(widget.description!, style: style.descriptionStyle),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Wrap(
              spacing: TDTheme.of(context).spacer4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (widget.noteWidget != null)
                  widget.noteWidget!
                else if (widget.note != null)
                  TDText(widget.note!, style: style.noteStyle),
                if (widget.rightIconWidget != null)
                  widget.rightIconWidget!
                else if (widget.rightIcon != null)
                  Icon(widget.rightIcon, size: 24, color: style.rightIconColor),
                if (widget.arrow ?? false) Icon(TDIcons.chevron_right, size: 24, color: style.arrowColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  CrossAxisAlignment _getAlign() {
    switch (widget.align) {
      case TDCellAlign.top:
        return CrossAxisAlignment.start;
      case TDCellAlign.middle:
        return CrossAxisAlignment.center;
      case TDCellAlign.bottom:
        return CrossAxisAlignment.end;
      default:
        return CrossAxisAlignment.center;
    }
  }

  void _setStatus(String status, int milliseconds) {
    if ((widget.disabled ?? false) || !(widget.hover ?? true)) {
      return;
    }
    if (milliseconds == 0) {
      setState(() {
        _status = status;
      });
      return;
    }
    Future.delayed(Duration(milliseconds: milliseconds), () {
      setState(() {
        _status = status;
      });
    });
  }

  List<Widget> _getImage() {
    var imageSize = widget.imageSize ?? 48;
    var list = <Widget>[];
    if (widget.imageWidget != null) {
      list.add(widget.imageWidget!);
    } else if (widget.image != null) {
        list.add(ClipRRect(
          borderRadius: BorderRadius.circular(widget.imageCircle ?? 50),
          child: Image(
            image: widget.image!,
            width: imageSize,
            height: imageSize,
            fit: BoxFit.cover,
          ),
        ));
    }
    if (list.isEmpty) {
      return list;
    }
    list.add(SizedBox(width: TDTheme.of(context).spacer12));
    return list;
  }
}