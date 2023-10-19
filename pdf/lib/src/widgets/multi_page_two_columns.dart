import '../../pdf.dart';
import '../../widgets.dart';

class MultiPageTwoColumns extends MultiPage {
  MultiPageTwoColumns({
    PageTheme? pageTheme,
    PdfPageFormat? pageFormat,
    required BuildListCallback build,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    BuildCallback? header,
    BuildCallback? footer,
    ThemeData? theme,
    int maxPages = 20,
    PageOrientation? orientation,
    EdgeInsetsGeometry? margin,
    TextDirection? textDirection,
  }) : super(
          pageTheme: pageTheme,
          pageFormat: pageFormat,
          build: build,
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          header: header,
          footer: footer,
          theme: theme,
          maxPages: maxPages,
          orientation: orientation,
          margin: margin,
          textDirection: textDirection,
        );

  @override
  void postProcess(Document document) {
    super.postProcess(document);

    final _margin = resolvedMargin!;
    final _mustRotate = mustRotate;
    final pageHeight = _mustRotate ? pageFormat.width : pageFormat.height;
    final pageWidth = _mustRotate ? pageFormat.height : pageFormat.width;
    final halfPageWidth = (pageWidth - _margin.horizontal) / 2;

    for (var page in pages) {
      var leftColumnMaxHeight = 0.0;
      var rightColumnMaxHeight = 0.0;

      // Determine the max height of both columns
      for (var i = 0; i < page.widgets.length; i++) {
        if (i % 2 == 0) {
          leftColumnMaxHeight += page.widgets[i].child.box!.height;
        } else {
          rightColumnMaxHeight += page.widgets[i].child.box!.height;
        }
      }

      var leftColumnHeight = leftColumnMaxHeight;
      var rightColumnHeight = rightColumnMaxHeight;

      // Iterate through widgets and position them in the respective column
      for (var i = 0; i < page.widgets.length; i++) {
        final widget = page.widgets[i];
        final isLeftColumn = i % 2 == 0;
        final columnHeight =
            isLeftColumn ? leftColumnHeight : rightColumnHeight;

        // Calculate position
        final x = _margin.left + (isLeftColumn ? 0 : halfPageWidth);
        final y = pageHeight -
            _margin.top -
            columnHeight +
            (isLeftColumn ? leftColumnMaxHeight : rightColumnMaxHeight) -
            widget.child.box!.height;

        // Paint child
        _paintChild(page.context, widget.child, x, y, pageFormat.height);

        // Decrease column height for next widget
        if (isLeftColumn) {
          leftColumnHeight -= widget.child.box!.height;
        } else {
          rightColumnHeight -= widget.child.box!.height;
        }
      }
    }
  }
}

void _paintChild(
    Context context, Widget child, double x, double y, double pageHeight) {
  child.box = child.box!.copyWith(x: x, y: y);
  child.paint(context);
}
