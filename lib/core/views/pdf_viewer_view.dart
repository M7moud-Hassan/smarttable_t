import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:smart_table_app/core/extensions/context_extensions.dart';

class PdfViwerView extends StatefulWidget {
  const PdfViwerView({super.key, required this.url, this.title = ''});
  final String url;
  final String title;

  @override
  State<PdfViwerView> createState() => _PdfViwerViewState();
}

class _PdfViwerViewState extends State<PdfViwerView> {
  int page = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Stack(
          children: [
            PDF(
              onPageChanged: (currentPage, total) =>
                  setState(() => page = (currentPage ?? 1)),
              backgroundColor: Colors.grey,
            ).cachedFromUrl(
              widget.url,
              placeholder: (progress) => Center(child: Text('$progress %')),
              errorWidget: (error) => Center(child: Text(error.toString())),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${context.locale.page} ${page + 1}',
                      style: context.textTheme.bodyLarge),
                ],
              ),
            ),
          ],
        ));
  }
}
