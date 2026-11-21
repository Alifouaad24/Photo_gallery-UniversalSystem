# google_mlkit_text_recognition 0.15.1
#
# The plugin references the Chinese/Devanagari/Japanese/KoreanTextRecognizerOptions
# classes, but declares their artifacts as `compileOnly` (opt-in per the plugin
# README). This app only uses the default Latin recognizer
# (TextRecognizer() / TextRecognitionScript.latin), so those code paths are never
# executed and the artifacts are intentionally not bundled.
#
# The rules below are scoped to exactly these classes so that any OTHER missing
# class is still reported by R8.
#
# If a non-Latin script is ever needed, add the matching dependency instead, e.g.
#   implementation("com.google.mlkit:text-recognition-japanese:16.0.1")
# and remove the corresponding lines here.
-dontwarn com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions$Builder
