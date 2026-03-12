import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keyPropsFile = rootProject.file("key.properties")
val keyProps = Properties().apply {
    if (keyPropsFile.exists()) load(keyPropsFile.inputStream())
}

// Keystore disponibile se key.properties esiste in locale OPPURE le env vars sono impostate in CI
val hasReleaseKey = keyPropsFile.exists() || System.getenv("KEY_STORE_PASSWORD") != null

android {
    namespace = "com.example.meteo"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // La signingConfig "release" viene creata SOLO se il keystore è disponibile
    if (hasReleaseKey) {
        signingConfigs {
            create("release") {
                storeFile = file(
                    keyProps.getProperty("storeFile")
                        ?: System.getenv("KEY_STORE_PATH") ?: "keystore.jks"
                )
                storePassword = keyProps.getProperty("storePassword")
                    ?: System.getenv("KEY_STORE_PASSWORD") ?: ""
                keyAlias = keyProps.getProperty("keyAlias")
                    ?: System.getenv("KEY_ALIAS") ?: ""
                keyPassword = keyProps.getProperty("keyPassword")
                    ?: System.getenv("KEY_PASSWORD") ?: ""
            }
        }
    }

    defaultConfig {
        applicationId = "com.example.meteo"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKey) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
