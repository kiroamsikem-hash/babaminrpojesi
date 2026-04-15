plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.odev_asistani"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.odev_asistani"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = 2
        versionName = "1.1.0"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            // Minify ve shrink'i tamamen kapat
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
