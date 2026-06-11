import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ==========================================
// 1. MEMBACA FILE KEY.PROPERTIES
// ==========================================
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.ti24a5.app13"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    // ==========================================
    // 2. MENGHUBUNGKAN KE KTP DIGITAL (KEYSTORE)
    // ==========================================
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    defaultConfig {
        // ==========================================
        // INI YANG SUDAH DIGANTI SESUAI MINTANYA GOOGLE
        // ==========================================
        applicationId = "com.ti24a5.app13"
        minSdk = 24  // <-- INI YANG SUDAH KITA UBAH JADI 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // ==========================================
            // 3. PAKAI KTP UNTUK VERSI RELEASE
            // ==========================================
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}