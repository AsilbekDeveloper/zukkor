import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// 2026-09-29, Play Console tayyorgarligi - `key.properties` (git'ga
// KIRMAYDI, `android/.gitignore`da) haqiqiy release keystore ma'lumotlarini
// saqlaydi. Fayl topilmasa (masalan CI/boshqa dasturchi kompyuterida)
// bo'sh Properties bilan davom etadi - shunda pastdagi signingConfig
// debug'ga tushib qoladi, build umuman qulamaydi (faqat Play Console'ga
// yaroqsiz bo'ladi, buni build vaqtida ko'rish mumkin).
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.zukkor.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications requires this - it uses Java 8+ APIs
        // (java.time etc.) that need to be desugared for compatibility with
        // minSdk versions below API 26.
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.zukkor.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // `key.properties` mavjud bo'lsa haqiqiy release kalit bilan
            // imzolanadi (Play Console'ga yuklash uchun shart), aks holda
            // debug kalitga qaytadi - shunda `flutter run --release` hali
            // ham ishlayveradi (masalan `key.properties`ga ega bo'lmagan
            // boshqa dasturchi kompyuterida).
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }

            // R8 (kod siqish/optimallashtirish/nomlarni xiralashtirish) va
            // resurslarni siqish - avval o'chirilgan edi (2026-09-13
            // prod-tayyorlik auditi topilmasi), shuning uchun "release"
            // build aslida faqat nomi bilan release, hajmi ham,
            // himoyalanishi ham debug'dan farq qilmasdi.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
