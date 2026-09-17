# =====================================================================
# Al Furqan Book Shop — release R8 keep rules (17/09/2026)
# =====================================================================
# BACKGROUND (LIVE-verified root cause):
#   image_cropper 11.0.0 (pub.dev) Android side pe jitpack se
#   'com.github.Yalantis:ucrop:2.2.11' use karti hai (implementation scope).
#   uCrop 2.2.11 apni BitmapLoadTask me okhttp3.* use karta hai, par
#   jitpack POM se okhttp APP ke classpath par nahi aata + image_cropper
#   ka consumer-proguard-rules.pro version 11.0.0 me publish hi nahi hua
#   (upstream hnvn/flutter_image_cropper ne 25/09/2025 ko commit
#   058c878b me ye fix DAALA — 11.0.0 ke BAAD). Isliye release R8 me:
#   "ERROR: Missing class okhttp3.OkHttpClient ... ucrop BitmapLoadTask".
#
#   Yeh rules UPSTREAM ke official fix jaisi hi hain (okhttp3 + ucrop
#   keep/dontwarn) + okio (okhttp ka companion) + real okhttp dependency
#   bhi app/build.gradle me pin ki gayi hai (5.1.0 — uCrop 2.2.11 ka
#   apna compile version), taaki classes classpath par waqai maujood hon.
# =====================================================================

# OkHttp (uCrop ke network-image path ke liye refer hota hai)
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**

# Okio (OkHttp ka transitive companion)
-keep class okio.** { *; }
-dontwarn okio.**

# uCrop crop engine (image_cropper plugin ke peeche)
-keep class com.yalantis.ucrop.** { *; }
-dontwarn com.yalantis.ucrop.**
