// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TextWithTap extends StatelessWidget {
  final Function? onTap;
  final String text;
  final double? fontSize;
  final Color? color;
  final TextAlign? textAlign;
  final Alignment? alignment;
  final double? marginTop;
  final bool? textItalic;
  final double? marginLeft;
  final double? marginRight;
  final double? marginBottom;
  final FontWeight? fontWeight;
  final TextDecoration? decoration;
  final TextOverflow? overflow;
  final bool? selectableText;
  final bool? urlDetectable;
  final int? maxLines;
  final bool? humanize;
  final bool? removeWww;
  final bool? looseUrl;
  final bool? defaultToHttps;
  final bool? excludeLastPeriod;

  const TextWithTap(
    this.text, {
    Key? key,
    this.textAlign = TextAlign.start,
    this.alignment,
    this.marginTop = 0,
    this.marginLeft = 0,
    this.marginRight = 0,
    this.marginBottom = 0,
    this.fontWeight,
    this.fontSize,
    this.color,
    this.decoration,
    this.onTap,
    this.overflow = TextOverflow.visible,
    this.maxLines,
    this.textItalic = false,
    this.selectableText = false,
        this.urlDetectable = false,
        this.humanize = true,
        this.removeWww = false,
        this.looseUrl = true,
        this.defaultToHttps = false,
        this.excludeLastPeriod = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      margin: EdgeInsets.only(
          left: marginLeft!,
          top: marginTop!,
          bottom: marginBottom!,
          right: marginRight!),
      child: GestureDetector(
        onTap: onTap as void Function()?,
        child: getText(),
      ),
    );
  }

  Widget getText(){

    if(selectableText! && urlDetectable!){

      return SelectableLinkify(
        onOpen: _onOpen,
        //textScaleFactor: 2.0,
        selectionControls: MaterialTextSelectionControls(),
        /*toolbarOptions: const ToolbarOptions(
          copy: true,
          selectAll: true,
          paste: false,
          cut: false,
        ),*/
        text: text,
        options: LinkifyOptions(
          humanize: humanize!,
          removeWww: removeWww!,
          looseUrl: looseUrl!,
          defaultToHttps: defaultToHttps!,
          excludeLastPeriod: excludeLastPeriod!,
        ),
        maxLines: maxLines,
        textAlign: textAlign,
        style: GoogleFonts.roboto(
          //overflow: overflow,
          fontSize: fontSize,
          fontStyle: textItalic! ? FontStyle.italic : FontStyle.normal,
          color: color,
          fontWeight: fontWeight,
          decoration: decoration,
        ),
      );

    } else if(selectableText! && !urlDetectable!){

      return SelectableText(
        text,
        maxLines: maxLines,
        textAlign: textAlign,
        selectionControls: MaterialTextSelectionControls(),
        toolbarOptions: const ToolbarOptions(
          copy: true,
          selectAll: true,
          paste: false,
          cut: false,
        ),
        style: GoogleFonts.roboto(
          //overflow: overflow,
          fontSize: fontSize,
          fontStyle: textItalic! ? FontStyle.italic : FontStyle.normal,
          color: color,
          fontWeight: fontWeight,
          decoration: decoration,
        ),
      );

    } else if(!selectableText! && urlDetectable!){

      return Linkify(
        text: text,
        onOpen: _onOpen,
        maxLines: maxLines,
        textAlign: textAlign!,
        overflow: overflow!,
        options: LinkifyOptions(
           humanize: humanize!,
           removeWww: removeWww!,
           looseUrl: looseUrl!,
           defaultToHttps: defaultToHttps!,
           excludeLastPeriod: excludeLastPeriod!,
        ),
        style: GoogleFonts.roboto(
          //overflow: overflow,
          fontSize: fontSize,
          fontStyle: textItalic! ? FontStyle.italic : FontStyle.normal,
          color: color,
          fontWeight: fontWeight,
          decoration: decoration,
        ),
      );

    } else if(!selectableText! && !urlDetectable!){

      return Text(
        text,
        maxLines: maxLines,
        textAlign: textAlign,
        overflow: overflow,
        style: GoogleFonts.roboto(
          //overflow: overflow,
          fontSize: fontSize,
          fontStyle: textItalic! ? FontStyle.italic : FontStyle.normal,
          color: color,
          fontWeight: fontWeight,
          decoration: decoration,
        ),
      );
    }

    return Container();
  }

  Future<void> _onOpen(LinkableElement link) async {
    if (await canLaunchUrlString(link.url)) {
      await launchUrlString(link.url);
    } else {
      throw 'Could not launch $link';
    }
  }
}
