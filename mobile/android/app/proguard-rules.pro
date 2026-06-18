# ALTYN — R8/ProGuard keep rules (release build).
# Dart коды AOT-компиляцияланған әрі бұрыннан tree-shake болады; R8 тек Android
# хост (Java/Kotlin) + плагин кодын кішірейтеді. Төмендегі ережелер reflection
# арқылы шақырылатын кластарды (Flutter engine, Firebase, плагиндер) сақтайды.

# ── Flutter engine / embedding ─────────────────────────────────────────────
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# ── Firebase / Google Play services (push notifications) ────────────────────
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# ── Жалпы: аннотациялар мен қолтаңбаларды сақтау (сериализация/reflection) ──
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# ── Жиі reflection қолданатын плагиндер үшін ескерту басу ──────────────────
-dontwarn javax.annotation.**
