/// Shared Arabic/keyboard-roop search normalizer.
///
/// 17/09: ye logic pehle SIRF main Search page (SearchController._normSearch)
/// me tha — Shop/category page ka in-page search RAW contains() karta tha,
/// isliye FARSI ye (الحدیث) category page ke ANDAR bhi "No products" deta
/// tha. Ab dono pages ek hi shared normalizer use karte hai (kaam ka code
/// teen jagah duplicate nahi — ek hi source of truth).
///
/// BACKGROUND (15/09 e2e root cause): user "الحدیث" type karta hai FARSI/URDU
/// keyboard ye (U+06CC) se, catalog Arabic ye (U+064A) use karta hai —
/// raw match kabhi nahi hota. DONO sides canonical form me aane ke baad
/// compare hota hai.
///
/// !!! 16/09 deep-review BUG CATCH (historic): strip-range ko "[0640-0652]"
/// EK saath NAHI likhna — U+0641..U+064A Asli HAROOF hai (ف ق ك ل م ن ه و ى ي)
/// — contiguous range unhe bhi kaat deti thi. Tatweel (0640) ALAG aur
/// tashkeel block (064B-0652) ALAG likha gaya hai. Code points Python se
/// VERIFY kiye hue hai (13 roop mappings exact).
library;

String normSearchText(String? s) {
  var t = (s ?? '').toLowerCase();
  // harakat/tashkeel (064B-0652), dagger alef (0670), Quranic marks
  // (06D6-06ED), tatweel (0640), zero-width/bidi marks hatao.
  t = t.replaceAll(
      RegExp(
          '[\\u0640\\u064B-\\u0652\\u0670\\u06D6-\\u06ED\\u200C\\u200D\\u200E\\u200F\\uFEFF]'),
      '');
  // keyboard roop -> ek canonical Arabi rup (dono sides same hote hai):
  // \u0623 \u0625 \u0622 \u0671 -> \u0627 (alef ke roop)
  // \u06CC FARSI ye / \u0649 / \u06D2 URDU bari ye / \u0626 -> \u064A
  // \u06A9 FARSI ke -> \u0643 | \u0624 -> \u0648
  // \u0629 taa-marbuta / \u06C1 / \u06BE -> \u0647
  const roop = {
    '\u0623': '\u0627',
    '\u0625': '\u0627',
    '\u0622': '\u0627',
    '\u0671': '\u0627',
    '\u06CC': '\u064A',
    '\u0649': '\u064A',
    '\u06D2': '\u064A',
    '\u0626': '\u064A',
    '\u06A9': '\u0643',
    '\u0624': '\u0648',
    '\u0629': '\u0647',
    '\u06C1': '\u0647',
    '\u06BE': '\u0647',
  };
  roop.forEach((from, to) {
    t = t.replaceAll(from, to);
  });
  // Arabic-Indic + Extended digits -> latin (Arabic keyboard se SKU)
  for (var i = 0; i < 10; i++) {
    t = t.replaceAll(String.fromCharCode(0x0660 + i), '$i');
    t = t.replaceAll(String.fromCharCode(0x06F0 + i), '$i');
  }
  return t.replaceAll(RegExp(r'\s+'), ' ').trim();
}
